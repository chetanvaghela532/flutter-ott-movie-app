import 'package:flutter/material.dart';
import '../../domain/entities/movie_entity.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import 'movie_card.dart';

class MovieSection extends StatelessWidget {
  final String title;
  final List<MovieEntity> movies;
  final Function(MovieEntity) onMovieTap;

  const MovieSection({
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

    final sectionHeight = Responsive.height(context, 24);
    final horizontalPadding = Responsive.spacing(context, 16);
    final verticalPadding = Responsive.spacing(context, 12);
    final titleFontSize = Responsive.fontSize(context, 20);
    final cardWidth = Responsive.width(context, 35);

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
              return MovieCard(
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

