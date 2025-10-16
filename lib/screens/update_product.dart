import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';
import '../services/pocketbase_service.dart';

class UpdateProductPage extends StatefulWidget {
  final PocketBaseService service;
  final Product product;

  const UpdateProductPage({super.key, required this.service, required this.product});

  @override
  State<UpdateProductPage> createState() => _UpdateProductPageState();
}

class _UpdateProductPageState extends State<UpdateProductPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController quantityController;
  String category = '';
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

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.product.name);
    priceController = TextEditingController(text: widget.product.price.toString());
    quantityController = TextEditingController(text: widget.product.quantity.toString());
    category = widget.product.category;
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => pickedImage = picked);
  }

  Future<void> updateProduct() async {
    if (_formKey.currentState!.validate()) {
      await widget.service.updateProduct(
        widget.product.id,
        {
          'name': nameController.text,
          'category': category,
          'price': double.tryParse(priceController.text) ?? 0,
          'quantity': int.tryParse(quantityController.text) ?? 0,
        },
        imageFile: pickedImage,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('แก้ไขสินค้า')),
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
                  child: pickedImage != null
                      ? (kIsWeb
                          ? Image.network(pickedImage!.path, fit: BoxFit.cover)
                          : Image.file(File(pickedImage!.path), fit: BoxFit.cover))
                      : (widget.product.image != null
                          ? Image.network(widget.product.image!, fit: BoxFit.cover)
                          : const Icon(Icons.image_not_supported, size: 50, color: Colors.grey)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'ชื่อสินค้า'),
                validator: (v) => v!.isEmpty ? 'กรอกชื่อสินค้า' : null,
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
                onChanged: (v) => setState(() => category = v!),
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'ราคา'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'กรอกราคา' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'จำนวนสินค้า'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'กรอกจำนวน' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('บันทึกการแก้ไข'),
                onPressed: updateProduct,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
