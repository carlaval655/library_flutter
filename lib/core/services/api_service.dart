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

  Future<MovieApiResult> getMovieDetails(int movieId) async {
    final url =
        'https://api.themoviedb.org/3/movie/$movieId?api_key=$_apiKey&language=es';

    final response = await _dio.get(url);
    final data = response.data;

    final genreIds = (data['genres'] as List<dynamic>?)
            ?.map((genre) => genre['id'] as int)
            .toList() ??
        [];
    final genreNames = genreIds
        .map((id) => genreMap[id] ?? 'Desconocido')
        .toList();

    return MovieApiResult(
      id: data['id'],
      title: data['title'] ?? '',
      posterPath: data['poster_path'],
      overview: data['overview'] ?? '',
      releaseDate: data['release_date'] ?? '',
      genreNames: genreNames,
      duration: data['runtime'],
    );
  }
}

const Map<int, String> genreMap = {
  28: 'Acción',
  12: 'Aventura',
  16: 'Animación',
  35: 'Comedia',
  80: 'Crimen',
  99: 'Documental',
  18: 'Drama',
  10751: 'Familia',
  14: 'Fantasía',
  36: 'Historia',
  27: 'Terror',
  10402: 'Música',
  9648: 'Misterio',
  10749: 'Romance',
  878: 'Ciencia Ficción',
  10770: 'Película de TV',
  53: 'Suspenso',
  10752: 'Bélica',
  37: 'Western',
};

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
    final genreIds = (json['genre_ids'] as List<dynamic>?) ?? [];
    final genreNames = genreIds
        .map((id) => genreMap[int.tryParse(id.toString())] ?? 'Desconocido')
        .toList();
    return MovieApiResult(
      id: json['id'],
      title: json['title'] ?? '',
      posterPath: json['poster_path'],
      overview: json['overview'] ?? '',
      releaseDate: json['release_date'] ?? '',
      genreNames: genreNames,
      duration: json['runtime'],
    );
  }

  //to string for debugging
  @override
  String toString() {
    return 'MovieApiResult(id: $id, title: $title, posterPath: $posterPath, overview: $overview, releaseDate: $releaseDate, genreNames: $genreNames, duration: $duration)';
  }
}