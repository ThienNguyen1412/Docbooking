// File: lib/screens/admin/admin_service/admin_service_screen.dart

import 'package:flutter/material.dart';
import '../../../models/health_package.dart';
import 'add_edit_service_screen.dart';

class AdminServiceScreen extends StatefulWidget {
  const AdminServiceScreen({super.key});

  @override
  State<AdminServiceScreen> createState() => _AdminServiceScreenState();
}

class _AdminServiceScreenState extends State<AdminServiceScreen> {
  List<HealthPackage> _packages = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _packages = List.from(HealthPackage.getPackages());
  }

  // Lọc danh sách dựa trên từ khóa tìm kiếm
  List<HealthPackage> get _filteredPackages {
    if (_searchQuery.isEmpty) {
      return _packages;
    }
    final query = _searchQuery.toLowerCase();
    return _packages.where((pkg) => pkg.name.toLowerCase().contains(query)).toList();
  }

  void _navigateAndAddPackage() async {
    final newPackage = await Navigator.of(context).push<HealthPackage>(
      MaterialPageRoute(builder: (ctx) => const AddEditServiceScreen()),
    );
    if (newPackage != null && mounted) {
      setState(() => _packages.add(newPackage));
      _showSnackBar('Đã thêm gói khám: ${newPackage.name}', Colors.green);
    }
  }

  void _navigateAndEditPackage(HealthPackage package) async {
    final updatedPackage = await Navigator.of(context).push<HealthPackage>(
      MaterialPageRoute(builder: (ctx) => AddEditServiceScreen(healthPackage: package)),
    );
    if (updatedPackage != null && mounted) {
      setState(() {
        final index = _packages.indexWhere((p) => p.id == updatedPackage.id);
        if (index != -1) _packages[index] = updatedPackage;
      });
      _showSnackBar('Đã cập nhật gói khám: ${updatedPackage.name}', Colors.blue);
    }
  }

  void _deletePackage(String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa gói khám "$name"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Không')),
          TextButton(
            onPressed: () {
              if (mounted) {
                setState(() => _packages.removeWhere((p) => p.id == id));
              }
              Navigator.of(ctx).pop();
              _showSnackBar('Đã xóa gói khám: $name', Colors.red);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      )
    );
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)..removeCurrentSnackBar()..showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildSearchBar(),
          _buildHeaderRow(),
          Expanded(
            child: _filteredPackages.isEmpty
              ? const Center(child: Text('Không tìm thấy gói khám nào.'))
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: _filteredPackages.length,
                  itemBuilder: (context, index) {
                    final pkg = _filteredPackages[index];
                    return _buildServiceCard(pkg);
                  },
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateAndAddPackage,
        tooltip: 'Thêm Gói khám mới',
        backgroundColor: Colors.red.shade700,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // --- WIDGETS TÙY CHỈNH CHO GIAO DIỆN ---

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm gói khám...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Danh sách Dịch vụ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Chip(
            label: Text('Tổng: ${_filteredPackages.length}'),
            backgroundColor: Colors.red.withOpacity(0.1),
            labelStyle: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(HealthPackage pkg) {
    Widget? tag;
    if (pkg.isDiscount) {
      tag = _buildTag('ƯU ĐÃI', Colors.red);
    } else if (pkg.isFeatured) {
      tag = _buildTag('NỔI BẬT', Colors.purple);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    pkg.image ?? 'https://via.placeholder.com/400x200?text=No+Image',
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                        height: 120,
                        color: Colors.grey[200],
                        child: const Center(child: Icon(Icons.image_not_supported))),
                  ),
                ),
                if (tag != null) Positioned(top: 8, left: 8, child: tag),
              ],
            ),
            const SizedBox(height: 12),
            Text(pkg.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              pkg.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (pkg.isDiscount && pkg.oldPrice != null)
                      Text(
                        pkg.formattedOldPrice!,
                        style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey),
                      ),
                    Text(
                      pkg.formattedPrice,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: pkg.isDiscount ? Colors.red : Colors.green.shade700),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                      onPressed: () => _navigateAndEditPackage(pkg),
                      tooltip: 'Sửa',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deletePackage(pkg.id, pkg.name),
                      tooltip: 'Xóa',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}