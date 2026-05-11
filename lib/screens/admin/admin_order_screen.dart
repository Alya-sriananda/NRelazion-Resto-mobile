import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/order_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/meja_provider.dart';
import '../../models/order_model.dart';
import 'admin_dashboard_screen.dart';

class AdminOrderScreen extends StatefulWidget {
  const AdminOrderScreen({super.key});

  @override
  State<AdminOrderScreen> createState() => _AdminOrderScreenState();
}

class _AdminOrderScreenState extends State<AdminOrderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders();
      context.read<UserProvider>().fetchUsers();
      context.read<MejaProvider>().fetchMeja();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: AppColors.dark),
          title: const Text('Kelola Pesanan', style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.gray,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Aktif'),
              Tab(text: 'Selesai'),
              Tab(text: 'Batal'),
            ],
          ),
        ),
        drawer: const AdminDrawer(),
        body: Consumer<OrderProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.orders.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.errorMessage.isNotEmpty && provider.orders.isEmpty) {
              return Center(child: Text(provider.errorMessage));
            }

            final aktifList = provider.orders.where((o) => o.status.toLowerCase() != 'selesai' && o.status.toLowerCase() != 'batal').toList();
            final selesaiList = provider.orders.where((o) => o.status.toLowerCase() == 'selesai').toList();
            final batalList = provider.orders.where((o) => o.status.toLowerCase() == 'batal').toList();

            return TabBarView(
              children: [
                // Aktif
                RefreshIndicator(
                  onRefresh: () => provider.fetchOrders(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: aktifList.length,
                    itemBuilder: (context, index) {
                      return _buildOrderCard(aktifList[index], AppColors.warning);
                    },
                  ),
                ),
                // Selesai
                RefreshIndicator(
                  onRefresh: () => provider.fetchOrders(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: selesaiList.length,
                    itemBuilder: (context, index) {
                      return _buildOrderCard(selesaiList[index], AppColors.success);
                    },
                  ),
                ),
                // Batal
                RefreshIndicator(
                  onRefresh: () => provider.fetchOrders(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: batalList.length,
                    itemBuilder: (context, index) {
                      return _buildOrderCard(batalList[index], AppColors.accent);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order, Color statusColor) {
    final userProv = context.watch<UserProvider>();
    final mejaProv = context.watch<MejaProvider>();

    String userName = order.userId;
    try {
      final user = userProv.users.firstWhere((u) => u.id == order.userId);
      userName = user.nama;
    } catch (_) {}

    String tableName = 'Meja ${order.mejaId}';
    try {
      final meja = mejaProv.meja.firstWhere((m) => m.id == order.mejaId);
      tableName = 'Meja ${meja.nomor}';
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('#${order.id.substring(0, 6).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(order.status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(tableName, style: const TextStyle(color: AppColors.gray, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text('Rp ${order.totalHarga}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/orderDetail', arguments: order);
                  },
                  child: const Text('Detail'),
                ),
              ),
              if (order.status.toLowerCase() != 'selesai' && order.status.toLowerCase() != 'batal') ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<OrderProvider>().updateOrderStatus(order.id, 'Selesai');
                    },
                    child: const Text('Selesaikan'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
