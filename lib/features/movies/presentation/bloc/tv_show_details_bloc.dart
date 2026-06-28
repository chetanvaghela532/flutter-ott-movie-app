import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/get_tv_show_details.dart';
import '../../domain/usecases/get_tv_show_cast.dart';
import '../../domain/usecases/get_tv_show_videos.dart';
import '../../domain/usecases/get_tv_show_watch_providers.dart';
import '../../domain/usecases/get_tv_show_images.dart';
import '../../domain/usecases/get_similar_tv_shows.dart';
import '../../domain/entities/movie_entity.dart';
import '../../domain/entities/cast_entity.dart';
import '../../domain/entities/video_entity.dart';
import '../../domain/entities/watch_provider_entity.dart';
import '../../domain/entities/movie_image_entity.dart';
import 'tv_show_details_event.dart';
import 'tv_show_details_state.dart';

class TvShowDetailsBloc extends Bloc<TvShowDetailsEvent, TvShowDetailsState> {
  final GetTvShowDetails getTvShowDetails;
  final GetTvShowCast getTvShowCast;
  final GetTvShowVideos getTvShowVideos;
  final GetTvShowWatchProviders getTvShowWatchProviders;
  final GetTvShowImages getTvShowImages;
  final GetSimilarTvShows getSimilarTvShows;

  TvShowDetailsBloc({
    required this.getTvShowDetails,
    required this.getTvShowCast,
    required this.getTvShowVideos,
    required this.getTvShowWatchProviders,
    required this.getTvShowImages,
    required this.getSimilarTvShows,
  }) : super(TvShowDetailsInitial()) {
    on<LoadTvShowDetails>(_onLoadTvShowDetails);
    on<LoadTvShowCast>(_onLoadTvShowCast);
    on<LoadSimilarTvShows>(_onLoadSimilarTvShows);
    on<LoadTvShowVideos>(_onLoadTvShowVideos);
    on<LoadAllTvShowDetails>(_onLoadAllTvShowDetails);
  }

  Future<void> _onLoadTvShowDetails(
    LoadTvShowDetails event,
    Emitter<TvShowDetailsState> emit,
  ) async {
    emit(TvShowDetailsLoading());
    final result = await getTvShowDetails(event.tvShowId);
    result.fold(
      (failure) => emit(TvShowDetailsError(failure.message)),
      (tvShow) => emit(TvShowDetailsLoaded(tvShow: tvShow)),
    );
  }

  Future<void> _onLoadTvShowCast(
    LoadTvShowCast event,
    Emitter<TvShowDetailsState> emit,
  ) async {
    final result = await getTvShowCast(event.tvShowId);
    result.fold(
      (failure) {
        if (state is TvShowDetailsLoaded) {
          emit((state as TvShowDetailsLoaded).copyWith(cast: null));
        }
      },
      (cast) {
        if (state is TvShowDetailsLoaded) {
          emit((state as TvShowDetailsLoaded).copyWith(cast: cast));
        }
      },
    );
  }

  Future<void> _onLoadSimilarTvShows(
    LoadSimilarTvShows event,
    Emitter<TvShowDetailsState> emit,
  ) async {
    final result = await getSimilarTvShows(event.tvShowId, page: event.page);
    result.fold(
      (failure) {
        if (state is TvShowDetailsLoaded) {
          emit((state as TvShowDetailsLoaded).copyWith(similarTvShows: null));
        }
      },
      (similarTvShows) {
        if (state is TvShowDetailsLoaded) {
          emit((state as TvShowDetailsLoaded).copyWith(similarTvShows: similarTvShows));
        }
      },
    );
  }

  Future<void> _onLoadTvShowVideos(
    LoadTvShowVideos event,
    Emitter<TvShowDetailsState> emit,
  ) async {
    final result = await getTvShowVideos(event.tvShowId);
    result.fold(
      (failure) {
        // Silently fail - videos are optional
        if (state is TvShowDetailsLoaded) {
          emit((state as TvShowDetailsLoaded).copyWith(videos: null));
        }
      },
      (videos) {
        if (state is TvShowDetailsLoaded) {
          emit((state as TvShowDetailsLoaded).copyWith(videos: videos));
        }
      },
    );
  }

  Future<void> _onLoadAllTvShowDetails(
    LoadAllTvShowDetails event,
    Emitter<TvShowDetailsState> emit,
  ) async {
    // Emit loading state first
    emit(TvShowDetailsLoading());

    // Call all APIs in parallel with explicit types
    final Future<Either<Failure, MovieEntity>> tvShowDetailsFuture = getTvShowDetails(event.tvShowId);
    final Future<Either<Failure, List<CastEntity>>> castFuture = getTvShowCast(event.tvShowId);
    final Future<Either<Failure, List<VideoEntity>>> videosFuture = getTvShowVideos(event.tvShowId);
    final Future<Either<Failure, List<WatchProviderEntity>>> watchProvidersFuture = getTvShowWatchProviders(event.tvShowId);
    final Future<Either<Failure, Map<String, List<MovieImageEntity>>>> imagesFuture = getTvShowImages(event.tvShowId);
    final Future<Either<Failure, List<MovieEntity>>> similarTvShowsFuture = getSimilarTvShows(event.tvShowId);

    // Wait for all APIs to complete
    final results = await Future.wait([
      tvShowDetailsFuture,
      castFuture,
      videosFuture,
      watchProvidersFuture,
      imagesFuture,
      similarTvShowsFuture,
    ]);

    // Extract results with proper typing
    final tvShowDetailsResult = results[0] as Either<Failure, MovieEntity>;
    final castResult = results[1] as Either<Failure, List<CastEntity>>;
    final videosResult = results[2] as Either<Failure, List<VideoEntity>>;
    final watchProvidersResult = results[3] as Either<Failure, List<WatchProviderEntity>>;
    final imagesResult = results[4] as Either<Failure, Map<String, List<MovieImageEntity>>>;
    final similarTvShowsResult = results[5] as Either<Failure, List<MovieEntity>>;

    // Check if main TV show details failed
    tvShowDetailsResult.fold(
      (failure) => emit(TvShowDetailsError(failure.message)),
      (tvShow) {
        // Extract optional data (cast, videos, similar TV shows)
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

        List<MovieEntity>? similarTvShows;
        similarTvShowsResult.fold(
          (failure) => similarTvShows = null,
          (similarTvShowsData) => similarTvShows = similarTvShowsData,
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

        // Emit final state with all data
        emit(TvShowDetailsLoaded(
          tvShow: tvShow,
          cast: cast,
          videos: videos,
          similarTvShows: similarTvShows,
          watchProviders: watchProviders,
          images: images,
        ));
      },
    );
  }
}

