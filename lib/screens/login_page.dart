import 'package:flutter/material.dart';
import '../services/pocketbase_service.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final service = PocketBaseService();

  void login() async {
    bool ok = await service.login(emailController.text, passController.text);
    if (ok) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage(service: service)),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('เข้าสู่ระบบล้มเหลว')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('เข้าสู่ระบบ')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: InputDecoration(labelText: 'อีเมล')),
            TextField(controller: passController, obscureText: true, decoration: InputDecoration(labelText: 'รหัสผ่าน')),
            SizedBox(height: 20),
            ElevatedButton(onPressed: login, child: Text('เข้าสู่ระบบ')),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterPage(service: service)),
                );
              },
              child: Text('สมัครสมาชิก'),
            ),
          ],
        ),
      ),
    );
  }
}
