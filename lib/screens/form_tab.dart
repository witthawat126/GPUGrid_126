import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gpu_job.dart';

class FormTab extends StatefulWidget {
  const FormTab({super.key});

  @override
  State<FormTab> createState() => _FormTabState();
}

class _FormTabState extends State<FormTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _gpuController = TextEditingController();
  final _hoursController = TextEditingController();

  String _selectedFramework = 'PyTorch';
  final List<String> _frameworks = ['PyTorch', 'TensorFlow', 'JAX'];
  bool _isLoading = false;

  Future<void> _submitJob() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final job = GpuJob(
          experimentName: _nameController.text.trim(),
          framework: _selectedFramework,
          researcherEmail: _emailController.text.trim(),
          allocatedGpus: int.parse(_gpuController.text.trim()),
          maxComputeHours: int.parse(_hoursController.text.trim()),
        );

        await FirebaseFirestore.instance.collection('gpu_jobs').add(job.toMap()); // FirebaseFirestore

        _nameController.clear();
        _emailController.clear();
        _gpuController.clear();
        _hoursController.clear();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ยื่นคำขอจองคลัสเตอร์ GPU สำเร็จ!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ยื่นคำขอจองโหนดประมวลผล GPU',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // 1. ชื่อโปรเจกต์
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อโปรเจกต์ / การทดลอง (Experiment Name)',
                    hintText: 'เช่น LLM-FineTune-V3',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'กรุณากรอกชื่อโปรเจกต์' : null,
                ),
                const SizedBox(height: 15),

                // 2. ประเภท Framework
                DropdownButtonFormField<String>(
                  initialValue: _selectedFramework,
                  decoration: const InputDecoration(
                    labelText: 'ประเภทโมเดล / Framework',
                    border: OutlineInputBorder(),
                  ),
                  items: _frameworks.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                  onChanged: (v) => setState(() => _selectedFramework = v!),
                ),
                const SizedBox(height: 15),

                // 3. อีเมลนักวิจัย
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'อีเมลนักวิจัยหลัก (Principal Researcher)',
                    hintText: 'name@lab.org',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'กรุณากรอกอีเมล';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                      return 'รูปแบบอีเมลไม่ถูกต้อง';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // 4. จำนวนการ์ด GPU
                TextFormField(
                  controller: _gpuController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'จำนวนการ์ด GPU ที่ขอใช้ (Allocated GPUs)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'กรุณากรอกจำนวนการ์ด';
                    if (int.tryParse(v) == null) return 'ต้องเป็นตัวเลขเท่านั้น';
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // 5. เวลาจำกัดการรัน
                TextFormField(
                  controller: _hoursController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'เวลาจำกัดการรัน (Max Compute Hours)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'กรุณากรอกชั่วโมงรัน';
                    if (int.tryParse(v) == null) return 'ต้องเป็นตัวเลขเท่านั้น';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _submitJob,
                    icon: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.cloud_upload),
                    label: const Text('ส่งคำขอจองทรัพยากร', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}