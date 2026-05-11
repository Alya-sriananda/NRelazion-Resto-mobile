import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/order_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/meja_provider.dart';
import '../../models/order_model.dart';


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
      length: 5,
      child: Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text('Kelola Pesanan', style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.gray,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Menunggu'),
              Tab(text: 'Dikonfirmasi'),
              Tab(text: 'Diproses'),
              Tab(text: 'Siap Diambil'),
              Tab(text: 'Selesai'),
            ],
          ),
        ),
        body: Consumer<OrderProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.orders.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.errorMessage.isNotEmpty && provider.orders.isEmpty) {
              return Center(child: Text(provider.errorMessage));
            }

            return TabBarView(
              children: [
                _buildOrderList(provider, 'menunggu'),
                _buildOrderList(provider, 'dikonfirmasi'),
                _buildOrderList(provider, 'diproses'),
                _buildOrderList(provider, 'siap diambil'),
                _buildOrderList(provider, 'selesai'),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderList(OrderProvider provider, String status) {
    final filtered = provider.orders.where((o) {
      final s = o.status.toLowerCase().trim();
      if (status == 'menunggu') {
        return s == 'menunggu' || s == 'menunggu konfirmasi';
      }
      return s == status;
    }).toList();

    return RefreshIndicator(
      onRefresh: () => provider.fetchOrders(),
      child: filtered.isEmpty
          ? Center(child: Text('Tidak ada pesanan ${status == 'menunggu' ? 'masuk' : status}'))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: filtered.length,
              itemBuilder: (context, index) => _buildOrderCard(filtered[index]),
            ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
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
      tableName = '${meja.area} - ${meja.nomor}';
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('#${order.id.substring(0, 6).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              _buildStatusBadge(order.status),
            ],
          ),
          const Divider(height: 24),
          Row(
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
          const SizedBox(height: 16),
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
              const SizedBox(width: 8),
              _buildActionButton(order),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(OrderModel order) {
    String label = '';
    String nextStatus = '';
    Color color = AppColors.primary;

    final currentStatus = order.status.toLowerCase().trim();
    switch (currentStatus) {
      case 'menunggu':
      case 'menunggu konfirmasi':
        label = 'Konfirmasi';
        nextStatus = 'Dikonfirmasi';
        color = Colors.blue;
        break;
      case 'dikonfirmasi':
        label = 'Proses';
        nextStatus = 'Diproses';
        color = Colors.orange;
        break;
      case 'diproses':
        label = 'Siap Diambil';
        nextStatus = 'Siap Diambil';
        color = Colors.green;
        break;
      case 'siap diambil':
        label = 'Selesaikan';
        nextStatus = 'Selesai';
        color = AppColors.success;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
        onPressed: () async {
          _showLoadingDialog(context);
          final success = await context.read<OrderProvider>().updateOrderStatus(order.id, nextStatus);
          if (mounted) Navigator.pop(context); // Close loading
          
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status pesanan diperbarui menjadi $nextStatus')));
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.read<OrderProvider>().errorMessage)));
          }
        },
        child: Text(label),
      ),
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildStatusBadge(String status) {
    final s = status.toLowerCase().trim();
    Color color;
    switch (s) {
      case 'selesai': color = AppColors.success; break;
      case 'batal': color = AppColors.accent; break;
      case 'menunggu': color = AppColors.warning; break;
      default: color = AppColors.info;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
