import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/order_provider.dart';
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

    for (var o in orderProv.orders) {
      if (o.status.toLowerCase() == 'selesai') {
        totalPendapatan += o.totalHarga;
        
        // Parse items to get accurate sold count
        for (var item in o.items) {
          menuTerjual += item.quantity;
          topMenusCount[item.nama] = (topMenusCount[item.nama] ?? 0) + item.quantity;
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
        iconTheme: const IconThemeData(color: AppColors.dark),
        title: const Text('Dashboard', style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppColors.dark),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const AdminDrawer(),
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
                  _buildStatCard('Total Pendapatan', 'Rp $totalPendapatan', Icons.account_balance_wallet, AppColors.success),
                  _buildStatCard('Pesanan Aktif', '$pesananAktif', Icons.receipt_long, AppColors.warning),
                  _buildStatCard('Menu Terjual', '$menuTerjual', Icons.restaurant, AppColors.info),
                  _buildStatCard('Total Menu', '${menuProv.menus.length}', Icons.menu_book, AppColors.primary),
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
                    price = 'Rp ${m.harga}';
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

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                CircleAvatar(backgroundColor: Colors.white, radius: 24, child: Icon(Icons.person, color: AppColors.primary)),
                SizedBox(height: 12),
                Text('Admin Resto', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text('admin@nrelazion.com', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          _buildDrawerItem(context, Icons.dashboard, 'Dashboard', '/adminDashboard'),
          _buildDrawerItem(context, Icons.restaurant_menu, 'Kelola Menu', '/adminMenu'),
          _buildDrawerItem(context, Icons.table_restaurant, 'Kelola Meja', '/adminMeja'),
          _buildDrawerItem(context, Icons.receipt_long, 'Kelola Pesanan', '/adminOrder'),
          _buildDrawerItem(context, Icons.people, 'Kelola User', '/adminUser'),
          _buildDrawerItem(context, Icons.bar_chart, 'Laporan', '/adminReport'),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.accent),
            title: const Text('Logout', style: TextStyle(color: AppColors.accent)),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, String route) {
    final bool isSelected = ModalRoute.of(context)?.settings.name == route;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.primary : AppColors.gray),
      title: Text(title, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.dark, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      selectedTileColor: AppColors.primary.withValues(alpha: 0.05),
      onTap: () {
        if (!isSelected) {
          Navigator.pushReplacementNamed(context, route);
        } else {
          Navigator.pop(context);
        }
      },
    );
  }
}
