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

  static const Color _background = Color(0xFF0B0B1E);
  static const Color _surface = Color(0xFF15152B);
  static const Color _purple = Color(0xFF651FFF);
  static const Color _purpleLight = Color(0xFF9D7CFF);
  static const Color _textPrimary = Colors.white;
  static const Color _textSecondary = Color(0xFFA8A7C0);

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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _purple,
              onPrimary: Colors.white,
              surface: _surface,
              onSurface: _textPrimary,
            ),
          ),
          child: child!,
        );
      },
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ไม่สามารถเลือกรูปได้: $e')));
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
        const SnackBar(
          content: Text('กรุณากรอกข้อมูลให้ครบ (ชื่อ, ข้อความ, วันที่เปิด)'),
        ),
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

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _textPrimary,
        elevation: 0,
        title: const Text(
          'Create Capsule',
          style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======================================================
            // Header
            // ======================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_purple.withValues(alpha: 0.30), _surface, _surface],
                ),
                border: Border.all(color: _purple.withValues(alpha: 0.25)),
                boxShadow: [
                  BoxShadow(
                    color: _purple.withValues(alpha: 0.10),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Row(
                children: [
                  _HeaderIcon(),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'สร้าง Time Capsule ⏳',
                          style: TextStyle(
                            color: _textPrimary,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          'เขียนบางอย่างที่คุณอยากส่งไปยังอนาคต',
                          style: TextStyle(
                            color: _textSecondary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ======================================================
            // Basic Information
            // ======================================================
            const _SectionTitle(
              icon: Icons.edit_note_rounded,
              title: 'ข้อมูล Capsule',
            ),

            const SizedBox(height: 12),

            _FieldContainer(
              child: TextField(
                controller: _titleController,
                style: const TextStyle(color: _textPrimary),
                decoration: _inputDecoration(
                  hintText: 'เช่น ถึงฉันในอีก 1 ปี',
                  prefixIcon: Icons.title_rounded,
                ),
              ),
            ),

            const SizedBox(height: 14),

            _FieldContainer(
              child: TextField(
                controller: _messageController,
                maxLines: 7,
                style: const TextStyle(color: _textPrimary, height: 1.5),
                decoration: _inputDecoration(
                  hintText: 'เขียนข้อความถึงตัวคุณในอนาคต...',
                  prefixIcon: Icons.message_outlined,
                  alignLabelWithHint: true,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ======================================================
            // Open Date
            // ======================================================
            const _SectionTitle(
              icon: Icons.calendar_month_outlined,
              title: 'วันที่เปิด Capsule',
            ),

            const SizedBox(height: 12),

            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _openDate == null
                        ? Colors.white.withValues(alpha: 0.10)
                        : _purple.withValues(alpha: 0.55),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _purple.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.calendar_today_rounded,
                        color: _purpleLight,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _openDate == null
                                ? 'เลือกวันที่ต้องการเปิด'
                                : 'วันที่เปิด Capsule',
                            style: const TextStyle(
                              color: _textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _openDate == null
                                ? 'แตะเพื่อเลือกวันที่'
                                : '${_openDate!.day.toString().padLeft(2, '0')}/'
                                      '${_openDate!.month.toString().padLeft(2, '0')}/'
                                      '${_openDate!.year}',
                            style: TextStyle(
                              color: _openDate == null
                                  ? _textSecondary
                                  : _textPrimary,
                              fontSize: 15,
                              fontWeight: _openDate == null
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: _textSecondary,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ======================================================
            // Friend Capsule
            // ======================================================
            const _SectionTitle(
              icon: Icons.people_outline_rounded,
              title: 'Friend Capsule',
              optional: true,
            ),

            const SizedBox(height: 8),

            const Text(
              'กรอก email ของเพื่อนเพื่อส่ง Capsule ให้โดยตรง',
              style: TextStyle(color: _textSecondary, fontSize: 13),
            ),

            const SizedBox(height: 12),

            _FieldContainer(
              child: TextField(
                controller: _recipientController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: _textPrimary),
                decoration: _inputDecoration(
                  hintText: 'friend@example.com',
                  prefixIcon: Icons.person_outline_rounded,
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _recipientController,
                    builder: (context, value, child) {
                      if (value.text.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          size: 18,
                          color: _textSecondary,
                        ),
                        onPressed: () => _recipientController.clear(),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ======================================================
            // Mood
            // ======================================================
            const _SectionTitle(
              icon: Icons.mood_outlined,
              title: 'Mood / อารมณ์ความรู้สึก',
              optional: true,
            ),

            const SizedBox(height: 8),

            const Text(
              'เลือกอารมณ์ของคุณในขณะบันทึกความทรงจำนี้',
              style: TextStyle(color: _textSecondary, fontSize: 13),
            ),

            const SizedBox(height: 12),

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
                  selectedColor: _purple.withValues(alpha: 0.22),
                  backgroundColor: _surface,
                  side: BorderSide(
                    color: isSelected
                        ? _purple
                        : Colors.white.withValues(alpha: 0.10),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  labelStyle: TextStyle(
                    color: isSelected ? _purpleLight : _textSecondary,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  checkmarkColor: _purpleLight,
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // ======================================================
            // Image
            // ======================================================
            const _SectionTitle(
              icon: Icons.image_outlined,
              title: 'รูปภาพแนบ',
              optional: true,
            ),

            const SizedBox(height: 8),

            const Text(
              'แนบรูปถ่ายแห่งความทรงจำที่จะเปิดดูในอนาคต',
              style: TextStyle(color: _textSecondary, fontSize: 13),
            ),

            const SizedBox(height: 12),

            if (_selectedImageBytes == null)
              InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 30,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _purple.withValues(alpha: 0.25)),
                  ),
                  child: const Column(
                    children: [
                      _ImageUploadIcon(),
                      SizedBox(height: 12),
                      Text(
                        'แตะเพื่อเลือกรูปภาพจากเครื่อง',
                        style: TextStyle(
                          color: _purpleLight,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'รองรับไฟล์ JPG, PNG, WEBP',
                        style: TextStyle(color: _textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            else
              _ImagePreview(
                imageBytes: _selectedImageBytes!,
                imageName: _selectedImageName,
                onRemove: _removeImage,
              ),

            const SizedBox(height: 30),

            // ======================================================
            // Create Button
            // ======================================================
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _createCapsule,
                icon: _isLoading
                    ? const SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.lock_outline_rounded),
                label: Text(
                  _isLoading
                      ? 'กำลังบันทึกและอัปโหลด...'
                      : 'Create Time Capsule',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _purple.withValues(alpha: 0.35),
                  disabledForegroundColor: Colors.white54,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: _textSecondary, fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: _purpleLight, size: 21),
      suffixIcon: suffixIcon,
      alignLabelWithHint: alignLabelWithHint,
      filled: true,
      fillColor: _surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _purple, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

// ================================================================
// Header Icon
// ================================================================

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: _CreatePageState._purple.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _CreatePageState._purple.withValues(alpha: 0.25),
        ),
      ),
      child: const Icon(
        Icons.lock_clock_rounded,
        color: _CreatePageState._purpleLight,
        size: 30,
      ),
    );
  }
}

// ================================================================
// Section Title
// ================================================================

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool optional;

  const _SectionTitle({
    required this.icon,
    required this.title,
    this.optional = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _CreatePageState._purple.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _CreatePageState._purpleLight, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: _CreatePageState._textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (optional) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'ไม่บังคับ',
              style: TextStyle(
                color: _CreatePageState._textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ================================================================
// Field Container
// ================================================================

class _FieldContainer extends StatelessWidget {
  final Widget child;

  const _FieldContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ================================================================
// Image Upload Icon
// ================================================================

class _ImageUploadIcon extends StatelessWidget {
  const _ImageUploadIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: _CreatePageState._purple.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.add_photo_alternate_outlined,
        size: 30,
        color: _CreatePageState._purpleLight,
      ),
    );
  }
}

// ================================================================
// Image Preview
// ================================================================

class _ImagePreview extends StatelessWidget {
  final Uint8List imageBytes;
  final String? imageName;
  final VoidCallback onRemove;

  const _ImagePreview({
    required this.imageBytes,
    required this.imageName,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _CreatePageState._surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _CreatePageState._purple.withValues(alpha: 0.25),
        ),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Image.memory(
              imageBytes,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
            ),
          ),

          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.black.withValues(alpha: 0.65),
              shape: const CircleBorder(),
              child: IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                tooltip: 'ลบรูปภาพ',
                onPressed: onRemove,
              ),
            ),
          ),

          if (imageName != null)
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  imageName!,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
