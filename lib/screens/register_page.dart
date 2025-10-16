import 'package:flutter/material.dart';
import '../services/pocketbase_service.dart';

class RegisterPage extends StatefulWidget {
  final PocketBaseService service;
  const RegisterPage({required this.service});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  void register() async {
    bool ok = await widget.service.register(
      _emailCtrl.text,
      _passCtrl.text,
      _nameCtrl.text,
    );
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('สมัครสมาชิกสำเร็จ')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('สมัครไม่สำเร็จ')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('สมัครสมาชิก')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _nameCtrl, decoration: InputDecoration(labelText: 'ชื่อ')),
            TextField(controller: _emailCtrl, decoration: InputDecoration(labelText: 'อีเมล')),
            TextField(controller: _passCtrl, obscureText: true, decoration: InputDecoration(labelText: 'รหัสผ่าน')),
            SizedBox(height: 20),
            ElevatedButton(onPressed: register, child: Text('สมัครสมาชิก')),
          ],
        ),
      ),
    );
  }
}
