import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/date_utils.dart';

class CountdownWidget extends StatefulWidget {
  final DateTime openDate;
  final bool compact;

  const CountdownWidget({
    super.key,
    required this.openDate,
    this.compact = false,
  });

  @override
  State<CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget> {
  late Timer _timer;
  late Map<String, int> _parts;

  @override
  void initState() {
    super.initState();
    _parts = AppDateUtils.getCountdownParts(widget.openDate);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _parts = AppDateUtils.getCountdownParts(widget.openDate);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = AppDateUtils.isUnlocked(widget.openDate);

    if (unlocked) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_open_rounded, color: AppTheme.gold, size: 20),
          const SizedBox(width: 8),
          Text(
            'เปิดได้แล้ว!',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.gold,
            ),
          ),
        ],
      );
    }

    if (widget.compact) {
      return Text(
        AppDateUtils.getCountdown(widget.openDate),
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTheme.purpleLight,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _TimeUnit(value: _parts['days']!, label: 'วัน'),
        _Separator(),
        _TimeUnit(value: _parts['hours']!, label: 'ชม.'),
        _Separator(),
        _TimeUnit(value: _parts['minutes']!, label: 'นาที'),
        _Separator(),
        _TimeUnit(value: _parts['seconds']!, label: 'วิ'),
      ],
    );
  }
}

class _TimeUnit extends StatelessWidget {
  final int value;
  final String label;

  const _TimeUnit({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.indigo.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value.toString().padLeft(2, '0'),
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppTheme.purpleLight,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: isDark ? AppTheme.textMutedDark : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        ':',
        style: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: AppTheme.purple.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
