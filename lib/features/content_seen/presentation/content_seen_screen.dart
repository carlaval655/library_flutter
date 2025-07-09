import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_movie_tracker/features/content_seen/presentation/add_movie_bottom_sheet.dart';

import '../../../core/db/local_db.dart';
import '../domain/movie_model.dart';
import 'content_seen_screen.dart';

final moviesProvider =
    FutureProvider<List<MovieModel>>((ref) async {
  final db = LocalDbService();
  return await db.getAllMovies();
});

class ContentSeenScreen extends ConsumerWidget {
  const ContentSeenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moviesAsync = ref.watch(moviesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Contenido Visto")),
      body: SafeArea(
        child: moviesAsync.when(
          data: (movies) => ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return ListTile(
                leading: movie.posterPath != null
                    ? Image.network(movie.posterPath!, width: 50)
                    : const Icon(Icons.movie),
                title: Text(movie.title),
                subtitle: Text("${movie.year} - ${movie.status}"),
                onTap: () {
                  // TODO: mostrar detalles
                },
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text("Error: $e")),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (ctx) => const AddMovieBottomSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}