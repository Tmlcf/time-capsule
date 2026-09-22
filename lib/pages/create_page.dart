import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:time_capsule/services/capsule_service.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();

  final CapsuleService _capsuleService = CapsuleService();
  final ImagePicker _picker = ImagePicker();

  DateTime? _openDate;
  String? _selectedMood;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isLoading = false;

  static const List<Map<String, String>> _moodOptions = [
    {'emoji': '😊', 'label': 'Happy'},
    {'emoji': '🥰', 'label': 'Love'},
    {'emoji': '🤩', 'label': 'Excited'},
    {'emoji': '😌', 'label': 'Calm'},
    {'emoji': '😢', 'label': 'Sad'},
    {'emoji': '💪', 'label': 'Motivated'},
    {'emoji': '✨', 'label': 'Hopeful'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _recipientController.dispose();
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
      setState(() => _openDate = picked);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageName = image.name;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถเลือกรูปได้: $e')),
      );
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImageBytes = null;
      _selectedImageName = null;
    });
  }

  bool _isValidEmail(String email) {
    if (email.isEmpty) return true;
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  Future<void> _createCapsule() async {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();
    final recipientEmail = _recipientController.text.trim();

    if (title.isEmpty || message.isEmpty || _openDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบ (ชื่อ, ข้อความ, วันที่เปิด)')),
      );
      return;
    }

    if (!_isValidEmail(recipientEmail)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('รูปแบบ email ผู้รับไม่ถูกต้อง')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _capsuleService.createCapsule(
        title: title,
        message: message,
        openDate: _openDate!,
        recipientEmail: recipientEmail.isEmpty ? null : recipientEmail,
        mood: _selectedMood,
        imageBytes: _selectedImageBytes,
        imageFileName: _selectedImageName,
      );

      if (!mounted) return;

      final msg = recipientEmail.isEmpty
          ? 'สร้าง Time Capsule สำเร็จ 🎉'
          : 'ส่ง Capsule ถึง $recipientEmail สำเร็จ 📦';

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));

      _titleController.clear();
      _messageController.clear();
      _recipientController.clear();
      setState(() {
        _openDate = null;
        _selectedMood = null;
        _selectedImageBytes = null;
        _selectedImageName = null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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

            // 1. Title
            const Text('ชื่อ Capsule',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'เช่น ถึงฉันในอีก 1 ปี',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Message
            const Text('ข้อความ',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 7,
              decoration: InputDecoration(
                hintText: 'เขียนข้อความถึงตัวคุณในอนาคต...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 20),

            // 3. Open date
            const Text('วันที่เปิด Capsule',
                style: TextStyle(fontWeight: FontWeight.bold)),
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
                      style: TextStyle(
                        fontSize: 15,
                        color: _openDate == null
                            ? Colors.grey.shade600
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 4. Recipient (Friend Capsule)
            Row(
              children: [
                const Text('ส่งให้เพื่อน (Friend Capsule)',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'ไม่บังคับ',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'กรอก email ของเพื่อน — ถ้าต้องการส่งให้ตัวเอง ให้เว้นว่างไว้',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _recipientController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'friend@example.com',
                prefixIcon: const Icon(Icons.person_outline),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _recipientController,
                  builder: (context, value, child) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => _recipientController.clear(),
                    );
                  },
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 24),

            // 5. Mood Selector
            Row(
              children: [
                const Text('Mood / อารมณ์ความรู้สึก',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'ไม่บังคับ',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.amber.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'เลือกอารมณ์ของคุณในขณะบันทึกความทรงจำนี้',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _moodOptions.map((mood) {
                final moodValue = '${mood['emoji']} ${mood['label']}';
                final isSelected = _selectedMood == moodValue;
                return ChoiceChip(
                  label: Text(moodValue),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedMood = selected ? moodValue : null;
                    });
                  },
                  selectedColor: theme.colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.grey.shade300,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 6. Image attachment / preview
            Row(
              children: [
                const Text('รูปภาพแนบ (Image Attachment)',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'ไม่บังคับ',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.purple.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'แนบรูปถ่ายแห่งความทรงจำที่จะเปิดดูในอนาคต',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 10),
            if (_selectedImageBytes == null)
              InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade400,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.grey.shade50,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 40,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'แตะเพื่อเลือกรูปภาพจากเครื่อง',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'รองรับไฟล์ JPG, PNG, WEBP',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.memory(
                        _selectedImageBytes!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.black54,
                      shape: const CircleBorder(),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 20),
                        tooltip: 'ลบรูปภาพ',
                        onPressed: _removeImage,
                      ),
                    ),
                  ),
                  if (_selectedImageName != null)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _selectedImageName!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 32),

            // 7. Create button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _createCapsule,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.lock_outline),
                label: Text(
                  _isLoading
                      ? 'กำลังบันทึกและอัปโหลด...'
                      : 'Create Time Capsule',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
