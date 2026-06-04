import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../theme/app_colors.dart';
import 'home_page.dart';
import 'catalog_page.dart';
import 'inventory_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';
import 'admin_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String _role = 'customer';

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).fetchCart();
      Provider.of<CartProvider>(context, listen: false).fetchInventory();
    });
  }

  void _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _role = prefs.getString('role') ?? 'customer';
    });
  }

  List<Widget> _getPages() {
    return [
      if (_role == 'customer') ...[
        const HomePage(),
        const CatalogPage(initialFilter: 'All'),
        const CartPage(),
        const InventoryPage(),
        const ProfilePage(),
      ],
      if (_role == 'admin') ...[const AdminPage(), const ProfilePage()],
    ];
  }

  List<BottomNavigationBarItem> _getNavItems() {
    return [
      if (_role == 'customer') ...const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_outlined),
          activeIcon: Icon(Icons.menu_book),
          label: 'Catalog',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_outlined),
          activeIcon: Icon(Icons.shopping_cart),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          activeIcon: Icon(Icons.inventory_2),
          label: 'Inventory',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      if (_role == 'admin') ...const [
        BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings_outlined),
          activeIcon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
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
    final textTheme = Theme.of(context).textTheme;

    if (_selectedIndex >= pages.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bg2,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 32,
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            Text(
              'GENSHIN IMPORT',
              style: textTheme.headlineSmall?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.highlight,
              ),
            ),
          ],
        ),
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.primaryBlue, width: 1.0),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: AppColors.bgBlue,
          selectedItemColor: AppColors.highlight,
          unselectedItemColor: AppColors.greyText,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          items: navItems,
        ),
      ),
    );
  }
}
