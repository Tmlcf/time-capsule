import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';

class MoodSelector extends StatelessWidget {
  final String? selectedMood;
  final ValueChanged<String?> onMoodSelected;

  const MoodSelector({
    super.key,
    this.selectedMood,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'อารมณ์ตอนนี้',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.textDark : AppTheme.textLight,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            // "None" option
            _MoodChip(
              emoji: '✨',
              label: 'ไม่ระบุ',
              isSelected: selectedMood == null,
              onTap: () => onMoodSelected(null),
            ),
            ...AppConstants.moods.map(
              (mood) => _MoodChip(
                emoji: mood['emoji']!,
                label: mood['label']!,
                isSelected: selectedMood == mood['emoji'],
                onTap: () => onMoodSelected(
                  selectedMood == mood['emoji'] ? null : mood['emoji'],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MoodChip extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodChip({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.purple.withValues(alpha: 0.3)
              : isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.indigo.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? AppTheme.purple
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppTheme.purpleLight
                    : isDark
                        ? AppTheme.textMutedDark
                        : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
