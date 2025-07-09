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
  final String? posterPath;     // Local path

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
    };
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
    );
  }
}