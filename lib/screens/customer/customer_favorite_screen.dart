import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/favorite_provider.dart';
import '../../utils/format_helper.dart';
import '../../models/menu_model.dart';

class CustomerFavoriteScreen extends StatelessWidget {
  const CustomerFavoriteScreen({super.key});

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
    final favProv = context.watch<FavoriteProvider>();
    final favorites = favProv.favorites;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Menu Favorit', style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.bold)),
      ),
      body: favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border_rounded, size: 80, color: AppColors.gray.withValues(alpha: 0.2)),
                  const SizedBox(height: 16),
                  const Text('Belum ada menu favorit', style: TextStyle(color: AppColors.gray)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final menu = favorites[index];
                return _buildFavoriteCard(context, menu, favProv);
              },
            ),
    );
  }

  Widget _buildFavoriteCard(BuildContext context, MenuModel menu, FavoriteProvider favProv) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/menuDetail', arguments: menu),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 70, height: 70,
                color: Colors.grey[100],
                child: menu.gambarUrl.isNotEmpty
                    ? Image.network(_formatImageUrl(menu.gambarUrl), fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image))
                    : const Icon(Icons.fastfood),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(menu.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(menu.kategori, style: const TextStyle(color: AppColors.gray, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(FormatHelper.formatRupiah(menu.harga), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.favorite_rounded, color: AppColors.accent),
              onPressed: () => favProv.toggleFavorite(menu),
            ),
          ],
        ),
      ),
    );
  }
}
