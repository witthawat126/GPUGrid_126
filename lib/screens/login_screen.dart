import 'package:flutter/material.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'admin@test.com');
  String _selectedRole = 'Admin';

  void _login(String email, String role) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(userEmail: email, userRole: role),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade900, Colors.deepPurple.shade600],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.memory, size: 70, color: Colors.deepPurple),
                    const SizedBox(height: 10),
                    const Text(
                      'GPUGrid',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const Text('Cloud GPU Cluster Allocator', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 25),

                    // ช่องกรอกอีเมล
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email ผู้ใช้งาน',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // เลือก Role
                    DropdownButtonFormField<String>(
                      initialValue: _selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'ระดับสิทธิ์ (Role)',
                        prefixIcon: Icon(Icons.security),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Admin', child: Text('Admin (สิทธิ์เต็ม CRUD)')),
                        DropdownMenuItem(value: 'Operator', child: Text('Operator (ดูและสร้างเท่านั้น)')),
                      ],
                      onChanged: (v) => setState(() => _selectedRole = v!),
                    ),
                    const SizedBox(height: 20),

                    // ปุ่มเข้าสู่ระบบ
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _login(_emailController.text.trim(), _selectedRole),
                        child: const Text('เข้าสู่ระบบ (Sign In)', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const Text('⚡ ปุ่มลัดสำหรับอาจารย์ทดสอบ (Quick Test)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 10),

                    // ปุ่มลัด Admin
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      icon: const Icon(Icons.admin_panel_settings),
                      label: const Text('เข้าสู่ระบบเป็น Admin'),
                      onPressed: () => _login('admin@test.com', 'Admin'),
                    ),
                    const SizedBox(height: 8),

                    // ปุ่มลัด Operator
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.blue),
                      icon: const Icon(Icons.person),
                      label: const Text('เข้าสู่ระบบเป็น Operator'),
                      onPressed: () => _login('operator@test.com', 'Operator'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}