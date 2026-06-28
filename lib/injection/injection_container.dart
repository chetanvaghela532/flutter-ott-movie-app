import 'package:get_it/get_it.dart';
import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../features/movies/data/datasources/movie_remote_data_source.dart';
import '../features/movies/data/repositories/movie_repository_impl.dart';
import '../features/movies/domain/repositories/movie_repository.dart';
import '../features/movies/domain/usecases/get_trending_movies.dart';
import '../features/movies/domain/usecases/get_popular_movies.dart';
import '../features/movies/domain/usecases/get_top_rated_movies.dart';
import '../features/movies/domain/usecases/get_upcoming_movies.dart';
import '../features/movies/domain/usecases/get_movie_details.dart';
import '../features/movies/domain/usecases/get_movie_cast.dart';
import '../features/movies/domain/usecases/get_movie_videos.dart';
import '../features/movies/domain/usecases/get_movie_watch_providers.dart';
import '../features/movies/domain/usecases/get_movie_images.dart';
import '../features/movies/domain/usecases/get_similar_movies.dart';
import '../features/movies/domain/usecases/search_movies.dart';
import '../features/movies/domain/usecases/get_trending_tv_shows.dart';
import '../features/movies/domain/usecases/get_popular_tv_shows.dart';
import '../features/movies/domain/usecases/get_top_rated_tv_shows.dart';
import '../features/movies/domain/usecases/get_tv_show_details.dart';
import '../features/movies/domain/usecases/get_tv_show_cast.dart';
import '../features/movies/domain/usecases/get_tv_show_videos.dart';
import '../features/movies/domain/usecases/get_tv_show_watch_providers.dart';
import '../features/movies/domain/usecases/get_tv_show_images.dart';
import '../features/movies/domain/usecases/get_similar_tv_shows.dart';
import '../features/movies/domain/usecases/search_person.dart';
import '../features/movies/domain/usecases/get_person_details.dart';
import '../features/movies/domain/usecases/get_person_movie_credits.dart';
import '../features/movies/presentation/bloc/movies_bloc.dart';
import '../features/movies/presentation/bloc/movie_details_bloc.dart';
import '../features/movies/presentation/bloc/tv_show_details_bloc.dart';
import '../features/movies/presentation/bloc/person_search_bloc.dart';
import '../features/movies/presentation/bloc/person_details_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Core
  sl.registerLazySingleton<DioClient>(
    () => DioClient(baseUrl: ApiConstants.tmdbBaseUrl),
  );

  //! Features - Movies
  // Data sources
  sl.registerLazySingleton<MovieRemoteDataSource>(
    () => MovieRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<MovieRepository>(
    () => MovieRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetTrendingMovies(sl()));
  sl.registerLazySingleton(() => GetPopularMovies(sl()));
  sl.registerLazySingleton(() => GetTopRatedMovies(sl()));
  sl.registerLazySingleton(() => GetUpcomingMovies(sl()));
  sl.registerLazySingleton(() => GetMovieDetails(sl()));
  sl.registerLazySingleton(() => GetMovieCast(sl()));
  sl.registerLazySingleton(() => GetMovieVideos(sl()));
  sl.registerLazySingleton(() => GetMovieWatchProviders(sl()));
  sl.registerLazySingleton(() => GetMovieImages(sl()));
  sl.registerLazySingleton(() => GetSimilarMovies(sl()));
  sl.registerLazySingleton(() => SearchMovies(sl()));
  sl.registerLazySingleton(() => GetTrendingTvShows(sl()));
  sl.registerLazySingleton(() => GetPopularTvShows(sl()));
  sl.registerLazySingleton(() => GetTopRatedTvShows(sl()));
  sl.registerLazySingleton(() => GetTvShowDetails(sl()));
  sl.registerLazySingleton(() => GetTvShowCast(sl()));
  sl.registerLazySingleton(() => GetTvShowVideos(sl()));
  sl.registerLazySingleton(() => GetTvShowWatchProviders(sl()));
  sl.registerLazySingleton(() => GetTvShowImages(sl()));
  sl.registerLazySingleton(() => GetSimilarTvShows(sl()));
  sl.registerLazySingleton(() => SearchPerson(sl()));
  sl.registerLazySingleton(() => GetPersonDetails(sl()));
  sl.registerLazySingleton(() => GetPersonMovieCredits(sl()));

  // BLoC Factory - creates new instances each time
  sl.registerFactory(
    () => MoviesBloc(
      getTrendingMovies: sl(),
      getPopularMovies: sl(),
      getTopRatedMovies: sl(),
      getUpcomingMovies: sl(),
      searchMovies: sl(),
      getTrendingTvShows: sl(),
      getPopularTvShows: sl(),
      getTopRatedTvShows: sl(),
    ),
  );

  sl.registerFactory(
    () => MovieDetailsBloc(
      getMovieDetails: sl(),
      getMovieCast: sl(),
      getMovieVideos: sl(),
      getMovieWatchProviders: sl(),
      getMovieImages: sl(),
      getSimilarMovies: sl(),
    ),
  );

  sl.registerFactory(
    () => TvShowDetailsBloc(
      getTvShowDetails: sl(),
      getTvShowCast: sl(),
      getTvShowVideos: sl(),
      getTvShowWatchProviders: sl(),
      getTvShowImages: sl(),
      getSimilarTvShows: sl(),
    ),
  );

  sl.registerFactory(
    () => PersonSearchBloc(
      searchPerson: sl(),
    ),
  );

  sl.registerFactory(
    () => PersonDetailsBloc(
      getPersonDetails: sl(),
      getPersonMovieCredits: sl(),
    ),
  );
}
