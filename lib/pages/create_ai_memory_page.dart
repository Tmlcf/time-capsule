import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:time_capsule/core/theme/app_theme.dart';
import 'package:time_capsule/models/capsule.dart';
import 'package:time_capsule/services/capsule_service.dart';

class CreateAiMemoryPage extends StatefulWidget {
  const CreateAiMemoryPage({super.key});

  @override
  State<CreateAiMemoryPage> createState() => _CreateAiMemoryPageState();
}

class _CreateAiMemoryPageState extends State<CreateAiMemoryPage> {
  final _promptController = TextEditingController();
  final _capsuleService = CapsuleService();
  String _selectedMood = 'Inspired';
  bool _isLoading = false;

  final List<String> _moods = [
    'Inspired',
    'Happy',
    'Reflective',
    'Grateful',
    'Dreamer',
  ];

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_promptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your prompt or memory reflection')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _capsuleService.createCapsule(
        title: 'AI Memory - $_selectedMood',
        message: _promptController.text.trim(),
        type: CapsuleType.ai,
        mood: _selectedMood,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI Memory Capsule saved! 🤖')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Memory Capsule')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'AI Memory Capsule 🤖',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Synthesize and organize your thoughts with AI curation',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select Mood / Theme',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: _moods.map((mood) {
                final isSelected = _selectedMood == mood;
                return ChoiceChip(
                  label: Text(mood),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedMood = mood);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _promptController,
              maxLines: 7,
              decoration: InputDecoration(
                labelText: 'Reflections or thoughts',
                hintText: 'What memorable experience or question do you want the AI to remember?',
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Generate & Seal Memory',
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
