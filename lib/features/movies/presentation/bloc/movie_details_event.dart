import 'package:equatable/equatable.dart';

abstract class MovieDetailsEvent extends Equatable {
  const MovieDetailsEvent();

  @override
  List<Object> get props => [];
}

class LoadMovieDetails extends MovieDetailsEvent {
  final int movieId;
  const LoadMovieDetails(this.movieId);

  @override
  List<Object> get props => [movieId];
}

class LoadMovieCast extends MovieDetailsEvent {
  final int movieId;
  const LoadMovieCast(this.movieId);

  @override
  List<Object> get props => [movieId];
}

class LoadSimilarMovies extends MovieDetailsEvent {
  final int movieId;
  final int page;
  const LoadSimilarMovies(this.movieId, {this.page = 1});

  @override
  List<Object> get props => [movieId, page];
}

class LoadMovieVideos extends MovieDetailsEvent {
  final int movieId;
  const LoadMovieVideos(this.movieId);

  @override
  List<Object> get props => [movieId];
}

class LoadMovieCrew extends MovieDetailsEvent {
  final int movieId;
  const LoadMovieCrew(this.movieId);

  @override
  List<Object> get props => [movieId];
}

class LoadAllMovieDetails extends MovieDetailsEvent {
  final int movieId;
  const LoadAllMovieDetails(this.movieId);

  @override
  List<Object> get props => [movieId];
}

