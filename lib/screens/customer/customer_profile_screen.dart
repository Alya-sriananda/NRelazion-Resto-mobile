import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  String _formatImageUrl(String url) {
    if (url.contains('drive.google.com')) {
      final regExp = RegExp(r'\/d\/([^\/]+)\/');
      final match = regExp.firstMatch(url);
      if (match != null) {
        return 'https://drive.google.com/uc?export=view&id=${match.group(1)}';
      }
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final authProv = context.watch<AuthProvider>();
    final user = authProv.currentUser;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Profile
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    backgroundImage: user?.fotoUrl != null && user!.fotoUrl.isNotEmpty ? NetworkImage(_formatImageUrl(user.fotoUrl)) : null,
                    child: user?.fotoUrl == null || user!.fotoUrl.isEmpty ? const Icon(Icons.person, size: 50, color: AppColors.primary) : null,
                  ),
                  const SizedBox(height: 16),
                  Text(user?.nama ?? 'Tamu', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(user?.email ?? '-', style: const TextStyle(color: AppColors.gray)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Customer', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Menu Items
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildProfileMenuItem(Icons.person_outline_rounded, 'Edit Profil', () {
                    Navigator.pushNamed(context, '/editProfile');
                  }),
                  _buildProfileMenuItem(Icons.favorite_outline_rounded, 'Menu Favorit', () {
                    Navigator.pushNamed(context, '/favorite');
                  }),
                  _buildProfileMenuItem(Icons.notifications_none_rounded, 'Notifikasi', () {}),
                  _buildProfileMenuItem(Icons.security_rounded, 'Keamanan', () {}),
                  _buildProfileMenuItem(Icons.help_outline_rounded, 'Bantuan', () {}),
                  const SizedBox(height: 20),
                  _buildProfileMenuItem(Icons.logout_rounded, 'Keluar', () {
                    authProv.logout();
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  }, isLogout: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isLogout ? AppColors.accent.withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Icon(icon, color: isLogout ? AppColors.accent : AppColors.primary, size: 20),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isLogout ? AppColors.accent : AppColors.dark)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.gray),
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
