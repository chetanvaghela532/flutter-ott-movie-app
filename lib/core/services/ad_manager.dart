import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_config_manager.dart';
import 'config_service.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  bool _initialized = false;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  BannerAd? _bannerAd;
  NativeAd? _nativeAd;
  AppOpenAd? _appOpenAd;

  int _interstitialLoadAttempts = 0;
  int _rewardedLoadAttempts = 0;
  int _appOpenLoadAttempts = 0;

  Future<void> init() async {
    if (_initialized) return;
    final cfg = ConfigService();
    if (!cfg.adsEnabled || cfg.adNetwork != 'admob') {
      _initialized = true;
      return;
    }
    await MobileAds.instance.initialize();
    await AdConfigManager().init();
    _initialized = true;
    // if (cfg.bannerEnabled) {
    //   await loadBanner();
    // }
    await preloadInterstitial();
    await preloadRewarded();
    if (cfg.nativeEnabled) {
      await loadNative();
    }
    await preloadAppOpen();
  }

  BannerAd? createBannerAd({Function(Ad, LoadAdError)? onAdFailedToLoad}) {
    final adUnitId = AdConfigManager().bannerAdUnitId;
    if (adUnitId.isEmpty) {
      return null;
    }
    return BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {},
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (onAdFailedToLoad != null) {
            onAdFailedToLoad(ad, error);
          }
        },
      ),
    );
  }

  // BannerAd? get bannerAd => _bannerAd;

  Future<void> preloadInterstitial() async {
    final cfg = ConfigService();
    if (!cfg.adsEnabled || cfg.adNetwork != 'admob') return;
    final adUnitId = AdConfigManager().interstitialAdUnitId;
    if (adUnitId.isEmpty) return;
    _interstitialAd?.dispose();
    _interstitialAd = null;
    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialLoadAttempts = 0;
        },
        onAdFailedToLoad: (error) async {
          _interstitialAd = null;
          _interstitialLoadAttempts += 1;
          await _retryLoadInterstitial();
        },
      ),
    );
  }

  Future<void> _retryLoadInterstitial() async {
    final cfg = ConfigService();
    final max = cfg.adLoadMaxRetries;
    if (_interstitialLoadAttempts > max) return;
    final base = cfg.adLoadInitialBackoffMs;
    final delayMs = base * (1 << (_interstitialLoadAttempts - 1));
    await Future.delayed(Duration(milliseconds: delayMs));
    await preloadInterstitial();
  }

  Future<void> showInterstitialIfAllowed() async {
    if (_interstitialAd == null) return;
    if (!AdConfigManager().canShowInterstitial()) return;
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
      onAdShowedFullScreenContent: (ad) {},
      onAdDismissedFullScreenContent: (ad) async {
        ad.dispose();
        await AdConfigManager().markInterstitialShown();
        await preloadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) async {
        ad.dispose();
        await preloadInterstitial();
      },
    );
    _interstitialAd!.show();
  }

  Future<void> recordClickAndMaybeShowInterstitial() async {
    await AdConfigManager().incrementClick();
    await showInterstitialIfAllowed();
  }

  Future<void> preloadRewarded() async {
    final cfg = ConfigService();
    if (!cfg.adsEnabled || cfg.adNetwork != 'admob') return;
    final adUnitId = AdConfigManager().rewardedAdUnitId;
    if (adUnitId.isEmpty) return;
    _rewardedAd?.dispose();
    _rewardedAd = null;
    await RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedLoadAttempts = 0;
        },
        onAdFailedToLoad: (error) async {
          _rewardedAd = null;
          _rewardedLoadAttempts += 1;
          await _retryLoadRewarded();
        },
      ),
    );
  }

  Future<void> _retryLoadRewarded() async {
    final cfg = ConfigService();
    final max = cfg.adLoadMaxRetries;
    if (_rewardedLoadAttempts > max) return;
    final base = cfg.adLoadInitialBackoffMs;
    final delayMs = base * (1 << (_rewardedLoadAttempts - 1));
    await Future.delayed(Duration(milliseconds: delayMs));
    await preloadRewarded();
  }

  Future<void> showRewardedIfAllowed({Function()? onRewardEarned}) async {
    if (_rewardedAd == null) return;
    if (!AdConfigManager().canShowRewarded()) return;
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback<RewardedAd>(
      onAdShowedFullScreenContent: (ad) {},
      onAdDismissedFullScreenContent: (ad) async {
        ad.dispose();
        await AdConfigManager().markRewardedShown();
        await preloadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, error) async {
        ad.dispose();
        await preloadRewarded();
      },
    );
    await _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
      if (onRewardEarned != null) onRewardEarned();
    });
  }

  Future<void> loadNative() async {
    final adUnitId = AdConfigManager().nativeAdUnitId;
    if (adUnitId.isEmpty) {
      _nativeAd = null;
      return;
    }
    _nativeAd?.dispose();
    _nativeAd = NativeAd(
      adUnitId: adUnitId,
      factoryId: 'listTile',
      listener: NativeAdListener(
        onAdLoaded: (ad) {},
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _nativeAd = null;
        },
      ),
      request: const AdRequest(),
    );
    await _nativeAd!.load();
  }

  NativeAd? get nativeAd => _nativeAd;

  Future<void> preloadAppOpen() async {
    final cfg = ConfigService();
    if (!cfg.adsEnabled || cfg.adNetwork != 'admob' || !cfg.appOpenEnabled) return;
    final adUnitId = AdConfigManager().appOpenAdUnitId;
    if (adUnitId.isEmpty) return;
    _appOpenAd?.dispose();
    _appOpenAd = null;
    try {
      await AppOpenAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            _appOpenAd = ad;
            _appOpenLoadAttempts = 0;
          },
          onAdFailedToLoad: (error) async {
            _appOpenAd = null;
            _appOpenLoadAttempts += 1;
            await _retryLoadAppOpen();
          },
        ),
      );
    } catch (_) {}
  }

  Future<void> _retryLoadAppOpen() async {
    final cfg = ConfigService();
    final max = cfg.adLoadMaxRetries;
    if (_appOpenLoadAttempts > max) return;
    final base = cfg.adLoadInitialBackoffMs;
    final delayMs = base * (1 << (_appOpenLoadAttempts - 1));
    await Future.delayed(Duration(milliseconds: delayMs));
    await preloadAppOpen();
  }

  Future<void> showAppOpenIfAllowed() async {
    if (_appOpenAd == null) return;
    if (!AdConfigManager().canShowAppOpen()) return;
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback<AppOpenAd>(
      onAdShowedFullScreenContent: (ad) {},
      onAdDismissedFullScreenContent: (ad) async {
        ad.dispose();
        await AdConfigManager().markAppOpenShown();
        await preloadAppOpen();
      },
      onAdFailedToShowFullScreenContent: (ad, error) async {
        ad.dispose();
        await preloadAppOpen();
      },
    );
    _appOpenAd!.show();
  }

  Future<void> showInterstitialOrProceed(Function postAction) async {
    await AdConfigManager().incrementClick();
    if (_interstitialAd != null && AdConfigManager().canShowInterstitial()) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
        onAdDismissedFullScreenContent: (ad) async {
          ad.dispose();
          await AdConfigManager().markInterstitialShown();
          await preloadInterstitial();
          postAction();
        },
        onAdFailedToShowFullScreenContent: (ad, error) async {
          ad.dispose();
          await preloadInterstitial();
          postAction();
        },
      );
      _interstitialAd!.show();
    } else {
      postAction();
    }
  }

  Future<void> dispose() async {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _bannerAd?.dispose();
    _nativeAd?.dispose();
    _appOpenAd?.dispose();
    _interstitialAd = null;
    _rewardedAd = null;
    _bannerAd = null;
    _nativeAd = null;
    _appOpenAd = null;
  }
}
