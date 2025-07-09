import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/presentation/profile_screen.dart';
import '../../content_seen/presentation/content_seen_screen.dart';
import '../../recommendations/presentation/recommendations_screen.dart';
import '../../friends/presentation/friends_screen.dart';

final homeIndexProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(homeIndexProvider);

    final screens = [
      const ProfileScreen(),
      const ContentSeenScreen(),
      const RecommendationsScreen(),
      const FriendsScreen(),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple, Colors.purple],
          ),
        ),
        child: SafeArea(child: screens[index]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => ref.read(homeIndexProvider.notifier).state = i,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.white,
        iconSize: 28,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil', backgroundColor: Color.fromARGB(255, 174, 148, 210)),
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Visto'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Recomendados'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Amigos'),
        ],
      ),
    );
  }
}