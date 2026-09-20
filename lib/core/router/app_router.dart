import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:time_capsule/pages/login_page.dart';
import 'package:time_capsule/pages/home_page.dart';
import 'package:time_capsule/pages/create_page.dart';
import 'package:time_capsule/pages/map_page.dart';
import 'package:time_capsule/pages/capsules_page.dart';
import 'package:time_capsule/pages/profile_page.dart';
import 'package:time_capsule/widgets/scaffold_with_nav_bar.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),

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
            GoRoute(path: '/map', builder: (context, state) => const MapPage()),
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
