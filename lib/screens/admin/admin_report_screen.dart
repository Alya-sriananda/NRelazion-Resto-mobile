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
import '../../utils/format_helper.dart';

class AdminReportScreen extends StatefulWidget {
  const AdminReportScreen({super.key});

  @override
  State<AdminReportScreen> createState() => _AdminReportScreenState();
}

class _AdminReportScreenState extends State<AdminReportScreen> {
  String _selectedReportType = 'Harian'; // Harian, Mingguan, Bulanan, Tahunan
  final DateTime _now = DateTime.now();
  int _touchedBarIndex = -1;

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
      return [
        BarChartGroupData(
          x: 0,
          barRods: [
            BarChartRodData(
              toY: 0,
              color: AppColors.primary.withValues(alpha: 0.2),
              width: 10,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
          ],
        ),
      ];
    }

    // Prepare raw values
    List<MapEntry<int, double>> entries = [];

    if (_selectedReportType == 'Harian') {
      Map<int, double> hourlyData = {};
      for (var o in filteredOrders) {
        hourlyData[o.tanggal.hour] = (hourlyData[o.tanggal.hour] ?? 0) + o.totalHarga.toDouble();
      }
      var sortedKeys = hourlyData.keys.toList()..sort();
      for (var k in sortedKeys) {
        entries.add(MapEntry(k, hourlyData[k]!));
      }
    } else if (_selectedReportType == 'Mingguan') {
      Map<int, double> dailyData = {};
      for (var o in filteredOrders) {
        dailyData[o.tanggal.weekday] = (dailyData[o.tanggal.weekday] ?? 0) + o.totalHarga.toDouble();
      }
      for (int i = 1; i <= 7; i++) {
        entries.add(MapEntry(i, (dailyData[i] ?? 0).toDouble()));
      }
    } else if (_selectedReportType == 'Bulanan') {
      Map<int, double> dailyData = {};
      for (var o in filteredOrders) {
        dailyData[o.tanggal.day] = (dailyData[o.tanggal.day] ?? 0) + o.totalHarga.toDouble();
      }
      var sortedKeys = dailyData.keys.toList()..sort();
      for (var k in sortedKeys) {
        entries.add(MapEntry(k, dailyData[k]!));
      }
    } else {
      // Tahunan
      Map<int, double> monthlyData = {};
      for (var o in filteredOrders) {
        monthlyData[o.tanggal.month] = (monthlyData[o.tanggal.month] ?? 0) + o.totalHarga.toDouble();
      }
      for (int i = 1; i <= 12; i++) {
        entries.add(MapEntry(i, (monthlyData[i] ?? 0).toDouble()));
      }
    }

