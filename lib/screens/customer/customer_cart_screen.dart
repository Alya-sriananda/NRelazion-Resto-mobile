import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/meja_provider.dart';
import '../../models/order_model.dart';
import '../../models/cart_model.dart';
import '../../models/meja_model.dart';
import '../../utils/format_helper.dart';
import 'customer_main_screen.dart';

class CustomerCartScreen extends StatefulWidget {
  const CustomerCartScreen({super.key});

  @override
  State<CustomerCartScreen> createState() => _CustomerCartScreenState();
}

class _CustomerCartScreenState extends State<CustomerCartScreen> {
  String? _selectedMejaId;
  String _selectedArea = 'Semua';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MejaProvider>().fetchMeja();
    });
  }

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

  void _checkout() async {
    if (_isLoading) return;

    final cartProv = context.read<CartProvider>();
    final orderProv = context.read<OrderProvider>();
    final authProv = context.read<AuthProvider>();

    if (_selectedMejaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih nomor meja terlebih dahulu')),
      );
      return;
    }

    final newOrder = OrderModel(
      userId: authProv.currentUser?.id ?? 'guest',
      mejaId: _selectedMejaId!,
      itemsJson: json.encode(cartProv.items.map((item) => OrderItem(
        menuId: item.menuId,
        nama: item.nama,
        harga: item.harga,
        quantity: item.quantity,
        size: item.size,
      ).toJson()).toList()),
      totalHarga: cartProv.totalAmount,
    );

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await orderProv.addOrder(newOrder);
      if (success && mounted) {
        // Otomatisasi status meja
        context.read<MejaProvider>().updateMejaStatus(_selectedMejaId!, 'Terisi');

        cartProv.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan berhasil dibuat!')),
        );
        CustomerMainScreen.of(context)?.setSelectedIndex(3); // Go to history
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat pesanan: ${orderProv.errorMessage}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat pesanan: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProv = context.watch<CartProvider>();
    final mejaProv = context.watch<MejaProvider>();

    return PopScope(
      canPop: !_isLoading,
      child: Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text('Keranjang Belanja', style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.bold)),
          actions: [
            if (cartProv.items.isNotEmpty && !_isLoading)
              IconButton(
                icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.accent),
                onPressed: () => _showClearDialog(cartProv),
              ),
          ],
        ),
        body: Stack(
          children: [
            cartProv.items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 80, color: AppColors.gray.withValues(alpha: 0.2)),
                        const SizedBox(height: 16),
                        const Text('Keranjangmu masih kosong', style: TextStyle(color: AppColors.gray, fontSize: 16)),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            CustomerMainScreen.of(context)?.setSelectedIndex(0);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          ),
                          child: const Text('Mulai Belanja', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: cartProv.items.length,
                          itemBuilder: (context, index) {
                            final item = cartProv.items[index];
                            return _buildCartItem(item, cartProv);
                          },
                        ),
                      ),
                      _buildCheckoutSection(cartProv, mejaProv),
                    ],
                  ),
            if (_isLoading)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {}, // swallow taps
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Memproses pesanan...',
                              style: TextStyle(
                                color: AppColors.dark,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showClearDialog(CartProvider cartProv) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Keranjang?'),
        content: const Text('Semua item di keranjang akan dihapus.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              cartProv.clear();
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item, CartProvider cartProv) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/menuDetail', arguments: item);
      },
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
                child: item.gambarUrl.isNotEmpty
                    ? Image.network(_formatImageUrl(item.gambarUrl), fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image))
                    : const Icon(Icons.fastfood),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('Level/Ukuran: ${item.size}', style: const TextStyle(color: AppColors.gray, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(FormatHelper.formatRupiah(item.harga), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: AppColors.gray),
                  onPressed: () => cartProv.removeItem(item.id),
                ),
                Row(
                  children: [
                    _buildQtyBtn(Icons.remove, () => cartProv.decrementQuantity(item.id)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    _buildQtyBtn(Icons.add, () => cartProv.incrementQuantity(item.id)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: AppColors.dark),
      ),
    );
  }

  Widget _buildCheckoutSection(CartProvider cartProv, MejaProvider mejaProv) {
    // Unique areas
    Set<String> areas = {'Semua'};
    for (var m in mejaProv.meja) {
      areas.add(m.area);
    }

    // Filtered mejas
    List<MejaModel> displayMejas = mejaProv.meja;
    if (_selectedArea != 'Semua') {
      displayMejas = displayMejas.where((m) => m.area == _selectedArea).toList();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pilih Meja', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          
          // Area Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: areas.map((area) {
                final isAreaSelected = _selectedArea == area;
                return GestureDetector(
                  onTap: () => setState(() => _selectedArea = area),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isAreaSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isAreaSelected ? AppColors.primary : AppColors.gray.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      area,
                      style: TextStyle(
                        color: isAreaSelected ? Colors.white : AppColors.gray,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Table Grid
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: displayMejas.length,
              itemBuilder: (context, index) {
                return _buildTableTile(displayMejas[index]);
              },
            ),
          ),
          
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Pembayaran', style: TextStyle(color: AppColors.gray, fontSize: 14)),
              Text(FormatHelper.formatRupiah(cartProv.totalAmount), style: const TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _checkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isLoading ? Colors.grey : AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('Checkout Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableTile(MejaModel meja) {
    final isSelected = _selectedMejaId == meja.id;
    bool isAvailable = meja.status == 'Tersedia';

    return GestureDetector(
      onTap: isAvailable ? () => setState(() => _selectedMejaId = meja.id) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(right: 12),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : (isAvailable ? Colors.white : Colors.grey[200]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.3), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              meja.nomor,
              style: TextStyle(
                color: isSelected ? Colors.white : (isAvailable ? AppColors.primary : Colors.grey),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (!isAvailable)
              const Text('Penuh', style: TextStyle(fontSize: 8, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
