import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/movies/domain/entities/movie_entity.dart';

class FavoriteItem {
  final int id;
  final String type; // 'movie' or 'tv'
  final MovieEntity movie;
  final String? videoUrl;

  FavoriteItem({
    required this.id,
    required this.type,
    required this.movie,
    this.videoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'videoUrl': videoUrl,
      'movie': {
        'id': movie.id,
        'title': movie.title,
        'overview': movie.overview,
        'posterPath': movie.posterPath,
        'backdropPath': movie.backdropPath,
        'voteAverage': movie.voteAverage,
        'voteCount': movie.voteCount,
        'releaseDate': movie.releaseDate,
        'genreIds': movie.genreIds,
        'runtime': movie.runtime,
        'budget': movie.budget,
        'revenue': movie.revenue,
        'tagline': movie.tagline,
        'genres': movie.genres?.map((g) => {'id': g.id, 'name': g.name}).toList(),
      },
    };
  }

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    final movieJson = json['movie'] as Map<String, dynamic>;
    return FavoriteItem(
      id: json['id'] as int,
      type: json['type'] as String,
      videoUrl: json['videoUrl'] as String?,
      movie: MovieEntity(
        id: movieJson['id'] as int,
        title: movieJson['title'] as String,
        overview: movieJson['overview'] as String?,
        posterPath: movieJson['posterPath'] as String?,
        backdropPath: movieJson['backdropPath'] as String?,
        voteAverage: (movieJson['voteAverage'] as num?)?.toDouble(),
        voteCount: movieJson['voteCount'] as int?,
        releaseDate: movieJson['releaseDate'] as String?,
        genreIds: movieJson['genreIds'] != null
            ? List<int>.from(movieJson['genreIds'] as List)
            : null,
        runtime: movieJson['runtime'] as int?,
        budget: movieJson['budget'] as int?,
        revenue: movieJson['revenue'] as int?,
        tagline: movieJson['tagline'] as String?,
        genres: movieJson['genres'] != null
            ? (movieJson['genres'] as List)
                .map((g) => GenreEntity(
                      id: g['id'] as int,
                      name: g['name'] as String,
                    ))
                .toList()
            : null,
      ),
    );
  }
}

class FavoritesService {
  static const String _favoritesKey = 'favorites_list';

  // Get all favorites
  Future<List<FavoriteItem>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString(_favoritesKey);
      
      if (favoritesJson == null || favoritesJson.isEmpty) {
        return [];
      }

      final List<dynamic> favoritesList = json.decode(favoritesJson);
      return favoritesList
          .map((item) => FavoriteItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Check if item is favorite
  Future<bool> isFavorite(int id, String type) async {
    final favorites = await getFavorites();
    return favorites.any((item) => item.id == id && item.type == type);
  }

  // Add to favorites
  Future<bool> addFavorite(MovieEntity movie, String type, {String? videoUrl}) async {
    try {
      final favorites = await getFavorites();
      
      // Check if already exists
      if (favorites.any((item) => item.id == movie.id && item.type == type)) {
        return false;
      }

      if (favorites.length >= 20) {
        return false;
      }

      final favoriteItem = FavoriteItem(
        id: movie.id,
        type: type,
        movie: movie,
        videoUrl: videoUrl,
      );

      favorites.add(favoriteItem);
      return await _saveFavorites(favorites);
    } catch (e) {
      return false;
    }
  }

  Future<bool> canAddMore() async {
    final favorites = await getFavorites();
    return favorites.length < 20;
  }

  // Remove from favorites
  Future<bool> removeFavorite(int id, String type) async {
    try {
      final favorites = await getFavorites();
      favorites.removeWhere((item) => item.id == id && item.type == type);
      return await _saveFavorites(favorites);
    } catch (e) {
      return false;
    }
  }

  // Toggle favorite
  Future<bool> toggleFavorite(MovieEntity movie, String type, {String? videoUrl}) async {
    final isFav = await isFavorite(movie.id, type);
    if (isFav) {
      return await removeFavorite(movie.id, type);
    } else {
      return await addFavorite(movie, type, videoUrl: videoUrl);
    }
  }

  // Save favorites to local storage
  Future<bool> _saveFavorites(List<FavoriteItem> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = json.encode(
        favorites.map((item) => item.toJson()).toList(),
      );
      return await prefs.setString(_favoritesKey, favoritesJson);
    } catch (e) {
      return false;
    }
  }

  // Clear all favorites
  Future<bool> clearFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_favoritesKey);
    } catch (e) {
      return false;
    }
  }
}

