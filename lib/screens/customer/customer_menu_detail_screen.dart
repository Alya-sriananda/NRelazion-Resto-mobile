import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/menu_model.dart';
import '../../models/cart_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/menu_provider.dart';

class CustomerMenuDetailScreen extends StatefulWidget {
  const CustomerMenuDetailScreen({super.key});

  @override
  State<CustomerMenuDetailScreen> createState() => _CustomerMenuDetailScreenState();
}

class _CustomerMenuDetailScreenState extends State<CustomerMenuDetailScreen> {
  String _selectedOption = '';
  int _quantity = 1;
  bool _isInit = false;
  CartItem? _editingItem;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final args = ModalRoute.of(context)!.settings.arguments;
      
      MenuModel? menu;
      if (args is MenuModel) {
        menu = args;
        _selectedOption = (menu.kategori == 'Makanan Utama' || menu.kategori == 'Cemilan') ? 'Normal' : 'Medium';
      } else if (args is CartItem) {
        _editingItem = args;
        _quantity = _editingItem!.quantity;
        _selectedOption = _editingItem!.size;
      }
      _isInit = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    final menuProv = context.watch<MenuProvider>();
    final cartProv = context.read<CartProvider>();
    final favProv = context.watch<FavoriteProvider>();

    MenuModel? menu;
    if (args is MenuModel) {
      menu = args;
    } else if (args is CartItem) {
      try {
        menu = menuProv.menus.firstWhere((m) => m.id == args.menuId);
      } catch (e) {
        return const Scaffold(body: Center(child: Text('Menu tidak ditemukan')));
      }
    }

    if (menu == null) return const Scaffold(body: Center(child: Text('Data tidak valid')));

    bool isFood = menu.kategori == 'Makanan Utama' || menu.kategori == 'Cemilan';
    List<String> options = isFood ? ['Normal', 'Pedas', 'Max'] : ['Small', 'Medium', 'Large'];
    List<IconData> icons = isFood 
        ? [Icons.sentiment_satisfied_alt_rounded, Icons.whatshot_rounded, Icons.local_fire_department_rounded] 
        : [Icons.coffee_rounded, Icons.coffee_rounded, Icons.coffee_rounded];

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Image
                  Stack(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.45,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: menu.gambarUrl.isNotEmpty 
                          ? Image.network(
                              _formatImageUrl(menu.gambarUrl),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                            )
                          : const Icon(Icons.fastfood, size: 64, color: Colors.grey),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10,
                        left: 20, right: 20,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildCircleButton(Icons.arrow_back_ios_new_rounded, () => Navigator.pop(context)),
                            _buildCircleButton(
                              favProv.isFavorite(menu.id) ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              () {
                                favProv.toggleFavorite(menu!);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(favProv.isFavorite(menu.id) ? 'Ditambahkan ke favorit' : 'Dihapus dari favorit'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              iconColor: favProv.isFavorite(menu.id) ? AppColors.accent : AppColors.dark,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Content
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(menu.nama, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.dark)),
                                  const SizedBox(height: 4),
                                  Text(menu.kategori, style: const TextStyle(fontSize: 14, color: AppColors.gray)),
                                ],
                              ),
                            ),
                            Row(
                              children: const [
                                Icon(Icons.star, color: Colors.amber, size: 20),
                                SizedBox(width: 4),
                                Text('4.8', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(isFood ? 'Level Pedas' : 'Pilih Ukuran', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(options.length, (index) {
                            return _buildOptionTile(options[index], icons[index], isFood ? 1.0 : (0.8 + (index * 0.2)));
                          }),
                        ),
                        const SizedBox(height: 24),
                        const Text('Deskripsi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          menu.deskripsi.isNotEmpty ? menu.deskripsi : 'Nikmati kelezatan ${menu.nama} yang dibuat dengan bahan pilihan berkualitas tinggi.',
                          style: const TextStyle(color: AppColors.gray, height: 1.5),
                        ),
                        const SizedBox(height: 100), // Space for bottom bar
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomAction(context, menu, cartProv),
    );
  }

  Widget _buildBottomAction(BuildContext context, MenuModel menu, CartProvider cartProv) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Harga', style: TextStyle(color: AppColors.gray, fontSize: 12)),
                  Text('Rp ${menu.harga * _quantity}', style: const TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  _buildQuantityButton(Icons.remove, () {
                    if (_quantity > 1) setState(() => _quantity--);
                  }),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  _buildQuantityButton(Icons.add, () => setState(() => _quantity++)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                if (_editingItem != null) {
                  cartProv.updateItem(_editingItem!.id, _selectedOption, _quantity);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan diperbarui')));
                } else {
                  cartProv.addItem(menu.id, menu.nama, menu.harga, menu.gambarUrl, _selectedOption);
                  // handle quantity if more than 1 initial (addItem only adds 1)
                  if (_quantity > 1) {
                    for(int i=1; i<_quantity; i++) {
                      cartProv.addItem(menu.id, menu.nama, menu.harga, menu.gambarUrl, _selectedOption);
                    }
                  }
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ditambahkan ke keranjang')));
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Text(_editingItem != null ? 'Simpan Perubahan' : 'Tambahkan ke Keranjang', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(String label, IconData icon, double scale) {
    final isSelected = _selectedOption == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedOption = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: MediaQuery.of(context).size.width * 0.28,
        height: 100,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.primary, width: 2),
          boxShadow: isSelected ? [
            BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
          ] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : AppColors.primary, size: 24 * scale),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap, {Color iconColor = AppColors.dark}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gray.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, color: AppColors.dark, size: 20),
      ),
    );
  }
}
