import 'package:my_movie_tracker/features/content_seen/domain/movie_model.dart';

class RecommendationModel {
  final int? localId;
  final String? remoteId;
  final String userId;
  final int movieId;
  final String comentario;
  final bool isPublic;
  final DateTime createdAt;

  RecommendationModel({
    this.localId,
    this.remoteId,
    required this.userId,
    required this.movieId,
    required this.comentario,
    required this.isPublic,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'localId': localId,
      'remoteId': remoteId,
      'userId': userId,
      'movieId': movieId,
      'comentario': comentario,
      'isPublic': isPublic ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory RecommendationModel.fromMap(Map<String, dynamic> map) {
    return RecommendationModel(
      localId: map['localId'],
      remoteId: map['remoteId'],
      userId: map['userId'],
      movieId: map['movieId'],
      comentario: map['comentario'],
      isPublic: map['isPublic'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

class RecommendationWithMovie {
  final RecommendationModel recommendation;
  final MovieModel movie;

  RecommendationWithMovie({
    required this.recommendation,
    required this.movie,
  });
}