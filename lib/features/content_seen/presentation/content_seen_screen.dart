import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_movie_tracker/features/content_seen/presentation/add_movie_bottom_sheet.dart';
import 'package:my_movie_tracker/features/content_seen/application/movies_provider.dart' as movies_provider;

import '../../../core/db/local_db.dart';
import '../domain/movie_model.dart';
import 'content_seen_screen.dart';
import 'package:my_movie_tracker/features/profile/application/current_user_provider.dart';

class ContentSeenScreen extends ConsumerWidget {
  const ContentSeenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return currentUserAsync.when(
      data: (user) {
        if (user == null) {
          return Scaffold(
            body: Center(child: Text("No hay sesión activa.")),
          );
        }
        final moviesAsync = ref.watch(movies_provider.moviesProvider(user.id));

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Contenido Visto",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.deepPurple,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF7B1FA2),
                  Color(0xFF512DA8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: moviesAsync.when(
                    data: (movies) => ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: movies.length,
                      itemBuilder: (context, index) {
                        final movie = movies[index];
                        return ListTile(
                          leading: movie.posterPath != null
                              ? Image.network(movie.posterPath!, width: 50)
                              : const Icon(Icons.movie),
                          title: Text(
                            movie.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "${movie.year} - ${movie.status}",
                            style: TextStyle(color: Colors.grey[800]),
                          ),
                          onTap: () {
                            // TODO: mostrar detalles
                          },
                        );
                      },
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text("Error: $e")),
                  ),
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.deepPurple,
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (ctx) => const AddMovieBottomSheet(),
              );
              ref.invalidate(movies_provider.moviesProvider(user.id));
            },
            child: const Icon(
              Icons.add,
              size: 32,
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text("Error: $e")),
      ),
    );
  }
}