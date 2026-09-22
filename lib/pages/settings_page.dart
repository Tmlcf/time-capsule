import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:time_capsule/providers/auth_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _privateProfile = false;

  static const Color _background = Color(0xFF0B0B1E);
  static const Color _surface = Color(0xFF15152B);
  static const Color _purple = Color(0xFF651FFF);
  static const Color _purpleLight = Color(0xFF9D7CFF);
  static const Color _textPrimary = Colors.white;
  static const Color _textSecondary = Color(0xFFA8A7C0);

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'ออกจากระบบ',
          style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'คุณต้องการออกจากระบบใช่ไหม?',
          style: TextStyle(color: _textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'ยกเลิก',
              style: TextStyle(color: _textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB3263E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'ออกจากระบบ',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();

      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ออกจากระบบไม่สำเร็จ: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),

          // Display
          const _SectionHeader(
            title: 'การแสดงผล',
            icon: Icons.palette_outlined,
          ),
          const SizedBox(height: 10),
          _SettingsCard(
            children: [
              _SettingSwitchTile(
                icon: isDark
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
                title: 'โหมดกลางคืน',
                subtitle: isDark ? 'เปิดใช้งานอยู่' : 'ปิดใช้งานอยู่',
                value: isDark,
                onChanged: (value) {
                  if (value) {
                    ref.read(themeModeProvider.notifier).setDark();
                  } else {
                    ref.read(themeModeProvider.notifier).setLight();
                  }
                },
              ),
            ],
          ),

          // Notifications
          const _SectionHeader(
            title: 'การแจ้งเตือน',
            icon: Icons.notifications_none_rounded,
          ),
          const SizedBox(height: 10),
          _SettingsCard(
            children: [
              _SettingSwitchTile(
                icon: Icons.notifications_none_rounded,
                title: 'รับการแจ้งเตือน',
                subtitle: _notificationsEnabled
                    ? 'เปิดใช้งานอยู่'
                    : 'ปิดใช้งานอยู่',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });

                  // TODO: เชื่อมต่อ backend ตอน Person 4 ทำ Notification
                },
              ),
            ],
          ),

          // Privacy
          const _SectionHeader(
            title: 'ความเป็นส่วนตัว',
            icon: Icons.shield_outlined,
          ),
          const SizedBox(height: 10),
          _SettingsCard(
            children: [
              _SettingSwitchTile(
                icon: Icons.lock_outline_rounded,
                title: 'โปรไฟล์ส่วนตัว',
                subtitle: 'ซ่อนโปรไฟล์จากผู้ใช้อื่น',
                value: _privateProfile,
                onChanged: (value) {
                  setState(() {
                    _privateProfile = value;
                  });

                  // TODO: เชื่อมต่อ backend ตอน Person 4 ทำ Friend Capsule
                },
              ),
            ],
          ),

          // Account
          const _SectionHeader(
            title: 'บัญชี',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 10),
          _SettingsCard(
            children: [
              _SettingActionTile(
                icon: Icons.person_outline_rounded,
                title: 'ดูโปรไฟล์',
                subtitle: 'ดูข้อมูลบัญชีของคุณ',
                onTap: () => context.pop(),
              ),
              const _SettingsDivider(),
              _SettingActionTile(
                icon: Icons.logout_rounded,
                title: 'ออกจากระบบ',
                subtitle: 'ออกจากบัญชี Time Capsule',
                iconColor: Color(0xFFFF5C70),
                titleColor: Color(0xFFFF6B7D),
                onTap: _logout,
              ),
            ],
          ),

          const SizedBox(height: 36),

          // App info
          _buildAppInfo(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF20104A), Color(0xFF15152B)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _purple.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: _purple.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.settings_rounded,
              color: _purpleLight,
              size: 28,
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ปรับแต่งแอปของคุณ',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'จัดการการแสดงผล การแจ้งเตือน และบัญชี',
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfo() {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_purple, _purpleLight]),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.hourglass_bottom_rounded,
            color: Colors.white,
            size: 25,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Time Capsule',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Version 1.0.0',
          style: TextStyle(color: _textSecondary, fontSize: 11),
        ),
        const SizedBox(height: 6),
        const Text(
          'สร้างด้วย ❤️ โดย Group Project',
          style: TextStyle(color: Color(0xFF77768F), fontSize: 11),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  static const Color purpleLight = Color(0xFF9D7CFF);
  static const Color textSecondary = Color(0xFFA8A7C0);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 10),
      child: Row(
        children: [
          Icon(icon, size: 17, color: purpleLight),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  static const Color surface = Color(0xFF15152B);
  static const Color purple = Color(0xFF651FFF);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: purple.withValues(alpha: 0.16)),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  static const Color purple = Color(0xFF651FFF);
  static const Color purpleLight = Color(0xFF9D7CFF);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFA8A7C0);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: purple.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, color: purpleLight, size: 21),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Text(
          subtitle,
          style: const TextStyle(color: textSecondary, fontSize: 11),
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeTrackColor: purple,
        activeThumbColor: Colors.white,
      ),
    );
  }
}

class _SettingActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color titleColor;
  final VoidCallback onTap;

  const _SettingActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor = const Color(0xFF9D7CFF),
    this.titleColor = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Icon(icon, color: iconColor, size: 24),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Text(
          subtitle,
          style: const TextStyle(color: Color(0xFFA8A7C0), fontSize: 11),
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        color: Color(0xFF77768F),
        size: 15,
      ),
      onTap: onTap,
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 58),
      child: Divider(height: 1, color: Color(0xFF2A2A45)),
    );
  }
}
