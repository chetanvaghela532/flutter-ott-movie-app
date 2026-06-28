import 'package:equatable/equatable.dart';
import '../../domain/entities/movie_entity.dart';
import '../../domain/entities/cast_entity.dart';
import '../../domain/entities/video_entity.dart';
import '../../domain/entities/watch_provider_entity.dart';
import '../../domain/entities/movie_image_entity.dart';

abstract class TvShowDetailsState extends Equatable {
  const TvShowDetailsState();

  @override
  List<Object> get props => [];
}

class TvShowDetailsInitial extends TvShowDetailsState {}

class TvShowDetailsLoading extends TvShowDetailsState {}

class TvShowDetailsLoaded extends TvShowDetailsState {
  final MovieEntity tvShow;
  final List<CastEntity>? cast;
  final List<MovieEntity>? similarTvShows;
  final List<VideoEntity>? videos;
  final List<WatchProviderEntity>? watchProviders;
  final Map<String, List<MovieImageEntity>>? images;

  const TvShowDetailsLoaded({
    required this.tvShow,
    this.cast,
    this.similarTvShows,
    this.videos,
    this.watchProviders,
    this.images,
  });

  @override
  List<Object> get props => [tvShow, cast ?? [], similarTvShows ?? [], videos ?? [], watchProviders ?? [], images ?? {}];
  
  TvShowDetailsLoaded copyWith({
    MovieEntity? tvShow,
    List<CastEntity>? cast,
    List<MovieEntity>? similarTvShows,
    List<VideoEntity>? videos,
    List<WatchProviderEntity>? watchProviders,
    Map<String, List<MovieImageEntity>>? images,
  }) {
    return TvShowDetailsLoaded(
      tvShow: tvShow ?? this.tvShow,
      cast: cast ?? this.cast,
      similarTvShows: similarTvShows ?? this.similarTvShows,
      videos: videos ?? this.videos,
      watchProviders: watchProviders ?? this.watchProviders,
      images: images ?? this.images,
    );
  }
}

class TvShowDetailsError extends TvShowDetailsState {
  final String message;

  const TvShowDetailsError(this.message);

  @override
  List<Object> get props => [message];
}

