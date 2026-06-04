import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/cart_provider.dart';
import 'package:frontend/pages/admin_page.dart';
import 'package:frontend/pages/cart_page.dart';
import 'package:frontend/pages/catalog_page.dart';
import 'package:frontend/pages/home_page.dart';
import 'package:frontend/pages/inventory_page.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:frontend/pages/main_screen.dart';
import 'package:frontend/pages/profile_page.dart';
import 'package:frontend/pages/register_page.dart';
import 'package:frontend/theme/app_colors.dart';

void main() {
  runApp(const GenshinImportApp());
}

class GenshinImportApp extends StatelessWidget {
  const GenshinImportApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: MaterialApp(
        title: 'Genshin Import',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.bgBlue,
          primaryColor: AppColors.primaryBlue,
          colorScheme: const ColorScheme.dark(
            primary: AppColors.highlight,
            secondary: AppColors.highlightSecondary,
            surface: AppColors.secondaryBlue,
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontFamily: 'HYWenHei',
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryText,
            ),
            headlineLarge: TextStyle(
              fontFamily: 'HYWenHei',
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryText,
            ),
            headlineMedium: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
            headlineSmall: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
            bodyMedium: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryText,
            ),
          ),
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/catalog': (context) => const CatalogPage(initialFilter: 'All'),
          '/cart': (context) => const CartPage(),
          '/profile': (context) => const ProfilePage(),
          '/inventory': (context) => const InventoryPage(),
          '/home': (context) => const MainScreen(),
          '/admin': (context) => const AdminPage(),
        },
      ),
    );
  }
}
