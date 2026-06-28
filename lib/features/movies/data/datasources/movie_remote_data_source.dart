import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/movie_model.dart';
import '../models/cast_model.dart';
import '../models/crew_model.dart';
import '../models/video_model.dart';
import '../models/watch_provider_model.dart';
import '../models/movie_image_model.dart';
import '../models/person_model.dart';

abstract class MovieRemoteDataSource {
  Future<List<MovieModel>> getTrendingMovies({int page = 1});
  Future<List<MovieModel>> getPopularMovies({int page = 1});
  Future<List<MovieModel>> getTopRatedMovies({int page = 1});
  Future<List<MovieModel>> getUpcomingMovies({int page = 1});
  Future<MovieModel> getMovieDetails(int movieId);
  Future<List<CastModel>> getMovieCast(int movieId);
  Future<List<CrewModel>> getMovieCrew(int movieId);
  Future<List<VideoModel>> getMovieVideos(int movieId);
  Future<List<WatchProviderModel>> getMovieWatchProviders(int movieId, {String region = 'US'});
  Future<Map<String, List<MovieImageModel>>> getMovieImages(int movieId);
  Future<List<MovieModel>> searchMovies(String query, {int page = 1});
  Future<List<MovieModel>> getSimilarMovies(int movieId, {int page = 1});
  
  // TV Show methods
  Future<List<MovieModel>> getTrendingTvShows({int page = 1});
  Future<List<MovieModel>> getPopularTvShows({int page = 1});
  Future<List<MovieModel>> getTopRatedTvShows({int page = 1});
  Future<List<MovieModel>> searchTvShows(String query, {int page = 1});
  Future<MovieModel> getTvShowDetails(int tvShowId);
  Future<List<CastModel>> getTvShowCast(int tvShowId);
  Future<List<VideoModel>> getTvShowVideos(int tvShowId);
  Future<List<WatchProviderModel>> getTvShowWatchProviders(int tvShowId, {String region = 'US'});
  Future<Map<String, List<MovieImageModel>>> getTvShowImages(int tvShowId);
  Future<List<MovieModel>> getSimilarTvShows(int tvShowId, {int page = 1});
  
  // Person methods
  Future<List<PersonModel>> searchPerson(String query, {int page = 1});
  Future<PersonModel> getPersonDetails(int personId);
  Future<Map<String, List<PersonMovieCreditModel>>> getPersonMovieCredits(int personId);
}

