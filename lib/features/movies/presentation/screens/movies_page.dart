import 'package:flutter/material.dart';
import 'package:ott_watch/features/movies/presentation/screens/settings_screen.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/piktv_service.dart';
import '../../../../models/piktv_models.dart';
import '../../../../core/utils/responsive.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../core/services/ad_config_manager.dart';
import '../../../../core/services/ad_manager.dart';
import '../widgets/piktv_movie_section.dart';
import '../widgets/piktv_movie_card.dart';
import 'movie_details_screen.dart';
import 'search_screen.dart';

class MoviesPage extends StatefulWidget {
  const MoviesPage({super.key});

  @override
  State<MoviesPage> createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
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

  void _navigateToMovieDetails(PikTvMovie movie) {
    AdManager().showInterstitialOrProceed(() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MovieDetailsScreen(
            movieId: movie.tmdbId,
            isPlayAvailable: movie.isPlayAvailable,
          ),
        ),
      );
    });
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

  // Filter movies by genre
  List<PikTvMovie> _getMoviesByGenre(String genreName) {
    if (_pikTvData == null) return [];
    return _pikTvData!.latestMovie.where((movie) {
      return movie.generes.any((genre) => genre.name == genreName);
    }).toList();
  }

  // Build movies wrap layout
  Widget _buildMoviesWrap() {
    if (_pikTvData == null || _pikTvData!.latestMovie.isEmpty) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final padding = Responsive.spacing(context, 16);
    final spacing = Responsive.spacing(context, 12);
    final availableWidth = screenWidth - (padding * 2);

    // Target card width to match section sizing across breakpoints
    double desiredPercent;
    if (Responsive.isMobile(context)) {
      desiredPercent = 35;
    } else if (Responsive.isTablet(context)) {
      desiredPercent = 16;
    } else {
      desiredPercent = 12;
    }
    final desiredWidth = Responsive.width(context, desiredPercent);

    // Compute columns to approximate desired width, then clamp sensibly
    int crossAxisCount =
        ((availableWidth + spacing) / (desiredWidth + spacing)).floor();
    if (Responsive.isMobile(context)) {
      crossAxisCount = crossAxisCount.clamp(2, 3);
    } else if (Responsive.isTablet(context)) {
      crossAxisCount = crossAxisCount.clamp(3, 6);
    } else {
      crossAxisCount = crossAxisCount.clamp(4, 8);
    }

    final cardWidth =
        (availableWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: _pikTvData!.latestMovie.map((movie) {
        return SizedBox(
          width: cardWidth,
          child: PikTvMovieCard(
            movie: movie,
            onTap: () => _navigateToMovieDetails(movie),
            width: cardWidth,
          ),
        );
      }).toList(),
    );
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
            onMovieTap: (movie) => _navigateToMovieDetails(movie),
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
        title: const Text('Movies'),
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
              onRefresh: _refreshData,
              color: AppTheme.primaryColor,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(Responsive.spacing(context, 16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // All Movies in Wrap Layout
                    if (_pikTvData!.latestMovie.isNotEmpty) ...[
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: Responsive.spacing(context, 16),
                        ),
                        child: Text(
                          'All Movies',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: Responsive.fontSize(context, 20),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildMoviesWrap(),
                      SizedBox(height: Responsive.spacing(context, 24)),
                    ],
                    // Genre-based Movie Sections
                    ..._buildGenreMovieSections(),
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
