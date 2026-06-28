import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../injection/injection_container.dart' as di;
import '../bloc/person_details_bloc.dart';
import '../bloc/person_details_event.dart';
import '../bloc/person_details_state.dart';
import 'movie_details_screen.dart';
import 'tv_show_details_screen.dart';

class PersonDetailsScreen extends StatefulWidget {
  final int personId;

  const PersonDetailsScreen({
    super.key,
    required this.personId,
  });

  @override
  State<PersonDetailsScreen> createState() => _PersonDetailsScreenState();
}

class _PersonDetailsScreenState extends State<PersonDetailsScreen> {
  bool _isBiographyExpanded = false;

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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<PersonDetailsBloc>()
        ..add(LoadAllPersonDetails(widget.personId)),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: BlocBuilder<PersonDetailsBloc, PersonDetailsState>(
          builder: (context, state) {
            if (state is PersonDetailsLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryColor,
                ),
              );
            }

            if (state is PersonDetailsError) {
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
                        context.read<PersonDetailsBloc>().add(LoadAllPersonDetails(widget.personId));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is PersonDetailsLoaded) {
              final person = state.person;
              final credits = state.movieCredits;
              final castCredits = credits?['cast'] ?? [];
              final crewCredits = credits?['crew'] ?? [];

              return CustomScrollView(
                slivers: [
                  // Hero profile section
                  SliverAppBar(
                    expandedHeight: Responsive.height(context, 40),
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
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (person.profilePath != null)
                            CachedNetworkImage(
                              imageUrl: person.profileUrl,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Container(
                                color: AppTheme.cardColor,
                              ),
                            )
                          else
                            Container(color: AppTheme.cardColor),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.5),
                                  AppTheme.backgroundColor,
                                ],
                                stops: const [0.0, 0.6, 1.0],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Content section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(Responsive.spacing(context, 16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name and basic info
                          Text(
                            person.name,
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: Responsive.fontSize(context, 28),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                          SizedBox(height: Responsive.spacing(context, 16)),
                          
                          // Known for department
                          if (person.knownForDepartment != null) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.work,
                                  color: AppTheme.primaryColor,
                                  size: Responsive.fontSize(context, 18),
                                ),
                                SizedBox(width: Responsive.spacing(context, 8)),
                                Text(
                                  person.knownForDepartment!,
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: Responsive.fontSize(context, 14),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: Responsive.spacing(context, 12)),
                          ],
                          
                          // Birthday and place of birth
                          if (person.birthday != null || person.placeOfBirth != null) ...[
                            Row(
                              children: [
                                if (person.birthday != null) ...[
                                  Icon(
                                    Icons.cake,
                                    color: AppTheme.primaryColor,
                                    size: Responsive.fontSize(context, 18),
                                  ),
                                  SizedBox(width: Responsive.spacing(context, 8)),
                                  Text(
                                    _formatDate(person.birthday),
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: Responsive.fontSize(context, 14),
                                    ),
                                  ),
                                ],
                                if (person.birthday != null && person.placeOfBirth != null)
                                  SizedBox(width: Responsive.spacing(context, 16)),
                                if (person.placeOfBirth != null) ...[
                                  Icon(
                                    Icons.location_on,
                                    color: AppTheme.primaryColor,
                                    size: Responsive.fontSize(context, 18),
                                  ),
                                  SizedBox(width: Responsive.spacing(context, 8)),
                                  Expanded(
                                    child: Text(
                                      person.placeOfBirth!,
                                      style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: Responsive.fontSize(context, 14),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: Responsive.spacing(context, 24)),
                          ],
                          
                          // Biography
                          if (person.biography != null && person.biography!.isNotEmpty) ...[
                            Text(
                              'Biography',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: Responsive.fontSize(context, 20),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: Responsive.spacing(context, 12)),
                            Text(
                              person.biography!,
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: Responsive.fontSize(context, 14),
                                height: 1.6,
                              ),
                              maxLines: _isBiographyExpanded ? null : 6,
                              overflow: _isBiographyExpanded 
                                  ? TextOverflow.visible 
                                  : TextOverflow.ellipsis,
                            ),
                            if (person.biography!.length > 200)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isBiographyExpanded = !_isBiographyExpanded;
                                  });
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(top: Responsive.spacing(context, 8)),
                                  child: Text(
                                    _isBiographyExpanded ? 'Show Less' : 'Show More',
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
                          
                          // Cast Credits
                          if (castCredits.isNotEmpty) ...[
                            Text(
                              'Acting Credits',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: Responsive.fontSize(context, 20),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: Responsive.spacing(context, 12)),
                            SizedBox(
                              height: Responsive.height(context, 30),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: castCredits.length,
                                itemBuilder: (context, index) {
                                  final credit = castCredits[index];
                                  return Container(
                                    width: Responsive.width(context, 35),
                                    margin: EdgeInsets.only(
                                      right: Responsive.spacing(context, 12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              if (credit.mediaType == 'movie') {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => MovieDetailsScreen(
                                                      movieId: credit.id,
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => TvShowDetailsScreen(
                                                      tvShowId: credit.id,
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(Responsive.spacing(context, 12)),
                                              child: CachedNetworkImage(
                                                imageUrl: credit.posterUrl,
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
                                                    Icons.movie,
                                                    color: AppTheme.textSecondary,
                                                    size: Responsive.fontSize(context, 40),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: Responsive.spacing(context, 8)),
                                        Text(
                                          credit.title,
                                          style: TextStyle(
                                            color: AppTheme.textPrimary,
                                            fontSize: Responsive.fontSize(context, 12),
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (credit.character != null) ...[
                                          SizedBox(height: Responsive.spacing(context, 4)),
                                          Text(
                                            'as ${credit.character}',
                                            style: TextStyle(
                                              color: AppTheme.textSecondary,
                                              fontSize: Responsive.fontSize(context, 10),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: Responsive.spacing(context, 24)),
                          ],
                          
                          // Crew Credits
                          if (crewCredits.isNotEmpty) ...[
                            Text(
                              'Crew Credits',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: Responsive.fontSize(context, 20),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: Responsive.spacing(context, 12)),
                            SizedBox(
                              height: Responsive.height(context, 30),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: crewCredits.length,
                                itemBuilder: (context, index) {
                                  final credit = crewCredits[index];
                                  return Container(
                                    width: Responsive.width(context, 35),
                                    margin: EdgeInsets.only(
                                      right: Responsive.spacing(context, 12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              if (credit.mediaType == 'movie') {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => MovieDetailsScreen(
                                                      movieId: credit.id,
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => TvShowDetailsScreen(
                                                      tvShowId: credit.id,
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(Responsive.spacing(context, 12)),
                                              child: CachedNetworkImage(
                                                imageUrl: credit.posterUrl,
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
                                                    Icons.movie,
                                                    color: AppTheme.textSecondary,
                                                    size: Responsive.fontSize(context, 40),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: Responsive.spacing(context, 8)),
                                        Text(
                                          credit.title,
                                          style: TextStyle(
                                            color: AppTheme.textPrimary,
                                            fontSize: Responsive.fontSize(context, 12),
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (credit.job != null) ...[
                                          SizedBox(height: Responsive.spacing(context, 4)),
                                          Text(
                                            credit.job!,
                                            style: TextStyle(
                                              color: AppTheme.textSecondary,
                                              fontSize: Responsive.fontSize(context, 10),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
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
}

