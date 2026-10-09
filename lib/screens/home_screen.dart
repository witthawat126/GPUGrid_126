import 'package:flutter/material.dart';
import 'form_tab.dart';
import 'display_tab.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userEmail;
  final String userRole;

  const HomeScreen({
    super.key,
    required this.userEmail,
    required this.userRole,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String currentEmail;
  late String currentRole;

  @override
  void initState() {
    super.initState();
    currentEmail = widget.userEmail;
    currentRole = widget.userRole;
  }

  void _signOut() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('GPUGrid 🚀', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            Chip(
              backgroundColor: currentRole == 'Admin' ? Colors.red.shade100 : Colors.blue.shade100,
              label: Text(
                currentRole,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: currentRole == 'Admin' ? Colors.red.shade900 : Colors.blue.shade900,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sign Out',
              onPressed: _signOut,
            ),
          ],
        ),
        body: TabBarView(
          children: [
            const FormTab(),
            DisplayTab(currentRole: currentRole),
          ],
        ),
        bottomNavigationBar: const Material(
          color: Colors.deepPurple,
          child: TabBar(
            indicatorColor: Colors.amber,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.add_task), text: 'ยื่นคำขอจอง'),
              Tab(icon: Icon(Icons.monitor_heart), text: 'จอมอนิเตอร์คิวงาน'),
            ],
          ),
        ),
      ),
    );
  }
}