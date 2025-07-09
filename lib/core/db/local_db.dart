import 'package:my_movie_tracker/features/content_seen/domain/movie_model.dart';
import 'package:my_movie_tracker/features/recommendations/data/recommendations_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../features/content_seen/domain/movie_model.dart';

class LocalDbService {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB('movies.db');
    return _db!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE movies(
            localId INTEGER PRIMARY KEY AUTOINCREMENT,
            remoteId TEXT,
            userId TEXT,
            title TEXT,
            year INTEGER,
            rating REAL,
            review TEXT,
            status TEXT,
            posterPath TEXT,
            genre TEXT,
            duration INTEGER,
            watchedAt TEXT
          );
        ''');
        await db.execute('''
          CREATE TABLE recommendations (
            localId INTEGER PRIMARY KEY AUTOINCREMENT,
            remoteId TEXT,
            userId TEXT,
            movieId INTEGER,
            comentario TEXT,
            isPublic INTEGER,
            createdAt TEXT
          );
        ''');
      },
    );
  }

  Future<void> insertMovie(MovieModel movie) async {
    final db = await database;
    await db.insert('movies', movie.toLocalJson());
  }

  Future<List<MovieModel>> getAllMovies() async {
    final db = await database;
    final result = await db.query('movies');
    return result.map((e) => MovieModel.fromLocalJson(e)).toList();
  }

  Future<List<MovieModel>> getMoviesByUserId(String userId) async {
    final db = await database;
    final result = await db.query(
      'movies',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return result.map((e) => MovieModel.fromLocalJson(e)).toList();
  }
  Future<void> deleteDatabaseFile() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'movies.db');
  await deleteDatabase(path);
  print("Database deleted!");
}

  Future<void> deleteMovie(int localId) async {
    final db = await database;
    await db.delete(
      'movies',
      where: 'localId = ?',
      whereArgs: [localId],
    );
  }

  Future<void> updateMovie(MovieModel movie) async {
    final db = await database;
    await db.update(
      'movies',
      movie.toLocalJson(),
      where: 'localId = ?',
      whereArgs: [movie.localId],
    );
  }

  Future<void> insertRecommendation(Map<String, dynamic> recommendation) async {
    final db = await database;
    await db.insert('recommendations', recommendation);
  }
  
  Future<List<RecommendationModel>> getRecommendationsByUserId(String userId) async {
    final db = await database;
    final result = await db.query(
      'recommendations',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    return result.map((e) => RecommendationModel.fromMap(e)).toList();
  }

 Future<List<RecommendationWithMovie>> getRecommendationsWithMovieDetailsByUserId(String userId) async {
  final db = await database;

  // Obtener recomendaciones del usuario
  final recResult = await db.query(
    'recommendations',
    where: 'userId = ?',
    whereArgs: [userId],
    orderBy: 'createdAt DESC',
  );

  List<RecommendationWithMovie> combined = [];

  for (final recMap in recResult) {
    final rec = RecommendationModel.fromMap(recMap);

    // Buscar película asociada
    final movieResult = await db.query(
      'movies',
      where: 'localId = ?',
      whereArgs: [rec.movieId],
    );

    if (movieResult.isNotEmpty) {
      final movie = MovieModel.fromLocalJson(movieResult.first);
      combined.add(
        RecommendationWithMovie(
          recommendation: rec,
          movie: movie,
        ),
      );
    }
  }

  return combined;
} 
}


  
  