import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:ott_watch/core/services/piktv_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/services/config_service.dart';
import '../../../../models/piktv_models.dart';
import '../widgets/piktv_movie_section.dart';
import '../widgets/piktv_top10_section.dart';
import '../widgets/piktv_featured_banner.dart';
import 'movie_details_screen.dart';
import 'tv_show_details_screen.dart';
import 'settings_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../core/services/ad_config_manager.dart';
import '../../../../core/services/ad_manager.dart';

class PikTvHomeScreen extends StatefulWidget {
  const PikTvHomeScreen({super.key});

  @override
  State<PikTvHomeScreen> createState() => _PikTvHomeScreenState();
}

class _PikTvHomeScreenState extends State<PikTvHomeScreen> {
  PikTvData? _pikTvData;
  bool _isLoading = true;
  String? _errorMessage;
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _loadPikTvData();
    _loadBannerAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    if (!AdConfigManager().isBannerEnabled) return;
    _bannerAd = AdManager().createBannerAd(
      onAdFailedToLoad: (ad, error) {
        setState(() {
          _bannerAd = null;
        });
      },
    );
    _bannerAd?.load();
  }

  Future<void> _loadPikTvData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await PikTvService().getPikTvData();
      if (mounted) {
        setState(() {
          _pikTvData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load data: $e';
        });
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await PikTvService().refreshData();
      if (mounted) {
        setState(() {
          _pikTvData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load data: $e';
        });
      }
    }
  }

  void _navigateToDetails(dynamic item) {
    if (item is PikTvMovie) {
      // Navigate to movie details screen
      AdManager().showInterstitialOrProceed(() {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailsScreen(
              movieId: item.tmdbId,
              isPlayAvailable: item.isPlayAvailable,
            ),
          ),
        );
      });
    } else if (item is PikTvSeries) {
      // Navigate to TV show details screen
      AdManager().showInterstitialOrProceed(() {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TvShowDetailsScreen(
              tvShowId: item.tmdbId,
              isPlayAvailable: item.isPlayAvailable,
            ),
          ),
        );
      });
    }
  }

  // Get all unique genres from movies
  Set<String> _getAllMovieGenres() {
    if (_pikTvData == null) return {};
    final Set<String> genres = {};
    for (var movie in _pikTvData!.latestMovie) {
      for (var genre in movie.generes) {
        if (genre.name.isNotEmpty) {
          genres.add(genre.name);
        }
      }
    }
    return genres;
  }

  // Get all unique genres from series
  Set<String> _getAllSeriesGenres() {
    if (_pikTvData == null) return {};
    final Set<String> genres = {};
    for (var series in _pikTvData!.latestSeries) {
      for (var genre in series.generes) {
        if (genre.name.isNotEmpty) {
          genres.add(genre.name);
        }
      }
    }
    return genres;
  }

  // Filter movies by genre
  List<PikTvMovie> _getMoviesByGenre(String genreName) {
    if (_pikTvData == null) return [];
    return _pikTvData!.latestMovie.where((movie) {
      return movie.generes.any((genre) => genre.name == genreName);
    }).toList();
  }

  // Filter series by genre
  List<PikTvSeries> _getSeriesByGenre(String genreName) {
    if (_pikTvData == null) return [];
    return _pikTvData!.latestSeries.where((series) {
      return series.generes.any((genre) => genre.name == genreName);
    }).toList();
  }

  // Build genre-based movie sections
  List<Widget> _buildGenreMovieSections() {
    if (_pikTvData == null) return [];

    final genres = _getAllMovieGenres().toList()..sort();
    final List<Widget> sections = [];

    for (var genre in genres) {
      final movies = _getMoviesByGenre(genre);
      if (movies.isNotEmpty) {
        sections.add(
          PikTvMovieSection(
            title: '$genre Movies',
            movies: movies,
            onMovieTap: (movie) => _navigateToDetails(movie),
          ),
        );
      }
    }

    return sections;
  }

  // Build genre-based series sections
  List<Widget> _buildGenreSeriesSections() {
    if (_pikTvData == null) return [];

    final genres = _getAllSeriesGenres().toList()..sort();
    final List<Widget> sections = [];

    for (var genre in genres) {
      final series = _getSeriesByGenre(genre);
      if (series.isNotEmpty) {
        sections.add(
          PikTvSeriesSection(
            title: '$genre Series',
            series: series,
            onSeriesTap: (series) => _navigateToDetails(series),
          ),
        );
      }
    }

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      bottomNavigationBar: _buildBanner(),
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Image.asset(AppAssets.logoRemoved, fit: BoxFit.contain),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            )
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadPikTvData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : _pikTvData == null
          ? const Center(
              child: Text(
                'No data available',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadPikTvData,
              color: AppTheme.primaryColor,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Featured banner (Latest Movies)
                    if (_pikTvData!.latestMovie.isNotEmpty)
                      PikTvFeaturedBanner(
                        movies: _pikTvData!.latestMovie.take(5).toList(),
                        onMovieTap: (movie) => _navigateToDetails(movie),
                      ),
                    // Latest Movies Section
                    if (_pikTvData!.latestMovie.isNotEmpty)
                      PikTvMovieSection(
                        title: 'Latest Movies',
                        movies: _pikTvData!.latestMovie,
                        onMovieTap: (movie) => _navigateToDetails(movie),
                      ),
                    // Latest Series Section
                    // if (_pikTvData!.latestSeries.isNotEmpty)
                    //   PikTvSeriesSection(
                    //     title: 'Latest Series',
                    //     series: _pikTvData!.latestSeries,
                    //     onSeriesTap: (series) => _navigateToDetails(series),
                    //   ),
                    // Top 10 Movies Section
                    if (_pikTvData!.top10Movies.isNotEmpty)
                      PikTvTop10MovieSection(
                        title: 'Top 10 Movies',
                        movies: _pikTvData!.top10Movies,
                        onMovieTap: (movie) => _navigateToDetails(movie),
                      ),

                    // Genre-based Movie Sections
                    ..._buildGenreMovieSections(),
                    // Top 10 Series Section
                    if (_pikTvData!.top10Series.isNotEmpty)
                      PikTvTop10SeriesSection(
                        title: 'Top 10 Series',
                        series: _pikTvData!.top10Series,
                        onSeriesTap: (series) => _navigateToDetails(series),
                      ),
                    // Genre-based Series Sections
                    ..._buildGenreSeriesSections(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBanner() {
    if (_bannerAd == null) return const SizedBox.shrink();
    return Container(
      color: AppTheme.surfaceColor,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: _bannerAd!.size.height.toDouble(),
          width: _bannerAd!.size.width.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      ),
    );
  }
}
