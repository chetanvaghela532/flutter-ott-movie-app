import 'package:flutter/material.dart';
import '../../../../models/piktv_models.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import 'piktv_movie_card.dart';

class PikTvMovieSection extends StatelessWidget {
  final String title;
  final List<PikTvMovie> movies;
  final Function(PikTvMovie) onMovieTap;

  const PikTvMovieSection({
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
      widthPercent = 35;
    } else if (Responsive.isTablet(context)) {
      widthPercent = 16;
    } else {
      widthPercent = 12;
    }
    final cardWidth = Responsive.width(context, widthPercent);
    final sectionHeight = cardWidth * 1.5;

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
              return PikTvMovieCard(
                movie: movies[index],
                onTap: () => onMovieTap(movies[index]),
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

class PikTvSeriesSection extends StatelessWidget {
  final String title;
  final List<PikTvSeries> series;
  final Function(PikTvSeries) onSeriesTap;

  const PikTvSeriesSection({
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
      widthPercent = 35;
    } else if (Responsive.isTablet(context)) {
      widthPercent = 16;
    } else {
      widthPercent = 12;
    }
    final cardWidth = Responsive.width(context, widthPercent);
    final sectionHeight = cardWidth * 1.5;

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
              return PikTvSeriesCard(
                series: series[index],
                onTap: () => onSeriesTap(series[index]),
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