    // Map to BarChartGroupData with styling
    List<BarChartGroupData> result = [];
    for (int i = 0; i < entries.length; i++) {
      final xVal = entries[i].key;
      final yVal = entries[i].value;

      bool isTouched = _touchedBarIndex == i;
      bool isActive = false;
      if (_selectedReportType == 'Harian') {
        isActive = xVal == _now.hour;
      } else if (_selectedReportType == 'Mingguan') {
        isActive = xVal == _now.weekday;
      } else if (_selectedReportType == 'Bulanan') {
        isActive = xVal == _now.day;
      } else if (_selectedReportType == 'Tahunan') {
        isActive = xVal == _now.month;
      }

      double width = 10;
      Color color = AppColors.primary.withValues(alpha: 0.2);

      if (isTouched) {
        width = 16;
        color = AppColors.primary;
      } else if (isActive) {
        width = 16;
        color = AppColors.primaryDark;
      }

      result.add(
        BarChartGroupData(
          x: xVal,
          barRods: [
            BarChartRodData(
              toY: yVal,
              color: color,
              width: width,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
          ],
        ),
      );
    }
    return result;
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
    
    // Theme colors
    final primaryColor = PdfColor.fromHex('#C08A45'); // AppColors.primary
    final darkColor = PdfColor.fromHex('#1E1E1E');    // AppColors.dark

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('NRelazion Resto', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                    pw.SizedBox(height: 4),
                    pw.Text('Laporan Pendapatan $_selectedReportType', style: pw.TextStyle(fontSize: 16, color: darkColor)),
                  ],
                ),
                pw.Text('Dicetak:\n${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.right),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Divider(color: primaryColor, thickness: 2),
            pw.SizedBox(height: 16),
            
            // Summary
            pw.Text('Ringkasan', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: primaryColor)),
            pw.SizedBox(height: 8),
            pw.Row(
              children: [
                pw.Expanded(child: pw.Text('Total Pesanan Selesai: ${filteredOrders.length}', style: const pw.TextStyle(fontSize: 12))),
                pw.Expanded(child: pw.Text('Total Pendapatan: Rp $totalPendapatan', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold))),
              ]
            ),
            pw.SizedBox(height: 24),
            
            // Table
            pw.Text('Rincian Transaksi', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: primaryColor)),
            pw.SizedBox(height: 12),
            pw.TableHelper.fromTextArray(
              headers: ['ID Order', 'Tanggal', 'ID Pelanggan', 'Menu', 'Status', 'Total'],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
              headerDecoration: pw.BoxDecoration(color: primaryColor),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellAlignment: pw.Alignment.topLeft,
              data: filteredOrders.map((o) {
                String menuText = o.items.map((item) => '${item.quantity}x ${item.nama}').join('\n');
                return [
                  o.id.length > 6 ? o.id.substring(0, 6).toUpperCase() : o.id.toUpperCase(),
                  DateFormat('dd/MM/yy HH:mm').format(o.tanggal),
                  o.userId.isEmpty ? '-' : (o.userId.length > 6 ? o.userId.substring(0, 6).toUpperCase() : o.userId.toUpperCase()),
                  menuText,
                  o.status,
                  'Rp ${o.totalHarga}'
                ];
              }).toList(),
            ),
          ];
        },
      ),
    );

    // Share / Download PDF
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Laporan_$_selectedReportType.pdf',
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

    int currentIndex = 0;
    switch (_selectedReportType) {
      case 'Mingguan': currentIndex = 1; break;
      case 'Bulanan': currentIndex = 2; break;
      case 'Tahunan': currentIndex = 3; break;
      case 'Harian':
      default: currentIndex = 0; break;
    }

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2)),
                  ],
                ),
                child: BottomNavigationBar(
                  currentIndex: currentIndex,
                  onTap: (index) {
                    String type;
                    switch (index) {
                      case 1: type = 'Mingguan'; break;
                      case 2: type = 'Bulanan'; break;
                      case 3: type = 'Tahunan'; break;
                      case 0:
                      default: type = 'Harian'; break;
                    }
                    setState(() {
                      _selectedReportType = type;
                      _touchedBarIndex = -1;
                    });
                  },
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.white,
                  selectedItemColor: AppColors.primary,
                  unselectedItemColor: AppColors.gray,
                  selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.today), label: 'Harian'),
                    BottomNavigationBarItem(icon: Icon(Icons.view_week), label: 'Mingguan'),
                    BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Bulanan'),
                    BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Tahunan'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards
                    Row(
                      children: [
                        Expanded(child: _buildSummaryCard('Total Pendapatan', FormatHelper.formatRupiah(totalPendapatan), AppColors.success)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildSummaryCard('Total Pesanan', '${filteredOrders.length}', AppColors.primary)),
                      ],
                    ),
              const SizedBox(height: 24),

              // Chart Area
              Container(
                height: 250,
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFF7ED)), // light orange border
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 4)),
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
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: maxY > 0 ? maxY / 4 : 25000,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey[100]!,
                                strokeWidth: 1,
                                dashArray: [5, 5],
                              );
                            },
                          ),
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchCallback: (FlTouchEvent event, barTouchResponse) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    barTouchResponse == null ||
                                    barTouchResponse.spot == null) {
                                  _touchedBarIndex = -1;
                                  return;
                                }
                                _touchedBarIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                              });
                            },
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (group) => const Color(0xFF374151), // slate-700
                              tooltipBorderRadius: BorderRadius.circular(8),
                              tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              tooltipMargin: 8,
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                return BarTooltipItem(
                                  FormatHelper.formatRupiah(rod.toY.toInt()),
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
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
                                  int v = value.toInt();
                                  bool isActive = false;
                                  if (_selectedReportType == 'Harian') {
                                    isActive = v == _now.hour;
                                  } else if (_selectedReportType == 'Mingguan') {
                                    isActive = v == _now.weekday;
                                  } else if (_selectedReportType == 'Bulanan') {
                                    isActive = v == _now.day;
                                  } else if (_selectedReportType == 'Tahunan') {
                                    isActive = v == _now.month;
                                  }

                                  final style = TextStyle(
                                    color: isActive ? AppColors.dark : AppColors.gray,
                                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 10,
                                  );
                                  return SideTitleWidget(
                                    meta: meta,
                                    space: 4,
                                    child: Text(_getChartBottomTitle(value), style: style),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: true, 
                                    reservedSize: 40,
                                    getTitlesWidget: (val, meta) {
                                      if (val == 0) {
                                        return const Text('0', style: TextStyle(color: AppColors.gray, fontSize: 10));
                                      }
                                      return Text('${(val/1000).toInt()}k', style: const TextStyle(color: AppColors.gray, fontSize: 10));
                                    })),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                    FormatHelper.formatRupiah(o.totalHarga)
                  );
                }),
            ],
          ),
        ),
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
