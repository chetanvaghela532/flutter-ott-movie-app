import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../bloc/movies_bloc.dart';
import '../bloc/movies_event.dart';
import '../bloc/movies_state.dart';
import '../widgets/movie_card.dart';
import 'movie_details_screen.dart';
import '../../domain/entities/movie_entity.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSearchMode = false;

  // Common movie genres with their TMDB IDs
  final List<Map<String, dynamic>> _genres = [
    {'id': 28, 'name': 'Action'},
    {'id': 12, 'name': 'Adventure'},
    {'id': 16, 'name': 'Animation'},
    {'id': 35, 'name': 'Comedy'},
    {'id': 80, 'name': 'Crime'},
    {'id': 99, 'name': 'Documentary'},
    {'id': 18, 'name': 'Drama'},
    {'id': 10751, 'name': 'Family'},
    {'id': 14, 'name': 'Fantasy'},
    {'id': 36, 'name': 'History'},
    {'id': 27, 'name': 'Horror'},
    {'id': 10402, 'name': 'Music'},
    {'id': 9648, 'name': 'Mystery'},
    {'id': 10749, 'name': 'Romance'},
    {'id': 878, 'name': 'Science Fiction'},
    {'id': 10770, 'name': 'TV Movie'},
    {'id': 53, 'name': 'Thriller'},
    {'id': 10752, 'name': 'War'},
    {'id': 37, 'name': 'Western'},
  ];

  @override
  void initState() {
    super.initState();
    // Load trending movies by default
    context.read<MoviesBloc>().add(const LoadTrendingMovies());
    // Listen to scroll events for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      // Load more when user scrolls to 80% of the list
      final state = context.read<MoviesBloc>().state;
      if (state is MoviesLoaded && state.hasMorePages && !state.isLoadingMore) {
        context.read<MoviesBloc>().add(const LoadMoreMovies());
      }
    }
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _isSearchMode = false;
      });
      // Reload default movies
      context.read<MoviesBloc>().add(const LoadTrendingMovies());
      return;
    }
    setState(() {
      _isSearchMode = true;
    });
    context.read<MoviesBloc>().add(SearchMoviesEvent(query));
  }

  void _onGenreSelected(String genreName) {
    setState(() {
      _isSearchMode = true;
      _searchController.text = genreName;
    });
    // Search for movies with this genre
    context.read<MoviesBloc>().add(SearchMoviesEvent(genreName));
  }

  void _onAllSelected() {
    setState(() {
      _isSearchMode = false;
      _searchController.clear();
    });
    // Reload default movies
    context.read<MoviesBloc>().add(const LoadTrendingMovies());
  }

  void _navigateToDetails(MovieEntity movie) {
    // For now, we'll navigate to MovieDetailsScreen
    // In a real app, you might want to check if it's a TV show based on some criteria
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailsScreen(movieId: movie.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Search Movies & Shows'),
      ),
      body: BlocBuilder<MoviesBloc, MoviesState>(
        builder: (context, state) {
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Search field
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(Responsive.spacing(context, 16)),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search movies or web series...',
                      hintStyle: const TextStyle(color: AppTheme.textSecondary),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppTheme.textSecondary,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: AppTheme.textSecondary,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _performSearch('');
                                setState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppTheme.cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Responsive.spacing(context, 12)),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: Responsive.spacing(context, 16),
                        vertical: Responsive.spacing(context, 12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                      _performSearch(value);
                    },
                  ),
                ),
              ),
              // Genre search chips
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.spacing(context, 16),
                    vertical: Responsive.spacing(context, 8),
                  ),
                  child: Wrap(
                    spacing: Responsive.isTablet(context)
                        ? Responsive.spacing(context, 12)
                        : Responsive.spacing(context, 8),
                    runSpacing: Responsive.isTablet(context)
                        ? Responsive.spacing(context, 12)
                        : Responsive.spacing(context, 8),
                    children: [
                      // "All" option
                      FilterChip(
                        label: const Text('All'),
                        selected: !_isSearchMode,
                        onSelected: (selected) {
                          if (selected) {
                            _onAllSelected();
                          }
                        },
                        selectedColor: AppTheme.primaryColor,
                        checkmarkColor: AppTheme.textPrimary,
                        labelStyle: TextStyle(
                          color: !_isSearchMode ? AppTheme.textPrimary : AppTheme.textSecondary,
                          fontWeight: !_isSearchMode ? FontWeight.w600 : FontWeight.normal,
                          fontSize: Responsive.isTablet(context) ? 14 : 12,
                        ),
                        backgroundColor: AppTheme.cardColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.isTablet(context)
                              ? Responsive.spacing(context, 14)
                              : Responsive.spacing(context, 12),
                          vertical: Responsive.isTablet(context)
                              ? Responsive.spacing(context, 10)
                              : Responsive.spacing(context, 8),
                        ),
                      ),
                      // Genre chips
                      ..._genres.map((genre) {
                        final genreName = genre['name'] as String;
                        final isSelected = _isSearchMode && _searchController.text == genreName;
                        return FilterChip(
                          label: Text(genreName),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              _onGenreSelected(genreName);
                            }
                          },
                          selectedColor: AppTheme.primaryColor,
                          checkmarkColor: AppTheme.textPrimary,
                          labelStyle: TextStyle(
                            color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            fontSize: Responsive.isTablet(context) ? 14 : 12,
                          ),
                          backgroundColor: AppTheme.cardColor,
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.isTablet(context)
                                ? Responsive.spacing(context, 14)
                                : Responsive.spacing(context, 12),
                            vertical: Responsive.isTablet(context)
                                ? Responsive.spacing(context, 10)
                                : Responsive.spacing(context, 8),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              // Movies grid or loading/error states
              if (state is MoviesLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                )
              else if (state is MoviesError)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: Responsive.fontSize(context, 64),
                          color: AppTheme.textSecondary.withOpacity(0.5),
                        ),
                        SizedBox(height: Responsive.spacing(context, 16)),
                        Text(
                          state.message,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: Responsive.fontSize(context, 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (state is MoviesLoaded)
                state.movies.isEmpty
                    ? SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.movie_outlined,
                                size: Responsive.fontSize(context, 64),
                                color: AppTheme.textSecondary.withOpacity(0.5),
                              ),
                              SizedBox(height: Responsive.spacing(context, 16)),
                              Text(
                                'No results found',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: Responsive.fontSize(context, 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: EdgeInsets.all(Responsive.spacing(context, 16)),
                        sliver: SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: () {
                              final screenWidth = MediaQuery.of(context).size.width;
                              final padding = Responsive.spacing(context, 16);
                              final spacing = Responsive.spacing(context, 12);
                              final availableWidth = screenWidth - (padding * 2);
                              double desiredPercent;
                              if (Responsive.isMobile(context)) {
                                desiredPercent = 35;
                              } else if (Responsive.isTablet(context)) {
                                desiredPercent = 16;
                              } else {
                                desiredPercent = 12;
                              }
                              final desiredWidth = Responsive.width(context, desiredPercent);
                              int count =
                                  ((availableWidth + spacing) / (desiredWidth + spacing)).floor();
                              if (Responsive.isMobile(context)) {
                                count = count.clamp(2, 3);
                              } else if (Responsive.isTablet(context)) {
                                count = count.clamp(4, 6);
                              } else {
                                count = count.clamp(6, 8);
                              }
                              return count;
                            }(),
                            childAspectRatio: 0.7,
                            crossAxisSpacing: Responsive.spacing(context, 12),
                            mainAxisSpacing: Responsive.spacing(context, 12),
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return LayoutBuilder(
                                builder: (context, constraints) {
                                  return MovieCard(
                                    movie: state.movies[index],
                                    onTap: () => _navigateToDetails(state.movies[index]),
                                    width: constraints.maxWidth - Responsive.spacing(context, 12),
                                  );
                                },
                              );
                            },
                            childCount: state.movies.length,
                          ),
                        ),
                      ),
              // Loading more indicator
              if (state is MoviesLoaded && state.isLoadingMore)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(Responsive.spacing(context, 16)),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                )
              else
                // Initial state - show default movies
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.movie_outlined,
                          size: Responsive.fontSize(context, 64),
                          color: AppTheme.textSecondary.withOpacity(0.5),
                        ),
                        SizedBox(height: Responsive.spacing(context, 16)),
                        Text(
                          'Browse trending movies',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: Responsive.fontSize(context, 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
