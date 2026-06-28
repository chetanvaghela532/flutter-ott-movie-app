import 'package:flutter/material.dart';
import '../../domain/entities/movie_entity.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import 'movie_card.dart';

class RankedMovieCard extends StatelessWidget {
  final MovieEntity movie;
  final VoidCallback onTap;
  final int rank;
  final double? width;

  const RankedMovieCard({
    super.key,
    required this.movie,
    required this.onTap,
    required this.rank,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = width ?? Responsive.width(context, 35);
    final padding = Responsive.spacing(context, 8);
    final rankFontSize = Responsive.fontSize(context, 24);
    final rankBadgeSize = cardWidth * 0.25;
    
    return Stack(
      children: [
        MovieCard(
          movie: movie,
          onTap: onTap,
          width: cardWidth,
        ),
        // Rank number overlay on top of image
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
              '$rank',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: rankFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

