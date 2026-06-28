import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/utils/common_secure.dart';
import '../../../../core/services/config_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import '../../../../core/services/ad_config_manager.dart';
import '../../../../core/services/ad_manager.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeOutAnimation;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _pulseAnimation;

  // Future to track config loading
  Future<void>? _configFuture;

  @override
  void initState() {
    super.initState();

    // Start loading config immediately
    _configFuture = _fetchAndSetupConfig();

    // Initialize animation controller with 5.5 second duration (slower)
    // 0.0-0.15: Black screen (15% of time = ~0.8s)
    // 0.15-0.25: Logo fades in (10% of time = ~0.55s)
    // 0.25-0.85: Logo scales up (60% of time = ~3.3s)
    // 0.85-1.0: Logo fades out (15% of time = ~0.8s)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5500),
    );

    // Logo fade-in animation: appears after black screen (slower)
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.25, curve: Curves.easeInOut),
      ),
    );

    // Scale animation: starts from 0.5, grows slowly and smoothly to 20 (full screen)
    _scaleAnimation = Tween<double>(begin: 0.5, end: 20.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.85, curve: Curves.easeInOutCubic),
      ),
    );

    // Fade out animation: fades out at the end
    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.85, 1.0, curve: Curves.easeIn),
      ),
    );

    // Pulse animation: subtle pulse effect after logo appears
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.4, curve: Curves.easeInOut),
      ),
    );

    // Start animation
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestAppTrackingTransparency();
    });

    // Navigate to main screen after animation completes
    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        // Ensure config is loaded before navigating
        if (_configFuture != null) {
          await _configFuture;
        }

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const MainNavigationScreen(),
            ),
          );
        }
      }
    });
  }

  Future<void> _requestAppTrackingTransparency() async {
    if (Platform.isIOS) {
      try {
        final status =
            await AppTrackingTransparency.trackingAuthorizationStatus;
        if (status == TrackingStatus.notDetermined) {
          // Wait a moment before showing the dialog to ensure the app is fully active
          await Future.delayed(const Duration(milliseconds: 1000));
          final result =
              await AppTrackingTransparency.requestTrackingAuthorization();
          debugPrint('App Tracking Transparency status: $result');
        } else {
          debugPrint('App Tracking Transparency already determined: $status');
        }
      } catch (e) {
        debugPrint('Error requesting App Tracking Transparency: $e');
      }
    }
  }

  Future<void> _fetchAndSetupConfig() async {
    const configUrl = String.fromEnvironment('REMOTE_CONFIG_URL');
    Map<String, dynamic>? loadedConfig;
    if (configUrl.isNotEmpty) {
      try {
        final dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );
        final response = await dio.get(configUrl);
        if (response.statusCode == 200) {
          final encryptedData = response.data.toString();
          final decryptedString = CommonSecure.decrypt(encryptedData);
          if (decryptedString != null) {
            loadedConfig = json.decode(decryptedString);
            // debugPrint('loadedConfig ==>> $loadedConfig');
          }
        }
      } catch (_) {}
    }
    if (loadedConfig == null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final cached = prefs.getString('remote_config_cache');
        if (cached != null && cached.isNotEmpty) {
          loadedConfig = json.decode(cached);
        }
      } catch (_) {}
    }
    if (loadedConfig != null) {
      ConfigService().setConfig(loadedConfig);
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'remote_config_cache',
        json.encode(ConfigService().currentConfig),
      );
    } catch (_) {}
    try {
      await AdConfigManager().init();
      await AdManager().init();
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // Background
              Container(
                width: size.width,
                height: size.height,
                color: AppTheme.backgroundColor,
              ),
              // Animated Logo (only shows after black screen period)
              if (_controller.value >= 0.15)
                Center(
                  child: Opacity(
                    opacity: _fadeInAnimation.value * _fadeOutAnimation.value,
                    child: Transform.scale(
                      scale: _controller.value < 0.25
                          ? 0.5
                          : _scaleAnimation.value *
                                (1.0 + (_pulseAnimation.value - 1.0) * 0.1),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            AppAssets.logoRemoved,
                            width: 120,
                            height: 120,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              // App Name (shown after logo appears, fades out early)
              if (_controller.value >= 0.25 && _controller.value < 0.5)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 200),
                    child: Opacity(
                      opacity:
                          _fadeInAnimation.value *
                          (1.0 - ((_controller.value - 0.25) * 4)),
                      child: const Text(
                        "Moviebox",
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
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
