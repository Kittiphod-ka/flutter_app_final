import 'dart:convert';
import 'dart:io';
import 'package:faker/faker.dart';
import 'package:http/http.dart' as http;

const String pocketbaseUrl = 'http://127.0.0.1:8090';

// ✅ หมวดหมู่พรีเซ็ตให้ตรงกับแอป
final List<String> categories = [
  'อาหาร',
  'เครื่องดื่ม',
  'อุปกรณ์อิเล็กทรอนิกส์',
  'ของใช้ในบ้าน',
  'เสื้อผ้า',
  'ของเล่น',
  'อื่น ๆ',
];

Future<void> generateFakeProducts() async {
  final faker = Faker();

  for (int i = 0; i < 20; i++) {
    try {
      // ✅ สุ่มค่าพื้นฐานสินค้า
      final randomCategory =
          categories[faker.randomGenerator.integer(categories.length - 1)];
      final randomPrice =
          faker.randomGenerator.integer(500, min: 10).toDouble();
      final randomQuantity = faker.randomGenerator.integer(100, min: 1);
      final name = faker.food.dish();

      // ✅ ดาวน์โหลดภาพสุ่มจาก Picsum
      final imageUrl = 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/400';
      final imgResponse = await http.get(Uri.parse(imageUrl));

      if (imgResponse.statusCode != 200) {
        print('⚠️ Failed to fetch random image');
        continue;
      }

      // ✅ เขียนไฟล์ชั่วคราว (จำเป็นสำหรับ multipart)
      final file = File('temp_image_${i + 1}.jpg');
      await file.writeAsBytes(imgResponse.bodyBytes);

      // ✅ สร้าง multipart request เพื่ออัปโหลดพร้อมข้อมูลสินค้า
      final uri = Uri.parse('$pocketbaseUrl/api/collections/products/records');
      final request = http.MultipartRequest('POST', uri)
        ..fields['name'] = name
        ..fields['category'] = randomCategory
        ..fields['price'] = randomPrice.toString()
        ..fields['quantity'] = randomQuantity.toString()
        ..files.add(await http.MultipartFile.fromPath('image', file.path));

      final response = await request.send();
      final resBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final product = jsonDecode(resBody);
        print('✅ Created: ${product["name"]} (${product["id"]})');
      } else {
        print('❌ Error ${response.statusCode}: $resBody');
      }

      // ✅ ลบไฟล์ชั่วคราวหลังอัปโหลดเสร็จ
      await file.delete();
    } catch (e) {
      print('❌ Exception: $e');
    }
  }

  print('🎉 Fake products with images created successfully!');
}

void main() => generateFakeProducts();
