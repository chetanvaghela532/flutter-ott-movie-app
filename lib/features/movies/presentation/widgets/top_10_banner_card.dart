import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/movie_entity.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import 'rating_badge.dart';

class Top10BannerCard extends StatelessWidget {
  final MovieEntity mainMovie;
  final List<MovieEntity> sideMovies;
  final Function(MovieEntity) onMovieTap;
  final int mainRank;

  const Top10BannerCard({
    super.key,
    required this.mainMovie,
    required this.sideMovies,
    required this.onMovieTap,
    required this.mainRank,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = Responsive.width(context, 85);
    final mainCardHeight = Responsive.height(context, 35);
    final sideCardHeight = Responsive.height(context, 18);
    final borderRadius = Responsive.spacing(context, 12);
    final padding = Responsive.spacing(context, 8);
    final spacing = Responsive.spacing(context, 8);
    final rankBadgeSize = Responsive.width(context, 16);
    final rankFontSize = Responsive.fontSize(context, 20);

    return Container(
      width: cardWidth,
      margin: EdgeInsets.only(right: Responsive.spacing(context, 16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main large movie card (banner style)
          GestureDetector(
            onTap: () => onMovieTap(mainMovie),
            child: Container(
              width: cardWidth,
              height: mainCardHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: Responsive.spacing(context, 8),
                    offset: Offset(0, Responsive.spacing(context, 4)),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: mainMovie.backdropUrl.isNotEmpty
                          ? mainMovie.backdropUrl
                          : mainMovie.posterUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppTheme.cardColor,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: Responsive.spacing(context, 2),
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppTheme.cardColor,
                        child: Icon(
                          Icons.movie_outlined,
                          color: AppTheme.textSecondary,
                          size: Responsive.fontSize(context, 48),
                        ),
                      ),
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.4),
                            Colors.black.withOpacity(0.8),
                          ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),
                    // Rank badge
                    Positioned(
                      top: padding,
                      left: padding,
                      child: Container(
                        width: rankBadgeSize,
                        height: rankBadgeSize,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: Responsive.spacing(context, 4),
                              offset: Offset(0, Responsive.spacing(context, 2)),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$mainRank',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: rankFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Movie info at bottom
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(padding * 1.5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (mainMovie.voteAverage != null)
                              Padding(
                                padding: EdgeInsets.only(bottom: spacing / 2),
                                child: RatingBadge(rating: mainMovie.voteAverage!),
                              ),
                            Text(
                              mainMovie.title,
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: Responsive.fontSize(context, 18),
                                fontWeight: FontWeight.bold,
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
                            if (mainMovie.year.isNotEmpty) ...[
                              SizedBox(height: spacing / 2),
                              Text(
                                mainMovie.year,
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: Responsive.fontSize(context, 12),
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
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: spacing),
          // Two smaller movie cards below
          Row(
            children: [
              if (sideMovies.isNotEmpty)
                Expanded(
                  child: _buildSmallCard(
                    context,
                    sideMovies[0],
                    mainRank + 1,
                    sideCardHeight,
                    borderRadius,
                    padding,
                    spacing,
                  ),
                ),
              if (sideMovies.length > 1) ...[
                SizedBox(width: spacing),
                Expanded(
                  child: _buildSmallCard(
                    context,
                    sideMovies[1],
                    mainRank + 2,
                    sideCardHeight,
                    borderRadius,
                    padding,
                    spacing,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallCard(
    BuildContext context,
    MovieEntity movie,
    int rank,
    double height,
    double borderRadius,
    double padding,
    double spacing,
  ) {
    final rankBadgeSize = Responsive.width(context, 10);
    final rankFontSize = Responsive.fontSize(context, 14);

    return GestureDetector(
      onTap: () => onMovieTap(movie),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: Responsive.spacing(context, 4),
              offset: Offset(0, Responsive.spacing(context, 2)),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: movie.posterUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppTheme.cardColor,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: Responsive.spacing(context, 2),
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppTheme.cardColor,
                  child: Icon(
                    Icons.movie_outlined,
                    color: AppTheme.textSecondary,
                    size: Responsive.fontSize(context, 32),
                  ),
                ),
              ),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              // Rank badge
              Positioned(
                top: padding / 2,
                left: padding / 2,
                child: Container(
                  width: rankBadgeSize,
                  height: rankBadgeSize,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: Responsive.spacing(context, 2),
                        offset: Offset(0, Responsive.spacing(context, 1)),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: rankFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Movie title at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(padding),
                  child: Text(
                    movie.title,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: Responsive.fontSize(context, 12),
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
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

