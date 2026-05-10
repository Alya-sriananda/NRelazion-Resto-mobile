import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/order_provider.dart';
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
                      final o = aktifList[index];
                      return _buildOrderCard(o.id, o.userId, 'Meja ${o.mejaId}', 'Rp ${o.totalHarga}', AppColors.warning, o.status);
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
                      final o = selesaiList[index];
                      return _buildOrderCard(o.id, o.userId, 'Meja ${o.mejaId}', 'Rp ${o.totalHarga}', AppColors.success, o.status);
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
                      final o = batalList[index];
                      return _buildOrderCard(o.id, o.userId, 'Meja ${o.mejaId}', 'Rp ${o.totalHarga}', AppColors.accent, o.status);
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

  Widget _buildOrderCard(String id, String name, String table, String total, Color statusColor, String statusText) {
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
              Text('#$id', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(table, style: const TextStyle(color: AppColors.gray, fontSize: 12)),
                ],
              ),
              Text(total, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          if (statusText.toLowerCase() != 'selesai' && statusText.toLowerCase() != 'batal')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Detail'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<OrderProvider>().updateOrderStatus(id, 'Selesai');
                    },
                    child: const Text('Selesaikan'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
