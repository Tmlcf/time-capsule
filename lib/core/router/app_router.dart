import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:time_capsule/pages/login_page.dart';
import 'package:time_capsule/pages/register_page.dart';
import 'package:time_capsule/pages/home_page.dart';
import 'package:time_capsule/pages/create_page.dart';
import 'package:time_capsule/pages/map_page.dart';
import 'package:time_capsule/pages/capsules_page.dart';
import 'package:time_capsule/pages/profile_page.dart';
import 'package:time_capsule/pages/settings_page.dart';
import 'package:time_capsule/pages/capsule_detail_page.dart';
import 'package:time_capsule/models/capsule.dart';
import 'package:time_capsule/widgets/scaffold_with_nav_bar.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

// ============================================================
// GoRouterRefreshStream — แจ้ง go_router ให้ตรวจ redirect ใหม่
// ทุกครั้งที่ auth state เปลี่ยน (login/logout)
// ============================================================
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',

  // ============================================================
  // refreshListenable — บอก go_router ให้ตรวจ redirect ใหม่
  // เมื่อมีการ login หรือ logout
  // ============================================================
  refreshListenable: _GoRouterRefreshStream(
    Supabase.instance.client.auth.onAuthStateChange,
  ),

  // ============================================================
  // Redirect Guard — ตรวจสอบ auth ก่อนเข้าทุก route
  // ============================================================
  redirect: (context, state) {
    final user = Supabase.instance.client.auth.currentUser;
    final isLoggedIn = user != null;
    final location = state.matchedLocation;

    // หน้าที่ไม่ต้อง login
    final isAuthPage =
        location == '/login' || location == '/register';

    // ถ้ายังไม่ได้ login และพยายามเข้าหน้าที่ต้อง login → ไปหน้า login
    if (!isLoggedIn && !isAuthPage) {
      return '/login';
    }

    // ถ้า login อยู่แล้วและพยายามเข้าหน้า login/register → ไปหน้า home
    if (isLoggedIn && isAuthPage) {
      return '/home';
    }

    return null; // ไม่ redirect
  },

  routes: [
    // ============ Auth Routes (ไม่มี Bottom Nav) ============
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),

    // Settings อยู่นอก StatefulShellRoute (ไม่มี bottom nav)
    GoRoute(
      path: '/settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SettingsPage(),
    ),

    // ============ Main App Routes (มี Bottom Nav) ============
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/map',
              builder: (context, state) => const MapPage(),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/create',
              builder: (context, state) => const CreatePage(),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/capsules',
              builder: (context, state) => const CapsulesPage(),
              routes: [
                GoRoute(
                  path: 'detail',
                  builder: (context, state) {
                    final capsule = state.extra as Capsule;
                    return CapsuleDetailPage(capsule: capsule);
                  },
                ),
              ],
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
