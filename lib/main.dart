import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/services/firebase_service.dart';
import 'core/services/notification_handler.dart' show navigatorKey;
import 'injection/injection_container.dart' as di;
import 'features/movies/presentation/bloc/movies_bloc.dart';
import 'features/movies/presentation/bloc/movies_event.dart';
import 'features/movies/presentation/bloc/movie_details_bloc.dart';
import 'features/movies/presentation/screens/main_navigation_screen.dart';
import 'features/movies/presentation/screens/search_screen.dart';
import 'features/movies/presentation/screens/settings_screen.dart';
import 'features/movies/presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  await di.init();
  runApp(const MovieGuideApp());
}

class MovieGuideApp extends StatelessWidget {
  const MovieGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<MoviesBloc>()..add(const LoadTrendingMovies()),
        ),
        BlocProvider(
          create: (_) => di.sl<MovieDetailsBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Movie Guide',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey, // Add navigator key for notification navigation
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/home': (context) => const MainNavigationScreen(),
          '/search': (context) => const SearchScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}
