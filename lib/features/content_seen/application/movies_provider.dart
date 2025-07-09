import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_movie_tracker/core/db/local_db.dart';
import 'package:my_movie_tracker/features/content_seen/domain/movie_model.dart';
import 'package:my_movie_tracker/features/profile/application/current_user_provider.dart';
import 'package:my_movie_tracker/features/profile/application/profile_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final moviesProvider = FutureProvider.family<List<MovieModel>, String>((ref, userId) async {
  final db = LocalDbService();
  print("Fetching movies for user: $userId");
  return await db.getMoviesByUserId(userId);
});
