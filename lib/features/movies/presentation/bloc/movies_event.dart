import 'package:equatable/equatable.dart';

abstract class MoviesEvent extends Equatable {
  const MoviesEvent();

  @override
  List<Object> get props => [];
}

class LoadTrendingMovies extends MoviesEvent {
  final int page;
  const LoadTrendingMovies({this.page = 1});

  @override
  List<Object> get props => [page];
}

class LoadPopularMovies extends MoviesEvent {
  final int page;
  const LoadPopularMovies({this.page = 1});

  @override
  List<Object> get props => [page];
}

class LoadTopRatedMovies extends MoviesEvent {
  final int page;
  const LoadTopRatedMovies({this.page = 1});

  @override
  List<Object> get props => [page];
}

class LoadUpcomingMovies extends MoviesEvent {
  final int page;
  const LoadUpcomingMovies({this.page = 1});

  @override
  List<Object> get props => [page];
}

class SearchMoviesEvent extends MoviesEvent {
  final String query;
  final int page;
  const SearchMoviesEvent(this.query, {this.page = 1});

  @override
  List<Object> get props => [query, page];
}

// TV Show Events
class LoadTrendingTvShows extends MoviesEvent {
  final int page;
  const LoadTrendingTvShows({this.page = 1});

  @override
  List<Object> get props => [page];
}

class LoadPopularTvShows extends MoviesEvent {
  final int page;
  const LoadPopularTvShows({this.page = 1});

  @override
  List<Object> get props => [page];
}

class LoadTopRatedTvShows extends MoviesEvent {
  final int page;
  const LoadTopRatedTvShows({this.page = 1});

  @override
  List<Object> get props => [page];
}

class LoadMoreMovies extends MoviesEvent {
  const LoadMoreMovies();

  @override
  List<Object> get props => [];
}

