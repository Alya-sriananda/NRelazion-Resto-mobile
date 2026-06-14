import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/menu_provider.dart';
import '../../utils/format_helper.dart';
import '../../models/menu_model.dart';

class CustomerMenuListScreen extends StatefulWidget {
  const CustomerMenuListScreen({super.key});

  @override
  State<CustomerMenuListScreen> createState() => _CustomerMenuListScreenState();
}

class _CustomerMenuListScreenState extends State<CustomerMenuListScreen> {
  String _selectedCategory = 'Semua';
  final List<String> _categories = ['Semua', 'Makanan Utama', 'Cemilan', 'Minuman', 'Coffee'];

  String _formatImageUrl(String url) {
    if (url.contains('drive.google.com')) {
      final regExp = RegExp(r'\/d\/([^\/]+)\/');
      final match = regExp.firstMatch(url);
      if (match != null) {
        return 'https://drive.google.com/uc?export=view&id=${match.group(1)}';
      }
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final menuProv = context.watch<MenuProvider>();
    
    var filteredMenus = menuProv.menus;
    if (_selectedCategory != 'Semua') {
      filteredMenus = menuProv.menus.where((m) => m.kategori == _selectedCategory).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Daftar Menu', style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: AppColors.dark), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 60,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = category),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.gray,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Menu Grid
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => menuProv.fetchMenus(),
              child: filteredMenus.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restaurant_menu, size: 64, color: AppColors.gray.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        const Text('Menu tidak ditemukan', style: TextStyle(color: AppColors.gray)),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: filteredMenus.length,
                    itemBuilder: (context, index) {
                      return _buildGridCard(context, filteredMenus[index]);
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, MenuModel menu) {
    final imageUrl = _formatImageUrl(menu.gambarUrl);
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/menuDetail', arguments: menu);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Container(
                  width: double.infinity,
                  color: Colors.grey[100],
                  child: menu.gambarUrl.isNotEmpty 
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
                      )
                    : const Icon(Icons.fastfood, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(menu.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(menu.kategori, style: const TextStyle(color: AppColors.gray, fontSize: 10)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(FormatHelper.formatRupiah(menu.harga), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
                        child: const Icon(Icons.add, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
