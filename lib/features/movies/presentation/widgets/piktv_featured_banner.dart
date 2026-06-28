import 'dart:async';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../models/piktv_models.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import 'rating_badge.dart';

class PikTvFeaturedBanner extends StatefulWidget {
  final List<PikTvMovie> movies;
  final Function(PikTvMovie) onMovieTap;

  const PikTvFeaturedBanner({
    super.key,
    required this.movies,
    required this.onMovieTap,
  });

  @override
  State<PikTvFeaturedBanner> createState() => _PikTvFeaturedBannerState();
}

class _PikTvFeaturedBannerState extends State<PikTvFeaturedBanner> {
  late CarouselSliderController _carouselController;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _carouselController = CarouselSliderController();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    super.dispose();
  }

  void _startAutoSlide() {
    if (widget.movies.isEmpty || widget.movies.length <= 1) return;
    
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && widget.movies.isNotEmpty) {
        _carouselController.nextPage();
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) {
      return const SizedBox.shrink();
    }

    final bannerHeight = Responsive.height(context, 50);
    final cardPadding = Responsive.spacing(context, 12);
    final cardMargin = Responsive.spacing(context, 4);

    return SizedBox(
      height: bannerHeight,
      child: CarouselSlider.builder(
        carouselController: _carouselController,
        itemCount: widget.movies.length,
        itemBuilder: (context, index, realIndex) {
          final movie = widget.movies[index];
          return _buildBannerItem(context, movie, cardPadding, cardMargin);
        },
        options: CarouselOptions(
          height: bannerHeight,
          viewportFraction: 0.8,
          autoPlay: false,
          enlargeCenterPage: true,
          enlargeStrategy: CenterPageEnlargeStrategy.scale,
          enableInfiniteScroll: widget.movies.length > 1,
          padEnds: true,
        ),
      ),
    );
  }

  Widget _buildBannerItem(
    BuildContext context,
    PikTvMovie movie,
    double cardPadding,
    double cardMargin,
  ) {
    // Use backdropUrl (w1280) for banner, fallback to posterUrl (w500)
    final bannerUrl = movie.backdropUrl.isNotEmpty 
        ? movie.backdropUrl 
        : movie.posterUrl;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: cardMargin),
      child: GestureDetector(
        onTap: () => widget.onMovieTap(movie),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Responsive.spacing(context, 16)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: bannerUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppTheme.cardColor,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppTheme.cardColor,
                  child: Icon(
                    Icons.movie_outlined,
                    color: AppTheme.textSecondary,
                    size: Responsive.fontSize(context, 64),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.5),
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
              Positioned(
                bottom: Responsive.spacing(context, 20),
                left: Responsive.spacing(context, 16),
                right: Responsive.spacing(context, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (movie.rating != null)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: Responsive.spacing(context, 8),
                        ),
                        child: RatingBadge(rating: movie.rating!),
                      ),
                    Text(
                      movie.movieName,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: Responsive.fontSize(context, 24),
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            blurRadius: Responsive.spacing(context, 8),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (movie.releaseYear.isNotEmpty) ...[
                      SizedBox(height: Responsive.spacing(context, 6)),
                      Text(
                        movie.releaseYear,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: Responsive.fontSize(context, 14),
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: Responsive.spacing(context, 8),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (movie.generes.isNotEmpty) ...[
                      SizedBox(height: Responsive.spacing(context, 6)),
                      Wrap(
                        spacing: Responsive.spacing(context, 8),
                        children: movie.generes.take(3).map((genre) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Responsive.spacing(context, 8),
                              vertical: Responsive.spacing(context, 4),
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(
                                Responsive.spacing(context, 4),
                              ),
                            ),
                            child: Text(
                              genre.name,
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: Responsive.fontSize(context, 10),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PikTvSeriesFeaturedBanner extends StatefulWidget {
  final List<PikTvSeries> series;
  final Function(PikTvSeries) onSeriesTap;

  const PikTvSeriesFeaturedBanner({
    super.key,
    required this.series,
    required this.onSeriesTap,
  });

  @override
  State<PikTvSeriesFeaturedBanner> createState() => _PikTvSeriesFeaturedBannerState();
}

class _PikTvSeriesFeaturedBannerState extends State<PikTvSeriesFeaturedBanner> {
  late CarouselSliderController _carouselController;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _carouselController = CarouselSliderController();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    super.dispose();
  }

  void _startAutoSlide() {
    if (widget.series.isEmpty || widget.series.length <= 1) return;
    
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && widget.series.isNotEmpty) {
        _carouselController.nextPage();
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.series.isEmpty) {
      return const SizedBox.shrink();
    }

    final bannerHeight = Responsive.height(context, 50);
    final cardPadding = Responsive.spacing(context, 12);
    final cardMargin = Responsive.spacing(context, 4);

    return SizedBox(
      height: bannerHeight,
      child: CarouselSlider.builder(
        carouselController: _carouselController,
        itemCount: widget.series.length,
        itemBuilder: (context, index, realIndex) {
          final series = widget.series[index];
          return _buildBannerItem(context, series, cardPadding, cardMargin);
        },
        options: CarouselOptions(
          height: bannerHeight,
          viewportFraction: 0.8,
          autoPlay: false,
          enlargeCenterPage: true,
          enlargeStrategy: CenterPageEnlargeStrategy.scale,
          enableInfiniteScroll: widget.series.length > 1,
          padEnds: true,
        ),
      ),
    );
  }

  Widget _buildBannerItem(
    BuildContext context,
    PikTvSeries series,
    double cardPadding,
    double cardMargin,
  ) {
    // Use backdropUrl (w1280) for banner, fallback to posterUrl (w500)
    final bannerUrl = series.backdropUrl.isNotEmpty 
        ? series.backdropUrl 
        : series.posterUrl;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: cardMargin),
      child: GestureDetector(
        onTap: () => widget.onSeriesTap(series),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Responsive.spacing(context, 16)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: bannerUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppTheme.cardColor,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppTheme.cardColor,
                  child: Icon(
                    Icons.tv_outlined,
                    color: AppTheme.textSecondary,
                    size: Responsive.fontSize(context, 64),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.5),
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
              Positioned(
                bottom: Responsive.spacing(context, 20),
                left: Responsive.spacing(context, 16),
                right: Responsive.spacing(context, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (series.rating != null)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: Responsive.spacing(context, 8),
                        ),
                        child: RatingBadge(rating: series.rating!),
                      ),
                    Text(
                      series.movieName,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: Responsive.fontSize(context, 24),
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            blurRadius: Responsive.spacing(context, 8),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (series.releaseYear.isNotEmpty) ...[
                      SizedBox(height: Responsive.spacing(context, 6)),
                      Text(
                        series.releaseYear,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: Responsive.fontSize(context, 14),
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: Responsive.spacing(context, 8),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (series.generes.isNotEmpty) ...[
                      SizedBox(height: Responsive.spacing(context, 6)),
                      Wrap(
                        spacing: Responsive.spacing(context, 8),
                        children: series.generes.take(3).map((genre) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Responsive.spacing(context, 8),
                              vertical: Responsive.spacing(context, 4),
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(
                                Responsive.spacing(context, 4),
                              ),
                            ),
                            child: Text(
                              genre.name,
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: Responsive.fontSize(context, 10),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

