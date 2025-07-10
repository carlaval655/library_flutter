import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_movie_tracker/features/profile/application/current_user_provider.dart';
import 'package:my_movie_tracker/features/recommendations/data/recommendations_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/db/local_db.dart';

final recommendationsProvider = FutureProvider<List<RecommendationWithMovie>>((ref) async {
  final userAsync = ref.watch(currentUserProvider);
  final user = userAsync.value;
  if (user == null) {
    return [];
  }
  final db = LocalDbService();
  return await db.getRecommendationsWithMovieDetailsByUserId(user.id);
});

class RecommendationsScreen extends ConsumerWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationsAsync = ref.watch(recommendationsProvider);
    final supabase = Supabase.instance.client;
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;

    Future<void> makePublic(RecommendationWithMovie rec) async {
      if (user == null) return;

      try {
        // Check if movie exists in remote 'movies' table by api_movie_id
        final movieResponse = await supabase
            .from('movies')
            .select('id')
            .eq('api_movie_id', rec.movie.apiMovieId ?? '')
            .limit(1)
            .maybeSingle();

        String movieId;
        if (movieResponse != null) {
          movieId = movieResponse['id'];
        } else {
          // Insert movie and get id
          final insertMovieResponse = await supabase.from('movies').insert({
            'api_movie_id': rec.movie.apiMovieId,
            'title': rec.movie.title,
            'year': rec.movie.year,
            'genre': rec.movie.genre,
            'duration': rec.movie.duration,
            'poster_path': rec.movie.posterPath,
          }).select('id').single();

          if (insertMovieResponse == null || !insertMovieResponse.containsKey('id')) {
            throw Exception('Error al insertar la película');
          }
          movieId = insertMovieResponse['id'] as String;
        }

        // Insert recommendation with is_public true
        await supabase.from('recommendations').insert({
          'movie_id': movieId,
          'user_id': user.id,
          'comentario': rec.recommendation.comentario,
          'is_public': true,
          'created_at': DateTime.now().toIso8601String(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('¡Recomendación publicada!')),
        );

        ref.invalidate(recommendationsProvider);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al publicar: $e')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Mis Recomendaciones"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7B1FA2), Color(0xFF512DA8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: recommendationsAsync.when(
          data: (recs) {
            if (recs.isEmpty) {
              return Center(child: Text("No tienes recomendaciones."));
            }
            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: recs.length,
              itemBuilder: (context, index) {
                final rec = recs[index];
                return Card(
                  color: Colors.white.withOpacity(0.9),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (rec.movie.posterPath != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  rec.movie.posterPath!,
                                  width: 80,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
                              Icon(Icons.movie, size: 50, color: Colors.deepPurple),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    rec.movie.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "${rec.movie.year} · ${rec.movie.genre ?? "Sin género"}",
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Duración: ${rec.movie.duration} min",
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          rec.recommendation.comentario,
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Recomendado el ${rec.recommendation.createdAt.toLocal().toString().split(".")[0]}",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () => makePublic(rec),
                            child: Text('Hacer pública'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text("Error: $e")),
        ),
      ),
    );
  }
}