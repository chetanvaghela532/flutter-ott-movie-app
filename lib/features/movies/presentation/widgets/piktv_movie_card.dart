import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../models/piktv_models.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import 'rating_badge.dart';

class PikTvMovieCard extends StatelessWidget {
  final PikTvMovie movie;
  final VoidCallback onTap;
  final double? width;

  const PikTvMovieCard({
    super.key,
    required this.movie,
    required this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = width ?? Responsive.width(context, 35);
    final cardHeight = cardWidth * 1.5; // Maintain aspect ratio
    final borderRadius = Responsive.spacing(context, 12);
    final margin = Responsive.spacing(context, 12);
    final padding = Responsive.spacing(context, 8);
    final titleFontSize = Responsive.fontSize(context, 14);
    final yearFontSize = Responsive.fontSize(context, 12);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        margin: EdgeInsets.only(right: margin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: SizedBox(
                width: width ?? double.infinity,
                height: cardHeight,
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: movie.posterUrl.isNotEmpty 
                          ? movie.posterUrl 
                          : movie.backdropUrl,
                      width: width ?? double.infinity,
                      height: cardHeight,
                      fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: width ?? double.infinity,
                      height: cardHeight,
                      color: AppTheme.cardColor,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: Responsive.spacing(context, 2),
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: width ?? double.infinity,
                      height: cardHeight,
                      color: AppTheme.cardColor,
                      child: Icon(
                        Icons.movie_outlined,
                        color: AppTheme.textSecondary,
                        size: Responsive.fontSize(context, 48),
                      ),
                    ),
                  ),
                  // Gradient overlay at bottom for text readability
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                            Colors.black.withOpacity(0.9),
                          ],
                        ),
                      ),
                      padding: EdgeInsets.all(padding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            movie.movieName,
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: Responsive.spacing(context, 4),
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (movie.releaseYear.isNotEmpty) ...[
                            SizedBox(height: Responsive.spacing(context, 2)),
                            Text(
                              movie.releaseYear,
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: yearFontSize,
                                shadows: [
                                  Shadow(
                                    color: Colors.black,
                                    blurRadius: Responsive.spacing(context, 4),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                    if (movie.rating != null)
                    Positioned(
                      top: padding,
                      right: padding,
                      child: RatingBadge(rating: movie.rating!),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PikTvSeriesCard extends StatelessWidget {
  final PikTvSeries series;
  final VoidCallback onTap;
  final double? width;

  const PikTvSeriesCard({
    super.key,
    required this.series,
    required this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = width ?? Responsive.width(context, 35);
    final cardHeight = cardWidth * 1.5; // Maintain aspect ratio
    final borderRadius = Responsive.spacing(context, 12);
    final margin = Responsive.spacing(context, 12);
    final padding = Responsive.spacing(context, 8);
    final titleFontSize = Responsive.fontSize(context, 14);
    final yearFontSize = Responsive.fontSize(context, 12);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        margin: EdgeInsets.only(right: margin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: series.posterUrl.isNotEmpty 
                        ? series.posterUrl 
                        : series.backdropUrl,
                    width: width ?? double.infinity,
                    height: cardHeight,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: width ?? double.infinity,
                      height: cardHeight,
                      color: AppTheme.cardColor,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: Responsive.spacing(context, 2),
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: width ?? double.infinity,
                      height: cardHeight,
                      color: AppTheme.cardColor,
                      child: Icon(
                        Icons.tv_outlined,
                        color: AppTheme.textSecondary,
                        size: Responsive.fontSize(context, 48),
                      ),
                    ),
                  ),
                  // Gradient overlay at bottom for text readability
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                            Colors.black.withOpacity(0.9),
                          ],
                        ),
                      ),
                      padding: EdgeInsets.all(padding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            series.movieName,
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: Responsive.spacing(context, 4),
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (series.releaseYear.isNotEmpty) ...[
                            SizedBox(height: Responsive.spacing(context, 2)),
                            Text(
                              series.releaseYear,
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: yearFontSize,
                                shadows: [
                                  Shadow(
                                    color: Colors.black,
                                    blurRadius: Responsive.spacing(context, 4),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (series.rating != null)
                    Positioned(
                      top: padding,
                      right: padding,
                      child: RatingBadge(rating: series.rating!),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

