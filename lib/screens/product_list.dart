import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/pocketbase_service.dart';
import 'update_product.dart';

class ProductListPage extends StatefulWidget {
  final PocketBaseService service;
  const ProductListPage({super.key, required this.service});

  @override
  ProductListPageState createState() => ProductListPageState();
}

class ProductListPageState extends State<ProductListPage> {
  List<Product> products = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final list = await widget.service.getProducts();
    if (!mounted) return;
    setState(() {
      products = list;
      loading = false;
    });
  }

  Future<void> deleteProduct(String id) async {
    await widget.service.deleteProduct(id);
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('รายการสินค้าทั้งหมด')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(child: Text('ยังไม่มีสินค้า'))
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, i) {
                    final p = products[i];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: p.image != null
                            ? Image.network(p.image!,
                                width: 60, height: 60, fit: BoxFit.cover)
                            : const Icon(Icons.image_not_supported,
                                size: 50, color: Colors.grey),
                        title: Text(p.name),
                        subtitle: Text(
                            'หมวดหมู่: ${p.category}\nราคา: ${p.price} บาท • ${p.quantity} ชิ้น'),
                        isThreeLine: true,
                        trailing: Wrap(
                          spacing: 12,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => UpdateProductPage(
                                        service: widget.service, product: p),
                                  ),
                                );
                                if (result == true) load();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteProduct(p.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
