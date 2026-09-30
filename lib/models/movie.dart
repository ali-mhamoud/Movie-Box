class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final String releaseDate;
  final double rating;
  final int? runtime;
  final List<String> genres;

  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.rating,
    this.runtime,
    this.genres = const [],
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as int? ?? 0,
      title: (json['title'] ?? json['name'] ?? 'Unknown').toString(),
      overview: (json['overview'] ?? '').toString(),
      posterPath: (json['poster_path'] ?? '').toString(),
      backdropPath: (json['backdrop_path'] ?? '').toString(),
      releaseDate: (json['release_date'] ?? '').toString(),
      rating: (json['vote_average'] as num?)?.toDouble() ?? 0,
      runtime: json['runtime'] as int?,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => (e as Map<String, dynamic>)['name'].toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toDbMap({required String userId, required String listType}) {
    return {
      'user_id': userId,
      'movie_id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'release_date': releaseDate,
      'rating': rating,
      'runtime': runtime,
      'genres': genres.join('|'),
      'list_type': listType,
    };
  }

  factory Movie.fromDb(Map<String, dynamic> map) {
    return Movie(
      id: map['movie_id'] as int,
      title: map['title'] as String,
      overview: (map['overview'] ?? '') as String,
      posterPath: (map['poster_path'] ?? '') as String,
      backdropPath: (map['backdrop_path'] ?? '') as String,
      releaseDate: (map['release_date'] ?? '') as String,
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      runtime: map['runtime'] as int?,
      genres: (map['genres'] as String?)
              ?.split('|')
              .where((e) => e.isNotEmpty)
              .toList() ??
          const [],
    );
  }
}
