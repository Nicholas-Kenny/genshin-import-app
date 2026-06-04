import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class CartItem {
  final int id;
  final String name;
  final String category;
  final String type;
  final int stars;
  final int price;
  final String? imageUrl;
  final int stock;
  int qty;

  CartItem({
    required this.id,
    required this.name,
    required this.category,
    required this.type,
    required this.stars,
    required this.price,
    this.imageUrl,
    required this.stock,
    this.qty = 1,
  });
}

class InventoryItem {
  final int id;
  final String name;
  final int price;
  final String? imageUrl;
  final DateTime purchasedAt;
  final int stars;
  final String type;
  final String category;

  InventoryItem({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    required this.purchasedAt,
    this.stars = 4,
    this.type = 'Item',
    this.category = 'General',
  });
}

class CartProvider extends ChangeNotifier {
  List<CartItem> _cartItems = [];
  List<InventoryItem> _inventoryItems = [];
  bool _isLoading = false;

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);
  List<InventoryItem> get inventoryItems => List.unmodifiable(_inventoryItems);
  int get cartCount => _cartItems.fold(0, (sum, item) => sum + item.qty);
  int get cartTotal =>
      _cartItems.fold(0, (sum, item) => sum + item.price * item.qty);
  bool get isLoading => _isLoading;

  // 1. TARIK DATA KERANJANG DARI MYSQL
  Future<void> fetchCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/cart'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List decoded = jsonDecode(response.body);
        _cartItems.clear();
        for (var e in decoded) {
          _cartItems.add(
            CartItem(
              id: e['item_id'] as int,
              name: e['name'].toString(),
              category: e['category']?.toString() ?? 'Unknown',
              type: e['type']?.toString() ?? '-',
              stars: e['stars'] != null ? (e['stars'] as num).toInt() : 4,
              price: (e['price'] as num).toInt(),
              imageUrl: e['image_url']?.toString(),
              stock: (e['stock'] as num).toInt(),
              qty: (e['quantity'] as num).toInt(),
            ),
          );
        }
        notifyListeners();
      }
    } catch (e) {
      print("Error fetch cart: $e");
    }
  }

  // 2. TARIK DATA INVENTORY DARI MYSQL
  Future<void> fetchInventory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/cart/inventory'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List decoded = jsonDecode(response.body);
        _inventoryItems.clear();
        for (var e in decoded) {
          _inventoryItems.add(
            InventoryItem(
              id: e['item_id'] as int,
              name: e['name'].toString(),
              price: e['price'] != null ? (e['price'] as num).toInt() : 0,
              imageUrl: e['image_url']?.toString(),
              purchasedAt: e['purchased_at'] != null
                  ? DateTime.parse(e['purchased_at'].toString())
                  : DateTime.now(),
              stars: e['stars'] != null ? (e['stars'] as num).toInt() : 4,
              type: e['type']?.toString() ?? 'Item',
              category: e['category']?.toString() ?? 'General',
            ),
          );
        }
        notifyListeners();
      }
    } catch (e) {
      print("Error fetch inventory: $e");
    }
  }

  // 3. TOMBOL TAMBAH QUANTITY / ADD TO CART VIA API
  Future<void> addToCart(dynamic item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final itemId = item['id'] ?? item['item_id'];

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/cart/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'item_id': itemId, 'quantity': 1}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchCart(); // Ambil ulang data terupdate dari MySQL
      }
    } catch (e) {
      print("Error add to cart: $e");
    }
  }

  Future<void> incrementQty(int id) async {
    final itemIdx = _cartItems.indexWhere((e) => e.id == id);
    if (itemIdx >= 0) {
      final item = _cartItems[itemIdx];
      if (item.qty >= item.stock) return;
    }
    await addToCart({'id': id});
  }

  // 4. TOMBOL KURANG QUANTITY VIA API
  Future<void> decrementQty(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/cart/reduce'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'item_id': id}),
      );

      if (response.statusCode == 200) {
        await fetchCart(); // Sinkronkan ulang data dari MySQL
      }
    } catch (e) {
      print("Error decrement: $e");
    }
  }

  bool isInCart(int id) => _cartItems.any((e) => e.id == id);

  // 5. PROSES CHECKOUT (BUY) VIA API
  Future<bool> checkout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/cart/checkout'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        _cartItems.clear();
        await fetchInventory(); // Tarik data inventory terbaru dari MySQL
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print("Error checkout: $e");
      return false;
    }
  }

  void clearAll() {
    _cartItems.clear();
    _inventoryItems.clear();
    notifyListeners();
  }
}
