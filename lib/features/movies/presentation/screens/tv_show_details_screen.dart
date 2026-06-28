import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/services/favorites_service.dart';
import '../../../../injection/injection_container.dart' as di;
import '../../domain/entities/video_entity.dart';
import '../bloc/tv_show_details_bloc.dart';
import '../bloc/tv_show_details_event.dart';
import '../bloc/tv_show_details_state.dart';
import '../widgets/movie_card.dart';
import '../widgets/video_player_dialog.dart';
import '../widgets/video_url_player_dialog.dart';
import 'person_details_screen.dart';
import 'main_navigation_screen.dart';

class TvShowDetailsScreen extends StatefulWidget {
  final int tvShowId;
  final bool? isPlayAvailable;
  final String? videoUrl;

  const TvShowDetailsScreen({
    super.key,
    required this.tvShowId,
    this.isPlayAvailable,
    this.videoUrl,
  });

  @override
  State<TvShowDetailsScreen> createState() => _TvShowDetailsScreenState();
}

class _TvShowDetailsScreenState extends State<TvShowDetailsScreen> {
  bool _isOverviewExpanded = false;
  bool _isFavorite = false;
  final FavoritesService _favoritesService = FavoritesService();

  @override
  void initState() {
    super.initState();
    if (widget.isPlayAvailable != null) {
      print('TvShowDetailsScreen isPlayAvailable: ${widget.isPlayAvailable}');
    }
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFav = await _favoritesService.isFavorite(widget.tvShowId, 'tv');
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return 'N/A';
    try {
      final parsed = DateTime.parse(date);
      final months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${months[parsed.month - 1]} ${parsed.day}, ${parsed.year}';
    } catch (e) {
      return date;
    }
  }

