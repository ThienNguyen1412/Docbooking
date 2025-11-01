// File: lib/screens/service/service_payment_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:qr_flutter/qr_flutter.dart'; 
import 'package:vietqr_gen/vietqr_generator.dart'; 
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart'; 

import '../../../models/health_package.dart';
import '../home/details_screen.dart'; 
import '../../../models/notification.dart';
// ✨ (QUAN TRỌNG) Thêm import service để gọi API
import '../../../services/appointment.dart'; 

// ✨ (QUAN TRỌNG) Thêm import này để có thể dùng showLoadingDialog
// (Giả sử file này nằm trong thư mục 'appointment' cùng cấp)
import '../appointment/appointment_detail_screen.dart';


class ServicePaymentScreen extends StatefulWidget {
  final HealthPackage healthPackage;
  final BookingDetails bookingDetails;

  final Function(AppNotification) addNotification;
  
  // ✨ (MỚI) Thêm callback này để ra lệnh chuyển tab
  // Bạn sẽ cần truyền nó từ màn hình chính (main_screen.dart)
  final VoidCallback? onBookingCompleteGoToAppointments;

  const ServicePaymentScreen({
    super.key,
    required this.healthPackage,
    required this.bookingDetails,
    required this.addNotification,
    this.onBookingCompleteGoToAppointments, // ✨ (MỚI)
  });

  @override
  State<ServicePaymentScreen> createState() => _ServicePaymentScreenState();
}

class _ServicePaymentScreenState extends State<ServicePaymentScreen> {
  int _selectedPaymentMethod = 0;
  bool _isBooking = false; // ✨ (MỚI) Thêm cờ để xử lý trạng thái loading

  final Bank _bankEnum = Bank.acb; 
  final String _accountNo = '23071517'; 
  final String _accountName = 'Nguyễn Minh Thiện';
  final String _bankName = 'Ngân hàng ACB';

  late final String transferAmount; 
  late final String transferContent; 
  late final String vietQrPayload; 
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    transferAmount = widget.healthPackage.price.toString(); 
    String phone = widget.bookingDetails.phone;
    transferContent = 'CK${widget.healthPackage.id}${phone.replaceAll(RegExp(r'[^0-9]'), '')}';

