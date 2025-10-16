import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/product.dart';

const String pocketbaseUrl = 'http://127.0.0.1:8090'; // ถ้าใช้ Emulator ให้ใช้ 10.0.2.2

class PocketBaseService {
  String? token;
  Map<String, dynamic>? userData; // ✅ เก็บข้อมูลผู้ใช้หลังล็อกอิน

  // ------------------- 🔐 LOGIN -------------------
  Future<bool> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$pocketbaseUrl/api/collections/users/auth-with-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identity': email, 'password': password}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      token = data['token'];
      userData = data['record'];
      return true;
    }
    return false;
  }

  // ------------------- 🧾 REGISTER -------------------
  Future<bool> register(String email, String password, String name) async {
    final res = await http.post(
      Uri.parse('$pocketbaseUrl/api/collections/users/records'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'passwordConfirm': password,
        'name': name,
      }),
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }

  // ------------------- 📦 GET PRODUCTS -------------------
  Future<List<Product>> getProducts() async {
    final res = await http.get(
      Uri.parse('$pocketbaseUrl/api/collections/products/records'),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body)['items'] as List;
      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('โหลดสินค้าล้มเหลว (${res.statusCode})');
    }
  }

  // ------------------- ➕ ADD PRODUCT (NO IMAGE) -------------------
  Future<void> addProduct(Map<String, dynamic> product) async {
    final res = await http.post(
      Uri.parse('$pocketbaseUrl/api/collections/products/records'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('เพิ่มสินค้าไม่สำเร็จ: ${res.statusCode}');
    }
  }

  // ------------------- 🖼️ ADD PRODUCT WITH IMAGE -------------------
  Future<void> addProductWithImage(
      Map<String, dynamic> product, dynamic imageFile) async {
    final uri = Uri.parse('$pocketbaseUrl/api/collections/products/records');
    final request = http.MultipartRequest('POST', uri);

    // ✅ เพิ่มฟิลด์ข้อมูลสินค้า
    product.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    // ✅ ตรวจว่าเป็น Web หรือไม่
    if (imageFile != null) {
      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: imageFile.name,
          contentType: MediaType('image', 'jpeg'),
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ));
      }
    }

    final res = await request.send();
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('อัปโหลดสินค้าพร้อมรูปไม่สำเร็จ: ${res.statusCode}');
    }
  }

  // ------------------- ✏️ UPDATE PRODUCT -------------------
  Future<void> updateProduct(String id, Map<String, dynamic> product,
      {dynamic imageFile}) async {
    final uri =
        Uri.parse('$pocketbaseUrl/api/collections/products/records/$id');

    if (imageFile != null) {
      // ✅ PATCH พร้อมรูปภาพ
      final request = http.MultipartRequest('PATCH', uri);
      product.forEach((k, v) => request.fields[k] = v.toString());

      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: imageFile.name,
          contentType: MediaType('image', 'jpeg'),
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ));
      }

      final res = await request.send();
      if (res.statusCode != 200) {
        throw Exception('อัปเดตรูปสินค้าไม่สำเร็จ: ${res.statusCode}');
      }
    } else {
      // ✅ PATCH ข้อมูลธรรมดา
      final res = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product),
      );
      if (res.statusCode != 200) {
        throw Exception('อัปเดตสินค้าไม่สำเร็จ: ${res.statusCode}');
      }
    }
  }

  // ------------------- ❌ DELETE PRODUCT -------------------
  Future<void> deleteProduct(String id) async {
    final res = await http.delete(
      Uri.parse('$pocketbaseUrl/api/collections/products/records/$id'),
    );
    if (res.statusCode != 204) {
      throw Exception('ลบสินค้าไม่สำเร็จ: ${res.statusCode}');
    }
  }
}
