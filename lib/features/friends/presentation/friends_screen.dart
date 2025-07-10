import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final usersProvider = FutureProvider<List<AppUser>>((ref) async {
  final List<dynamic> data = await Supabase.instance.client
      .from('profiles')
      .select();

  return data.map((userMap) {
    return AppUser(
      id: userMap['id'],
      name: '${userMap['nombre']} ${userMap['apellido']}',
      photoUrl: userMap['foto_url'] ?? '',
    );
  }).toList();
});

class AppUser {
  final String id;
  final String name;
  final String photoUrl;

  AppUser({required this.id, required this.name, required this.photoUrl});
}

// Define a model class for MovieRecommendation to hold the combined data
class Movie {
  final String? posterPath;
  final String title;
  final int year;
  final String? genre;
  final int duration;
  final int rating;

  Movie({
    this.posterPath,
    required this.title,
    required this.year,
    this.genre,
    required this.duration,
    required this.rating,
  });
}

class Recommendation {
  final String comentario;
  final DateTime createdAt;

  Recommendation({
    required this.comentario,
    required this.createdAt,
  });
}

class MovieRecommendation {
  final Movie movie;
  final Recommendation recommendation;

  MovieRecommendation({
    required this.movie,
    required this.recommendation,
  });
}

// FutureProvider.family to fetch recommendations for a given userId
final userRecommendationsProvider = FutureProvider.family<List<MovieRecommendation>, String>((ref, userId) async {
  final supabase = Supabase.instance.client;

  // Query to fetch recommendations joined with movies info for the userId
  final response = await supabase
      .from('recommendations')
      .select('comentario, created_at, movies (poster_path, title, year, genre, duration, rating_stars)')
      .eq('user_id', userId)
      .order('created_at', ascending: false)
      .limit(20);

  if (response == null) {
    throw Exception("Error al obtener recomendaciones");
  }

  final List<dynamic> data = response;

  return data.map((recMap) {
    final movieMap = recMap['movies'];
    return MovieRecommendation(
      movie: Movie(
        posterPath: movieMap['poster_path'],
        title: movieMap['title'] ?? 'Sin título',
        year: movieMap['year'] ?? 0,
        genre: movieMap['genre'],
        duration: movieMap['duration'] ?? 0,
        rating: movieMap['rating'] ?? 0,
      ),
      recommendation: Recommendation(
        comentario: recMap['comentario'] ?? '',
        createdAt: DateTime.parse(recMap['created_at']),
      ),
    );
  }).toList();
});

class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7B1FA2), Color(0xFF512DA8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: usersAsync.when(
          data: (users) {
            if (users.isEmpty) {
              return const Center(child: Text('No hay usuarios disponibles.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  color: Colors.white,
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundImage: user.photoUrl.isNotEmpty ? NetworkImage(user.photoUrl) : null,
                      child: user.photoUrl.isEmpty ? const Icon(Icons.person, size: 28, color: Colors.white) : null,
                      backgroundColor: Colors.deepPurple,
                    ),
                    title: Text(
                      user.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 16),
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        minimumSize: const Size(100, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        textStyle: const TextStyle(fontSize: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserRecommendationsScreen(
                              userId: user.id,
                              userName: user.name,
                            ),
                          ),
                        );
                      },
                      child: const Text("Ver Recomendaciones", 
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}

class UserRecommendationsScreen extends ConsumerWidget {
  final String userId;
  final String userName;

  const UserRecommendationsScreen({super.key, required this.userId, required this.userName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationsAsync = ref.watch(userRecommendationsProvider(userId));
    print("Cargando recomendaciones para el usuario: $userId");
    return Scaffold(
      appBar: AppBar(
        title: Text('Recomendaciones de $userName'),
        backgroundColor: Colors.deepPurple,
      ),
      body: recommendationsAsync.when(
        data: (recs) => recs.isEmpty
            ? const Center(child: Text("Este usuario no tiene recomendaciones públicas."))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: recs.length,
                itemBuilder: (context, index) {
                  print("Mostrando recomendación $index para el usuario: $userId");
                  print("Recomendación: ${recs[index].recommendation.comentario}");
                  print("Película: ${recs[index].movie.title} (${recs[index].
movie.year})");
                  print("Rating: ${recs[index].movie.rating}");
                  final rec = recs[index];
                  return Card(
                    color: Colors.white.withOpacity(0.9),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              rec.movie.posterPath != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        rec.movie.posterPath!,
                                        width: 80,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(Icons.movie, size: 50, color: Colors.deepPurple),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      rec.movie.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text("${rec.movie.year} · ${rec.movie.genre ?? "Sin género"}"),
                                    const SizedBox(height: 4),
                                    Text("Duración: ${rec.movie.duration} min"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            rec.recommendation.comentario,
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Recomendado el ${rec.recommendation.createdAt.toLocal().toString().split(".")[0]}",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: List.generate(
                              5,
                              (i) => Icon(
                                i < rec.movie.rating ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }
}