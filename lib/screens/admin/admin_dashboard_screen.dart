import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/order_provider.dart';
import '../../utils/format_helper.dart';
import '../../providers/menu_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders();
      context.read<MenuProvider>().fetchMenus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProv = context.watch<OrderProvider>();
    final menuProv = context.watch<MenuProvider>();
    
    int totalPendapatan = 0;
    int pesananAktif = 0;
    int menuTerjual = 0;
    Map<String, int> topMenusCount = {};
    
    DateTime now = DateTime.now();

    for (var o in orderProv.orders) {
      if (o.status.toLowerCase() == 'selesai') {
        // Filter untuk hari ini
        if (o.tanggal.year == now.year && o.tanggal.month == now.month && o.tanggal.day == now.day) {
          totalPendapatan += o.totalHarga;
          
          // Parse items to get accurate sold count
          for (var item in o.items) {
            menuTerjual += item.quantity;
            topMenusCount[item.nama] = (topMenusCount[item.nama] ?? 0) + item.quantity;
          }
        }
      } else if (o.status.toLowerCase() != 'batal') {
        pesananAktif += 1;
      }
    }

    // Sort top menus
    var sortedTopMenus = topMenusCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        
        title: const Text('Dashboard Admin', style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.accent),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await orderProv.fetchOrders();
          await menuProv.fetchMenus();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Selamat datang, Admin', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Ringkasan aktivitas resto hari ini', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Statistics Grid
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard('Pendapatan Hari Ini', FormatHelper.formatRupiah(totalPendapatan), Icons.account_balance_wallet, AppColors.success),
                  _buildStatCard('Pesanan Aktif', '$pesananAktif', Icons.receipt_long, AppColors.warning),
                  _buildStatCard('Menu Terjual', '$menuTerjual', Icons.restaurant, AppColors.info),
                  _buildStatCard('Total Menu', '${menuProv.menus.length}', Icons.menu_book, AppColors.primary),
                ],
              ),
              
              const SizedBox(height: 24),
              const Text('Aksi Cepat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildQuickActionCard('Kelola Meja', Icons.table_restaurant, Colors.orange, () {
                    Navigator.pushNamed(context, '/adminMeja');
                  })),
                  const SizedBox(width: 16),
                  Expanded(child: _buildQuickActionCard('Kelola User', Icons.people, Colors.purple, () {
                    Navigator.pushNamed(context, '/adminUser');
                  })),
                ],
              ),
              
              const SizedBox(height: 24),
              const Text('Menu Terlaris', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              
              // Top Menu List
              if (sortedTopMenus.isNotEmpty)
                ...sortedTopMenus.take(5).map((entry) {
                  final menuName = entry.key;
                  final soldCount = entry.value;
                  
                  // Find menu details from menuProv
                  String price = '';
                  String imgUrl = '';
                  try {
                    final m = menuProv.menus.firstWhere((m) => m.nama == menuName);
                    price = FormatHelper.formatRupiah(m.harga);
                    imgUrl = m.gambarUrl;
                  } catch (_) {}

                  return _buildTopMenuCard(menuName, price, '$soldCount terjual', imgUrl);
                })
              else
                const Text('Belum ada data penjualan'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: const TextStyle(color: AppColors.gray, fontSize: 12), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopMenuCard(String name, String price, String sold, String imgUrl) {
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
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              image: imgUrl.isNotEmpty ? DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover) : null,
            ),
            child: imgUrl.isEmpty ? const Icon(Icons.fastfood, color: Colors.grey) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(price, style: const TextStyle(color: AppColors.gray, fontSize: 12)),
              ],
            ),
          ),
          Text(sold, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
