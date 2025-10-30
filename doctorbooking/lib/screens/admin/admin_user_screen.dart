import 'package:flutter/material.dart';
import 'package:doctorbooking/models/user.dart';
import 'package:doctorbooking/services/user.dart';

class AdminUserScreen extends StatefulWidget {
  const AdminUserScreen({super.key});

  @override
  State<AdminUserScreen> createState() => _AdminUserScreenState();
}

class _AdminUserScreenState extends State<AdminUserScreen> {
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();

  List<User> _users = [];
  List<User> _filtered = [];
  bool _isLoading = false;
  String? _error;
  String? _deletingUserId;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilter);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final users = await _userService.getAllUsers();
      if (!mounted) return;
      setState(() {
        _users = users;
        _applyFilter();
      });
    } catch (e, st) {
      debugPrint('loadUsers error: $e\n$st');
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _filtered = List.from(_users));
      return;
    }
    setState(() {
      _filtered = _users.where((u) {
        final name = (u.fullName ?? '').toLowerCase();
        final email = (u.email ?? '').toLowerCase();
        final phone = (u.phone ?? '').toLowerCase();
        final id = (u.id ?? '').toLowerCase();
        return name.contains(q) ||
            email.contains(q) ||
            phone.contains(q) ||
            id.contains(q);
      }).toList();
    });
  }

  Future<void> _confirmAndDelete(User user) async {
    final id = user.id;
    if (id == null || id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể xóa: id người dùng không hợp lệ'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc chắn muốn xóa người dùng "${user.fullName ?? user.email ?? user.id}" không? Thao tác này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Không'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _deletingUserId = id);

    try {
      debugPrint('Deleting user id: $id');
      final msg = await _userService.deleteUser(id);
      if (!mounted) return;
      setState(() {
        _users.removeWhere((u) => u.id == id);
        _applyFilter();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.green),
      );
    } catch (e, st) {
      debugPrint('deleteUser error: $e\n$st');
      if (!mounted) return;
      final err = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Xóa thất bại: $err'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() => _deletingUserId = null);
    }
  }

  Widget _buildUserTile(User u) {
    final displayName = u.fullName ?? (u.email ?? 'Không rõ');
    final subtitleParts = <String>[];
    if ((u.email ?? '').isNotEmpty) subtitleParts.add(u.email!);
    if ((u.phone ?? '').isNotEmpty) subtitleParts.add(u.phone!);
    final subtitle = subtitleParts.join(' • ');

    final isDeleting = _deletingUserId != null && _deletingUserId == u.id;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            (displayName.isNotEmpty
                    ? displayName
                          .trim()
                          .split(RegExp(r'\s+'))
                          .map((s) => s.isNotEmpty ? s[0] : '')
                          .take(2)
                          .join()
                    : '?')
                .toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(displayName),
        subtitle: Text(subtitle),
        trailing: isDeleting
            ? const SizedBox(
                width: 36,
                height: 36,
                child: Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            : PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'delete') _confirmAndDelete(u);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Xóa'),
                      ],
                    ),
                  ),
                ],
              ),
        onTap: () {
          // optional: navigate to user detail / edit screen if implemented
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (_, value, __) {
                return TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText:
                        'Tìm kiếm theo tên, email, số điện thoại...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: value.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _applyFilter();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Lỗi khi tải người dùng:\n$_error',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _loadUsers,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadUsers,
                    child: _filtered.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 80),
                              Center(
                                child: Text(
                                  'Không tìm thấy người dùng nào.',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 8, bottom: 12),
                            itemCount: _filtered.length,
                            itemBuilder: (context, index) {
                              final u = _filtered[index];
                              return _buildUserTile(u);
                            },
                          ),
                  ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // optional: open create user screen in future
      //   },
      //   child: const Icon(Icons.person_add),
      //   backgroundColor: Colors.red.shade700,
      //   tooltip: 'Thêm người dùng',
      // ),
    );
  }
}
