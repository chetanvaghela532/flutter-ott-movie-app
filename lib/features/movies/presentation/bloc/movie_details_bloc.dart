import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/get_movie_details.dart';
import '../../domain/usecases/get_movie_cast.dart';
import '../../domain/usecases/get_movie_videos.dart';
import '../../domain/usecases/get_movie_watch_providers.dart';
import '../../domain/usecases/get_movie_images.dart';
import '../../domain/usecases/get_similar_movies.dart';
import '../../domain/entities/movie_entity.dart';
import '../../domain/entities/cast_entity.dart';
import '../../domain/entities/video_entity.dart';
import '../../domain/entities/watch_provider_entity.dart';
import '../../domain/entities/movie_image_entity.dart';
import 'movie_details_event.dart';
import 'movie_details_state.dart';

class MovieDetailsBloc extends Bloc<MovieDetailsEvent, MovieDetailsState> {
  final GetMovieDetails getMovieDetails;
  final GetMovieCast getMovieCast;
  final GetMovieVideos getMovieVideos;
  final GetMovieWatchProviders getMovieWatchProviders;
  final GetMovieImages getMovieImages;
  final GetSimilarMovies getSimilarMovies;

  MovieDetailsBloc({
    required this.getMovieDetails,
    required this.getMovieCast,
    required this.getMovieVideos, 
    required this.getMovieWatchProviders,
    required this.getMovieImages,
    required this.getSimilarMovies,
  }) : super(MovieDetailsInitial()) {
    on<LoadMovieDetails>(_onLoadMovieDetails);
    on<LoadMovieCast>(_onLoadMovieCast);
    on<LoadSimilarMovies>(_onLoadSimilarMovies);
    on<LoadMovieVideos>(_onLoadMovieVideos);
    on<LoadMovieCrew>(_onLoadMovieCrew);
    on<LoadAllMovieDetails>(_onLoadAllMovieDetails);
  }

  Future<void> _onLoadMovieDetails(
    LoadMovieDetails event,
    Emitter<MovieDetailsState> emit,
  ) async {
    emit(MovieDetailsLoading());
    final result = await getMovieDetails(event.movieId);
    result.fold(
      (failure) => emit(MovieDetailsError(failure.message)),
      (movie) => emit(MovieDetailsLoaded(movie: movie)),
    );
  }

  Future<void> _onLoadMovieCast(
    LoadMovieCast event,
    Emitter<MovieDetailsState> emit,
  ) async {
    final result = await getMovieCast(event.movieId);
    result.fold(
      (failure) {
        if (state is MovieDetailsLoaded) {
          emit((state as MovieDetailsLoaded).copyWith(cast: null));
        }
      },
      (cast) {
        if (state is MovieDetailsLoaded) {
          emit((state as MovieDetailsLoaded).copyWith(cast: cast));
        }
      },
    );
  }

  Future<void> _onLoadSimilarMovies(
    LoadSimilarMovies event,
    Emitter<MovieDetailsState> emit,
  ) async {
    final result = await getSimilarMovies(event.movieId, page: event.page);
    result.fold(
      (failure) {
        if (state is MovieDetailsLoaded) {
          emit((state as MovieDetailsLoaded).copyWith(similarMovies: null));
        }
      },
      (similarMovies) {
        if (state is MovieDetailsLoaded) {
          emit((state as MovieDetailsLoaded).copyWith(similarMovies: similarMovies));
        }
      },
    );
  }

  Future<void> _onLoadMovieVideos(
    LoadMovieVideos event,
    Emitter<MovieDetailsState> emit,
  ) async {
    final result = await getMovieVideos(event.movieId);
    result.fold(
      (failure) {
        // Silently fail - videos are optional
        if (state is MovieDetailsLoaded) {
          emit((state as MovieDetailsLoaded).copyWith(videos: null));
        }
      },
      (videos) {
        if (state is MovieDetailsLoaded) {
          emit((state as MovieDetailsLoaded).copyWith(videos: videos));
        }
      },
    );
  }

  Future<void> _onLoadMovieCrew(
    LoadMovieCrew event,
    Emitter<MovieDetailsState> emit,
  ) async {
    // Crew is optional - silently fail if not available
    // TODO: Implement proper crew use case if needed
    if (state is MovieDetailsLoaded) {
      emit((state as MovieDetailsLoaded).copyWith(crew: null));
    }
  }

  Future<void> _onLoadAllMovieDetails(
    LoadAllMovieDetails event,
    Emitter<MovieDetailsState> emit,
  ) async {
    // Emit loading state first
    emit(MovieDetailsLoading());

    // Call all APIs in parallel with explicit types
    final Future<Either<Failure, MovieEntity>> movieDetailsFuture = getMovieDetails(event.movieId);
    final Future<Either<Failure, List<CastEntity>>> castFuture = getMovieCast(event.movieId);
    final Future<Either<Failure, List<VideoEntity>>> videosFuture = getMovieVideos(event.movieId);
    final Future<Either<Failure, List<WatchProviderEntity>>> watchProvidersFuture = getMovieWatchProviders(event.movieId);
    final Future<Either<Failure, Map<String, List<MovieImageEntity>>>> imagesFuture = getMovieImages(event.movieId);
    final Future<Either<Failure, List<MovieEntity>>> similarMoviesFuture = getSimilarMovies(event.movieId);

    // Wait for all APIs to complete
    final results = await Future.wait([
      movieDetailsFuture,
      castFuture,
      videosFuture,
      watchProvidersFuture,
      imagesFuture,
      similarMoviesFuture,
    ]);

    // Extract results with proper typing
    final movieDetailsResult = results[0] as Either<Failure, MovieEntity>;
    final castResult = results[1] as Either<Failure, List<CastEntity>>;
    final videosResult = results[2] as Either<Failure, List<VideoEntity>>;
    final watchProvidersResult = results[3] as Either<Failure, List<WatchProviderEntity>>;
    final imagesResult = results[4] as Either<Failure, Map<String, List<MovieImageEntity>>>;
    final similarMoviesResult = results[5] as Either<Failure, List<MovieEntity>>;

    // Check if main movie details failed
    movieDetailsResult.fold(
      (failure) => emit(MovieDetailsError(failure.message)),
      (movie) {
        // Extract optional data (cast, videos, similar movies)
        List<CastEntity>? cast;
        castResult.fold(
          (failure) => cast = null,
          (castData) => cast = castData,
        );

        List<VideoEntity>? videos;
        videosResult.fold(
          (failure) => videos = null,
          (videosData) => videos = videosData,
        );

        List<MovieEntity>? similarMovies;
        similarMoviesResult.fold(
          (failure) => similarMovies = null,
          (similarMoviesData) => similarMovies = similarMoviesData,
        );

        List<WatchProviderEntity>? watchProviders;
        watchProvidersResult.fold(
          (failure) => watchProviders = null,
          (watchProvidersData) => watchProviders = watchProvidersData,
        );

        Map<String, List<MovieImageEntity>>? images;
        imagesResult.fold(
          (failure) => images = null,
          (imagesData) => images = imagesData,
        );

        // Extract crew from cast data if available
        // Since crew comes from the same credits endpoint, we'll set it to null for now
        // TODO: Implement proper crew extraction if needed
        List<Map<String, dynamic>>? crew = null;

        // Emit final state with all data
        emit(MovieDetailsLoaded(
          movie: movie,
          cast: cast,
          videos: videos,
          similarMovies: similarMovies,
          crew: crew,
          watchProviders: watchProviders,
          images: images,
        ));
      },
    );
  }
}


