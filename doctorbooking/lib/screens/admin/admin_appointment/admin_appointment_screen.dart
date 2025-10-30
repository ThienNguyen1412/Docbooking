import 'package:flutter/material.dart';
import '../../../../models/appointments.dart' as model;
import '../../../../services/appointment.dart';
import 'dart:convert';
/// Admin screen to list & manage appointments using backend APIs.
class AdminAppointmentScreen extends StatefulWidget {
  const AdminAppointmentScreen({super.key});

  @override
  State<AdminAppointmentScreen> createState() => _AdminAppointmentScreenState();
}

class _AdminAppointmentScreenState extends State<AdminAppointmentScreen>
    with SingleTickerProviderStateMixin {
  final List<model.Appointment> _appointments = [];
  bool _isLoading = false;
  String? _error;

  // simple paging
  int _page = 1;
  final int _pageSize = 100;
  int _total = 0;

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      debugPrint('Loading appointments page=$_page pageSize=$_pageSize');
      final res = await AppointmentService.instance.listAppointments(
        page: _page,
        pageSize: _pageSize,
      );

      // res expected: { total, page, pageSize, data }
      final rawList = res['data'];
      final List<model.Appointment> items = <model.Appointment>[];

      if (rawList is List) {
        for (final e in rawList) {
          if (e is model.Appointment) {
            items.add(e);
          } else if (e is Map<String, dynamic>) {
            items.add(model.Appointment.fromJson(e));
          } else {
            // try convert if possible
            try {
              final map = Map<String, dynamic>.from(e as Map);
              items.add(model.Appointment.fromJson(map));
            } catch (_) {
              // skip invalid item
            }
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _appointments
          ..clear()
          ..addAll(items);
        _total = res['total'] ?? items.length;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      debugPrint('Error loading appointments: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  List<model.Appointment> _filterByStatus(String status) =>
      _appointments.where((a) => model.appointmentStatusToString(a.status).toLowerCase() == status.toLowerCase()).toList();

  Future<void> _confirmAction(String id, String newStatus) async {
    if (_isLoading) return; // avoid duplicate flows while loading
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(newStatus == 'Confirmed' ? 'Xác nhận lịch' : 'Hủy lịch'),
        content: Text(newStatus == 'Confirmed'
            ? 'Bạn có chắc chắn muốn xác nhận lịch hẹn này?'
            : 'Bạn có chắc chắn muốn hủy lịch hẹn này?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Không')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(newStatus == 'Confirmed' ? 'Xác nhận' : 'Hủy', style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (newStatus.toLowerCase().contains('cancel')) {
      final reason = await _showCancelReasonDialog();
      if (reason == null || reason.trim().isEmpty) return;
      await _updateStatus(id, 'Cancelled', cancelReason: reason.trim());
    } else {
      await _updateStatus(id, newStatus);
    }
  }

  Future<String?> _showCancelReasonDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lý do hủy'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Nhập lý do hủy (bắt buộc)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Vui lòng nhập lý do hủy'), backgroundColor: Colors.redAccent));
                return;
              }
              Navigator.of(ctx).pop(text);
            },
            child: const Text('Xác nhận', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return result;
  }

  // IMPORTANT:
  // Backend currently expects PUT /api/appointment/{id} with body containing Status and possible CancelReason.
  // Previously we attempted PATCH /{id}/status which the backend does not implement and returned 404.
  // So here we call updateAppointment (PUT) with a minimal DTO.
  Future<void> _updateStatus(String id, String status, {String? cancelReason}) async {
    setState(() => _isLoading = true);
    try {
      final normalizedStatus = status.toLowerCase().contains('cancel') ? 'Cancelled' : status;
      final dto = <String, dynamic>{
        'Status': normalizedStatus,
        if (cancelReason != null && cancelReason.isNotEmpty) 'CancelReason': cancelReason,
      };

      debugPrint('Updating appointment status. id=$id dto=${jsonEncode(dto)}');

      // Use the generic updateAppointment (PUT) so it matches backend Update endpoint
      await AppointmentService.instance.updateAppointment(id, dto);

      // update local list
      final idx = _appointments.indexWhere((a) => a.id == id);
      if (idx >= 0) {
        final a = _appointments[idx];
        final newEnum = model.appointmentStatusFromString(normalizedStatus);
        final updated = a.copyWith(status: newEnum, cancelReason: cancelReason ?? a.cancelReason);
        setState(() {
          _appointments[idx] = updated;
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật trạng thái thành công'), backgroundColor: Colors.green));
    } catch (e) {
      debugPrint('Update status error: $e');
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cập nhật thất bại: $msg'), backgroundColor: Colors.redAccent));
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAppointment(String id, {bool force = false}) async {
    if (_isLoading) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa lịch hẹn'),
        content: const Text('Bạn có chắc chắn muốn xóa lịch hẹn này? (Không thể hoàn tác)'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Không')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      debugPrint('Deleting appointment id=$id force=$force');
      await AppointmentService.instance.deleteAppointment(id, force: force);
      setState(() {
        _appointments.removeWhere((a) => a.id == id);
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Xóa thành công'), backgroundColor: Colors.green));
    } catch (e) {
      debugPrint('Delete appointment error: $e');
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xóa thất bại: $msg'), backgroundColor: Colors.redAccent));
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Widget _buildAppointmentCard(model.Appointment app) {
    final dateStr = '${app.appointmentDate.day.toString().padLeft(2, '0')}/${app.appointmentDate.month.toString().padLeft(2, '0')}/${app.appointmentDate.year}';
    final timeStr = app.appointmentTime;

    // Try to use parsed doctorName from model if available, else show doctorId
    final doctorDisplay = (app.doctorName != null && app.doctorName!.isNotEmpty) ? app.doctorName! : (app.doctorId ?? '');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.badge_outlined, size: 20, color: Colors.blue.shade700),
            const SizedBox(width: 10),
            Expanded(child: Text('${app.patientFullName} • ${app.phone ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor(model.appointmentStatusToString(app.status)).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(model.appointmentStatusToString(app.status), style: TextStyle(color: _statusColor(model.appointmentStatusToString(app.status)), fontWeight: FontWeight.bold)),
            ),
          ]),
          const SizedBox(height: 8),
          Text('Bác sĩ: $doctorDisplay'),
          const SizedBox(height: 8),
          Text('Thời gian: $dateStr lúc $timeStr'),
          if ((app.note ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Ghi chú: ${app.note}'),
          ],
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            if (model.appointmentStatusToString(app.status).toLowerCase() == 'pending') ...[
              OutlinedButton.icon(
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Hủy'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                onPressed: _isLoading ? null : () => _confirmAction(app.id, 'Cancelled'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Xác nhận'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: _isLoading ? null : () => _confirmAction(app.id, 'Confirmed'),
              ),
            ] else ...[
              IconButton(
                tooltip: 'Xóa',
                onPressed: _isLoading ? null : () => _deleteAppointment(app.id, force: false),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
            ]
          ])
        ]),
      ),
    );
  }

  Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s == 'pending') return Colors.orange;
    if (s == 'confirmed') return Colors.blue;
    if (s == 'completed') return Colors.green;
    if (s == 'cancelled' || s == 'canceled') return Colors.red;
    return Colors.grey;
  }

  Widget _buildList(List<model.Appointment> data, String emptyMessage) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Lỗi: $_error', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: () => _loadAppointments(), child: const Text('Thử lại')),
        ]),
      );
    }
    if (data.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.inbox_outlined, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(emptyMessage, style: const TextStyle(color: Colors.black54)),
        ]),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final app = data[index];
          return _buildAppointmentCard(app);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pending = _filterByStatus('Pending');
    final confirmed = _filterByStatus('Confirmed');
    final cancelled = _filterByStatus('Cancelled');

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.red.shade700,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.white,
          indicatorColor: Colors.black,
          tabs: const [
            Tab(text: 'Chờ xử lý'),
            Tab(text: 'Đã xác nhận'),
            Tab(text: 'Đã hủy'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : () => _loadAppointments(),
        backgroundColor: Colors.red.shade700,
        child: const Icon(Icons.refresh),
        tooltip: 'Làm mới',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(pending, 'Không có lịch hẹn đang chờ xử lý.'),
          _buildList(confirmed, 'Chưa có lịch hẹn được xác nhận.'),
          _buildList(cancelled, 'Không có lịch hẹn bị hủy.'),
        ],
      ),
    );
  }
}