import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'home_page.dart';
import 'catalog_page.dart';
import 'inventory_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';
import 'admin_page.dart'; // Impor halaman admin kamu

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String _role = 'customer'; // Default role sebelum memuat data

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).fetchCart();
      Provider.of<CartProvider>(context, listen: false).fetchInventory();
    });
  }

  // Ambil data role yang disimpan saat login
  void _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _role = prefs.getString('role') ?? 'customer';
    });
  }

  // 1. DAFTAR HALAMAN DINAMIS
  List<Widget> _getPages() {
    return [
      const HomePage(),
      const CatalogPage(initialFilter: 'All'),
      const InventoryPage(),
      const CartPage(),
      if (_role == 'admin') const AdminPage(),
      const ProfilePage(),
    ];
  }

  List<BottomNavigationBarItem> _getNavItems() {
    return [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      const BottomNavigationBarItem(
        icon: Icon(Icons.menu_book),
        label: 'Catalog',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.inventory_2),
        label: 'Inventory',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.shopping_cart),
        label: 'Cart',
      ),
      if (_role == 'admin')
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings),
          label: 'Admin Panel',
        ),
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = _getPages();
    final navItems = _getNavItems();

    // Jaga-jaga jika terjadi pergeseran indeks setelah logout/login beda akun
    if (_selectedIndex >= pages.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      body: pages[_selectedIndex], // Menampilkan halaman aktif sesuai indeks
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color(0xFF15151E),
        selectedItemColor: const Color(0xFFD4AF37),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: navItems, // Menggunakan daftar tombol dinamis
      ),
    );
  }
}
