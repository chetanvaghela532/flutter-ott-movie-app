import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_review/in_app_review.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_assets.dart';
import 'favorites_screen.dart';
import '../../../../core/services/config_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '1.0.0';
  String _appName = 'MovieBox';
  bool _isLoadingVersion = true;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _version = packageInfo.version;
        _appName = packageInfo.appName;
        _isLoadingVersion = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingVersion = false;
      });
    }
  }

  Future<void> _openPrivacyPolicy() async {
    final url = ConfigService().privacyPolicy;
    if (url.isEmpty) {
      _showSnackBar('Privacy Policy not available');
      return;
    }
    await _launchUrl(url, 'Privacy Policy');
  }

  Future<void> _launchUrl(String url, String name) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          _showSnackBar('Could not open $name');
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error opening $name');
      }
    }
  }

  Future<void> _openRateApp() async {
    try {
      final InAppReview inAppReview = InAppReview.instance;

      // Check if the review is available
      if (await inAppReview.isAvailable()) {
        // Request the review (shows native dialog on iOS/Android)
        await inAppReview.requestReview();
      } else {
        // If in-app review is not available, open the store page
        // Note: Replace with your actual App Store ID when available
        await inAppReview.openStoreListing(
          appStoreId:
              '6757224928', // iOS App Store ID (leave empty if not published yet)
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error opening rating dialog');
      }
    }
  }

  Future<void> _openSendFeedback() async {
    try {
      const email = 'ottwatchmovies@gmail.com';
      const subject = 'MovieBox - Feedback';

      // Construct mailto URI as string for better Android compatibility
      final String mailtoUri =
          'mailto:$email?subject=${Uri.encodeComponent(subject)}';
      final Uri emailUri = Uri.parse(mailtoUri);

      // Try to launch directly - canLaunchUrl may not work correctly for mailto on Android
      try {
        await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        // Fallback: try with platformDefault mode
        try {
          await launchUrl(emailUri, mode: LaunchMode.platformDefault);
        } catch (e2) {
          if (mounted) {
            _showSnackBar(
              'No email app found. Please install an email client.',
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error opening email client');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? AppTheme.primaryColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            )
          : null,
      trailing:
          trailing ??
          const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? AppTheme.primaryColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            )
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
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
          'Settings',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.backgroundColor,
      ),
      body: ListView(
        children: [
          // App Info Section
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      AppAssets.logo512,
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _appName,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isLoadingVersion ? 'Loading...' : 'Version $_version',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // General Settings
          _buildSectionHeader('General'),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildSettingTile(
                  icon: Icons.favorite,
                  title: 'Favorites',
                  subtitle: 'View your favorite movies and TV shows',
                  iconColor: Colors.red,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FavoritesScreen(),
                      ),
                    );
                  },
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppTheme.dividerColor,
                  indent: 72,
                ),
                _buildSwitchTile(
                  icon: Icons.notifications_outlined,
                  title: 'Push Notifications',
                  subtitle: 'Receive updates and recommendations',
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppTheme.dividerColor,
                  indent: 72,
                ),
                _buildSettingTile(
                  icon: Icons.lock_outline,
                  title: 'Privacy Policy',
                  onTap: _openPrivacyPolicy,
                  iconColor: Colors.red,
                ),

              ],
            ),
          ),

          // Support
          _buildSectionHeader('Support'),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildSettingTile(
                  icon: Icons.feedback_outlined,
                  title: 'Send Feedback',
                  subtitle: 'Share your thoughts',
                  iconColor: Colors.teal,
                  onTap: _openSendFeedback,
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppTheme.dividerColor,
                  indent: 72,
                ),
                _buildSettingTile(
                  icon: Icons.star_outline,
                  title: 'Rate App',
                  subtitle: 'Rate us on the App Store',
                  iconColor: Colors.yellow,
                  onTap: _openRateApp,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
