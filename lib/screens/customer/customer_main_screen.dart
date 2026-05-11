import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'customer_home_screen.dart';
import 'customer_menu_list_screen.dart';
import 'customer_cart_screen.dart';
import 'customer_history_screen.dart';
import 'customer_profile_screen.dart';

class CustomerMainScreen extends StatefulWidget {
  const CustomerMainScreen({super.key});

  static dynamic of(BuildContext context) =>
      context.findAncestorStateOfType<_CustomerMainScreenState>();

  @override
  State<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends State<CustomerMainScreen> {
  int _selectedIndex = 0;

  void setSelectedIndex(int index) {
    setState(() => _selectedIndex = index);
  }

  final List<Widget> _screens = [
    const CustomerHomeScreen(),
    const CustomerMenuListScreen(),
    const CustomerCartScreen(),
    const CustomerHistoryScreen(),
    const CustomerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cream,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_rounded),
            _buildNavItem(1, Icons.restaurant_menu_rounded),
            _buildNavItem(2, Icons.shopping_cart_rounded),
            _buildNavItem(3, Icons.receipt_long_rounded),
            _buildNavItem(4, Icons.person_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: isSelected ? Border.all(color: AppColors.primary.withValues(alpha: 0.2)) : null,
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.primary : AppColors.gray.withValues(alpha: 0.6),
          size: isSelected ? 28 : 24,
        ),
      ),
    );
  }
}
