import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../constants/app_colors.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';

class AdminReportScreen extends StatefulWidget {
  const AdminReportScreen({super.key});

  @override
  State<AdminReportScreen> createState() => _AdminReportScreenState();
}

class _AdminReportScreenState extends State<AdminReportScreen> {
  String _selectedReportType = 'Harian'; // Harian, Mingguan, Bulanan, Tahunan
  final DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders();
    });
  }

  // Helper to filter orders based on selected type
  List<OrderModel> _getFilteredOrders(List<OrderModel> allOrders) {
    return allOrders.where((o) {
      if (o.status.toLowerCase() != 'selesai') return false;
      DateTime t = o.tanggal;
      switch (_selectedReportType) {
        case 'Harian':
          return t.year == _now.year && t.month == _now.month && t.day == _now.day;
        case 'Mingguan':
          // 7 hari terakhir
          return t.isAfter(_now.subtract(const Duration(days: 7))) && t.isBefore(_now.add(const Duration(days: 1)));
        case 'Bulanan':
          return t.year == _now.year && t.month == _now.month;
        case 'Tahunan':
          return t.year == _now.year;
        default:
          return false;
      }
    }).toList();
  }

  // Generate chart data based on type
  List<BarChartGroupData> _getChartData(List<OrderModel> filteredOrders) {
    if (filteredOrders.isEmpty) {
      return [BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 0, color: AppColors.primary, width: 16, borderRadius: BorderRadius.circular(4))])];
    }

    if (_selectedReportType == 'Harian') {
      // Group by hour
      Map<int, int> hourlyData = {};
      for (var o in filteredOrders) {
        hourlyData[o.tanggal.hour] = (hourlyData[o.tanggal.hour] ?? 0) + o.totalHarga;
      }
      List<BarChartGroupData> result = [];
      var sortedKeys = hourlyData.keys.toList()..sort();
      for (var k in sortedKeys) {
        result.add(BarChartGroupData(x: k, barRods: [BarChartRodData(toY: hourlyData[k]!.toDouble(), color: AppColors.primary, width: 16, borderRadius: BorderRadius.circular(4))]));
      }
      return result;
    } else if (_selectedReportType == 'Mingguan') {
      // Group by weekday
      Map<int, int> dailyData = {};
      for (var o in filteredOrders) {
        dailyData[o.tanggal.weekday] = (dailyData[o.tanggal.weekday] ?? 0) + o.totalHarga;
      }
      List<BarChartGroupData> result = [];
      for (int i = 1; i <= 7; i++) {
        result.add(BarChartGroupData(x: i, barRods: [BarChartRodData(toY: (dailyData[i] ?? 0).toDouble(), color: AppColors.primary, width: 16, borderRadius: BorderRadius.circular(4))]));
      }
      return result;
    } else if (_selectedReportType == 'Bulanan') {
      // Group by day of month
      Map<int, int> dailyData = {};
      for (var o in filteredOrders) {
        dailyData[o.tanggal.day] = (dailyData[o.tanggal.day] ?? 0) + o.totalHarga;
      }
      List<BarChartGroupData> result = [];
      var sortedKeys = dailyData.keys.toList()..sort();
      for (var k in sortedKeys) {
        result.add(BarChartGroupData(x: k, barRods: [BarChartRodData(toY: dailyData[k]!.toDouble(), color: AppColors.primary, width: 16, borderRadius: BorderRadius.circular(4))]));
      }
      return result;
    } else { 
      // Tahunan
      Map<int, int> monthlyData = {};
      for (var o in filteredOrders) {
        monthlyData[o.tanggal.month] = (monthlyData[o.tanggal.month] ?? 0) + o.totalHarga;
      }
      List<BarChartGroupData> result = [];
      for (int i = 1; i <= 12; i++) {
        result.add(BarChartGroupData(x: i, barRods: [BarChartRodData(toY: (monthlyData[i] ?? 0).toDouble(), color: AppColors.primary, width: 16, borderRadius: BorderRadius.circular(4))]));
      }
      return result;
    }
  }
  
  double _getMaxY(List<BarChartGroupData> data) {
    double max = 0;
    for (var d in data) {
      if (d.barRods.isNotEmpty && d.barRods[0].toY > max) {
        max = d.barRods[0].toY;
      }
    }
    return max == 0 ? 100000 : max * 1.2;
  }

  String _getChartBottomTitle(double value) {
    int v = value.toInt();
    if (_selectedReportType == 'Harian') {
      return '$v:00';
    } else if (_selectedReportType == 'Mingguan') {
      switch (v) {
        case 1: return 'Sen'; case 2: return 'Sel'; case 3: return 'Rab';
        case 4: return 'Kam'; case 5: return 'Jum'; case 6: return 'Sab';
        case 7: return 'Min'; default: return '';
      }
    } else if (_selectedReportType == 'Bulanan') {
      return '$v'; 
    } else { 
      switch (v) {
        case 1: return 'Jan'; case 2: return 'Feb'; case 3: return 'Mar';
        case 4: return 'Apr'; case 5: return 'Mei'; case 6: return 'Jun';
        case 7: return 'Jul'; case 8: return 'Ags'; case 9: return 'Sep';
        case 10: return 'Okt'; case 11: return 'Nov'; case 12: return 'Des';
        default: return '';
      }
    }
  }

  Future<void> _generatePdf(List<OrderModel> filteredOrders, int totalPendapatan) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Laporan Pendapatan $_selectedReportType', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('Tanggal Cetak: ${DateFormat('dd MMMM yyyy HH:mm').format(DateTime.now())}'),
              pw.SizedBox(height: 24),
              pw.Text('Ringkasan', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('Total Pesanan Selesai: ${filteredOrders.length}'),
              pw.Text('Total Pendapatan: Rp $totalPendapatan'),
              pw.SizedBox(height: 24),
              pw.Text('Rincian Transaksi', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                headers: ['ID Order', 'Tanggal', 'Status', 'Total Harga'],
                data: filteredOrders.map((o) => [
                  o.id.length > 6 ? o.id.substring(0, 6).toUpperCase() : o.id.toUpperCase(),
                  DateFormat('dd/MM/yyyy HH:mm').format(o.tanggal),
                  o.status,
                  'Rp ${o.totalHarga}'
                ]).toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Laporan_$_selectedReportType',
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProv = context.watch<OrderProvider>();
    final filteredOrders = _getFilteredOrders(orderProv.orders);
    
    int totalPendapatan = 0;
    for (var o in filteredOrders) {
      totalPendapatan += o.totalHarga;
    }
    
    final chartData = _getChartData(filteredOrders);
    final maxY = _getMaxY(chartData);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Laporan & Statistik', style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.print, color: AppColors.primary),
            onPressed: () => _generatePdf(filteredOrders, totalPendapatan),
            tooltip: 'Cetak PDF',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => orderProv.fetchOrders(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Pilihan Laporan Interaktif
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['Harian', 'Mingguan', 'Bulanan', 'Tahunan'].map((type) {
                      bool isSelected = _selectedReportType == type;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedReportType = type;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Text(
                            type,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.gray,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Summary Cards
              Row(
                children: [
                  Expanded(child: _buildSummaryCard('Total Pendapatan', 'Rp $totalPendapatan', AppColors.success)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSummaryCard('Total Pesanan', '${filteredOrders.length}', AppColors.primary)),
                ],
              ),
              const SizedBox(height: 24),

              // Chart Area
              Container(
                height: 250,
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
                    Text('Grafik Pendapatan $_selectedReportType', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    Expanded(
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: maxY,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                return BarTooltipItem(
                                  'Rp ${rod.toY.toInt()}',
                                  const TextStyle(color: Colors.white),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  const style = TextStyle(color: AppColors.gray, fontWeight: FontWeight.bold, fontSize: 10);
                                  return SideTitleWidget(meta: meta, space: 4, child: Text(_getChartBottomTitle(value), style: style));
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: true, 
                                    reservedSize: 40,
                                    getTitlesWidget: (val, meta) {
                                      if(val == 0) return const SizedBox();
                                      return Text('${(val/1000).toInt()}k', style: const TextStyle(color: AppColors.gray, fontSize: 10));
                                    })),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: chartData,
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
              if (filteredOrders.isEmpty)
                const Text('Belum ada transaksi di periode ini')
              else
                ...filteredOrders.map((o) {
                  return _buildTransactionItem(
                    o.id.length > 6 ? o.id.substring(0, 6).toUpperCase() : o.id.toUpperCase(), 
                    DateFormat('dd MMM yyyy HH:mm').format(o.tanggal), 
                    'Rp ${o.totalHarga}'
                  );
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