  void _playTrailer(VideoEntity? video) {
    if (video == null || video.key.isEmpty) return;
    
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => VideoPlayerDialog(video: video),
    );
  }

  void _playVideoUrl(String? videoUrl) {
    if (videoUrl == null || videoUrl.isEmpty) return;
    
    // Navigate to full-screen video player
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoUrlPlayerScreen(
          videoUrl: videoUrl,
          title: 'Playing Video',
          isWebSeries: true, // Use default embed player only for webseries
        ),
        fullscreenDialog: true,
      ),
    );
  }

  bool get _shouldShowPlayButton {
    return widget.videoUrl != null &&
        widget.videoUrl!.isNotEmpty &&
        (widget.isPlayAvailable == true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<TvShowDetailsBloc>()
        ..add(LoadAllTvShowDetails(widget.tvShowId)),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: BlocBuilder<TvShowDetailsBloc, TvShowDetailsState>(
          builder: (context, state) {
            if (state is TvShowDetailsLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryColor,
                ),
              );
            }

            if (state is TvShowDetailsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      style: const TextStyle(color: AppTheme.textPrimary),
                    ),
                    SizedBox(height: Responsive.spacing(context, 16)),
                    ElevatedButton(
                      onPressed: () {
                        context.read<TvShowDetailsBloc>().add(LoadAllTvShowDetails(widget.tvShowId));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is TvShowDetailsLoaded) {
              final tvShow = state.tvShow;
              VideoEntity? trailer;
              if (state.videos != null && state.videos!.isNotEmpty) {
                try {
                  trailer = state.videos!.firstWhere(
                    (v) => v.type.toLowerCase() == 'trailer',
                  );
                } catch (e) {
                  trailer = state.videos!.first;
                }
              }

              return CustomScrollView(
                slivers: [
                  // Hero banner section
                  SliverAppBar(
                    expandedHeight: Responsive.height(context, 30),
                    pinned: false,
                    backgroundColor: Colors.transparent,
                    leading: Container(
                      margin: EdgeInsets.all(Responsive.spacing(context, 8)),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    actions: [
                      Container(
                        margin: EdgeInsets.all(Responsive.spacing(context, 8)),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            _isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: _isFavorite ? AppTheme.primaryColor : Colors.white,
                          ),
                          onPressed: () async {
                            if (_isFavorite) {
                              final removed = await _favoritesService.removeFavorite(
                                widget.tvShowId,
                                'tv',
                              );
                              if (removed && mounted) {
                                setState(() {
                                  _isFavorite = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Removed from favorites'),
                                    backgroundColor: AppTheme.primaryColor,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            } else {
                              final canAdd = await _favoritesService.canAddMore();
                              if (!canAdd) {
                                if (!mounted) return;
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Limit Reached'),
                                    content: const Text('You can add only 20 favorites. Remove some items to add new.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                                return;
                              }
                              final added = await _favoritesService.addFavorite(
                                tvShow,
                                'tv',
                                videoUrl: widget.videoUrl,
                              );
                              if (added && mounted) {
                                setState(() {
                                  _isFavorite = true;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Added to favorites'),
                                    backgroundColor: AppTheme.primaryColor,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: tvShow.backdropUrl.isNotEmpty 
                                ? tvShow.backdropUrl 
                                : tvShow.posterUrl,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              color: AppTheme.cardColor,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.3),
                                  Colors.black.withOpacity(0.7),
                                  AppTheme.backgroundColor.withOpacity(0.95),
                                  AppTheme.backgroundColor,
                                ],
                                stops: const [0.0, 0.4, 0.7, 0.85, 1.0],
                              ),
                            ),
                          ),
                          // Centered Play Button (only if videoUrl is provided and isPlayAvailable is true)
                          if (_shouldShowPlayButton)
                            Center(
                              child: GestureDetector(
                                onTap: () => _playVideoUrl(widget.videoUrl),
                                child: Container(
                                  width: Responsive.width(context, 20),
                                  height: Responsive.width(context, 20),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.9),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.5),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: Responsive.fontSize(context, 40),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Content section
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Poster and details (overlapping hero section)
                        Container(
                          margin: EdgeInsets.only(
                            // top: Responsive.height(context, 40),
                            bottom: Responsive.spacing(context, 16),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.spacing(context, 16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Centered poster with light background
                              Container(
                                width: () {
                                  if (Responsive.isMobile(context)) return Responsive.width(context, 50);
                                  if (Responsive.isTablet(context)) return Responsive.width(context, 32);
                                  return Responsive.width(context, 24);
                                }(),
                                height: () {
                                  final w = Responsive.isMobile(context)
                                      ? Responsive.width(context, 50)
                                      : Responsive.isTablet(context)
                                          ? Responsive.width(context, 32)
                                          : Responsive.width(context, 24);
                                  return w * 1.5;
                                }(),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white.withOpacity(0.15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: tvShow.posterUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          color: Colors.white.withOpacity(0.2),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppTheme.primaryColor,
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => Container(
                                          color: Colors.white.withOpacity(0.2),
                                          child: Icon(
                                            Icons.tv,
                                            color: AppTheme.textSecondary,
                                            size: Responsive.fontSize(context, 40),
                                          ),
                                        ),
                                      ),
                                      // Light gradient overlay on poster
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.white.withOpacity(0.1),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: Responsive.spacing(context, 12)),
                              // Title and HD badge
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: Text(
                                      tvShow.title,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: Responsive.fontSize(context, 24),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: Responsive.spacing(context, 8)),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Responsive.spacing(context, 8),
                                      vertical: Responsive.spacing(context, 4),
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.cardColor,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'HD',
                                      style: TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: Responsive.fontSize(context, 12),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Tagline or subtitle if available
                              if (tvShow.tagline != null && tvShow.tagline!.isNotEmpty) ...[
                                SizedBox(height: Responsive.spacing(context, 8)),
                                Text(
                                  tvShow.tagline!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: Responsive.fontSize(context, 14),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // TV Show info cards and other details
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.spacing(context, 16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // TV Show info cards
                          Row(
                            children: [
                              Expanded(
                                child: _InfoCard(
                                  icon: Icons.access_time,
                                  label: 'Episode Runtime',
                                  value: tvShow.runtime != null 
                                      ? '${tvShow.runtime} min' 
                                      : 'N/A',
                                ),
                              ),
                              SizedBox(width: Responsive.spacing(context, 12)),
                              Expanded(
                                child: _InfoCard(
                                  icon: Icons.star,
                                  label: 'Rating',
                                  value: tvShow.voteAverage != null
                                      ? '${tvShow.voteAverage!.toStringAsFixed(1)}'
                                      : 'N/A',
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: Responsive.spacing(context, 12)),
                          
                          // First Air Date and genres
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'First Air Date',
                                      style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: Responsive.fontSize(context, 12),
                                      ),
                                    ),
                                    SizedBox(height: Responsive.spacing(context, 4)),
                                    Text(
                                      _formatDate(tvShow.releaseDate),
                                      style: TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: Responsive.fontSize(context, 14),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Genre',
                                      style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: Responsive.fontSize(context, 12),
                                      ),
                                    ),
                                    SizedBox(height: Responsive.spacing(context, 4)),
                                    Wrap(
                                      spacing: Responsive.spacing(context, 8),
                                      runSpacing: Responsive.spacing(context, 8),
                                      children: (tvShow.genres?.take(2).map((g) => g.name) ?? 
                                                (tvShow.genreIds?.take(2).map((id) => _getGenreName(id)) ?? []))
                                          .map((genre) => Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: Responsive.spacing(context, 12),
                                                  vertical: Responsive.spacing(context, 6),
                                                ),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: AppTheme.textSecondary.withOpacity(0.3),
                                                  ),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  genre,
                                                  style: TextStyle(
                                                    color: AppTheme.textPrimary,
                                                    fontSize: Responsive.fontSize(context, 12),
                                                  ),
                                                ),
                                              ))
                                          .toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: Responsive.spacing(context, 24)),
                          
                          // Synopsis section
                          if (tvShow.overview != null && tvShow.overview!.isNotEmpty) ...[
                            Text(
                              'Synopsis',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: Responsive.fontSize(context, 20),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: Responsive.spacing(context, 12)),
                            Text(
                              tvShow.overview!,
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: Responsive.fontSize(context, 14),
                                height: 1.6,
                              ),
                              maxLines: _isOverviewExpanded ? null : 4,
                              overflow: _isOverviewExpanded 
                                  ? TextOverflow.visible 
                                  : TextOverflow.ellipsis,
                            ),
                            if (tvShow.overview!.length > 200)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isOverviewExpanded = !_isOverviewExpanded;
                                  });
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(top: Responsive.spacing(context, 8)),
                                  child: Text(
                                    _isOverviewExpanded ? 'Show Less' : 'Show More',
                                    style: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontSize: Responsive.fontSize(context, 14),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            SizedBox(height: Responsive.spacing(context, 24)),
                          ],
                          
                          // Watch Providers section
                          if (state.watchProviders != null && state.watchProviders!.isNotEmpty) ...[
                            Text(
                              'Where to Watch',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: Responsive.fontSize(context, 20),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: Responsive.spacing(context, 12)),
                            Wrap(
                              spacing: Responsive.spacing(context, 12),
                              runSpacing: Responsive.spacing(context, 12),
                              children: state.watchProviders!.map((provider) {
                                return Container(
                                  width: Responsive.width(context, 25),
                                  height: Responsive.width(context, 25),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: AppTheme.cardColor,
                                    border: Border.all(
                                      color: AppTheme.textSecondary.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: provider.logoUrl.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: provider.logoUrl,
                                            fit: BoxFit.contain,
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
                                              child: Center(
                                                child: Text(
                                                  provider.providerName,
                                                  style: TextStyle(
                                                    color: AppTheme.textPrimary,
                                                    fontSize: Responsive.fontSize(context, 10),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(
                                            color: AppTheme.cardColor,
                                            child: Center(
                                              child: Text(
                                                provider.providerName,
                                                style: TextStyle(
                                                  color: AppTheme.textPrimary,
                                                  fontSize: Responsive.fontSize(context, 10),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                  ),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: Responsive.spacing(context, 24)),
                          ],
                          
                          // Posters Gallery section
                          if (state.images != null && 
                              state.images!['posters'] != null && 
                              state.images!['posters']!.isNotEmpty) ...[
                            Text(
                              'Posters',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: Responsive.fontSize(context, 20),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: Responsive.spacing(context, 12)),
                            SizedBox(
                              height: Responsive.height(context, 35),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: state.images!['posters']!.length,
                                itemBuilder: (context, index) {
                                  final poster = state.images!['posters']![index];
                                  return Container(
                                    width: Responsive.width(context, 60),
                                    margin: EdgeInsets.only(
                                      right: Responsive.spacing(context, 12),
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: AppTheme.cardColor,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: CachedNetworkImage(
                                        imageUrl: poster.posterUrl,
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
                                            Icons.image_not_supported,
                                            color: AppTheme.textSecondary,
                                            size: Responsive.fontSize(context, 40),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: Responsive.spacing(context, 24)),
                          ],
                          
                          // Backdrops Gallery section
                          if (state.images != null && 
                              state.images!['backdrops'] != null && 
                              state.images!['backdrops']!.isNotEmpty) ...[
                            Text(
                              'Backdrops',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: Responsive.fontSize(context, 20),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: Responsive.spacing(context, 12)),
                            SizedBox(
                              height: Responsive.height(context, 25),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: state.images!['backdrops']!.length,
                                itemBuilder: (context, index) {
                                  final backdrop = state.images!['backdrops']![index];
                                  return Container(
                                    width: Responsive.width(context, 80),
                                    margin: EdgeInsets.only(
                                      right: Responsive.spacing(context, 12),
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: AppTheme.cardColor,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: CachedNetworkImage(
                                        imageUrl: backdrop.backdropUrl,
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
                                            Icons.image_not_supported,
                                            color: AppTheme.textSecondary,
                                            size: Responsive.fontSize(context, 40),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: Responsive.spacing(context, 24)),
                          ],
                          
                          // Cast section
                          if (state.cast != null && state.cast!.isNotEmpty) ...[
                            Text(
                              'Cast',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: Responsive.fontSize(context, 20),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: Responsive.spacing(context, 12)),
                            ...state.cast!.take(10).map((cast) => _CastListItem(
                              name: cast.name,
                              character: cast.character,
                              profileUrl: cast.profileUrl,
                              personId: cast.id,
                            )),
                            SizedBox(height: Responsive.spacing(context, 24)),
                          ],
                          
                          // Videos section
                          if (state.videos != null && state.videos!.isNotEmpty) ...[
                            Text(
                              'Videos',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: Responsive.fontSize(context, 20),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: Responsive.spacing(context, 12)),
                            // Main trailer (if available)
                            if (trailer != null) ...[
                              GestureDetector(
                                onTap: () => _playTrailer(trailer),
                                child: Container(
                                  height: Responsive.height(context, 25),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: AppTheme.cardColor,
                                  ),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      if (trailer.youtubeThumbnail.isNotEmpty)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: CachedNetworkImage(
                                            imageUrl: trailer.youtubeThumbnail,
                                            fit: BoxFit.cover,
                                            errorWidget: (context, url, error) => Container(
                                              color: AppTheme.cardColor,
                                            ),
                                          ),
                                        )
                                      else
                                        Container(color: AppTheme.cardColor),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
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
                                      Positioned(
                                        bottom: Responsive.spacing(context, 12),
                                        left: Responsive.spacing(context, 12),
                                        right: Responsive.spacing(context, 12),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(Responsive.spacing(context, 8)),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.9),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.play_arrow,
                                                color: AppTheme.primaryColor,
                                                size: Responsive.fontSize(context, 24),
                                              ),
                                            ),
                                            SizedBox(width: Responsive.spacing(context, 12)),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    trailer.name,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: Responsive.fontSize(context, 16),
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(height: Responsive.spacing(context, 4)),
                                                  Container(
                                                    padding: EdgeInsets.symmetric(
                                                      horizontal: Responsive.spacing(context, 8),
                                                      vertical: Responsive.spacing(context, 4),
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: AppTheme.primaryColor,
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      trailer.type.toUpperCase(),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: Responsive.fontSize(context, 10),
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: Responsive.spacing(context, 16)),
                            ],
                            // Other videos (horizontal list)
                            if (state.videos!.length > 1) ...[
                              SizedBox(
                                height: Responsive.height(context, 20),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: state.videos!.length,
                                  itemBuilder: (context, index) {
                                    final video = state.videos![index];
                                    // Skip if it's the trailer (already shown above)
                                    if (video == trailer) return const SizedBox.shrink();
                                    
                                    return Container(
                                      width: Responsive.width(context, 60),
                                      margin: EdgeInsets.only(
                                        right: Responsive.spacing(context, 12),
                                      ),
                                      child: GestureDetector(
                                        onTap: () => _playTrailer(video),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            color: AppTheme.cardColor,
                                          ),
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              if (video.youtubeThumbnail.isNotEmpty)
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(12),
                                                  child: CachedNetworkImage(
                                                    imageUrl: video.youtubeThumbnail,
                                                    fit: BoxFit.cover,
                                                    errorWidget: (context, url, error) => Container(
                                                      color: AppTheme.cardColor,
                                                    ),
                                                  ),
                                                )
                                              else
                                                Container(color: AppTheme.cardColor),
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(12),
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      Colors.transparent,
                                                      Colors.black.withOpacity(0.8),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: Responsive.spacing(context, 8),
                                                left: Responsive.spacing(context, 8),
                                                right: Responsive.spacing(context, 8),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.play_circle_outline,
                                                          color: Colors.white,
                                                          size: Responsive.fontSize(context, 20),
                                                        ),
                                                        SizedBox(width: Responsive.spacing(context, 4)),
                                                        Expanded(
                                                          child: Text(
                                                            video.name,
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: Responsive.fontSize(context, 12),
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: Responsive.spacing(context, 4)),
                                                    Container(
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal: Responsive.spacing(context, 6),
                                                        vertical: Responsive.spacing(context, 2),
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: AppTheme.primaryColor,
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Text(
                                                        video.type.toUpperCase(),
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: Responsive.fontSize(context, 9),
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                            SizedBox(height: Responsive.spacing(context, 24)),
                          ],
                          
                          // Similar TV Shows section
                          if (state.similarTvShows != null && state.similarTvShows!.isNotEmpty) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Recommendations',
                                    style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: Responsive.fontSize(context, 20),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const MainNavigationScreen(initialIndex: 2),
                                        ),
                                        (route) => false,
                                      );
                                    },
                                    child: Text(
                                      'View All',
                                      style: TextStyle(
                                        color: Colors.amber,
                                        fontSize: Responsive.fontSize(context, 14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            SizedBox(height: Responsive.spacing(context, 12)),
                            () {
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
                              return SizedBox(
                              height: sectionHeight,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: state.similarTvShows!.length,
                                itemBuilder: (context, index) {
                                  return MovieCard(
                                    movie: state.similarTvShows![index],
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TvShowDetailsScreen(
                                            tvShowId: state.similarTvShows![index].id,
                                          ),
                                        ),
                                      );
                                    },
                                    width: cardWidth,
                                  );
                                },
                              ),
                            );
                            }(),
                          ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  String _getGenreName(int genreId) {
    const genreMap = {
      28: 'Action',
      12: 'Adventure',
      16: 'Animation',
      35: 'Comedy',
      80: 'Crime',
      99: 'Documentary',
      18: 'Drama',
      10751: 'Family',
      14: 'Fantasy',
      36: 'History',
      27: 'Horror',
      10402: 'Music',
      9648: 'Mystery',
      10749: 'Romance',
      878: 'Science Fiction',
      10770: 'TV Movie',
      53: 'Thriller',
      10752: 'War',
      37: 'Western',
    };
    return genreMap[genreId] ?? 'TV Show';
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.spacing(context, 12)),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryColor,
            size: Responsive.fontSize(context, 20),
          ),
          SizedBox(width: Responsive.spacing(context, 8)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: Responsive.fontSize(context, 11),
                  ),
                ),
                SizedBox(height: Responsive.spacing(context, 2)),
                Text(
                  value,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: Responsive.fontSize(context, 14),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CastListItem extends StatelessWidget {
  final String name;
  final String? character;
  final String profileUrl;
  final int personId;

  const _CastListItem({
    required this.name,
    this.character,
    required this.profileUrl,
    required this.personId,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PersonDetailsScreen(personId: personId),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: Responsive.spacing(context, 12)),
        child: Row(
          children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Responsive.width(context, 10)),
            child: CachedNetworkImage(
              imageUrl: profileUrl,
              width: Responsive.width(context, 15),
              height: Responsive.width(context, 15),
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: Responsive.width(context, 15),
                height: Responsive.width(context, 15),
                color: AppTheme.cardColor,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: Responsive.width(context, 15),
                height: Responsive.width(context, 15),
                color: AppTheme.cardColor,
                child: Icon(
                  Icons.person,
                  color: AppTheme.textSecondary,
                  size: Responsive.fontSize(context, 24),
                ),
              ),
            ),
          ),
          SizedBox(width: Responsive.spacing(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: Responsive.fontSize(context, 14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (character != null && character!.isNotEmpty) ...[
                  SizedBox(height: Responsive.spacing(context, 2)),
                  Text(
                    character!,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: Responsive.fontSize(context, 12),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: AppTheme.textSecondary,
            size: Responsive.fontSize(context, 16),
          ),
        ],
      ),
    ),
    );
  }
}
