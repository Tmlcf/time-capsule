import 'package:flutter/material.dart';
import 'package:time_capsule/services/capsule_service.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  final CapsuleService _capsuleService = CapsuleService();

  DateTime? _openDate;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _openDate = picked;
      });
    }
  }

  Future<void> _createCapsule() async {
    if (_titleController.text.trim().isEmpty ||
        _messageController.text.trim().isEmpty ||
        _openDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบ')));
      return;
    }

    try {
      await _capsuleService.createCapsule(
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
        openDate: _openDate!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('สร้าง Time Capsule สำเร็จ 🎉')),
      );

      _titleController.clear();
      _messageController.clear();

      setState(() {
        _openDate = null;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Capsule',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'สร้าง Time Capsule ⏳',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              'เขียนบางอย่างที่คุณอยากส่งไปยังอนาคต',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
            ),

            const SizedBox(height: 28),

            const Text(
              'ชื่อ Capsule',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'เช่น ถึงฉันในอีก 1 ปี',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'ข้อความ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _messageController,
              maxLines: 7,
              decoration: InputDecoration(
                hintText: 'เขียนข้อความถึงตัวคุณในอนาคต...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'วันที่เปิด Capsule',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined),
                    const SizedBox(width: 12),
                    Text(
                      _openDate == null
                          ? 'เลือกวันที่ต้องการเปิด'
                          : '${_openDate!.day}/${_openDate!.month}/${_openDate!.year}',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _createCapsule,
                icon: const Icon(Icons.lock_outline),
                label: const Text(
                  'Create Time Capsule',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
