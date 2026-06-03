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
          scaffoldBackgroundColor: const Color(0xFF1C1C28),
          primaryColor: const Color(0xFFD4AF37),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFD4AF37),
            secondary: Colors.blueAccent,
          ),
          fontFamily: 'Serif',
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
