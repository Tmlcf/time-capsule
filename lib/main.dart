import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:time_capsule/core/router/app_router.dart';
import 'package:time_capsule/core/theme/app_theme.dart';
import 'package:time_capsule/providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? 'https://placeholder.supabase.co',
    // ignore: deprecated_member_use
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? 'placeholder_key',
  );

  runApp(const ProviderScope(child: TimeCapsuleApp()));
}

class TimeCapsuleApp extends ConsumerWidget {
  const TimeCapsuleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // อ่าน themeMode จาก provider เพื่อให้ Settings page เปลี่ยน dark mode ได้จริง
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'Time Capsule',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
