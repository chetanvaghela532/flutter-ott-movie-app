import 'package:equatable/equatable.dart';
import '../../domain/entities/movie_entity.dart';

abstract class MoviesState extends Equatable {
  const MoviesState();

  @override
  List<Object> get props => [];
}

class MoviesInitial extends MoviesState {}

class MoviesLoading extends MoviesState {}

class MoviesLoaded extends MoviesState {
  final List<MovieEntity> movies;
  final int currentPage;
  final bool hasMorePages;
  final bool isLoadingMore;

  const MoviesLoaded({
    required this.movies,
    this.currentPage = 1,
    this.hasMorePages = true,
    this.isLoadingMore = false,
  });

  MoviesLoaded copyWith({
    List<MovieEntity>? movies,
    int? currentPage,
    bool? hasMorePages,
    bool? isLoadingMore,
  }) {
    return MoviesLoaded(
      movies: movies ?? this.movies,
      currentPage: currentPage ?? this.currentPage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object> get props => [movies, currentPage, hasMorePages, isLoadingMore];
}

class MoviesError extends MoviesState {
  final String message;

  const MoviesError(this.message);

  @override
  List<Object> get props => [message];
}