    try {
      vietQrPayload = VietQR.generate(
        bank: _bankEnum, 
        accountNumber: _accountNo, 
        amount: double.tryParse(transferAmount) ?? 0.0, 
        message: transferContent, 
      );
    } catch (e) {
      debugPrint("Lỗi khi tạo VietQR: $e.");
      vietQrPayload = "LỖI TẠO QR";
    }
  }

  // ======================================================
  // === ✨ (ĐÃ CẬP NHẬT) HÀM HOÀN TẤT ĐẶT LỊCH ===
  // ======================================================
  Future<void> _completeBooking(BuildContext context, String method) async {
    // (MỚI) Ngăn nhấn nút nhiều lần
    if (_isBooking) return;
    setState(() { _isBooking = true; });

    // (MỚI) Hiển thị dialog loading
    final closeLoading = await showLoadingDialog(context, message: 'Đang xác nhận lịch hẹn...');

    try {
      // (MỚI) BƯỚC 1: GỌI API ĐỂ LƯU LỊCH HẸN DỊCH VỤ
      // (Giả sử bạn có hàm 'createServiceAppointment' trong service)
      
      /*
      // Bỏ comment khối này khi bạn đã có API
      await AppointmentService.instance.createServiceAppointment(
        packageId: widget.healthPackage.id,
        bookingDetails: widget.bookingDetails,
        paymentMethod: method,
      );
      */
      
      // (TẠM THỜI) Giả lập độ trễ API
       await Future.delayed(const Duration(seconds: 2));


      // (CÓ SẴN) Bước 2: Tạo thông báo
      final notification = AppNotification(
        id: _uuid.v4(),
        title: 'Đặt dịch vụ thành công!',
        body:
            'Bạn đã đặt thành công dịch vụ "${widget.healthPackage.name}" vào lúc ${widget.bookingDetails.time.format(context)} ngày ${DateFormat('dd/MM/yyyy').format(widget.bookingDetails.date)}.',
        date: DateTime.now(),
      );

      // (CÓ SẴN) Bước 3: Gọi callback thông báo
      widget.addNotification(notification);
      
      // (MỚI) Đóng loading
      closeLoading(); 

      // (MỚI) Hiển thị SnackBar thành công
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              notification.title, 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating, 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            margin: const EdgeInsets.all(10.0),
          ),
        );
      }

      // (CẬP NHẬT) Bước 4: Quay về Root và Chuyển Tab
      if (mounted) {
        // Pop tất cả các màn hình trong stack hiện tại (Payment, Booking, Detail)
        // để quay về màn hình gốc của tab (ví dụ: màn hình Services)
        Navigator.of(context).popUntil((route) => route.isFirst);

        // (MỚI) Gọi callback để ra lệnh cho main_screen chuyển tab
        widget.onBookingCompleteGoToAppointments?.call();
      }

    } catch (e) {
      // (MỚI) Xử lý lỗi
      closeLoading();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đặt dịch vụ thất bại: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // (MỚI) Hoàn tất, cho phép nhấn nút lại
      if (mounted) {
        setState(() { _isBooking = false; });
      }
    }
  }


  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép $label: $text'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Thanh Toán & Xác Nhận'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildSummaryCard(widget.healthPackage, widget.bookingDetails),
            const SizedBox(height: 24),

            const Text(
              'Chọn Phương Thức Thanh Toán',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            
            _buildPaymentOption(
              value: 0,
              title: 'Thanh Toán Tại Quầy',
              subtitle: 'Thanh toán trực tiếp sau khi sử dụng dịch vụ.',
              icon: Icons.storefront_outlined,
            ),
            const SizedBox(height: 12),

            _buildPaymentOption(
              value: 1,
              title: 'Chuyển Khoản Ngân Hàng',
              subtitle: 'Quét mã VietQR để thanh toán trước.',
              icon: Icons.qr_code_2_rounded,
            ),
            const SizedBox(height: 24),

            if (_selectedPaymentMethod == 1) _buildTransferDetails(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          // ✨ (CẬP NHẬT) Vô hiệu hóa nút khi đang booking
          onPressed: _isBooking ? null : () => _completeBooking(
            context,
            _selectedPaymentMethod == 0 ? 'Thanh toán sau' : 'Chuyển khoản VietQR',
          ),
          style: ElevatedButton.styleFrom(
            disabledBackgroundColor: Colors.grey.shade400, // ✨ (MỚI)
            backgroundColor: _selectedPaymentMethod == 0 ? Colors.green.shade600 : Colors.orange.shade700,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isBooking // ✨ (CẬP NHẬT) Hiển thị loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
              )
            : Text(
                _selectedPaymentMethod == 0 ? 'XÁC NHẬN' : 'HOÀN TẤT THANH TOÁN',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
        ),
      ),
    ); 
  }

  Widget _buildSummaryCard(HealthPackage pkg, BookingDetails details) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tóm Tắt Đặt Dịch Vụ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
            const Divider(height: 20),
            _buildSummaryRow('Dịch Vụ', pkg.name),
            const Divider(height: 20, thickness: 0.5),
            _buildSummaryRow('Họ và Tên', details.name),
            _buildSummaryRow('Số điện thoại', details.phone),
            _buildSummaryRow('Ngày hẹn', DateFormat('dd/MM/yyyy').format(details.date)),
            _buildSummaryRow('Giờ hẹn', details.time.format(context)),
            if (details.note.isNotEmpty)
              _buildSummaryRow('Ghi chú', details.note),
            const Divider(height: 20),
            _buildSummaryRow('TỔNG THANH TOÁN', pkg.formattedPrice, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 15, color: Colors.grey.shade600)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value, 
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: isTotal ? 18 : 16, 
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal ? Colors.red.shade700 : Colors.black87
              )
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({ required int value, required String title, required String subtitle, required IconData icon }) {
    return Card(
      elevation: _selectedPaymentMethod == value ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _selectedPaymentMethod == value ? Colors.blue.shade700 : Colors.grey.shade300,
          width: _selectedPaymentMethod == value ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        onTap: () => setState(() => _selectedPaymentMethod = value),
        leading: Icon(icon, size: 32, color: _selectedPaymentMethod == value ? Colors.blue.shade700 : Colors.grey.shade600),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: _selectedPaymentMethod == value ? Colors.blue.shade900 : Colors.black87)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
        trailing: Radio<int>(
          value: value,
          groupValue: _selectedPaymentMethod,
          onChanged: (int? newValue) => setState(() => _selectedPaymentMethod = newValue!),
          activeColor: Colors.blue.shade600,
        ),
      ),
    );
  }

  Widget _buildTransferDetails() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Column(
          children: [
            const Text(
              'Quét Mã VietQR để thanh toán',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8), color: Colors.white),
              child: QrImageView(
                data: vietQrPayload, 
                version: QrVersions.auto,
                size: 180.0,
                errorStateBuilder: (cxt, err) => const Center(child: Text("Lỗi tạo mã QR.", textAlign: TextAlign.center)),
              ),
            ),
            const SizedBox(height: 15),
            _buildInfoRow('Ngân hàng', _bankName, Icons.account_balance),
            _buildInfoRow('Tên tài khoản', _accountName, Icons.person_outline),
            _buildInfoRow('Số tài khoản', _accountNo, Icons.credit_card, isCopyable: true),
            _buildInfoRow('Số tiền', widget.healthPackage.formattedPrice, Icons.monetization_on, isHighlight: true, isCopyable: true, copyValue: transferAmount),
            _buildInfoRow('Nội dung', transferContent, Icons.notes, isHighlight: true, isCopyable: true),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {bool isHighlight = false, bool isCopyable = false, String? copyValue}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: TextStyle(fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal, color: isHighlight ? Colors.blue.shade800 : Colors.black))),
          if (isCopyable)
            IconButton(
              icon: const Icon(Icons.copy, size: 18, color: Colors.blue),
              onPressed: () => _copyToClipboard(copyValue ?? value, label),
              tooltip: 'Sao chép',
            ),
        ],
      ),
    );
  }
}