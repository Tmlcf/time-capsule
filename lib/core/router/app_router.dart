import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:time_capsule/pages/splash_page.dart';
import 'package:time_capsule/pages/login_page.dart';
import 'package:time_capsule/pages/register_page.dart';
import 'package:time_capsule/pages/home_page.dart';
import 'package:time_capsule/pages/map_page.dart';
import 'package:time_capsule/pages/create_page.dart';
import 'package:time_capsule/pages/capsules_page.dart';
import 'package:time_capsule/pages/profile_page.dart';
import 'package:time_capsule/pages/capsule_detail_page.dart';
import 'package:time_capsule/pages/create_time_capsule_page.dart';
import 'package:time_capsule/pages/create_location_capsule_page.dart';
import 'package:time_capsule/pages/create_friend_capsule_page.dart';
import 'package:time_capsule/pages/create_ai_memory_page.dart';
import 'package:time_capsule/pages/notification_page.dart';
import 'package:time_capsule/widgets/scaffold_with_nav_bar.dart';

// ── Auth stream listener (triggers router refresh on auth change) ──────────────
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

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  refreshListenable: _GoRouterRefreshStream(
    Supabase.instance.client.auth.onAuthStateChange,
  ),
  redirect: (context, state) {
    final isLoggedIn = Supabase.instance.client.auth.currentUser != null;
    final location = state.matchedLocation;

    // Allow splash to always render first
    if (location == '/splash') return null;

    final authPages = {'/login', '/register'};
    final isAuthPage = authPages.contains(location);

    if (!isLoggedIn && !isAuthPage) return '/login';
    if (isLoggedIn && isAuthPage) return '/home';

    return null;
  },
  routes: [
    // ── Auth & Splash ──────────────────────────────────────────────────────
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),

    // ── Detail / Sub-pages ─────────────────────────────────────────────────
    GoRoute(
      path: '/capsule/:id',
      builder: (context, state) =>
          CapsuleDetailPage(capsuleId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/create/time',
      builder: (context, state) => const CreateTimeCapsulePage(),
    ),
    GoRoute(
      path: '/create/location',
      builder: (context, state) => const CreateLocationCapsulePage(),
    ),
    GoRoute(
      path: '/create/friend',
      builder: (context, state) => const CreateFriendCapsulePage(),
    ),
    GoRoute(
      path: '/create/ai',
      builder: (context, state) => const CreateAiMemoryPage(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationPage(),
    ),

    // ── Main Shell with Bottom Nav ─────────────────────────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomePage()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/map', builder: (context, state) => const MapPage()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/create', builder: (context, state) => const CreatePage()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/capsules',
            builder: (context, state) => const CapsulesPage(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ]),
      ],
    ),
  ],
);
