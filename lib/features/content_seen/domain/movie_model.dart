class MovieModel {
  final int? localId;           // Primary Key SQLite
  final String? remoteId;       // UUID Supabase
  final String userId;          // Supabase userId o local
  final String title;
  final int year;
  final double rating;
  final String review;
  final String status;
  final String? posterUrl;      // URL Supabase
  final String? posterPath; 
  final DateTime? watchedAt; // Fecha en que vio la película
  final String? genre;       // Género (opcional, de la API)
  final int? duration;       // Duración en minutos    // Local path
  final String? apiMovieId;

  MovieModel({
    this.localId,
    this.remoteId,
    required this.userId,
    required this.title,
    required this.year,
    required this.rating,
    required this.review,
    required this.status,
    this.posterUrl,
    this.posterPath,
    this.watchedAt,
    this.genre,
    this.duration,
    this.apiMovieId,
  });

  // Para guardar en Supabase
  Map<String, dynamic> toRemoteJson() {
    return {
      'id': remoteId,
      'user_id': userId,
      'title': title,
      'year': year,
      'rating': rating,
      'review': review,
      'status': status,
      'poster_url': posterUrl,
      'watched_at': watchedAt?.toIso8601String(),
      'genre': genre,
      'duration': duration,
      'api_movie_id': apiMovieId,
    };
  }

  // Para leer de Supabase
  factory MovieModel.fromRemoteJson(Map<String, dynamic> json) {
    return MovieModel(
      remoteId: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      year: json['year'] as int,
      rating: (json['rating'] as num).toDouble(),
      review: json['review'] as String,
      status: json['status'] as String,
      posterUrl: json['poster_url'] as String?,
      posterPath: json['poster_path'] as String?,
      watchedAt: json['watched_at'] != null
          ? DateTime.parse(json['watched_at'] as String)
          : null,
      genre: json['genre'] as String?,
      duration: json['duration'] as int?,
      apiMovieId: json['api_movie_id'] as String?,
    );
  }

  // Para guardar en SQLite
  Map<String, dynamic> toLocalJson() {
    return {
      'localId': localId,
      'remoteId': remoteId,
      'userId': userId,
      'title': title,
      'year': year,
      'rating': rating,
      'review': review,
      'status': status,
      'posterPath': posterPath,
      'watchedAt': watchedAt?.toIso8601String(),
      'genre': genre,
      'duration': duration,
      'apiMovieId': apiMovieId,
    };
  }

  //copyWith
  MovieModel copyWith({
    int? localId,
    String? remoteId,
    String? userId,
    String? title,
    int? year,
    double? rating,
    String? review,
    String? status,
    String? posterUrl,
    String? posterPath,
    DateTime? watchedAt,
    String? genre,
    int? duration,
    String? apiMovieId,
  }) {
    return MovieModel(
      localId: localId ?? this.localId,
      remoteId: remoteId ?? this.remoteId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      year: year ?? this.year,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      status: status ?? this.status,
      posterUrl: posterUrl ?? this.posterUrl,
      posterPath: posterPath ?? this.posterPath,
      watchedAt: watchedAt ?? this.watchedAt,
      genre: genre ?? this.genre,
      duration: duration ?? this.duration,
      apiMovieId: apiMovieId ?? this.apiMovieId,
    );
  }

  // Para leer de SQLite
  factory MovieModel.fromLocalJson(Map<String, dynamic> json) {
    return MovieModel(
      localId: json['localId'] as int?,
      remoteId: json['remoteId'] as String?,
      userId: json['userId'] as String,
      title: json['title'] as String,
      year: json['year'] as int,
      rating: (json['rating'] as num).toDouble(),
      review: json['review'] as String,
      status: json['status'] as String,
      posterPath: json['posterPath'] as String?,
      watchedAt: json['watchedAt'] != null
          ? DateTime.parse(json['watchedAt'] as String)
          : null,
      genre: json['genre'] as String?,
      duration: json['duration'] as int?,
      apiMovieId: json['apiMovieId'] as String?,
    );
  }
}