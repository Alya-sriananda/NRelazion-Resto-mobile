import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/meja_provider.dart';
import '../../models/meja_model.dart';

class KasirMejaScreen extends StatefulWidget {
  const KasirMejaScreen({super.key});

  @override
  State<KasirMejaScreen> createState() => _KasirMejaScreenState();
}

class _KasirMejaScreenState extends State<KasirMejaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MejaProvider>().fetchMeja();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mejaProv = context.watch<MejaProvider>();

    // Grouping by area
    Map<String, List<MejaModel>> groupedMeja = {};
    for (var m in mejaProv.meja) {
      if (!groupedMeja.containsKey(m.area)) {
        groupedMeja[m.area] = [];
      }
      groupedMeja[m.area]!.add(m);
    }

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Manajemen Meja', style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: () => mejaProv.fetchMeja(),
        child: mejaProv.isLoading && mejaProv.meja.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Status Legend
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildLegendItem('Tersedia', Colors.green),
                        _buildLegendItem('Terisi', Colors.red),
                        _buildLegendItem('Reserved', Colors.orange),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  ...groupedMeja.entries.map((entry) => _buildAreaSection(entry.key, entry.value)),
                ],
              ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.gray)),
      ],
    );
  }

  Widget _buildAreaSection(String area, List<MejaModel> tables) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(area, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: tables.length,
          itemBuilder: (context, index) => _buildMejaCard(tables[index]),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMejaCard(MejaModel meja) {
    Color color;
    switch (meja.status.toLowerCase()) {
      case 'tersedia': color = Colors.green; break;
      case 'terisi': color = Colors.red; break;
      case 'reserved': color = Colors.orange; break;
      default: color = Colors.grey;
    }

    return GestureDetector(
      onTap: () => _showStatusDialog(meja),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(meja.nomor, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text('Cap: ${meja.kapasitas}', style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }

  void _showStatusDialog(MejaModel meja) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Status Meja ${meja.nomor}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _statusOption(meja, 'Tersedia', Colors.green),
            _statusOption(meja, 'Reserved', Colors.orange),
            _statusOption(meja, 'Terisi', Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _statusOption(MejaModel meja, String status, Color color) {
    return ListTile(
      leading: Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      title: Text(status),
      onTap: () async {
        Navigator.pop(context);
        final success = await context.read<MejaProvider>().updateMejaStatus(meja.id, status);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status meja ${meja.nomor} diperbarui')));
        }
      },
    );
  }
}
