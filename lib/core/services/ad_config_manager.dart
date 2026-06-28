import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'config_service.dart';

class AdConfigManager {
  static final AdConfigManager _instance = AdConfigManager._internal();
  factory AdConfigManager() => _instance;
  AdConfigManager._internal();

  static const String _prefsPrefix = 'adcfg_';
  static const String _keyClickCount = '${_prefsPrefix}click_count';
  static const String _keyLastInterstitialAt = '${_prefsPrefix}last_interstitial_at';
  static const String _keyLastRewardedAt = '${_prefsPrefix}last_rewarded_at';
  static const String _keyLastShownType = '${_prefsPrefix}last_shown_type';
  static const String _keyLastAppOpenAt = '${_prefsPrefix}last_app_open_at';

  int _clickCount = 0;
  int _lastInterstitialAt = 0;
  int _lastRewardedAt = 0;
  String? _lastShownType;
  int _lastAppOpenAt = 0;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _clickCount = prefs.getInt(_keyClickCount) ?? 0;
    _lastInterstitialAt = prefs.getInt(_keyLastInterstitialAt) ?? 0;
    _lastRewardedAt = prefs.getInt(_keyLastRewardedAt) ?? 0;
    _lastShownType = prefs.getString(_keyLastShownType);
    _lastAppOpenAt = prefs.getInt(_keyLastAppOpenAt) ?? 0;
  }

  Future<void> resetCounters() async {
    _clickCount = 0;
    _lastInterstitialAt = 0;
    _lastRewardedAt = 0;
    _lastShownType = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyClickCount);
    await prefs.remove(_keyLastInterstitialAt);
    await prefs.remove(_keyLastRewardedAt);
    await prefs.remove(_keyLastShownType);
    await prefs.remove(_keyLastAppOpenAt);
  }

  bool canShowAppOpen() {
    final cfg = ConfigService();
    if (!cfg.adsEnabled) return false;
    if (cfg.adNetwork != 'admob') return false;
    if (!cfg.appOpenEnabled) return false;
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (_lastAppOpenAt > 0 &&
        (nowSec - _lastAppOpenAt) < cfg.appOpenMinSecondsBetween) {
      return false;
    }
    return true;
  }

  Future<void> markAppOpenShown() async {
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _lastAppOpenAt = nowSec;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastAppOpenAt, _lastAppOpenAt);
  }

  String get appOpenAdUnitId {
    final cfg = ConfigService();
    if (cfg.testMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/9257395921'
          : 'ca-app-pub-3940256099942544/5662855259';
    }
    return cfg.appOpenAdUnitIdPlatform;
  }
  Future<void> incrementClick({String? event}) async {
    _clickCount += 1;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyClickCount, _clickCount);
  }

  int get clickCount => _clickCount;

  bool get isBannerEnabled {
    final cfg = ConfigService();
    if (!cfg.adsEnabled) return false;
    if (cfg.adNetwork != 'admob') return false;
    return cfg.bannerEnabled;
  }

  bool get isNativeEnabled {
    final cfg = ConfigService();
    if (!cfg.adsEnabled) return false;
    if (cfg.adNetwork != 'admob') return false;
    return cfg.nativeEnabled;
  }

  bool canShowInterstitial() {
    final cfg = ConfigService();
    if (!cfg.adsEnabled) return false;
    if (cfg.adNetwork != 'admob') return false;
    if (_clickCount < cfg.interstitialClickInterval) return false;
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (_lastInterstitialAt > 0 &&
        (nowSec - _lastInterstitialAt) < cfg.minSecondsBetweenInterstitial) {
      return false;
    }
    // if (_lastShownType == 'interstitial') {
    //   return false;
    // }
    return true;
  }

  bool canShowRewarded() {
    final cfg = ConfigService();
    if (!cfg.adsEnabled) return false;
    if (cfg.adNetwork != 'admob') return false;
    if (_clickCount < cfg.rewardedClickInterval) return false;
    if (_lastShownType == 'rewarded') {
      return false;
    }
    return true;
  }

  Future<void> markInterstitialShown() async {
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _lastInterstitialAt = nowSec;
    _lastShownType = 'interstitial';
    _clickCount = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastInterstitialAt, _lastInterstitialAt);
    await prefs.setString(_keyLastShownType, _lastShownType!);
    await prefs.setInt(_keyClickCount, _clickCount);
  }

  Future<void> markRewardedShown() async {
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _lastRewardedAt = nowSec;
    _lastShownType = 'rewarded';
    _clickCount = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastRewardedAt, _lastRewardedAt);
    await prefs.setString(_keyLastShownType, _lastShownType!);
    await prefs.setInt(_keyClickCount, _clickCount);
  }

  String get bannerAdUnitId {
    final cfg = ConfigService();
    if (cfg.testMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-3940256099942544/2934735716';
    }
    return cfg.bannerAdUnitIdPlatform;
  }

  String get interstitialAdUnitId {
    final cfg = ConfigService();
    if (cfg.testMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712'
          : 'ca-app-pub-3940256099942544/4411468910';
    }
    return cfg.interstitialAdUnitIdPlatform;
  }

  String get rewardedAdUnitId {
    final cfg = ConfigService();
    if (cfg.testMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/5224354917'
          : 'ca-app-pub-3940256099942544/1712485313';
    }
    return cfg.rewardedAdUnitIdPlatform;
  }

  String get nativeAdUnitId {
    final cfg = ConfigService();
    if (cfg.testMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/2247696110'
          : 'ca-app-pub-3940256099942544/3986624511';
    }
    return cfg.nativeAdUnitIdPlatform;
  }
}
