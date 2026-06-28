import 'package:equatable/equatable.dart';

abstract class TvShowDetailsEvent extends Equatable {
  const TvShowDetailsEvent();

  @override
  List<Object> get props => [];
}

class LoadTvShowDetails extends TvShowDetailsEvent {
  final int tvShowId;
  const LoadTvShowDetails(this.tvShowId);

  @override
  List<Object> get props => [tvShowId];
}

class LoadTvShowCast extends TvShowDetailsEvent {
  final int tvShowId;
  const LoadTvShowCast(this.tvShowId);

  @override
  List<Object> get props => [tvShowId];
}

class LoadSimilarTvShows extends TvShowDetailsEvent {
  final int tvShowId;
  final int page;
  const LoadSimilarTvShows(this.tvShowId, {this.page = 1});

  @override
  List<Object> get props => [tvShowId, page];
}

class LoadTvShowVideos extends TvShowDetailsEvent {
  final int tvShowId;
  const LoadTvShowVideos(this.tvShowId);

  @override
  List<Object> get props => [tvShowId];
}

class LoadAllTvShowDetails extends TvShowDetailsEvent {
  final int tvShowId;
  const LoadAllTvShowDetails(this.tvShowId);

  @override
  List<Object> get props => [tvShowId];
}

