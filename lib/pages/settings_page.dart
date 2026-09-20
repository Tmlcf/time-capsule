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
  // toggle states (UI only สำหรับ notification/privacy — ยังไม่ต่อ backend)
  bool _notificationsEnabled = true;
  bool _privateProfile = false;

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ออกจากระบบ'),
        content: const Text('คุณต้องการออกจากระบบใช่ไหม?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ออกจากระบบ',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();
      if (mounted) context.go('/login');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ออกจากระบบไม่สำเร็จ: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // อ่านค่า themeMode จาก provider
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ตั้งค่า'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          // ============ หมวด: การแสดงผล ============
          _SectionHeader(title: 'การแสดงผล'),

          SwitchListTile(
            secondary: Icon(
              isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              color: colorScheme.primary,
            ),
            title: const Text('โหมดกลางคืน (Dark Mode)'),
            subtitle: Text(isDark ? 'เปิดอยู่' : 'ปิดอยู่'),
            value: isDark,
            onChanged: (val) {
              if (val) {
                ref.read(themeModeProvider.notifier).setDark();
              } else {
                ref.read(themeModeProvider.notifier).setLight();
              }
            },
          ),

          const Divider(height: 1),

          // ============ หมวด: การแจ้งเตือน ============
          _SectionHeader(title: 'การแจ้งเตือน'),

          SwitchListTile(
            secondary: Icon(Icons.notifications_outlined,
                color: colorScheme.primary),
            title: const Text('รับการแจ้งเตือน'),
            subtitle: Text(_notificationsEnabled ? 'เปิดอยู่' : 'ปิดอยู่'),
            value: _notificationsEnabled,
            onChanged: (val) {
              setState(() => _notificationsEnabled = val);
              // TODO: เชื่อมต่อ backend ตอน Person 4 ทำ Notification
            },
          ),

          const Divider(height: 1),

          // ============ หมวด: ความเป็นส่วนตัว ============
          _SectionHeader(title: 'ความเป็นส่วนตัว'),

          SwitchListTile(
            secondary:
                Icon(Icons.lock_outline, color: colorScheme.primary),
            title: const Text('โปรไฟล์ส่วนตัว'),
            subtitle: const Text('ซ่อนโปรไฟล์จากผู้ใช้อื่น'),
            value: _privateProfile,
            onChanged: (val) {
              setState(() => _privateProfile = val);
              // TODO: เชื่อมต่อ backend ตอน Person 4 ทำ Friend Capsule
            },
          ),

          const Divider(height: 1),

          // ============ หมวด: บัญชี ============
          _SectionHeader(title: 'บัญชี'),

          ListTile(
            leading: Icon(Icons.person_outline, color: colorScheme.primary),
            title: const Text('ดูโปรไฟล์'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              context.pop(); // กลับ Profile page
            },
          ),

          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('ออกจากระบบ',
                style: TextStyle(color: Colors.red)),
            onTap: _logout,
          ),

          const Divider(height: 1),

          // ============ App Version ============
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Time Capsule v1.0.0',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'สร้างด้วย ❤️ โดย Group Project',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ============ Widget ย่อย: หัวข้อหมวด ============
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
