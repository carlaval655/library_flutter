import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/content_seen/presentation/content_seen_screen.dart';
import '../../features/recommendations/presentation/recommendations_screen.dart';
import '../../features/friends/presentation/friends_screen.dart';
// import detail screen later

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: 'content',
            builder: (context, state) => const ContentSeenScreen(),
          ),
          GoRoute(
            path: 'recommendations',
            builder: (context, state) => const RecommendationsScreen(),
          ),
          GoRoute(
            path: 'friends',
            builder: (context, state) => const FriendsScreen(),
          ),
          // GoRoute(
          //   path: 'content/:id',
          //   builder: (context, state) {
          //     final id = state.params['id'];
          //     return DetailScreen(id: id!);
          //   },
          // ),
        ],
      ),
    ],
  );
});