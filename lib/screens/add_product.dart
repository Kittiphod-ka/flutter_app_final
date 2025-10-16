import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../services/pocketbase_service.dart';

class AddProductPage extends StatefulWidget {
  final PocketBaseService service;
  const AddProductPage({super.key, required this.service});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String category = '';
  double price = 0;
  int quantity = 0;
  XFile? pickedImage;

  // ✅ พรีเซ็ตหมวดหมู่
  final List<String> categories = [
    'อาหาร',
    'เครื่องดื่ม',
    'อุปกรณ์อิเล็กทรอนิกส์',
    'ของใช้ในบ้าน',
    'เสื้อผ้า',
    'ของเล่น',
    'อื่น ๆ'
  ];

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        pickedImage = picked;
      });
    }
  }

  Future<void> saveProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await widget.service.addProductWithImage({
        'name': name,
        'category': category,
        'price': price,
        'quantity': quantity,
      }, pickedImage);
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เพิ่มสินค้า')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 160,
                  color: Colors.grey[200],
                  child: pickedImage == null
                      ? const Icon(Icons.add_a_photo, size: 50, color: Colors.grey)
                      : (kIsWeb
                          ? Image.network(pickedImage!.path, fit: BoxFit.cover)
                          : Image.file(File(pickedImage!.path), fit: BoxFit.cover)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'ชื่อสินค้า'),
                validator: (v) => v!.isEmpty ? 'กรอกชื่อสินค้า' : null,
                onSaved: (v) => name = v!,
              ),
              const SizedBox(height: 10),

              // ✅ Dropdown หมวดหมู่
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'หมวดหมู่'),
                value: category.isEmpty ? null : category,
                items: categories
                    .map((c) => DropdownMenuItem<String>(
                          value: c,
                          child: Text(c),
                        ))
                    .toList(),
                validator: (v) => v == null || v.isEmpty ? 'เลือกหมวดหมู่' : null,
                onChanged: (v) {
                  setState(() {
                    category = v!;
                  });
                },
              ),
              const SizedBox(height: 10),

              TextFormField(
                decoration: const InputDecoration(labelText: 'ราคา'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty
                    ? 'กรอกราคา'
                    : (double.tryParse(v) == null ? 'กรอกตัวเลข' : null),
                onSaved: (v) => price = double.parse(v!),
              ),
              const SizedBox(height: 10),

              TextFormField(
                decoration: const InputDecoration(labelText: 'จำนวนสินค้า'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty
                    ? 'กรอกจำนวน'
                    : (int.tryParse(v) == null ? 'กรอกเป็นตัวเลข' : null),
                onSaved: (v) => quantity = int.parse(v!),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('บันทึกสินค้า'),
                onPressed: saveProduct,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
