import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gpu_job.dart';

class DisplayTab extends StatelessWidget {
  final String currentRole;

  const DisplayTab({super.key, required this.currentRole});

  bool get isAdmin => currentRole == 'Admin';

  void _confirmDelete(BuildContext context, String docId, String expName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการ Terminate Job'),
        content: Text('คุณต้องการยกเลิกงาน "$expName" ออกจากคลัสเตอร์ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              FirebaseFirestore.instance.collection('gpu_jobs').doc(docId).delete();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('ลบงาน $expName เรียบร้อยแล้ว')),
              );
            },
            child: const Text('Terminate', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editHours(BuildContext context, String docId, int currentHours) {
    final controller = TextEditingController(text: currentHours.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ปรับปรุงชั่วโมงการรัน (Edit)'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Max Compute Hours ใหม่'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              final newHours = int.tryParse(controller.text);
              if (newHours != null) {
                Navigator.pop(ctx);
                FirebaseFirestore.instance.collection('gpu_jobs').doc(docId).update({
                  'maxComputeHours': newHours,
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('อัปเดตชั่วโมงการรันสำเร็จ')),
                );
              }
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('gpu_jobs').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        // --- ส่วนที่ทำเพิ่มพิเศษ: คำนวณโควตา GPU รวมทั้งหมดในคลัสเตอร์ ---
        int totalGpusUsed = 0;
        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final g = data['allocatedGpus'] ?? 0;
          totalGpusUsed += (g is int ? g : int.tryParse(g.toString()) ?? 0);
        }
        const int maxClusterCapacity = 64; // กำหนดคลัสเตอร์มี 64 GPUs
        double usagePercent = (totalGpusUsed / maxClusterCapacity).clamp(0.0, 1.0);
        Color statusColor = usagePercent > 0.85
            ? Colors.red
            : (usagePercent > 0.5 ? Colors.orange : Colors.green);

        return Column(
          children: [
            // การ์ดแสดงผลสรุปโควตาคลัสเตอร์ (จุดเด่นที่ทำเพิ่ม)
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple.shade800, Colors.deepPurple.shade500],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '⚡ Cluster GPU Utilization',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${(usagePercent * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ใช้งานอยู่: $totalGpusUsed / $maxClusterCapacity GPUs (${docs.length} งานที่กำลังรัน)',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: usagePercent,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),

            // รายการงานทั้งหมด
            Expanded(
              child: docs.isEmpty
                  ? const Center(child: Text('ยังไม่มีคิวงานประมวลผล GPU ในระบบ'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final job = GpuJob.fromMap(doc.id, doc.data() as Map<String, dynamic>);

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              radius: 26,
                              child: FittedBox(
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text('${job.allocatedGpus} GPU', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                            title: Text(job.experimentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Framework: ${job.framework}\nชั่วโมงรัน: ${job.maxComputeHours} ชม. | โดย: ${job.researcherEmail}'),
                            trailing: isAdmin
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _editHours(context, job.id!, job.maxComputeHours),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _confirmDelete(context, job.id!, job.experimentName),
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}