import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/order_model.dart';
import '../../utils/format_helper.dart';
import '../../providers/meja_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final order = ModalRoute.of(context)!.settings.arguments as OrderModel;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.dark),
        title: const Text('Detail Pesanan', style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order #${order.id.substring(0, 6).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd MMMM yyyy, HH:mm').format(order.tanggal),
                          style: const TextStyle(color: AppColors.gray, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(order.status),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Order Info
            const Text('Informasi Pesanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  Consumer<MejaProvider>(
                    builder: (context, mejaProv, _) {
                      String tableName = 'Meja ${order.mejaId}';
                      try {
                        final meja = mejaProv.meja.firstWhere((m) => m.id == order.mejaId);
                        tableName = '${meja.area} - ${meja.nomor}';
                      } catch (_) {}
                      return _buildInfoRow('Meja', tableName);
                    },
                  ),
                  const Divider(height: 24),
                  _buildInfoRow('Metode Bayar', order.metodeBayar),
                  if (order.catatan.isNotEmpty) ...[
                    const Divider(height: 24),
                    _buildInfoRow('Catatan', order.catatan),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Items List
            const Text('Menu yang Dipesan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  ...order.items.map((item) => _buildItemRow(item)),
                  const Divider(height: 32, thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(FormatHelper.formatRupiah(order.totalHarga), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ],
              ),
            ),
            // Beli Lagi Button (only for completed or cancelled orders)
            if (['selesai', 'batal', 'dibatalkan'].contains(order.status.toLowerCase().trim())) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  label: const Text('Beli Lagi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shadowColor: AppColors.primary.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () => _buyAgain(context, order),
                ),
              ),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _buyAgain(BuildContext context, OrderModel order) {
    if (order.items.isEmpty) return;
    final cartProv = context.read<CartProvider>();
    final authProv = context.read<AuthProvider>();
    // Hanya bisa beli lagi jika sudah login
    if (authProv.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Silakan login untuk membeli lagi'),
          backgroundColor: AppColors.accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    for (final item in order.items) {
      cartProv.addItem(
        item.menuId,
        item.nama,
        item.harga,
        '', // gambarUrl tidak tersimpan di order item
        item.size,
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('${order.items.length} item ditambahkan ke keranjang'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.pop(context); // Kembali ke halaman riwayat
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'selesai': color = AppColors.success; break;
      case 'batal': case 'dibatalkan': color = AppColors.accent; break;
      case 'diproses': color = AppColors.warning; break;
      default: color = AppColors.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.gray)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildItemRow(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
            child: Text('${item.quantity}x', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(item.size, style: const TextStyle(color: AppColors.gray, fontSize: 11)),
              ],
            ),
          ),
          Text(FormatHelper.formatRupiah(item.harga * item.quantity), style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
