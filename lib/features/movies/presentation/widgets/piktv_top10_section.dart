import 'package:flutter/material.dart';
import '../../../../models/piktv_models.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import 'piktv_top10_card.dart';

class PikTvTop10MovieSection extends StatelessWidget {
  final String title;
  final List<PikTvMovie> movies;
  final Function(PikTvMovie) onMovieTap;

  const PikTvTop10MovieSection({
    super.key,
    required this.title,
    required this.movies,
    required this.onMovieTap,
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const SizedBox.shrink();
    }

    final horizontalPadding = Responsive.spacing(context, 16);
    final verticalPadding = Responsive.spacing(context, 12);
    final titleFontSize = Responsive.fontSize(context, 20);

    double widthPercent;
    if (Responsive.isMobile(context)) {
      widthPercent = 50;
    } else if (Responsive.isTablet(context)) {
      widthPercent = 28;
    } else {
      widthPercent = 22;
    }
    final cardWidth = Responsive.width(context, widthPercent);
    final sectionHeight = cardWidth * 1.125;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Text(
            title,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: sectionHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return PikTvTop10Card(
                rank: index + 1,
                posterUrl: movie.posterUrl.isNotEmpty ? movie.posterUrl : movie.thumbnail,
                onTap: () => onMovieTap(movie),
                width: cardWidth,
              );
            },
          ),
        ),
        SizedBox(height: Responsive.spacing(context, 16)),
      ],
    );
  }
}

class PikTvTop10SeriesSection extends StatelessWidget {
  final String title;
  final List<PikTvSeries> series;
  final Function(PikTvSeries) onSeriesTap;

  const PikTvTop10SeriesSection({
    super.key,
    required this.title,
    required this.series,
    required this.onSeriesTap,
  });

  @override
  Widget build(BuildContext context) {
    if (series.isEmpty) {
      return const SizedBox.shrink();
    }

    final horizontalPadding = Responsive.spacing(context, 16);
    final verticalPadding = Responsive.spacing(context, 12);
    final titleFontSize = Responsive.fontSize(context, 20);
    double widthPercent;
    if (Responsive.isMobile(context)) {
      widthPercent = 50;
    } else if (Responsive.isTablet(context)) {
      widthPercent = 28;
    } else {
      widthPercent = 22;
    }
    final cardWidth = Responsive.width(context, widthPercent);
    final sectionHeight = cardWidth * 1.125;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Text(
            title,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: sectionHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            itemCount: series.length,
            itemBuilder: (context, index) {
              final item = series[index];
              return PikTvTop10Card(
                rank: index + 1,
                posterUrl: item.posterUrl.isNotEmpty ? item.posterUrl : item.thumbnail,
                onTap: () => onSeriesTap(item),
                width: cardWidth,
              );
            },
          ),
        ),
        SizedBox(height: Responsive.spacing(context, 16)),
      ],
    );
  }
}
