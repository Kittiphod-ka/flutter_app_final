import 'package:flutter/material.dart';
import '../services/pocketbase_service.dart';
import '../models/product.dart';
import 'add_product.dart';
import 'product_list.dart';

class HomePage extends StatefulWidget {
  final PocketBaseService service;
  const HomePage({super.key, required this.service});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<Product> products = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final list = await widget.service.getProducts();
    if (!mounted) return;
    setState(() {
      products = list;
      loading = false;
    });
  }

  void _showProductPopup(Product product) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(16), // ✅ ขอบรอบ ๆ
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (product.image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      product.image!,
                      height: 250, // ✅ ขยายขนาดรูป
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  const Icon(Icons.image_not_supported,
                      size: 120, color: Colors.grey),
                const SizedBox(height: 20),
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "หมวดหมู่: ${product.category}",
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  "ราคา: ${product.price} บาท",
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  "จำนวน: ${product.quantity} ชิ้น",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.close),
                  label: const Text("ปิด"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    final username = widget.service.userData?['name'] ?? 'ผู้ใช้';
    return Scaffold(
      appBar: AppBar(
        title: const Text('หน้าหลัก'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductListPage(service: widget.service),
                ),
              );
              _loadProducts();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddProductPage(service: widget.service),
            ),
          );
          if (result == true) _loadProducts();
        },
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  Text('สวัสดี คุณ $username 👋',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('สินค้าแนะนำ',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  if (products.isEmpty)
                    const Text('ยังไม่มีสินค้า'),
                  ...products.take(3).map(
                    (p) => Card(
                      child: ListTile(
                        leading: p.image != null
                            ? Image.network(p.image!,
                                width: 60, height: 60, fit: BoxFit.cover)
                            : const Icon(Icons.image_not_supported,
                                size: 50, color: Colors.grey),
                        title: Text(p.name),
                        subtitle: Text('ราคา: ${p.price} บาท • ${p.quantity} ชิ้น'),
                        onTap: () => _showProductPopup(p), // ✅ คลิกแล้วโชว์ popup
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
