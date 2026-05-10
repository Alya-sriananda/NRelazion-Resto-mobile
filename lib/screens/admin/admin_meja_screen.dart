import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/meja_model.dart';
import '../../providers/meja_provider.dart';
import 'admin_dashboard_screen.dart'; // for Drawer

class AdminMejaScreen extends StatefulWidget {
  const AdminMejaScreen({super.key});

  @override
  State<AdminMejaScreen> createState() => _AdminMejaScreenState();
}

class _AdminMejaScreenState extends State<AdminMejaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MejaProvider>().fetchMeja();
    });
  }

  void _showFormMeja([MejaModel? meja]) {
    final isEdit = meja != null;
    final formKey = GlobalKey<FormState>();
    final nomorCtrl = TextEditingController(text: meja?.nomor);
    final areaCtrl = TextEditingController(text: meja?.area);
    final kapasitasCtrl = TextEditingController(text: meja?.kapasitas.toString());
    String status = meja?.status ?? 'Tersedia';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit Meja' : 'Tambah Meja'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: areaCtrl,
                    decoration: const InputDecoration(labelText: 'Area (Misal: Indoor)'),
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nomorCtrl,
                    decoration: const InputDecoration(labelText: 'Nomor Meja'),
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: kapasitasCtrl,
                    decoration: const InputDecoration(labelText: 'Kapasitas (Kursi)'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: ['Tersedia', 'Terisi', 'Reserved'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) => status = v!,
                  )
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newMeja = MejaModel(
                    id: isEdit ? meja.id : '',
                    area: areaCtrl.text,
                    nomor: nomorCtrl.text,
                    kapasitas: int.parse(kapasitasCtrl.text),
                    status: status,
                  );
                  final prov = context.read<MejaProvider>();
                  bool ok = isEdit ? await prov.updateMeja(newMeja) : await prov.addMeja(newMeja);
                  if (!context.mounted) return;
                  if (ok) Navigator.pop(context);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppColors.dark),
        title: const Text('Kelola Meja', style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () => _showFormMeja(),
          ),
        ],
      ),
      drawer: const AdminDrawer(),
      body: Consumer<MejaProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.meja.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final mejaList = provider.meja;
          
          final Map<String, List<MejaModel>> groupedMeja = {};
          for (var item in mejaList) {
            if (!groupedMeja.containsKey(item.area)) {
              groupedMeja[item.area] = [];
            }
            groupedMeja[item.area]!.add(item);
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchMeja(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Legend
                  Row(
                    children: [
                      _buildLegend(AppColors.success, 'Tersedia'),
                      const SizedBox(width: 16),
                      _buildLegend(AppColors.accent, 'Terisi'),
                      const SizedBox(width: 16),
                      _buildLegend(AppColors.warning, 'Reserved'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (groupedMeja.isEmpty) const Text('Belum ada data meja'),

                  // Areas
                  ...groupedMeja.entries.map((entry) {
                    return Column(
                      children: [
                        _buildAreaSection(entry.key, entry.value.map((m) {
                          Color statusColor = AppColors.success;
                          if (m.status.toLowerCase() == 'terisi') statusColor = AppColors.accent;
                          if (m.status.toLowerCase() == 'reserved') statusColor = AppColors.warning;
                          
                          return _buildTableCard(m, statusColor, isVip: m.area.toLowerCase().contains('vip'));
                        }).toList()),
                        const SizedBox(height: 24),
                      ],
                    );
                  }),

                  // Tambah Area Baru (Alias Tambah Meja)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showFormMeja(),
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Meja Baru'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.gray,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.gray, style: BorderStyle.solid),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.gray)),
      ],
    );
  }

  Widget _buildAreaSection(String title, List<Widget> tables) {
    return Container(
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
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: tables.length > 2 ? 3 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: tables.length > 2 ? 1.0 : 1.5,
            children: tables,
          ),
        ],
      ),
    );
  }

  Widget _buildTableCard(MejaModel m, Color statusColor, {bool isVip = false}) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit, color: AppColors.info),
                  title: const Text('Edit Meja'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showFormMeja(m);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: AppColors.accent),
                  title: const Text('Hapus Meja'),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.read<MejaProvider>().deleteMeja(m.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          border: Border.all(color: statusColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isVip ? Icons.workspace_premium : Icons.chair, color: statusColor, size: isVip ? 32 : 24),
            const SizedBox(height: 4),
            Text(m.nomor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text('${m.kapasitas} kursi', style: const TextStyle(fontSize: 10, color: AppColors.gray)),
            const SizedBox(height: 2),
            Text(m.status, style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
