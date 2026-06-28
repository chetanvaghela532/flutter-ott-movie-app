import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/movie_entity.dart';
import '../../domain/usecases/get_trending_movies.dart';
import '../../domain/usecases/get_popular_movies.dart';
import '../../domain/usecases/get_top_rated_movies.dart';
import '../../domain/usecases/get_upcoming_movies.dart';
import '../../domain/usecases/search_movies.dart' as usecases;
import '../../domain/usecases/get_trending_tv_shows.dart';
import '../../domain/usecases/get_popular_tv_shows.dart';
import '../../domain/usecases/get_top_rated_tv_shows.dart';
import 'movies_event.dart';
import 'movies_state.dart';

class MoviesBloc extends Bloc<MoviesEvent, MoviesState> {
  final GetTrendingMovies getTrendingMovies;
  final GetPopularMovies getPopularMovies;
  final GetTopRatedMovies getTopRatedMovies;
  final GetUpcomingMovies getUpcomingMovies;
  final usecases.SearchMovies searchMovies;
  final GetTrendingTvShows getTrendingTvShows;
  final GetPopularTvShows getPopularTvShows;
  final GetTopRatedTvShows getTopRatedTvShows;

  // Track the last event type and query for pagination
  String? _lastEventType; // 'trending', 'search', etc.
  String? _lastSearchQuery;

  MoviesBloc({
    required this.getTrendingMovies,
    required this.getPopularMovies,
    required this.getTopRatedMovies,
    required this.getUpcomingMovies,
    required this.searchMovies,
    required this.getTrendingTvShows,
    required this.getPopularTvShows,
    required this.getTopRatedTvShows,
  }) : super(MoviesInitial()) {
    on<LoadTrendingMovies>(_onLoadTrendingMovies);
    on<LoadPopularMovies>(_onLoadPopularMovies);
    on<LoadTopRatedMovies>(_onLoadTopRatedMovies);
    on<LoadUpcomingMovies>(_onLoadUpcomingMovies);
    on<SearchMoviesEvent>(_onSearchMovies);
    on<LoadTrendingTvShows>(_onLoadTrendingTvShows);
    on<LoadPopularTvShows>(_onLoadPopularTvShows);
    on<LoadTopRatedTvShows>(_onLoadTopRatedTvShows);
    on<LoadMoreMovies>(_onLoadMoreMovies);
  }

  Future<void> _onLoadTrendingMovies(
    LoadTrendingMovies event,
    Emitter<MoviesState> emit,
  ) async {
    _lastEventType = 'trending';
    _lastSearchQuery = null;
    emit(MoviesLoading());
    final result = await getTrendingMovies(page: event.page);
    result.fold(
      (failure) => emit(MoviesError(failure.message)),
      (movies) => emit(MoviesLoaded(
        movies: movies,
        currentPage: event.page,
        hasMorePages: movies.length >= 20, // TMDB typically returns 20 per page
      )),
    );
  }

  Future<void> _onLoadPopularMovies(
    LoadPopularMovies event,
    Emitter<MoviesState> emit,
  ) async {
    emit(MoviesLoading());
    final result = await getPopularMovies(page: event.page);
    result.fold(
      (failure) => emit(MoviesError(failure.message)),
      (movies) => emit(MoviesLoaded(
        movies: movies,
        currentPage: event.page,
        hasMorePages: movies.length >= 20,
      )),
    );
  }

  Future<void> _onLoadTopRatedMovies(
    LoadTopRatedMovies event,
    Emitter<MoviesState> emit,
  ) async {
    emit(MoviesLoading());
    final result = await getTopRatedMovies(page: event.page);
    result.fold(
      (failure) => emit(MoviesError(failure.message)),
      (movies) => emit(MoviesLoaded(
        movies: movies,
        currentPage: event.page,
        hasMorePages: movies.length >= 20,
      )),
    );
  }

  Future<void> _onLoadUpcomingMovies(
    LoadUpcomingMovies event,
    Emitter<MoviesState> emit,
  ) async {
    emit(MoviesLoading());
    final result = await getUpcomingMovies(page: event.page);
    result.fold(
      (failure) => emit(MoviesError(failure.message)),
      (movies) => emit(MoviesLoaded(
        movies: movies,
        currentPage: event.page,
        hasMorePages: movies.length >= 20,
      )),
    );
  }

  Future<void> _onSearchMovies(
    SearchMoviesEvent event,
    Emitter<MoviesState> emit,
  ) async {
    _lastEventType = 'search';
    _lastSearchQuery = event.query;
    emit(MoviesLoading());
    final result = await searchMovies(event.query, page: event.page);
    result.fold(
      (failure) => emit(MoviesError(failure.message)),
      (movies) => emit(MoviesLoaded(
        movies: movies,
        currentPage: event.page,
        hasMorePages: movies.length >= 20, // TMDB typically returns 20 per page
      )),
    );
  }

  Future<void> _onLoadTrendingTvShows(
    LoadTrendingTvShows event,
    Emitter<MoviesState> emit,
  ) async {
    emit(MoviesLoading());
    final result = await getTrendingTvShows(page: event.page);
    result.fold(
      (failure) => emit(MoviesError(failure.message)),
      (tvShows) => emit(MoviesLoaded(
        movies: tvShows,
        currentPage: event.page,
        hasMorePages: tvShows.length >= 20,
      )),
    );
  }

  Future<void> _onLoadPopularTvShows(
    LoadPopularTvShows event,
    Emitter<MoviesState> emit,
  ) async {
    emit(MoviesLoading());
    final result = await getPopularTvShows(page: event.page);
    result.fold(
      (failure) => emit(MoviesError(failure.message)),
      (tvShows) => emit(MoviesLoaded(
        movies: tvShows,
        currentPage: event.page,
        hasMorePages: tvShows.length >= 20,
      )),
    );
  }

  Future<void> _onLoadTopRatedTvShows(
    LoadTopRatedTvShows event,
    Emitter<MoviesState> emit,
  ) async {
    emit(MoviesLoading());
    final result = await getTopRatedTvShows(page: event.page);
    result.fold(
      (failure) => emit(MoviesError(failure.message)),
      (tvShows) => emit(MoviesLoaded(
        movies: tvShows,
        currentPage: event.page,
        hasMorePages: tvShows.length >= 20,
      )),
    );
  }

  Future<void> _onLoadMoreMovies(
    LoadMoreMovies event,
    Emitter<MoviesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MoviesLoaded) return;
    if (!currentState.hasMorePages || currentState.isLoadingMore) return;

    // Set loading more state
    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.currentPage + 1;
      Either<Failure, List<MovieEntity>> result;

      if (_lastEventType == 'trending') {
        result = await getTrendingMovies(page: nextPage);
      } else if (_lastEventType == 'search' && _lastSearchQuery != null) {
        result = await searchMovies(_lastSearchQuery!, page: nextPage);
      } else {
        // Default to trending if unknown
        result = await getTrendingMovies(page: nextPage);
      }

      result.fold(
        (failure) {
          emit(MoviesError(failure.message));
        },
        (newMovies) {
          final allMovies = [...currentState.movies, ...newMovies];
          final hasMore = newMovies.length >= 20; // Assume more pages if we got a full page
          emit(MoviesLoaded(
            movies: allMovies,
            currentPage: nextPage,
            hasMorePages: hasMore,
            isLoadingMore: false,
          ));
        },
      );
    } catch (e) {
      emit(MoviesError(e.toString()));
    }
  }
}

