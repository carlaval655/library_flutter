import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio();
  final String _apiKey = '085443411f88400db700923cd665800d';

  Future<List<MovieApiResult>> searchMovies(String query) async {
    final url =
        'https://api.themoviedb.org/3/search/movie?api_key=$_apiKey&query=$query&language=es';

    final response = await _dio.get(url);

    final List<MovieApiResult> movies = (response.data['results'] as List)
        .map((json) => MovieApiResult.fromJson(json))
        .toList();

    return movies;
  }
}

class MovieApiResult {
  final int id;
  final String title;
  final String? posterPath;
  final String overview;
  final String releaseDate;
  final List<String>? genreNames;
  final int? duration;

  MovieApiResult({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.overview,
    required this.releaseDate,
    this.genreNames,
    this.duration,
  });

  factory MovieApiResult.fromJson(Map<String, dynamic> json) {
    return MovieApiResult(
      id: json['id'],
      title: json['title'] ?? '',
      posterPath: json['poster_path'],
      overview: json['overview'] ?? '',
      releaseDate: json['release_date'] ?? '',
      genreNames: (json['genre_ids'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      duration: json['runtime'],
    );
  }
}