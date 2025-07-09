import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_movie_tracker/features/auth/presentation/auth_controller.dart';

import '../application/profile_provider.dart' as profile;

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profile.profileProvider);

    return profileAsync.when(
      data: (profile) => SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: profile.fotoUrl != null
                        ? NetworkImage(profile.fotoUrl!)
                        : null,
                    child: profile.fotoUrl == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "${profile.nombre} ${profile.apellido}",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(profile.email),
                  const SizedBox(height: 8),
                  Text("Edad: ${profile.edad}"),
                  const SizedBox(height: 32),
                  ElevatedButton(
  onPressed: () {
    ref.read(authControllerProvider.notifier).logout(context);
  },
  child: const Text("Cerrar Sesión"),
),
                ],
              ),
            ),
          ),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text("Error: $error"),
      ),
    );
  }
}