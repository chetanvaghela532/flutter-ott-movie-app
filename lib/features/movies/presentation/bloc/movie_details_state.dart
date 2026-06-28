import 'package:equatable/equatable.dart';
import '../../domain/entities/movie_entity.dart';
import '../../domain/entities/cast_entity.dart';
import '../../domain/entities/video_entity.dart';
import '../../domain/entities/watch_provider_entity.dart';
import '../../domain/entities/movie_image_entity.dart';

abstract class MovieDetailsState extends Equatable {
  const MovieDetailsState();

  @override
  List<Object> get props => [];
}

class MovieDetailsInitial extends MovieDetailsState {}

class MovieDetailsLoading extends MovieDetailsState {}

class MovieDetailsLoaded extends MovieDetailsState {
  final MovieEntity movie;
  final List<CastEntity>? cast;
  final List<MovieEntity>? similarMovies;
  final List<VideoEntity>? videos;
  final List<Map<String, dynamic>>? crew;
  final List<WatchProviderEntity>? watchProviders;
  final Map<String, List<MovieImageEntity>>? images;

  const MovieDetailsLoaded({
    required this.movie,
    this.cast,
    this.similarMovies,
    this.videos,
    this.crew,
    this.watchProviders,
    this.images,
  });

  @override
  List<Object> get props => [movie, cast ?? [], similarMovies ?? [], videos ?? [], crew ?? [], watchProviders ?? [], images ?? {}];
  
  MovieDetailsLoaded copyWith({
    MovieEntity? movie,
    List<CastEntity>? cast,
    List<MovieEntity>? similarMovies,
    List<VideoEntity>? videos,
    List<Map<String, dynamic>>? crew,
    List<WatchProviderEntity>? watchProviders,
    Map<String, List<MovieImageEntity>>? images,
  }) {
    return MovieDetailsLoaded(
      movie: movie ?? this.movie,
      cast: cast ?? this.cast,
      similarMovies: similarMovies ?? this.similarMovies,
      videos: videos ?? this.videos,
      crew: crew ?? this.crew,
      watchProviders: watchProviders ?? this.watchProviders,
      images: images ?? this.images,
    );
  }
}

class MovieDetailsError extends MovieDetailsState {
  final String message;

  const MovieDetailsError(this.message);

  @override
  List<Object> get props => [message];
}

