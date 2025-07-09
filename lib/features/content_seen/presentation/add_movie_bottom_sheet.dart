import 'package:my_movie_tracker/features/content_seen/presentation/content_seen_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/api_service.dart';
import '../../../core/db/local_db.dart';
import './../domain/movie_model.dart';

final searchMoviesProvider =
    StateNotifierProvider<SearchMoviesNotifier, AsyncValue<List<MovieApiResult>>>(
  (ref) => SearchMoviesNotifier(ApiService()),
);

final moviesProvider = FutureProvider<List<MovieModel>>((ref) async {
  final db = LocalDbService();
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) {
    return [];
  }
  return await db.getMoviesByUserId(userId);
});

class SearchMoviesNotifier extends StateNotifier<AsyncValue<List<MovieApiResult>>> {
  final ApiService apiService;

  SearchMoviesNotifier(this.apiService) : super(const AsyncData([]));

  Future<void> search(String query) async {
    state = const AsyncLoading();
    try {
      final results = await apiService.searchMovies(query);
      state = AsyncData(results);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

class AddMovieBottomSheet extends ConsumerStatefulWidget {
  const AddMovieBottomSheet({super.key});

  @override
  ConsumerState<AddMovieBottomSheet> createState() =>
      _AddMovieBottomSheetState();
}

class _AddMovieBottomSheetState extends ConsumerState<AddMovieBottomSheet> {
  final TextEditingController searchController = TextEditingController();
  final LocalDbService dbService = LocalDbService();

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchMoviesProvider);

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: "Buscar película",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(searchMoviesProvider.notifier)
                      .search(searchController.text);
                },
                child: const Text("Buscar"),
              ),
              const SizedBox(height: 16),
              searchState.when(
                data: (movies) => ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    return ListTile(
                      leading: movie.posterPath != null
                          ? Image.network(
                              "https://image.tmdb.org/t/p/w92${movie.posterPath}")
                          : const Icon(Icons.movie),
                      title: Text(movie.title),
                      subtitle: Text(movie.releaseDate),
                      onTap: () async {
                        /// Guardamos la película
                        final userId = Supabase.instance.client.auth.currentUser?.id ?? "NO_USER";
                        final newMovie = MovieModel(
                          userId: userId,
                          title: movie.title,
                          year: int.tryParse(
                                  movie.releaseDate.split('-').first) ??
                              0,
                          rating: 0,
                          review: "",
                          status: "Pendiente",
                          posterPath:
                              "https://image.tmdb.org/t/p/w500${movie.posterPath}",
                        );
                        await dbService.insertMovie(newMovie);
                        ref.invalidate(moviesProvider);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text("Error: $e"),
              )
            ],
          ),
        ),
      ),
    );
  }
}