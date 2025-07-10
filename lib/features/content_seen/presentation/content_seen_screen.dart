import 'package:my_movie_tracker/features/recommendations/presentation/recommendations_screen.dart';
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
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE1BEE7), Color(0xFFB39DDB)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: movie.posterPath != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        movie.posterPath!,
                                        width: 60,
                                        height: 90,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(Icons.movie, size: 60, color: Colors.white),
                              title: Text(
                                movie.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.deepPurple[900],
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    "${movie.year} - ${movie.genre ?? "Sin género"}",
                                    style: TextStyle(color: Colors.deepPurple[700]),
                                  ),
                                  if (movie.duration != null)
                                    Text(
                                      "Duración: ${movie.duration} min",
                                      style: TextStyle(color: Colors.deepPurple[700]),
                                    ),
                                  Row(
                                    children: List.generate(5, (index) {
                                      return Icon(
                                        index < movie.rating
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 20,
                                      );
                                    }),
                                  ),
                                  Text(
                                    movie.status,
                                    style: TextStyle(
                                      color: movie.status == "Visto"
                                          ? Colors.green[700]
                                          : (movie.status == "Pendiente"
                                              ? Colors.orange[700]
                                              : Colors.blue[700]),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                  ),
                                  backgroundColor: Colors.white,
                                  builder: (context) {
                                    final reviewController = TextEditingController(text: movie.review);
                                    String selectedStatus = movie.status;
                                    double selectedRating = movie.rating.toDouble();
                                    return StatefulBuilder(
                                      builder: (context, setState) {
                                        return Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Center(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.deepPurple.withOpacity(0.5),
                                                          blurRadius: 10,
                                                          offset: const Offset(0, 5),
                                                        ),
                                                      ],
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(12),
                                                      child: movie.posterPath != null
                                                          ? Image.network(movie.posterPath!, height: 250)
                                                          : const Icon(Icons.movie, size: 150, color: Colors.deepPurple),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                Text(
                                                  movie.title,
                                                  style: const TextStyle(
                                                      fontSize: 28,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF512DA8)),
                                                ),
                                                const SizedBox(height: 8),
                                                const Divider(thickness: 1.2, color: Color(0xFFE1BEE7)),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Text("Año: ",
                                                        style: TextStyle(
                                                            color: Colors.deepPurple[700],
                                                            fontWeight: FontWeight.bold)),
                                                    Text("${movie.year}",
                                                        style: const TextStyle(color: Colors.black87)),
                                                  ],
                                                ),
                                                if (movie.duration != null)
                                                  Row(
                                                    children: [
                                                      Text("Duración: ",
                                                          style: TextStyle(
                                                              color: Colors.deepPurple[700],
                                                              fontWeight: FontWeight.bold)),
                                                      Text("${movie.duration} min",
                                                          style: const TextStyle(color: Colors.black87)),
                                                    ],
                                                  ),
                                                if (movie.genre != null)
                                                  Row(
                                                    children: [
                                                      Text("Género: ",
                                                          style: TextStyle(
                                                              color: Colors.deepPurple[700],
                                                              fontWeight: FontWeight.bold)),
                                                      Text("${movie.genre}",
                                                          style: const TextStyle(color: Colors.black87)),
                                                    ],
                                                  ),
                                                const SizedBox(height: 12),
                                                const Divider(thickness: 1.2, color: Color(0xFFB39DDB)),
                                                const SizedBox(height: 8),
                                                DropdownButtonFormField<String>(
                                                  decoration: InputDecoration(
                                                    filled: true,
                                                    fillColor: Colors.deepPurple[50],
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                      borderSide: BorderSide.none,
                                                    ),
                                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                  ),
                                                  value: selectedStatus,
                                                  onChanged: (value) {
                                                    if (value != null) {
                                                      setState(() => selectedStatus = value);
                                                    }
                                                  },
                                                  items: ['Visto', 'Pendiente', 'Favorita']
                                                      .map((s) => DropdownMenuItem(
                                                            value: s,
                                                            child: Text(s,
                                                                style: TextStyle(color: Colors.deepPurple[800])),
                                                          ))
                                                      .toList(),
                                                ),
                                                const SizedBox(height: 12),
                                                Row(
                                                  children: List.generate(5, (index) {
                                                    return IconButton(
                                                      icon: Icon(
                                                        index < selectedRating
                                                            ? Icons.star
                                                            : Icons.star_border,
                                                        color: Colors.amber,
                                                      ),
                                                      iconSize: 28,
                                                      onPressed: () {
                                                        setState(() {
                                                          selectedRating = index + 1;
                                                        });
                                                      },
                                                    );
                                                  }),
                                                ),
                                                const SizedBox(height: 12),
                                                const Divider(thickness: 1.2, color: Color(0xFFE1BEE7)),
                                                const SizedBox(height: 8),
                                                TextField(
                                                  controller: reviewController,
                                                  decoration: InputDecoration(
                                                    labelText: "Reseña",
                                                    labelStyle: TextStyle(color: Colors.deepPurple[300]),
                                                    filled: true,
                                                    fillColor: Colors.deepPurple[50],
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                      borderSide: BorderSide.none,
                                                    ),
                                                  ),
                                                  style: const TextStyle(fontSize: 16),
                                                  maxLines: 3,
                                                ),
                                                const SizedBox(height: 20),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    ElevatedButton.icon(
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.deepPurple,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        padding: const EdgeInsets.symmetric(
                                                            horizontal: 20, vertical: 12),
                                                        elevation: 3,
                                                      ),
                                                      onPressed: () async {
                                                        final updatedMovie = movie.copyWith(
                                                          rating: selectedRating,
                                                          status: selectedStatus,
                                                          review: reviewController.text,
                                                        );
                                                        await LocalDbService().updateMovie(updatedMovie);
                                                        Navigator.pop(context);
                                                        ref.invalidate(movies_provider.moviesProvider(user.id));
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(content: Text("Cambios guardados correctamente")),
                                                        );
                                                      },
                                                      icon: const Icon(Icons.save, color: Colors.white),
                                                      label: const Text("Guardar", style: TextStyle(color: Colors.white)),
                                                    ),
                                                    OutlinedButton.icon(
                                                      style: OutlinedButton.styleFrom(
                                                        foregroundColor: Colors.deepPurple,
                                                        side: const BorderSide(color: Color(0xFF7B1FA2), width: 2),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        padding: const EdgeInsets.symmetric(
                                                            horizontal: 18, vertical: 12),
                                                      ),
                                                      onPressed: () async {
                                                        print("user: ${user.id}, movie: ${movie.localId}");
                                                        final newRecommendation = {
                                                          'userId': user.id,
                                                          'movieId': movie.localId,
                                                          'comentario': reviewController.text,
                                                          'isPublic': 1,
                                                          'createdAt': DateTime.now().toIso8601String(),
                                                          'rating': selectedRating,
                                                        };
                                                      
                                                        await LocalDbService().insertRecommendation(newRecommendation);
                                                        ref.invalidate(movies_provider.moviesProvider(user.id));
                                                        ref.invalidate(recommendationsProvider);
                                                        Navigator.pop(context);
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(content: Text("Recomendación guardada localmente")),
                                                        );
                                                      },
                                                      icon: const Icon(Icons.recommend, color: Color(0xFF7B1FA2)),
                                                      label: const Text("Recomendar",
                                                          style: TextStyle(
                                                              color: Color(0xFF7B1FA2),
                                                              fontWeight: FontWeight.bold)),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
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