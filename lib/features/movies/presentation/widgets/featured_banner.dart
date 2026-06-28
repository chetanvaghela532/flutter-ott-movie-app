import 'dart:async';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/movie_entity.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import 'rating_badge.dart';

class FeaturedBanner extends StatefulWidget {
  final List<MovieEntity> movies;
  final Function(MovieEntity) onMovieTap;

  const FeaturedBanner({
    super.key,
    required this.movies,
    required this.onMovieTap,
  });

  @override
  State<FeaturedBanner> createState() => _FeaturedBannerState();
}

class _FeaturedBannerState extends State<FeaturedBanner> {
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
    MovieEntity movie,
    double cardPadding,
    double cardMargin,
  ) {
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
                imageUrl: movie.backdropUrl,
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
                    if (movie.voteAverage != null)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: Responsive.spacing(context, 8),
                        ),
                        child: RatingBadge(rating: movie.voteAverage!),
                      ),
                    Text(
                      movie.title,
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
                    if (movie.overview != null && movie.overview!.isNotEmpty) ...[
                      SizedBox(height: Responsive.spacing(context, 6)),
                      Text(
                        movie.overview!,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: Responsive.fontSize(context, 12),
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: Responsive.spacing(context, 6),
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (movie.year.isNotEmpty) ...[
                      SizedBox(height: Responsive.spacing(context, 6)),
                      Text(
                        movie.year,
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

