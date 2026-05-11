import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class KasirProfileScreen extends StatelessWidget {
  const KasirProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProv = context.watch<AuthProvider>();
    final user = authProv.currentUser;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Profil Kasir', style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.person, size: 50, color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(user?.nama ?? 'Kasir Name', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(user?.email ?? 'kasir@nrelazion.com', style: const TextStyle(color: AppColors.gray)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
                    child: const Text('Role: KASIR', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            _buildProfileItem(Icons.edit_rounded, 'Edit Profil', () {
              Navigator.pushNamed(context, '/editProfile');
            }),
            _buildProfileItem(Icons.lock_rounded, 'Ubah Password', () {}),
            _buildProfileItem(Icons.info_rounded, 'Tentang Aplikasi', () {}),
            const Divider(height: 32),
            _buildProfileItem(Icons.logout_rounded, 'Logout', () {
              authProv.logout();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            }, isLogout: true),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isLogout ? AppColors.accent.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: isLogout ? AppColors.accent : AppColors.primary, size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isLogout ? AppColors.accent : AppColors.dark)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.gray),
    );
  }
}
