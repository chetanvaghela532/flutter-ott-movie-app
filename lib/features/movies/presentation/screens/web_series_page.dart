import 'package:flutter/material.dart';
import 'package:ott_watch/features/movies/presentation/screens/settings_screen.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/piktv_service.dart';
import '../../../../models/piktv_models.dart';
import '../widgets/piktv_movie_section.dart';
import '../widgets/piktv_featured_banner.dart';
import 'tv_show_details_screen.dart';
import 'search_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../core/services/ad_config_manager.dart';
import '../../../../core/services/ad_manager.dart';

class WebSeriesPage extends StatefulWidget {
  const WebSeriesPage({super.key});

  @override
  State<WebSeriesPage> createState() => _WebSeriesPageState();
}

class _WebSeriesPageState extends State<WebSeriesPage> {
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

  void _navigateToDetails(BuildContext context, PikTvSeries series) {
    AdManager().showInterstitialOrProceed(() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TvShowDetailsScreen(
            tvShowId: series.tmdbId,
            isPlayAvailable: series.isPlayAvailable,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      bottomNavigationBar: _buildBanner(),
      appBar: AppBar(
        title: const Text('Web Series'),
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
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppTheme.primaryColor,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryColor,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                style: const TextStyle(color: AppTheme.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadPikTvData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_pikTvData == null || _pikTvData!.latestSeries.isEmpty) {
      return const Center(
        child: Text(
          'No web series available',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
      );
    }

    final series = _pikTvData!.top10Series;
    final featuredSeries = series.take(5).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Featured series banner
          if (featuredSeries.isNotEmpty)
            PikTvSeriesFeaturedBanner(
              series: featuredSeries,
              onSeriesTap: (series) => _navigateToDetails(context, series),
            ),
          // All Series Section
          PikTvSeriesSection(
            title: 'All Web Series',
            series: series,
            onSeriesTap: (series) => _navigateToDetails(context, series),
          ),
        ],
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
