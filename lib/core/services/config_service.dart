import 'dart:io';

class ConfigService {
  static final ConfigService _instance = ConfigService._internal();
  factory ConfigService() => _instance;
  ConfigService._internal();

  Map<String, dynamic>? _config;

  void setConfig(Map<String, dynamic> config) {
    _config = {
      ..._defaultConfig,
      ...config,
    };
  }

  String get mainUrl => _config?['mainUrl'] ?? '';
  bool get showPlayButton => _config?['showPlayButton'] ?? false;
  String get privacyPolicy => _config?['privacyPolicy'] ?? '';
  String get telegramChannel => _config?['telegramChannel'] ?? '';
  bool get isInAppReviewShow => _config?['isInAppReviewShow'] ?? false;
  bool get showAds => _config?['showAds'] ?? false;
  int get addCounter => _config?['addCounter'] ?? 0;
  bool get forceUpdate => _config?['forceUpdate'] ?? false;
  bool get softUpdate => _config?['softUpdate'] ?? false;
  String get newPlayStoreAppUrl => _config?['newPlayStoreAppUrl'] ?? '';
  String get updateText => _config?['updateText'] ?? '';
  bool get adsEnabled => _config?['ads_enabled'] ?? false;
  int get interstitialClickInterval => _config?['interstitial_click_interval'] ?? 0;
  int get rewardedClickInterval => _config?['rewarded_click_interval'] ?? 0;
  bool get bannerEnabled => _config?['banner_enabled'] ?? false;
  bool get nativeEnabled => _config?['native_enabled'] ?? false;
  String get adNetwork => (_config?['ad_network'] ?? 'admob').toString();
  int get minSecondsBetweenInterstitial => _config?['min_seconds_between_interstitial'] ?? 60;
  bool get testMode => _config?['test_mode'] ?? false;
  String get bannerAdUnitId => _config?['banner_ad_unit_id'] ?? '';
  String get interstitialAdUnitId => _config?['interstitial_ad_unit_id'] ?? '';
  String get rewardedAdUnitId => _config?['rewarded_ad_unit_id'] ?? '';
  String get nativeAdUnitId => _config?['native_ad_unit_id'] ?? '';
  int get adLoadMaxRetries => _config?['ad_load_max_retries'] ?? 3;
  int get adLoadInitialBackoffMs => _config?['ad_load_initial_backoff_ms'] ?? 1000;
  bool get appOpenEnabled => _config?['app_open_enabled'] ?? false;
  int get appOpenMinSecondsBetween => _config?['app_open_min_seconds_between'] ?? 300;
  String get appOpenAdUnitId => _config?['app_open_ad_unit_id'] ?? '';
  String get appOpenAdUnitIdPlatform => _platformAdUnitId('app_open_ad_unit_id');
  
  bool get hasConfig => _config != null;

  Map<String, dynamic> get currentConfig => _config ?? _defaultConfig;

  String _platformAdUnitId(String key) {
    final v = _config?[key];
    if (v is String) return v;
    if (v is Map) {
      final platformKey = Platform.isAndroid ? 'android' : 'ios';
      final p = v[platformKey];
      if (p is String) return p;
      if (p != null) return p.toString();
    }
    return '';
  }

  String get bannerAdUnitIdPlatform => _platformAdUnitId('banner_ad_unit_id');
  String get interstitialAdUnitIdPlatform => _platformAdUnitId('interstitial_ad_unit_id');
  String get rewardedAdUnitIdPlatform => _platformAdUnitId('rewarded_ad_unit_id');
  String get nativeAdUnitIdPlatform => _platformAdUnitId('native_ad_unit_id');

  static const Map<String, dynamic> _defaultConfig = {
    'ads_enabled': false,
    'interstitial_click_interval': 3,
    'rewarded_click_interval': 5,
    'banner_enabled': false,
    'native_enabled': false,
    'ad_network': 'admob',
    'min_seconds_between_interstitial': 60,
    'test_mode': false,
    'banner_ad_unit_id': '',
    'interstitial_ad_unit_id': '',
    'rewarded_ad_unit_id': '',
    'native_ad_unit_id': '',
    'ad_load_max_retries': 3,
    'ad_load_initial_backoff_ms': 1000,
    'app_open_enabled': false,
    'app_open_min_seconds_between': 300,
    'app_open_ad_unit_id': '',
  };
}
