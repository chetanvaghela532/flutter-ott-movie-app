import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../domain/entities/movie_entity.dart';
import '../../domain/entities/cast_entity.dart';
import '../../domain/entities/video_entity.dart';
import '../../domain/entities/watch_provider_entity.dart';
import '../../domain/entities/movie_image_entity.dart';
import '../../domain/entities/person_entity.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/movie_remote_data_source.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remoteDataSource;

  MovieRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<MovieEntity>>> getTrendingMovies({int page = 1}) async {
    try {
      final movies = await remoteDataSource.getTrendingMovies(page: page);
      return Right(movies);
    } on AppException catch (e) {
      return Left(FailureMapper.mapExceptionToFailure(e));
    } catch (e) {
      return Left(FailureMapper.mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<MovieEntity>>> getPopularMovies({int page = 1}) async {
    try {
      final movies = await remoteDataSource.getPopularMovies(page: page);
      return Right(movies);
    } on AppException catch (e) {
      return Left(FailureMapper.mapExceptionToFailure(e));
    } catch (e) {
      return Left(FailureMapper.mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<MovieEntity>>> getTopRatedMovies({int page = 1}) async {
    try {
      final movies = await remoteDataSource.getTopRatedMovies(page: page);
      return Right(movies);
    } on AppException catch (e) {
      return Left(FailureMapper.mapExceptionToFailure(e));
    } catch (e) {
      return Left(FailureMapper.mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<MovieEntity>>> getUpcomingMovies({int page = 1}) async {
    try {
      final movies = await remoteDataSource.getUpcomingMovies(page: page);
      return Right(movies);
    } on AppException catch (e) {
      return Left(FailureMapper.mapExceptionToFailure(e));
    } catch (e) {
      return Left(FailureMapper.mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, MovieEntity>> getMovieDetails(int movieId) async {
    try {
      final movie = await remoteDataSource.getMovieDetails(movieId);
      return Right(movie);
    } on AppException catch (e) {
      return Left(FailureMapper.mapExceptionToFailure(e));
    } catch (e) {
      return Left(FailureMapper.mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<CastEntity>>> getMovieCast(int movieId) async {
    try {
      final cast = await remoteDataSource.getMovieCast(movieId);
      return Right(cast);
    } on AppException catch (e) {
      return Left(FailureMapper.mapExceptionToFailure(e));
    } catch (e) {
      return Left(FailureMapper.mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<VideoEntity>>> getMovieVideos(int movieId) async {
    try {
      final videos = await remoteDataSource.getMovieVideos(movieId);
      return Right(videos);
    } on AppException catch (e) {
      return Left(FailureMapper.mapExceptionToFailure(e));
    } catch (e) {
      return Left(FailureMapper.mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<WatchProviderEntity>>> getMovieWatchProviders(int movieId, {String region = 'US'}) async {
    try {
      final providers = await remoteDataSource.getMovieWatchProviders(movieId, region: region);
      return Right(providers);
    } on AppException catch (e) {
      return Left(FailureMapper.mapExceptionToFailure(e));
    } catch (e) {
      return Left(FailureMapper.mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Map<String, List<MovieImageEntity>>>> getMovieImages(int movieId) async {
    try {
      final images = await remoteDataSource.getMovieImages(movieId);
      return Right(images);
    } on AppException catch (e) {
      return Left(FailureMapper.mapExceptionToFailure(e));
    } catch (e) {
      return Left(FailureMapper.mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<MovieEntity>>> searchMovies(String query, {int page = 1}) async {
    try {
      final movies = await remoteDataSource.searchMovies(query, page: page);
      return Right(movies);
    } on AppException catch (e) {
      return Left(FailureMapper.mapExceptionToFailure(e));
    } catch (e) {
      return Left(FailureMapper.mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<MovieEntity>>> getSimilarMovies(int movieId, {int page = 1}) async {
    try {
      final movies = await remoteDataSource.getSimilarMovies(movieId, page: page);
      return Right(movies);
    } on AppException catch (e) {
      return Left(FailureMapper.mapExceptionToFailure(e));
    } catch (e) {
      return Left(FailureMapper.mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<MovieEntity>>> getTrendingTvShows({int page = 1}) async {
    try {
      final tvShows = await remoteDataSource.getTrendingTvShows(page: page);
      return Right(tvShows);
    } on AppException catch (e) {
      return Left(FailureMapper.mapExceptionToFailure(e));
    } catch (e) {
      return Left(FailureMapper.mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<MovieEntity>>> getPopularTvShows({int page = 1}) async {
    try {
      final tvShows = await remoteDataSource.getPopularTvShows(page: page);
      return Right(tvShows);
    } on AppException catch (e) {
      return Left(FailureMapper.mapExceptionToFailure(e));
    } catch (e) {
      return Left(FailureMapper.mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<MovieEntity>>> getTopRatedTvShows({int page = 1}) async {
    try {
      final tvShows = await remoteDataSource.getTopRatedTvShows(page: page);
      return Right(tvShows);
    } on AppException catch (e) {
      return Left(FailureMapper.mapExceptionToFailure(e));
    } catch (e) {
      return Left(FailureMapper.mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<MovieEntity>>> searchTvShows(String query, {int page = 1}) async {
    try {
      final tvShows = await remoteDataSource.searchTvShows(query, page: page);
      return Right(tvShows);
    } on AppException catch (e) {
      return Left(FailureMapper.mapExceptionToFailure(e));
    } catch (e) {
      return Left(FailureMapper.mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, MovieEntity>> getTvShowDetails(int tvShowId) async {
    try {
      final tvShow = await remoteDataSource.getTvShowDetails(tvShowId);
      return Right(tvShow);
    } on AppException catch (e) {
      return Left(FailureMapper.mapExceptionToFailure(e));
    } catch (e) {
      return Left(FailureMapper.mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<CastEntity>>> getTvShowCast(int tvShowId) async {
    try {
      final cast = await remoteDataSource.getTvShowCast(tvShowId);
      return Right(cast);
    } on AppException catch (e) {
      return Left(FailureMapper.mapExceptionToFailure(e));
    } catch (e) {
      return Left(FailureMapper.mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<VideoEntity>>> getTvShowVideos(int tvShowId) async {
    try {
      final videos = await remoteDataSource.getTvShowVideos(tvShowId);
      return Right(videos);
    } on AppException catch (e) {
      return Left(FailureMapper.mapExceptionToFailure(e));
    } catch (e) {
      return Left(FailureMapper.mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<WatchProviderEntity>>> getTvShowWatchProviders(int tvShowId, {String region = 'US'}) async {
    try {
      final providers = await remoteDataSource.getTvShowWatchProviders(tvShowId, region: region);
      return Right(providers);
    } on AppException catch (e) {
      return Left(FailureMapper.mapExceptionToFailure(e));
    } catch (e) {
      return Left(FailureMapper.mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Map<String, List<MovieImageEntity>>>> getTvShowImages(int tvShowId) async {
    try {
      final images = await remoteDataSource.getTvShowImages(tvShowId);
      return Right(images);
    } on AppException catch (e) {
      return Left(FailureMapper.mapExceptionToFailure(e));
    } catch (e) {
      return Left(FailureMapper.mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<MovieEntity>>> getSimilarTvShows(int tvShowId, {int page = 1}) async {
    try {
      final tvShows = await remoteDataSource.getSimilarTvShows(tvShowId, page: page);
      return Right(tvShows);
    } on AppException catch (e) {
      return Left(FailureMapper.mapExceptionToFailure(e));
    } catch (e) {
      return Left(FailureMapper.mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<PersonEntity>>> searchPerson(String query, {int page = 1}) async {
    try {
      final persons = await remoteDataSource.searchPerson(query, page: page);
      return Right(persons);
    } on AppException catch (e) {
      return Left(FailureMapper.mapExceptionToFailure(e));
    } catch (e) {
      return Left(FailureMapper.mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, PersonEntity>> getPersonDetails(int personId) async {
    try {
      final person = await remoteDataSource.getPersonDetails(personId);
      return Right(person);
    } on AppException catch (e) {
      return Left(FailureMapper.mapExceptionToFailure(e));
    } catch (e) {
      return Left(FailureMapper.mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Map<String, List<PersonMovieCreditEntity>>>> getPersonMovieCredits(int personId) async {
    try {
      final credits = await remoteDataSource.getPersonMovieCredits(personId);
      return Right(credits);
    } on AppException catch (e) {
      return Left(FailureMapper.mapExceptionToFailure(e));
    } catch (e) {
      return Left(FailureMapper.mapErrorToFailure(e));
    }
  }
}

