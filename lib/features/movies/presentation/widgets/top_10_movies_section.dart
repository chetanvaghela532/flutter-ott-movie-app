import 'package:flutter/material.dart';
import '../../domain/entities/movie_entity.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import 'top_10_banner_card.dart';

class Top10MoviesSection extends StatelessWidget {
  final List<MovieEntity> movies;
  final Function(MovieEntity) onMovieTap;

  const Top10MoviesSection({
    super.key,
    required this.movies,
    required this.onMovieTap,
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const SizedBox.shrink();
    }

    // Take only top 10 movies
    final top10Movies = movies.take(10).toList();
    
    final sectionHeight = Responsive.height(context, 55);
    final horizontalPadding = Responsive.spacing(context, 16);
    final verticalPadding = Responsive.spacing(context, 12);
    final titleFontSize = Responsive.fontSize(context, 20);

    // Group movies: 1 main + 2 side = 3 movies per card
    // This creates: [1,2,3], [4,5,6], [7,8,9], [10]
    final List<Widget> bannerCards = [];
    for (int i = 0; i < top10Movies.length; i += 3) {
      final mainMovie = top10Movies[i];
      final sideMovies = (i + 1 < top10Movies.length)
          ? [
              if (i + 1 < top10Movies.length) top10Movies[i + 1],
              if (i + 2 < top10Movies.length) top10Movies[i + 2],
            ]
          : <MovieEntity>[];
      
      bannerCards.add(
        Top10BannerCard(
          mainMovie: mainMovie,
          sideMovies: sideMovies,
          onMovieTap: onMovieTap,
          mainRank: i + 1,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Text(
            'Top 10 Movies',
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
            padding: EdgeInsets.only(
              left: horizontalPadding,
              right: horizontalPadding,
            ),
            itemCount: bannerCards.length,
            itemBuilder: (context, index) {
              return bannerCards[index];
            },
          ),
        ),
        SizedBox(height: Responsive.spacing(context, 16)),
      ],
    );
  }
}

