import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/order_provider.dart';
import '../../utils/format_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/meja_provider.dart';

class KasirDashboardScreen extends StatefulWidget {
  const KasirDashboardScreen({super.key});

  @override
  State<KasirDashboardScreen> createState() => _KasirDashboardScreenState();
}

class _KasirDashboardScreenState extends State<KasirDashboardScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialData();
    });
    // Auto refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        context.read<OrderProvider>().fetchOrders();
      }
    });
  }

  void _fetchInitialData() {
    context.read<OrderProvider>().fetchOrders();
    context.read<UserProvider>().fetchUsers();
    context.read<MejaProvider>().fetchMeja();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProv = context.watch<AuthProvider>();
    final orderProv = context.watch<OrderProvider>();
    final user = authProv.currentUser;

    int totalPendapatan = 0;
    int pesananHariIni = 0;
    int pesananMenunggu = 0;

    // Filter logic for daily stats (assuming simple filter for now)
    for (var o in orderProv.orders) {
      final status = o.status.toLowerCase().trim();
      if (status == 'selesai') {
        totalPendapatan += o.totalHarga;
      }
      if (status == 'menunggu' || status == 'menunggu konfirmasi') {
        pesananMenunggu += 1;
      }
      pesananHariIni += 1;
    }

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Kasir Dashboard', style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            tooltip: 'Refresh Data',
            onPressed: () {
              context.read<OrderProvider>().fetchOrders();
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppColors.dark),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await orderProv.fetchOrders();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Text
              const Text('Selamat bekerja,', style: TextStyle(color: AppColors.gray, fontSize: 14)),
              Text(user?.nama ?? 'Kasir', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.dark)),
              const SizedBox(height: 24),

              // Summary Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard('Pendapatan', FormatHelper.formatRupiah(totalPendapatan), Icons.payments_rounded, AppColors.success),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard('Menunggu', '$pesananMenunggu', Icons.hourglass_empty_rounded, AppColors.warning),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildStatCard('Total Pesanan Hari Ini', '$pesananHariIni', Icons.receipt_long_rounded, AppColors.primary, fullWidth: true),
              
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Pesanan Terbaru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      // Navigate to Pesanan Tab
                    },
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (orderProv.orders.isEmpty)
                const Center(child: Text('Tidak ada pesanan aktif'))
              else
                ...orderProv.orders.take(5).map((o) => _buildRecentOrderCard(o)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {bool fullWidth = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.gray, fontSize: 12)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrderCard(dynamic order) {
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: const Icon(Icons.person, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(tableName, style: const TextStyle(color: AppColors.gray, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(FormatHelper.formatRupiah(order.totalHarga), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(height: 4),
              _buildSmallStatusBadge(order.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'selesai': color = AppColors.success; break;
      case 'batal': color = AppColors.accent; break;
      case 'menunggu': color = AppColors.warning; break;
      default: color = AppColors.info;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(status, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold)),
    );
  }
}
