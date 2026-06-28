import '../../domain/entities/movie_entity.dart';

class MovieModel extends MovieEntity {
  const MovieModel({
    required super.id,
    required super.title,
    super.overview,
    super.posterPath,
    super.backdropPath,
    super.voteAverage,
    super.voteCount,
    super.releaseDate,
    super.genreIds,
    super.runtime,
    super.budget,
    super.revenue,
    super.tagline,
    super.genres,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? json['name'] as String? ?? 'Unknown',
      overview: json['overview'] as String?,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      voteCount: json['vote_count'] as int?,
      releaseDate: json['release_date'] as String? ?? json['first_air_date'] as String?,
      genreIds: json['genre_ids'] != null
          ? List<int>.from(json['genre_ids'] as List)
          : null,
      runtime: json['runtime'] as int?,
      budget: json['budget'] as int?,
      revenue: json['revenue'] as int?,
      tagline: json['tagline'] as String?,
      genres: json['genres'] != null
          ? (json['genres'] as List)
              .map((g) => GenreEntity(
                    id: g['id'] as int,
                    name: g['name'] as String,
                  ))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'release_date': releaseDate,
      'genre_ids': genreIds,
      'runtime': runtime,
      'budget': budget,
      'revenue': revenue,
      'tagline': tagline,
      'genres': genres?.map((g) => {'id': g.id, 'name': g.name}).toList(),
    };
  }
}