class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  final DioClient dioClient;

  MovieRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<MovieModel>> getTrendingMovies({int page = 1}) async {
    try {
      final response = await dioClient.get(
        ApiConstants.trendingMovies,
        queryParameters: {
          'api_key': ApiConstants.tmdbApiKey,
          'page': page,
        },
      );

      final results = response.data['results'] as List;
      return results
          .map((json) => MovieModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<MovieModel>> getPopularMovies({int page = 1}) async {
    try {
      final response = await dioClient.get(
        ApiConstants.popularMovies,
        queryParameters: {
          'api_key': ApiConstants.tmdbApiKey,
          'page': page,
        },
      );

      final results = response.data['results'] as List;
      return results
          .map((json) => MovieModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<MovieModel>> getTopRatedMovies({int page = 1}) async {
    try {
      final response = await dioClient.get(
        ApiConstants.topRatedMovies,
        queryParameters: {
          'api_key': ApiConstants.tmdbApiKey,
          'page': page,
        },
      );

      final results = response.data['results'] as List;
      return results
          .map((json) => MovieModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<MovieModel>> getUpcomingMovies({int page = 1}) async {
    try {
      final response = await dioClient.get(
        ApiConstants.upcomingMovies,
        queryParameters: {
          'api_key': ApiConstants.tmdbApiKey,
          'page': page,
        },
      );

      final results = response.data['results'] as List;
      return results
          .map((json) => MovieModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MovieModel> getMovieDetails(int movieId) async {
    try {
      final response = await dioClient.get(
        '${ApiConstants.movieDetails}/$movieId',
        queryParameters: {
          'api_key': ApiConstants.tmdbApiKey,
        },
      );

      return MovieModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CastModel>> getMovieCast(int movieId) async {
    try {
      final response = await dioClient.get(
        '${ApiConstants.movieDetails}/$movieId/credits',
        queryParameters: {
          'api_key': ApiConstants.tmdbApiKey,
        },
      );

      final cast = response.data['cast'] as List;
      return cast
          .map((json) => CastModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CrewModel>> getMovieCrew(int movieId) async {
    try {
      final response = await dioClient.get(
        '${ApiConstants.movieDetails}/$movieId/credits',
        queryParameters: {
          'api_key': ApiConstants.tmdbApiKey,
        },
      );

      final crew = response.data['crew'] as List;
      return crew
          .map((json) => CrewModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<VideoModel>> getMovieVideos(int movieId) async {
    try {
      final response = await dioClient.get(
        '${ApiConstants.movieDetails}/$movieId/videos',
        queryParameters: {
          'api_key': ApiConstants.tmdbApiKey,
        },
      );

      final results = response.data['results'] as List;
      return results
          .map((json) => VideoModel.fromJson(json as Map<String, dynamic>))
          .where((video) => video.site.toLowerCase() == 'youtube')
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<WatchProviderModel>> getMovieWatchProviders(int movieId, {String region = 'US'}) async {
    try {
      final response = await dioClient.get(
        '${ApiConstants.movieDetails}/$movieId/watch/providers',
        queryParameters: {
          'api_key': ApiConstants.tmdbApiKey,
        },
      );

      final results = response.data['results'] as Map<String, dynamic>?;
      if (results == null || results.isEmpty) {
        return [];
      }

      // Try to get providers for the specified region, or use the first available region
      Map<String, dynamic>? regionData = results[region] as Map<String, dynamic>?;
      if (regionData == null && results.isNotEmpty) {
        // Use the first available region
        regionData = results.values.first as Map<String, dynamic>?;
      }

      if (regionData == null) {
        return [];
      }

      // Get flatrate (streaming) providers
      final flatrate = regionData['flatrate'] as List?;
      if (flatrate == null || flatrate.isEmpty) {
        return [];
      }

      return flatrate
          .map((json) => WatchProviderModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, List<MovieImageModel>>> getMovieImages(int movieId) async {
    try {
      final response = await dioClient.get(
        '${ApiConstants.movieDetails}/$movieId/images',
        queryParameters: {
          'api_key': ApiConstants.tmdbApiKey,
        },
      );

      final data = response.data as Map<String, dynamic>;
      
      // Extract posters and backdrops
      final posters = (data['posters'] as List?)
          ?.map((json) => MovieImageModel.fromJson(json as Map<String, dynamic>))
          .toList() ?? [];
      
      final backdrops = (data['backdrops'] as List?)
          ?.map((json) => MovieImageModel.fromJson(json as Map<String, dynamic>))
          .toList() ?? [];

      return {
        'posters': posters,
        'backdrops': backdrops,
      };
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<MovieModel>> searchMovies(String query, {int page = 1}) async {
    try {
      final response = await dioClient.get(
        ApiConstants.searchMovies,
        queryParameters: {
          'api_key': ApiConstants.tmdbApiKey,
          'query': query,
          'page': page,
        },
      );

      final results = response.data['results'] as List;
      return results
          .map((json) => MovieModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<MovieModel>> getSimilarMovies(int movieId, {int page = 1}) async {
    try {
      final response = await dioClient.get(
        '${ApiConstants.movieDetails}/$movieId/similar',
        queryParameters: {
          'api_key': ApiConstants.tmdbApiKey,
          'page': page,
        },
      );

      final results = response.data['results'] as List;
      return results
          .map((json) => MovieModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<MovieModel>> getTrendingTvShows({int page = 1}) async {
    try {
      final response = await dioClient.get(
        ApiConstants.trendingTvShows,
        queryParameters: {
          'api_key': ApiConstants.tmdbApiKey,
          'page': page,
        },
      );

      final results = response.data['results'] as List;
      return results
          .map((json) => MovieModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<MovieModel>> getPopularTvShows({int page = 1}) async {
    try {
      final response = await dioClient.get(
        ApiConstants.popularTvShows,
        queryParameters: {
          'api_key': ApiConstants.tmdbApiKey,
          'page': page,
        },
      );

      final results = response.data['results'] as List;
      return results
          .map((json) => MovieModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<MovieModel>> getTopRatedTvShows({int page = 1}) async {
    try {
      final response = await dioClient.get(
        ApiConstants.topRatedTvShows,
        queryParameters: {
          'api_key': ApiConstants.tmdbApiKey,
          'page': page,
        },
      );

      final results = response.data['results'] as List;
      return results
          .map((json) => MovieModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<MovieModel>> searchTvShows(String query, {int page = 1}) async {
    try {
      final response = await dioClient.get(
        ApiConstants.searchTvShows,
        queryParameters: {
          'api_key': ApiConstants.tmdbApiKey,
          'query': query,
          'page': page,
        },
      );

      final results = response.data['results'] as List;
      return results
          .map((json) => MovieModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MovieModel> getTvShowDetails(int tvShowId) async {
    try {
      final response = await dioClient.get(
        '${ApiConstants.tvDetails}/$tvShowId',
        queryParameters: {
          'api_key': ApiConstants.tmdbApiKey,
        },
      );

      return MovieModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CastModel>> getTvShowCast(int tvShowId) async {
    try {
      final response = await dioClient.get(
        '${ApiConstants.tvDetails}/$tvShowId/credits',
        queryParameters: {
          'api_key': ApiConstants.tmdbApiKey,
        },
      );

      final cast = response.data['cast'] as List;
      return cast
          .map((json) => CastModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<VideoModel>> getTvShowVideos(int tvShowId) async {
    try {
      final response = await dioClient.get(
        '${ApiConstants.tvDetails}/$tvShowId/videos',
        queryParameters: {
          'api_key': ApiConstants.tmdbApiKey,
        },
      );

      final results = response.data['results'] as List;
      return results
          .map((json) => VideoModel.fromJson(json as Map<String, dynamic>))
          .where((video) => video.site.toLowerCase() == 'youtube')
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<WatchProviderModel>> getTvShowWatchProviders(int tvShowId, {String region = 'US'}) async {
    try {
      final response = await dioClient.get(
        '${ApiConstants.tvDetails}/$tvShowId/watch/providers',
        queryParameters: {
          'api_key': ApiConstants.tmdbApiKey,
        },
      );

      final results = response.data['results'] as Map<String, dynamic>?;
      if (results == null || results.isEmpty) {
        return [];
      }

      // Try to get providers for the specified region, or use the first available region
      Map<String, dynamic>? regionData = results[region] as Map<String, dynamic>?;
      if (regionData == null && results.isNotEmpty) {
        // Use the first available region
        regionData = results.values.first as Map<String, dynamic>?;
      }

      if (regionData == null) {
        return [];
      }

      // Get flatrate (streaming) providers
      final flatrate = regionData['flatrate'] as List?;
      if (flatrate == null || flatrate.isEmpty) {
        return [];
      }

      return flatrate
          .map((json) => WatchProviderModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, List<MovieImageModel>>> getTvShowImages(int tvShowId) async {
    try {
      final response = await dioClient.get(
        '${ApiConstants.tvDetails}/$tvShowId/images',
        queryParameters: {
          'api_key': ApiConstants.tmdbApiKey,
        },
      );

      final data = response.data as Map<String, dynamic>;
      
      // Extract posters and backdrops
      final posters = (data['posters'] as List?)
          ?.map((json) => MovieImageModel.fromJson(json as Map<String, dynamic>))
          .toList() ?? [];
      
      final backdrops = (data['backdrops'] as List?)
          ?.map((json) => MovieImageModel.fromJson(json as Map<String, dynamic>))
          .toList() ?? [];

      return {
        'posters': posters,
        'backdrops': backdrops,
      };
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<MovieModel>> getSimilarTvShows(int tvShowId, {int page = 1}) async {
    try {
      final response = await dioClient.get(
        '${ApiConstants.tvDetails}/$tvShowId/similar',
        queryParameters: {
          'api_key': ApiConstants.tmdbApiKey,
          'page': page,
        },
      );

      final results = response.data['results'] as List;
      return results
          .map((json) => MovieModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<PersonModel>> searchPerson(String query, {int page = 1}) async {
    try {
      final response = await dioClient.get(
        ApiConstants.searchPerson,
        queryParameters: {
          'api_key': ApiConstants.tmdbApiKey,
          'query': query,
          'page': page,
        },
      );

      final results = response.data['results'] as List?;
      if (results == null || results.isEmpty) {
        return [];
      }
      
      return results
          .map((json) => PersonModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PersonModel> getPersonDetails(int personId) async {
    try {
      final response = await dioClient.get(
        '${ApiConstants.personDetails}/$personId',
        queryParameters: {
          'api_key': ApiConstants.tmdbApiKey,
        },
      );

      return PersonModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, List<PersonMovieCreditModel>>> getPersonMovieCredits(int personId) async {
    try {
      // Use combined_credits endpoint to get both movies and TV shows
      final response = await dioClient.get(
        '${ApiConstants.personDetails}/$personId/combined_credits',
        queryParameters: {
          'api_key': ApiConstants.tmdbApiKey,
        },
      );

      final data = response.data as Map<String, dynamic>;
      
      // Extract cast and crew credits (includes both movies and TV shows)
      final cast = (data['cast'] as List?)
          ?.map((json) => PersonMovieCreditModel.fromJson(json as Map<String, dynamic>))
          .toList() ?? [];
      
      final crew = (data['crew'] as List?)
          ?.map((json) => PersonMovieCreditModel.fromJson(json as Map<String, dynamic>))
          .toList() ?? [];

      return {
        'cast': cast,
        'crew': crew,
      };
    } catch (e) {
      rethrow;
    }
  }
}

