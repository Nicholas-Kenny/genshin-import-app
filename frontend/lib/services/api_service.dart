import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:image_picker/image_picker.dart'; // Untuk tipe XFile
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://localhost:3000/api";

  static Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('role', data['role']);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  static Future<bool> loginWithGoogle(String idToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('role', data['role']);
        return true;
      }
      return false;
    } catch (e) {
      print('Google OAuth error: $e');
      return false;
    }
  }

  static Future<bool> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error saat register: $e');
      return false;
    }
  }

  static Future<List<dynamic>> getItems() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/items'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Gagal memuat data item');
      }
    } catch (e) {
      print('Get item error: $e');
      return [];
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
  }

  static Future<bool> addItem({
    required String name,
    required String type,
    required String category,
    required String description,
    required int stock,
    required int price,
    required int stars,
    XFile? imageFile,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/items'));
      request.headers.addAll({'Authorization': 'Bearer $token'});

      request.fields['name'] = name;
      request.fields['type'] = type;
      request.fields['category'] = category;
      request.fields['description'] = description;
      request.fields['stock'] = stock.toString();
      request.fields['price'] = price.toString();
      request.fields['stars'] = stars.toString();

      if (imageFile != null) {
        if (kIsWeb) {
          final bytes = await imageFile.readAsBytes();
          final mimeType = imageFile.mimeType ?? 'image/jpeg';
          final mimeSplit = mimeType.split('/');
          request.files.add(
            http.MultipartFile.fromBytes(
              'image',
              bytes,
              filename: imageFile.name.isEmpty ? 'upload.jpg' : imageFile.name,
              contentType: MediaType(mimeSplit[0], mimeSplit[1]),
            ),
          );
        } else {
          request.files.add(
            await http.MultipartFile.fromPath('image', imageFile.path),
          );
        }
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return response.statusCode == 201;
    } catch (e) {
      print('Error saat tambah item: $e');
      return false;
    }
  }

  static Future<bool> updateItem({
    required int id,
    required String name,
    required String type,
    required String category,
    required String description,
    required int stock,
    required int price,
    required int stars,
    String? existingImageUrl,
    XFile? newImageFile,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/items/$id'),
      );
      request.headers.addAll({'Authorization': 'Bearer $token'});

      request.fields['name'] = name;
      request.fields['type'] = type;
      request.fields['category'] = category;
      request.fields['description'] = description;
      request.fields['stock'] = stock.toString();
      request.fields['price'] = price.toString();
      request.fields['stars'] = stars.toString();
      if (existingImageUrl != null) {
        request.fields['image_url'] = existingImageUrl;
      }

      if (newImageFile != null) {
        if (kIsWeb) {
          final bytes = await newImageFile.readAsBytes();
          final mimeType = newImageFile.mimeType ?? 'image/jpeg';
          final mimeSplit = mimeType.split('/');
          request.files.add(
            http.MultipartFile.fromBytes(
              'image',
              bytes,
              filename: newImageFile.name.isEmpty
                  ? 'upload.jpg'
                  : newImageFile.name,
              contentType: MediaType(mimeSplit[0], mimeSplit[1]),
            ),
          );
        } else {
          request.files.add(
            await http.MultipartFile.fromPath('image', newImageFile.path),
          );
        }
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return response.statusCode == 200;
    } catch (e) {
      print('Error saat update item: $e');
      return false;
    }
  }
  static Future<bool> deleteItem(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.delete(
        Uri.parse('$baseUrl/items/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error saat hapus item: $e');
      return false;
    }
  }
}
