import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/order_provider.dart';
import 'admin_dashboard_screen.dart'; // for Drawer
import 'package:fl_chart/fl_chart.dart'; // Jika ingin menggunakan chart betulan

class AdminReportScreen extends StatefulWidget {
  const AdminReportScreen({super.key});

  @override
  State<AdminReportScreen> createState() => _AdminReportScreenState();
}

class _AdminReportScreenState extends State<AdminReportScreen> {
  String _selectedMonth = 'Mei 2026';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders(); // Fetch all orders
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProv = context.watch<OrderProvider>();
    
    int totalPendapatan = 0;
    int totalPesanan = 0;
    for (var o in orderProv.orders) {
      if (o.status.toLowerCase() == 'selesai') {
        totalPendapatan += o.totalHarga;
        totalPesanan += 1;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppColors.dark),
        title: const Text('Laporan & Statistik', style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.bold)),
      ),
      drawer: const AdminDrawer(),
      body: RefreshIndicator(
        onRefresh: () => orderProv.fetchOrders(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Bulan
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedMonth,
                    isExpanded: true,
                    items: ['Maret 2026', 'April 2026', 'Mei 2026'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedMonth = newValue!;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Summary Cards
              Row(
                children: [
                  Expanded(child: _buildSummaryCard('Total Pendapatan', 'Rp $totalPendapatan', AppColors.success)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSummaryCard('Total Pesanan', '$totalPesanan', AppColors.primary)),
                ],
              ),
              const SizedBox(height: 24),

              // Chart Area (Simplified)
              Container(
                height: 200,
                width: double.infinity,
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
                    const Text('Grafik Pendapatan', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Expanded(
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 200000,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  const style = TextStyle(color: AppColors.gray, fontWeight: FontWeight.bold, fontSize: 10);
                                  String text;
                                  switch (value.toInt()) {
                                    case 0: text = 'Minggu 1'; break;
                                    case 1: text = 'Minggu 2'; break;
                                    case 2: text = 'Minggu 3'; break;
                                    case 3: text = 'Minggu 4'; break;
                                    default: text = ''; break;
                                  }
                                  return SideTitleWidget(meta: meta, space: 4, child: Text(text, style: style));
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: [
                            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 120000, color: AppColors.primary, width: 16, borderRadius: BorderRadius.circular(4))]),
                            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 150000, color: AppColors.primary, width: 16, borderRadius: BorderRadius.circular(4))]),
                            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 80000, color: AppColors.primary, width: 16, borderRadius: BorderRadius.circular(4))]),
                            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 190000, color: AppColors.primary, width: 16, borderRadius: BorderRadius.circular(4))]),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text('Riwayat Transaksi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),

              // Transaction List
              if (orderProv.orders.isEmpty)
                const Text('Belum ada transaksi selesai')
              else
                ...orderProv.orders.where((o) => o.status.toLowerCase() == 'selesai').map((o) {
                  return _buildTransactionItem(o.id.substring(0, 6).toUpperCase(), o.createdAt.isNotEmpty ? o.createdAt : '10 Mei 2026', 'Rp ${o.totalHarga}');
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(String id, String date, String amount) {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order $id', style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(date, style: const TextStyle(color: AppColors.gray, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(amount, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
