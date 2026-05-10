import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/menu_model.dart';
import '../../providers/menu_provider.dart';
import 'admin_dashboard_screen.dart'; // for Drawer

class AdminMenuScreen extends StatefulWidget {
  const AdminMenuScreen({super.key});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  String _currentFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuProvider>().fetchMenus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppColors.dark),
        title: const Text('Kelola Menu', style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () {
              Navigator.pushNamed(context, '/adminMenuForm');
            },
          ),
        ],
      ),
      drawer: const AdminDrawer(),
      body: Consumer<MenuProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.menus.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage.isNotEmpty && provider.menus.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.errorMessage, style: const TextStyle(color: Colors.red)),
                  ElevatedButton(onPressed: () => provider.fetchMenus(), child: const Text('Coba Lagi'))
                ],
              ),
            );
          }

          var menus = provider.menus;
          if (_currentFilter == 'Aktif') {
            menus = menus.where((m) => m.statusAktif).toList();
          } else if (_currentFilter == 'Nonaktif') {
            menus = menus.where((m) => !m.statusAktif).toList();
          }

          return Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Semua', provider.menus.length, _currentFilter == 'Semua'),
                      _buildFilterChip('Aktif', provider.menus.where((m) => m.statusAktif).length, _currentFilter == 'Aktif'),
                      _buildFilterChip('Nonaktif', provider.menus.where((m) => !m.statusAktif).length, _currentFilter == 'Nonaktif'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.fetchMenus(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: menus.length,
                    itemBuilder: (context, index) {
                      final menu = menus[index];
                      return _buildMenuCard(context, menu);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, int count, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentFilter = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, MenuModel menu) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              image: menu.gambarUrl.isNotEmpty ? DecorationImage(image: NetworkImage(menu.gambarUrl), fit: BoxFit.cover) : null,
            ),
            child: menu.gambarUrl.isEmpty ? const Icon(Icons.fastfood, color: Colors.grey) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(menu.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis)),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/adminMenuForm', arguments: menu);
                          },
                          child: const Icon(Icons.edit, color: AppColors.info, size: 16),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Hapus Menu'),
                                content: Text('Yakin menghapus ${menu.nama}?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      context.read<MenuProvider>().deleteMenu(menu.id);
                                    },
                                    child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Icon(Icons.delete, color: AppColors.accent, size: 16),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${menu.kategori} • Rp ${menu.harga}', style: const TextStyle(color: AppColors.gray, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: menu.statusAktif ? AppColors.success.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        menu.statusAktif ? 'Aktif' : 'Nonaktif',
                        style: TextStyle(
                          color: menu.statusAktif ? AppColors.success : Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('0 terjual', style: TextStyle(color: AppColors.gray, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
