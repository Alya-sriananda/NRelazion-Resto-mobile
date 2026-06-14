import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/meja_provider.dart';
import '../../models/order_model.dart';
import 'package:intl/intl.dart';

class CustomerHistoryScreen extends StatefulWidget {
  const CustomerHistoryScreen({super.key});

  @override
  State<CustomerHistoryScreen> createState() => _CustomerHistoryScreenState();
}

class _CustomerHistoryScreenState extends State<CustomerHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId != null) {
        context.read<OrderProvider>().fetchOrders();
        context.read<MejaProvider>().fetchMeja();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProv = context.watch<OrderProvider>();
    final authProv = context.watch<AuthProvider>();
    
    final customerOrders = orderProv.orders.where((o) => o.userId == authProv.currentUser?.id).toList();
    customerOrders.sort((a, b) => b.tanggal.compareTo(a.tanggal));

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Riwayat Pesanan', style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: () => orderProv.fetchOrders(),
        child: customerOrders.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history_rounded, size: 80, color: AppColors.gray.withValues(alpha: 0.2)),
                    const SizedBox(height: 16),
                    const Text('Belum ada riwayat pesanan', style: TextStyle(color: AppColors.gray)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: customerOrders.length,
                itemBuilder: (context, index) {
                  return _buildOrderCard(customerOrders[index]);
                },
              ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final mejaProv = context.watch<MejaProvider>();
    String tableName = 'Meja ${order.mejaId}';
    try {
      final meja = mejaProv.meja.firstWhere((m) => m.id == order.mejaId);
      tableName = 'Meja ${meja.nomor}';
    } catch (_) {}

    Color statusColor;
    final s = order.status.toLowerCase().trim();
    if (s == 'selesai') {
      statusColor = AppColors.success;
    } else if (s == 'batal' || s == 'dibatalkan') {
      statusColor = AppColors.accent;
    } else if (s == 'menunggu' || s == 'menunggu konfirmasi') {
      statusColor = AppColors.warning;
    } else {
      statusColor = AppColors.info;
    }

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/orderDetail', arguments: order);
      },
      child: Container(
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
                Expanded(
                  child: Text(
                    DateFormat('dd MMM yyyy, HH:mm').format(order.tanggal),
                    style: const TextStyle(color: AppColors.gray, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order #${order.id.substring(0, 6).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('${order.items.length} Menu • $tableName', style: const TextStyle(color: AppColors.gray, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text('Rp ${order.totalHarga}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 12),
            // Short list of items
            Text(
              order.items.map((i) => '${i.quantity}x ${i.nama}').join(', '),
              style: const TextStyle(color: AppColors.gray, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (order.catatan.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Catatan: ${order.catatan}',
                style: const TextStyle(color: AppColors.accent, fontSize: 11, fontStyle: FontStyle.italic),
              ),
            ],
            if (s == 'menunggu' || s == 'menunggu konfirmasi') ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent),
                  ),
                  onPressed: () => _showCancelDialog(context, order),
                  child: const Text('Batalkan Pesanan'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext outerContext, OrderModel order) {
    showDialog(
      context: outerContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Batalkan Pesanan?'),
        content: const Text('Apakah Anda yakin ingin membatalkan pesanan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog
              showDialog(
                context: outerContext,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );
              final success = await outerContext.read<OrderProvider>().updateOrderStatus(order.id, 'Batal');
              if (mounted) Navigator.pop(outerContext); // Close loading
              if (success && mounted) {
                ScaffoldMessenger.of(outerContext).showSnackBar(const SnackBar(content: Text('Pesanan berhasil dibatalkan')));
              } else if (mounted) {
                ScaffoldMessenger.of(outerContext).showSnackBar(SnackBar(content: Text(outerContext.read<OrderProvider>().errorMessage)));
              }
            },
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }
}
