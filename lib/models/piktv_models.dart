class PikTvData {
  final List<PikTvMovie> latestMovie;
  final List<PikTvSeries> latestSeries;
  final List<PikTvMovie> top10Movies;
  final List<PikTvSeries> top10Series;

  PikTvData({
    required this.latestMovie,
    required this.latestSeries,
    required this.top10Movies,
    required this.top10Series,
  });

  factory PikTvData.fromJson(Map<String, dynamic> json) {
    return PikTvData(
      latestMovie: (json['latest_movie'] as List<dynamic>?)
              ?.map((item) => PikTvMovie.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      latestSeries: (json['latest_series'] as List<dynamic>?)
              ?.map((item) => PikTvSeries.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      top10Movies: (json['top_10_movies'] as List<dynamic>?)
              ?.map((item) => PikTvMovie.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      top10Series: (json['top_10_series'] as List<dynamic>?)
              ?.map((item) => PikTvSeries.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class PikTvMovie {
  final int tmdbId;
  final String imdbId;
  final String movieName;
  final String thumbnail;
  final String banner;
  final String link;
  final List<Cast> cast;
  final String imdb;
  final String movieLength;
  final String releaseYear;
  final List<Genre> generes;
  final String language;
  final bool isPlayAvailable;
  final String type;

  PikTvMovie({
    required this.tmdbId,
    required this.imdbId,
    required this.movieName,
    required this.thumbnail,
    required this.banner,
    required this.link,
    required this.cast,
    required this.imdb,
    required this.movieLength,
    required this.releaseYear,
    required this.generes,
    required this.language,
    required this.isPlayAvailable,
    required this.type,
  });

  factory PikTvMovie.fromJson(Map<String, dynamic> json) {
    return PikTvMovie(
      tmdbId: json['tmdb_id'] as int,
      imdbId: json['imdb_id'] as String? ?? '',
      movieName: json['movieName'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
      banner: json['banner'] as String? ?? '',
      link: json['link'] as String? ?? '',
      cast: (json['cast'] as List<dynamic>?)
              ?.map((item) => Cast.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      imdb: json['imdb'] as String? ?? 'N/A/10',
      movieLength: json['movie_length'] as String? ?? '',
      releaseYear: json['release_year'] as String? ?? '',
      generes: (json['generes'] as List<dynamic>?)
              ?.map((item) => Genre.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      language: json['language'] as String? ?? '',
      isPlayAvailable: json['is_play_available'] as bool? ?? false,
      type: json['type'] as String? ?? 'Movies',
    );
  }

  // Helper to get rating as double
  double? get rating {
    try {
      final ratingStr = imdb.replaceAll('/10', '').trim();
      if (ratingStr == 'N/A') return null;
      return double.tryParse(ratingStr);
    } catch (e) {
      return null;
    }
  }

  // Helper to get poster URL (w500 size) - uses original thumbnail if available
  String get posterUrl {
    // Use original thumbnail if it's a full URL
    if (thumbnail.isNotEmpty && thumbnail.startsWith('http')) {
      // If it contains /original/, convert to w500 size
      if (thumbnail.contains('/original/')) {
        return thumbnail.replaceFirst('/original/', '/w500/');
      }
      // If it already has a size, use as-is
      return thumbnail;
    }
    // Fallback: if thumbnail is empty, try banner and convert to w500
    if (banner.isNotEmpty && banner.startsWith('http')) {
      if (banner.contains('/original/')) {
        return banner.replaceFirst('/original/', '/w500/');
      }
      return banner;
    }
    return '';
  }

  // Helper to get backdrop URL (w1280 size) - uses original banner if available
  String get backdropUrl {
    // Use original banner if it's a full URL
    if (banner.isNotEmpty && banner.startsWith('http')) {
      // If it contains /original/, convert to w1280 size
      if (banner.contains('/original/')) {
        return banner.replaceFirst('/original/', '/w1280/');
      }
      // If it already has a size, use as-is
      return banner;
    }
    // Fallback: if banner is empty, try thumbnail and convert to w1280
    if (thumbnail.isNotEmpty && thumbnail.startsWith('http')) {
      if (thumbnail.contains('/original/')) {
        return thumbnail.replaceFirst('/original/', '/w1280/');
      }
      return thumbnail;
    }
    return '';
  }
}

class PikTvSeries {
  final int tmdbId;
  final String imdbId;
  final String movieName;
  final String thumbnail;
  final String banner;
  final String link;
  final List<Cast> cast;
  final String imdb;
  final String movieLength;
  final String releaseYear;
  final List<Genre> generes;
  final String language;
  final bool isPlayAvailable;
  final String type;

  PikTvSeries({
    required this.tmdbId,
    required this.imdbId,
    required this.movieName,
    required this.thumbnail,
    required this.banner,
    required this.link,
    required this.cast,
    required this.imdb,
    required this.movieLength,
    required this.releaseYear,
    required this.generes,
    required this.language,
    required this.isPlayAvailable,
    required this.type,
  });

  factory PikTvSeries.fromJson(Map<String, dynamic> json) {
    return PikTvSeries(
      tmdbId: json['tmdb_id'] as int,
      imdbId: json['imdb_id'] as String? ?? '',
      movieName: json['movieName'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
      banner: json['banner'] as String? ?? '',
      link: json['link'] as String? ?? '',
      cast: (json['cast'] as List<dynamic>?)
              ?.map((item) => Cast.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      imdb: json['imdb'] as String? ?? 'N/A/10',
      movieLength: json['movie_length'] as String? ?? '',
      releaseYear: json['release_year'] as String? ?? '',
      generes: (json['generes'] as List<dynamic>?)
              ?.map((item) => Genre.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      language: json['language'] as String? ?? '',
      isPlayAvailable: json['is_play_available'] as bool? ?? false,
      type: json['type'] as String? ?? 'Series',
    );
  }

  // Helper to get rating as double
  double? get rating {
    try {
      final ratingStr = imdb.replaceAll('/10', '').trim();
      if (ratingStr == 'N/A') return null;
      return double.tryParse(ratingStr);
    } catch (e) {
      return null;
    }
  }

  // Helper to get poster URL (w500 size) - uses original thumbnail if available
  String get posterUrl {
    // Use original thumbnail if it's a full URL
    if (thumbnail.isNotEmpty && thumbnail.startsWith('http')) {
      // If it contains /original/, convert to w500 size
      if (thumbnail.contains('/original/')) {
        return thumbnail.replaceFirst('/original/', '/w500/');
      }
      // If it already has a size, use as-is
      return thumbnail;
    }
    // Fallback: if thumbnail is empty, try banner and convert to w500
    if (banner.isNotEmpty && banner.startsWith('http')) {
      if (banner.contains('/original/')) {
        return banner.replaceFirst('/original/', '/w500/');
      }
      return banner;
    }
    return '';
  }

  // Helper to get backdrop URL (w1280 size) - uses original banner if available
  String get backdropUrl {
    // Use original banner if it's a full URL
    if (banner.isNotEmpty && banner.startsWith('http')) {
      // If it contains /original/, convert to w1280 size
      if (banner.contains('/original/')) {
        return banner.replaceFirst('/original/', '/w1280/');
      }
      // If it already has a size, use as-is
      return banner;
    }
    // Fallback: if banner is empty, try thumbnail and convert to w1280
    if (thumbnail.isNotEmpty && thumbnail.startsWith('http')) {
      if (thumbnail.contains('/original/')) {
        return thumbnail.replaceFirst('/original/', '/w1280/');
      }
      return thumbnail;
    }
    return '';
  }
}

class Cast {
  final int id;
  final String name;
  final String image;

  Cast({
    required this.id,
    required this.name,
    required this.image,
  });

  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      image: json['image'] as String? ?? '',
    );
  }
}

class Genre {
  final String name;

  Genre({
    required this.name,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      name: json['name'] as String? ?? '',
    );
  }
}

