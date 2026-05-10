import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_routes.dart';
import 'theme/app_theme.dart';

import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_meja_screen.dart';
import 'screens/admin/admin_menu_screen.dart';
import 'screens/admin/admin_menu_form_screen.dart';
import 'screens/admin/admin_user_screen.dart';
import 'screens/admin/admin_report_screen.dart';
import 'screens/admin/admin_order_screen.dart';

import 'providers/auth_provider.dart';
import 'providers/menu_provider.dart';
import 'providers/meja_provider.dart';
import 'providers/user_provider.dart';
import 'providers/order_provider.dart';

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
      ],
      child: MaterialApp(
        title: 'NRelazion Resto',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.adminDashboard, // Sementara kita mulai di Admin Dashboard
        routes: {
          AppRoutes.splash: (context) => const PlaceholderScreen(title: 'Splash Screen'),
          AppRoutes.login: (context) => const PlaceholderScreen(title: 'Login'),
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

// Temporary Placeholder
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}
