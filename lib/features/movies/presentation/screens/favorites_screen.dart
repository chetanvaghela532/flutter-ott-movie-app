import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/services/favorites_service.dart';
import 'movie_details_screen.dart';
import 'tv_show_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  List<FavoriteItem> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final favorites = await _favoritesService.getFavorites();
      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFavorite(FavoriteItem item) async {
    final removed = await _favoritesService.removeFavorite(item.id, item.type);
    if (removed) {
      _loadFavorites();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed from favorites'),
            backgroundColor: AppTheme.primaryColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _navigateToDetails(FavoriteItem item) {
    if (item.type == 'movie') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MovieDetailsScreen(
            movieId: item.id,
            videoUrl: item.videoUrl,
            isPlayAvailable: item.videoUrl != null && item.videoUrl!.isNotEmpty,
          ),
        ),
      ).then((_) {
        // Reload favorites when returning from details screen
        _loadFavorites();
      });
    } else if (item.type == 'tv') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TvShowDetailsScreen(
            tvShowId: item.id,
            videoUrl: item.videoUrl,
            isPlayAvailable: item.videoUrl != null && item.videoUrl!.isNotEmpty,
          ),
        ),
      ).then((_) {
        // Reload favorites when returning from details screen
        _loadFavorites();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Favorites',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.backgroundColor,
        actions: [
          if (_favorites.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh, color: AppTheme.textPrimary),
              onPressed: _loadFavorites,
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            )
          : _favorites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 80,
                        color: AppTheme.textSecondary.withOpacity(0.5),
                      ),
                      SizedBox(height: Responsive.spacing(context, 16)),
                      Text(
                        'No Favorites Yet',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: Responsive.fontSize(context, 20),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, 8)),
                      Text(
                        'Start adding movies and TV shows\nto your favorites',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: Responsive.fontSize(context, 14),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  color: AppTheme.primaryColor,
                  child: GridView.builder(
                    padding: EdgeInsets.all(Responsive.spacing(context, 16)),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.6,
                      crossAxisSpacing: Responsive.spacing(context, 12),
                      mainAxisSpacing: Responsive.spacing(context, 12),
                    ),
                    itemCount: _favorites.length,
                    itemBuilder: (context, index) {
                      final favorite = _favorites[index];
                      return GestureDetector(
                        onTap: () => _navigateToDetails(favorite),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: AppTheme.cardColor,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: CachedNetworkImage(
                                        imageUrl: favorite.movie.posterUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          color: AppTheme.cardColor,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppTheme.primaryColor,
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => Container(
                                          color: AppTheme.cardColor,
                                          child: Icon(
                                            favorite.type == 'movie'
                                                ? Icons.movie
                                                : Icons.tv,
                                            color: AppTheme.textSecondary,
                                            size: Responsive.fontSize(context, 40),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(Responsive.spacing(context, 8)),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            favorite.movie.title,
                                            style: TextStyle(
                                              color: AppTheme.textPrimary,
                                              fontSize: Responsive.fontSize(context, 14),
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: Responsive.spacing(context, 4)),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: Responsive.fontSize(context, 14),
                                              ),
                                              SizedBox(width: Responsive.spacing(context, 4)),
                                              Text(
                                                favorite.movie.voteAverage != null
                                                    ? favorite.movie.voteAverage!.toStringAsFixed(1)
                                                    : 'N/A',
                                                style: TextStyle(
                                                  color: AppTheme.textSecondary,
                                                  fontSize: Responsive.fontSize(context, 12),
                                                ),
                                              ),
                                              const Spacer(),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: Responsive.spacing(context, 6),
                                                  vertical: Responsive.spacing(context, 2),
                                                ),
                                                decoration: BoxDecoration(
                                                  color: favorite.type == 'movie'
                                                      ? AppTheme.primaryColor
                                                      : Colors.purple,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  favorite.type == 'movie' ? 'Movie' : 'TV Show',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: Responsive.fontSize(context, 10),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: Responsive.spacing(context, 8),
                              right: Responsive.spacing(context, 8),
                              child: GestureDetector(
                                onTap: () => _removeFavorite(favorite),
                                child: Container(
                                  padding: EdgeInsets.all(Responsive.spacing(context, 6)),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.favorite,
                                    color: AppTheme.primaryColor,
                                    size: Responsive.fontSize(context, 20),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

