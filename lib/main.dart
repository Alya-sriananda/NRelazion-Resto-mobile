import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_routes.dart';
import 'theme/app_theme.dart';

import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_meja_screen.dart';
import 'screens/admin/admin_menu_screen.dart';
import 'screens/admin/admin_menu_form_screen.dart';
import 'screens/admin/admin_user_screen.dart';
import 'screens/admin/admin_report_screen.dart';
import 'screens/admin/admin_order_screen.dart';

import 'screens/customer/customer_main_screen.dart';
import 'screens/customer/customer_menu_detail_screen.dart';
import 'screens/customer/customer_favorite_screen.dart';
import 'screens/customer/customer_history_screen.dart';
import 'screens/kasir/kasir_main_screen.dart';
import 'screens/shared/order_detail_screen.dart';

import 'providers/auth_provider.dart';
import 'providers/menu_provider.dart';
import 'providers/meja_provider.dart';
import 'providers/user_provider.dart';
import 'providers/order_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorite_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => MejaProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
      ],
      child: MaterialApp(
        title: 'NRelazion Resto',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (context) => const SplashScreen(),
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.register: (context) => const RegisterScreen(),
          
          // Customer
          AppRoutes.customerMain: (context) => const CustomerMainScreen(),
          AppRoutes.menuDetail: (context) => const CustomerMenuDetailScreen(),
          AppRoutes.favorite: (context) => const CustomerFavoriteScreen(),
          AppRoutes.history: (context) => const CustomerHistoryScreen(),
          AppRoutes.orderDetail: (context) => const OrderDetailScreen(),

          // Admin
          AppRoutes.adminDashboard: (context) => const AdminDashboardScreen(),
          AppRoutes.adminMenu: (context) => const AdminMenuScreen(),
          AppRoutes.adminMenuForm: (context) => const AdminMenuFormScreen(),
          AppRoutes.adminOrder: (context) => const AdminOrderScreen(),
          AppRoutes.adminMeja: (context) => const AdminMejaScreen(),
          AppRoutes.adminUser: (context) => const AdminUserScreen(),
          AppRoutes.adminReport: (context) => const AdminReportScreen(),
        },
      ),
    );
  }
}
