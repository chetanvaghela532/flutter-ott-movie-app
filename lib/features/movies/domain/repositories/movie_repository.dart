import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/movie_entity.dart';
import '../entities/cast_entity.dart';
import '../entities/video_entity.dart';
import '../entities/watch_provider_entity.dart';
import '../entities/movie_image_entity.dart';
import '../entities/person_entity.dart';

abstract class MovieRepository {
  Future<Either<Failure, List<MovieEntity>>> getTrendingMovies({int page = 1});
  Future<Either<Failure, List<MovieEntity>>> getPopularMovies({int page = 1});
  Future<Either<Failure, List<MovieEntity>>> getTopRatedMovies({int page = 1});
  Future<Either<Failure, List<MovieEntity>>> getUpcomingMovies({int page = 1});
  Future<Either<Failure, MovieEntity>> getMovieDetails(int movieId);
  Future<Either<Failure, List<CastEntity>>> getMovieCast(int movieId);
  Future<Either<Failure, List<VideoEntity>>> getMovieVideos(int movieId);
  Future<Either<Failure, List<WatchProviderEntity>>> getMovieWatchProviders(int movieId, {String region = 'US'});
  Future<Either<Failure, Map<String, List<MovieImageEntity>>>> getMovieImages(int movieId);
  Future<Either<Failure, List<MovieEntity>>> searchMovies(String query, {int page = 1});
  Future<Either<Failure, List<MovieEntity>>> getSimilarMovies(int movieId, {int page = 1});
  
  // TV Show methods
  Future<Either<Failure, List<MovieEntity>>> getTrendingTvShows({int page = 1});
  Future<Either<Failure, List<MovieEntity>>> getPopularTvShows({int page = 1});
  Future<Either<Failure, List<MovieEntity>>> getTopRatedTvShows({int page = 1});
  Future<Either<Failure, List<MovieEntity>>> searchTvShows(String query, {int page = 1});
  Future<Either<Failure, MovieEntity>> getTvShowDetails(int tvShowId);
  Future<Either<Failure, List<CastEntity>>> getTvShowCast(int tvShowId);
  Future<Either<Failure, List<VideoEntity>>> getTvShowVideos(int tvShowId);
  Future<Either<Failure, List<WatchProviderEntity>>> getTvShowWatchProviders(int tvShowId, {String region = 'US'});
  Future<Either<Failure, Map<String, List<MovieImageEntity>>>> getTvShowImages(int tvShowId);
  Future<Either<Failure, List<MovieEntity>>> getSimilarTvShows(int tvShowId, {int page = 1});
  
  // Person methods
  Future<Either<Failure, List<PersonEntity>>> searchPerson(String query, {int page = 1});
  Future<Either<Failure, PersonEntity>> getPersonDetails(int personId);
  Future<Either<Failure, Map<String, List<PersonMovieCreditEntity>>>> getPersonMovieCredits(int personId);
}

