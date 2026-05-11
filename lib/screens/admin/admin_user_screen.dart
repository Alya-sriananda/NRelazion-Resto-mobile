import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import 'admin_dashboard_screen.dart';

class AdminUserScreen extends StatefulWidget {
  const AdminUserScreen({super.key});

  @override
  State<AdminUserScreen> createState() => _AdminUserScreenState();
}

class _AdminUserScreenState extends State<AdminUserScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchUsers();
    });
  }

  void _showFormUser([UserModel? user]) {
    final isEdit = user != null;
    final formKey = GlobalKey<FormState>();
    final namaCtrl = TextEditingController(text: user?.nama);
    final emailCtrl = TextEditingController(text: user?.email);
    final passCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: user?.telepon);
    final fotoCtrl = TextEditingController(text: user?.fotoUrl);

    showDialog(
      context: context,
      builder: (context) {
        bool obscurePassword = true;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit Kasir' : 'Tambah Kasir'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(controller: namaCtrl, decoration: const InputDecoration(labelText: 'Nama'), validator: (v) => v!.isEmpty ? 'Wajib' : null),
                      const SizedBox(height: 16),
                      TextFormField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email'), validator: (v) => v!.isEmpty ? 'Wajib' : null),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passCtrl,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          labelText: isEdit ? 'Password Baru (Opsional)' : 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: AppColors.gray,
                            ),
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (v) => !isEdit && v!.isEmpty ? 'Wajib' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Telepon')),
                      const SizedBox(height: 16),
                      TextFormField(controller: fotoCtrl, decoration: const InputDecoration(labelText: 'URL Foto (Opsional)')),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final newUser = UserModel(
                        id: isEdit ? user.id : '',
                        nama: namaCtrl.text,
                        email: emailCtrl.text,
                        role: 'kasir',
                        telepon: phoneCtrl.text,
                        fotoUrl: fotoCtrl.text,
                      );
                      final prov = context.read<UserProvider>();
                      bool ok = isEdit 
                        ? await prov.updateUser(newUser, password: passCtrl.text)
                        : await prov.addUser(newUser, password: passCtrl.text);
                      if (!context.mounted) return;
                      if (ok) Navigator.pop(context);
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: AppColors.dark),
          title: const Text('Kelola User', style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.gray,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Kasir (Staf)'),
              Tab(text: 'Pelanggan'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add, color: AppColors.primary),
              onPressed: () => _showFormUser(),
            ),
          ],
        ),
        drawer: const AdminDrawer(),
        body: Consumer<UserProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.users.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final kasirList = provider.users.where((u) => u.role.toLowerCase() == 'kasir').toList();
            final pelangganList = provider.users.where((u) => u.role.toLowerCase() == 'customer').toList();

            return TabBarView(
              children: [
                // Tab Kasir
                RefreshIndicator(
                  onRefresh: () => provider.fetchUsers(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: kasirList.length,
                    itemBuilder: (context, index) {
                      final u = kasirList[index];
                      return _buildUserCard(context, u, 'Kasir', AppColors.info);
                    },
                  ),
                ),
                // Tab Pelanggan
                RefreshIndicator(
                  onRefresh: () => provider.fetchUsers(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: pelangganList.length,
                    itemBuilder: (context, index) {
                      final u = pelangganList[index];
                      return _buildCustomerCard(u, 'Customer', AppColors.success);
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

  Widget _buildUserCard(BuildContext context, UserModel user, String role, Color roleColor) {
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
        children: [
          CircleAvatar(
            backgroundColor: roleColor.withValues(alpha: 0.2),
            backgroundImage: user.fotoUrl.isNotEmpty ? NetworkImage(user.fotoUrl) : null,
            child: user.fotoUrl.isEmpty ? Icon(Icons.person, color: roleColor) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(user.email, style: const TextStyle(color: AppColors.gray, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(role, style: TextStyle(color: roleColor, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  InkWell(
                    onTap: () => _showFormUser(user),
                    child: const Icon(Icons.edit, color: AppColors.info, size: 16),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Hapus Kasir'),
                          content: Text('Yakin menghapus ${user.nama}?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                context.read<UserProvider>().deleteUser(user.id);
                              },
                              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Icon(Icons.delete, color: AppColors.accent, size: 16),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(UserModel user, String role, Color roleColor) {
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
        children: [
          CircleAvatar(
            backgroundColor: roleColor.withValues(alpha: 0.2),
            backgroundImage: user.fotoUrl.isNotEmpty ? NetworkImage(user.fotoUrl) : null,
            child: user.fotoUrl.isEmpty ? Icon(Icons.person, color: roleColor) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(user.email, style: const TextStyle(color: AppColors.gray, fontSize: 12)),
              ],
            ),
          ),
          Text(role, style: TextStyle(color: roleColor, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
