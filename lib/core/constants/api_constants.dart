class ApiConstants {
  static const String tmdbApiKey = String.fromEnvironment('TMDB_API_KEY');
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p';

  // API Endpoints - Movies
  static const String trendingMovies = '/trending/movie/week';
  static const String popularMovies = '/movie/popular';
  static const String topRatedMovies = '/movie/top_rated';
  static const String upcomingMovies = '/movie/upcoming';
  static const String movieDetails = '/movie';
  static const String searchMovies = '/search/movie';
  static const String movieWatchProviders =
      '/movie'; // /movie/{id}/watch/providers

  // API Endpoints - TV Shows
  static const String trendingTvShows = '/trending/tv/week';
  static const String popularTvShows = '/tv/popular';
  static const String topRatedTvShows = '/tv/top_rated';
  static const String tvDetails = '/tv';
  static const String searchTvShows = '/search/tv';

  // API Endpoints - Person
  static const String searchPerson = '/search/person';
  static const String personDetails = '/person';

  // Image sizes
  static const String posterSize = 'w500';
  static const String backdropSize = 'w1280';
  static const String profileSize = 'w500';
}
