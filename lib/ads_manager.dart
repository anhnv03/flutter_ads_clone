import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:infinity_ads_tracking_lib/ad_open_loader.dart';
import 'package:infinity_ads_tracking_lib/rewarded_ad_loader.dart';
import 'package:infinity_ads_tracking_lib/rewarded_interstitial_ad_loader.dart';

import 'ad_configuration.dart';
import 'banner_ad_loader.dart';
import 'interstitial_ad_loader.dart';
import 'native_ad_loader.dart';

/// Singleton class that manages loading, caching, and displaying of ads.
class AdManager {
  // Private constructor for singleton pattern.
  AdManager._privateConstructor();

  /// The single instance of [AdManager].
  static final AdManager instance = AdManager._privateConstructor();

  // Map of ad configurations by name.
  final Map<String, AdConfiguration> _configurations = {};

  // Cache of loaded ads by name.
  final Map<String, List<Ad>> _adCache = {};

  // App lifecycle tracking properties
  bool _showAdWhenAppOpened = false;
  DateTime? _pausedTime;
  static const Duration _minimumBackgroundDuration = Duration(seconds: 5);
  String? _appOpenAdName;
  AppLifecycleListener? _lifecycleListener;

  /// Initializes the [AdManager] with a list of [AdConfiguration].
  ///
  /// This method preloads ads based on the configurations provided.
  void initialize({
    required List<AdConfiguration> configurations,
    bool enableAppOpenAdTracking = false,
    String? appOpenAdName,
  }) {
    MobileAds.instance.initialize();

    for (var config in configurations) {
      if (_configurations.containsKey(config.name)) {
        throw Exception('Duplicate ad name: ${config.name}');
      }
      _configurations[config.name] = config;
      _adCache[config.name] = [];

      if (config.preload > 0) {
        _preloadAds(config);
      }
    }

    if (enableAppOpenAdTracking) {
      _appOpenAdName = appOpenAdName ?? 'app_open_ad_integration';
      _initializeLifecycleListener();
    }
  }

  void _initializeLifecycleListener() {
    _lifecycleListener?.dispose();
    _lifecycleListener = AppLifecycleListener(
      onStateChange: _handleAppLifecycleState,
    );
    debugPrint('[AdManager] Lifecycle listener initialized');
  }

  void _handleAppLifecycleState(AppLifecycleState state) {
    // Only process if app open ad tracking is enabled
    if (_appOpenAdName == null) return;

    debugPrint('[AdManager] Lifecycle state changed to: $state');

    switch (state) {
      case AppLifecycleState.paused:
        _pausedTime = DateTime.now();
        _showAdWhenAppOpened = true;
        debugPrint('[AdManager] App paused');
        break;

      case AppLifecycleState.resumed:
        if (_showAdWhenAppOpened && _pausedTime != null) {
          final pauseDuration = DateTime.now().difference(_pausedTime!);
          if (pauseDuration >= _minimumBackgroundDuration) {
            debugPrint(
                '[AdManager] Showing ad after background duration: ${pauseDuration.inSeconds}s');
            showAppOpenAd(_appOpenAdName!);
          } else {
            debugPrint(
                '[AdManager] Skip showing ad - background duration too short: ${pauseDuration.inSeconds}s');
          }
        }
        _showAdWhenAppOpened = false;
        _pausedTime = null;
        break;

      default:
        break;
    }
  }

  // Preloads ads based on the preload parameter in the configuration.
  void _preloadAds(AdConfiguration config) {
    for (int i = 0; i < config.preload; i++) {
      loadAd(config);
    }
  }

  // Loads an ad and adds it to the cache.
  Future<void> loadAd(AdConfiguration config) {
    switch (config.type) {
      case AdType.banner:
        return BannerAdLoader(config, _adCache).load();
      case AdType.interstitial:
        return InterstitialAdLoader(config, _adCache).load();
      case AdType.native:
        return NativeAdLoader(config, _adCache).load();
      case AdType.rewarded:
        return RewardedAdLoader(config, _adCache).load();
      case AdType.openApp:
        return AdOpenLoader(config, _adCache).load();
      case AdType.rewardedInterstitial:
        return RewardedInterstitialAdLoader(config, _adCache).load();
    }
  }

  /// Shows an interstitial ad by name.
  ///
  /// The [name] must correspond to an interstitial ad configuration.
  Future<void> showInterstitialAd(String name) async {
    if (!_configurations.containsKey(name)) {
      debugPrint('[AdManager] Ad configuration not found for name: $name');
      return;
    }

    var config = _configurations[name]!;
    if (config.type != AdType.interstitial) {
      debugPrint(
          '[AdManager] Ad configuration is not for an Interstitial Ad: $name');
      return;
    }

    if (_adCache[name]?.isNotEmpty ?? false) {
      _showInterstitial(name, config);
    } else {
      // case if adRequest is loading and not added to the cache
      debugPrint(
          '[AdManager] No interstitial ad ready for name: $name, load another and show');

      // load and add into cache
      await loadAd(config);
      if (_adCache[name]?.isNotEmpty ?? false) {
        _showInterstitial(name, config);
      }
    }
  }

  /// Shows a rewarded ad by name.
  ///
  /// The [name] must correspond to a rewarded ad configuration.
  Future<void> showRewardAd(String name,
      {required void Function(AdWithoutView, RewardItem)
          onUserEarnedReward}) async {
    if (!_configurations.containsKey(name)) {
      debugPrint('[AdManager] Ad configuration not found for name: $name');
      return;
    }

    var config = _configurations[name]!;
    if (config.type != AdType.rewarded) {
      debugPrint(
          '[AdManager] Ad configuration is not for a Rewarded Ad: $name');
      return;
    }

    if (_adCache[name]?.isNotEmpty ?? false) {
      _showRewarded(
          name: name, config: config, onUserEarnedReward: onUserEarnedReward);
    } else {
      // case if adRequest is loading and not added to the cache
      debugPrint(
          '[AdManager] No rewarded ad ready for name: $name, load another and show');

      // load and add into cache
      await loadAd(config);
      if (_adCache[name]?.isNotEmpty ?? false) {
        _showRewarded(
            name: name, config: config, onUserEarnedReward: onUserEarnedReward);
      }
    }
  }

  /// Shows a rewarded interstitial ad by name.
  ///
  /// The [name] must correspond to a rewarded interstitial ad configuration.
  Future<void> showRewardedInterstitialAd(
    String name, {
    required void Function(AdWithoutView, RewardItem) onUserEarnedReward,
  }) async {
    if (!_configurations.containsKey(name)) {
      debugPrint('[AdManager] Ad configuration not found for name: $name');
      return;
    }

    var config = _configurations[name]!;
    if (config.type != AdType.rewardedInterstitial) {
      debugPrint(
          '[AdManager] Ad configuration is not for a Rewarded Interstitial Ad: $name');
      return;
    }

    if (_adCache[name]?.isNotEmpty ?? false) {
      _showRewardedInterstitialAd(
          name: name, config: config, onUserEarnedReward: onUserEarnedReward);
    } else {
      // case if adRequest is loading and not added to the cache
      debugPrint(
          '[AdManager] No rewarded interstitial ad ready for name: $name, load another and show');

      // load and add into cache
      await loadAd(config);
      if (_adCache[name]?.isNotEmpty ?? false) {
        _showRewardedInterstitialAd(
            name: name, config: config, onUserEarnedReward: onUserEarnedReward);
      }
    }
  }

  /// Shows a rewarded ad by name.
  ///
  /// The [name] must correspond to a app open ad configuration.
  Future<void> showAppOpenAd(String name) async {
    if (!_configurations.containsKey(name)) {
      debugPrint('[AdManager] Ad configuration not found for name: $name');
      return;
    }

    var config = _configurations[name]!;
    // Fix: Check for correct ad type
    if (config.type != AdType.openApp) {
      // Changed from AdType.rewarded to AdType.openApp
      debugPrint(
          '[AdManager] Ad configuration is not for an App Open Ad: $name');
      return;
    }

    if (_adCache[name]?.isNotEmpty ?? false) {
      _showOpenAppAd(name: name, config: config);
    } else {
      // case if adRequest is loading and not added to the cache
      debugPrint(
          '[AdManager] No app open ad ready for name: $name, load another and show');

      // load and add into cache
      await loadAd(config);
      if (_adCache[name]?.isNotEmpty ?? false) {
        _showOpenAppAd(name: name, config: config);
      }
    }
  }

  /// Retrieves an ad configuration by name.
  ///
  /// Returns the [AdConfiguration] or `null` if not found.
  AdConfiguration? getConfiguration(String name) {
    return _configurations[name];
  }

  /// Gets an ad from the cache and removes it.
  /// Returns `null` if no ad is available in the cache.
  Ad? getAdFromCache(String name) {
    if (_adCache[name]?.isNotEmpty ?? false) {
      return _adCache[name]!.removeAt(0);
    }
    return null;
  }

  // Removes and returns the first ad from the cache.
  Ad _removeFirstAdFromCache(String name) {
    return _adCache[name]!.removeAt(0);
  }

  // Creates a FullScreenContentCallback to handle interstitial ad events.
  FullScreenContentCallback<InterstitialAd> _createFullScreenContentCallback(
      AdConfiguration config) {
    return FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('[AdManager] Ad showed full screen content: ${config.name}');
        _reloadAdIfNeeded(config);
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint(
            '[AdManager] Ad dismissed full screen content: ${config.name}');
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint(
            '[AdManager] Failed to show interstitial ad (${config.name}): $error');
        ad.dispose();
        _reloadAdIfNeeded(config);
      },
    );
  }

  // Reloads an ad if preload > 0 and the cache is empty.
  void _reloadAdIfNeeded(AdConfiguration config) {
    if (config.preload > 0 && (_adCache[config.name]?.isEmpty ?? true)) {
      debugPrint('[AdManager] Reloading ad for ${config.name}');
      loadAd(config);
    }
  }

  void _showInterstitial(String name, AdConfiguration config) {
    InterstitialAd ad = _removeFirstAdFromCache(name) as InterstitialAd;
    ad.fullScreenContentCallback = _createFullScreenContentCallback(config);
    ad.show();
    debugPrint('[AdManager] show interstitial ads');
  }

  // creates a full screen content callback to handle rewarded ad events.
  FullScreenContentCallback<RewardedAd>
      _createFullScreenContentCallbackRewarded(AdConfiguration config) {
    return FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('[AdManager] Ad showed full screen content: ${config.name}');
        _reloadAdIfNeeded(config);
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint(
            '[AdManager] Ad dismissed full screen content: ${config.name}');
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint(
            '[AdManager] Failed to show rewarded ad (${config.name}): $error');
        ad.dispose();
        _reloadAdIfNeeded(config);
      },
    );
  }

  void _showRewarded(
      {required String name,
      required AdConfiguration config,
      required void Function(AdWithoutView, RewardItem) onUserEarnedReward}) {
    RewardedAd ad = _removeFirstAdFromCache(name) as RewardedAd;
    ad.fullScreenContentCallback =
        _createFullScreenContentCallbackRewarded(config);
    ad.show(
      onUserEarnedReward: onUserEarnedReward,
    );
    debugPrint('[AdManager] show rewarded ads');
  }

  // creates a full screen content callback to handle app open ad events.
  FullScreenContentCallback<AppOpenAd>
      _createFullScreenContentCallbackOpenAppAd(AdConfiguration config) {
    return FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint(
            '[AdManager] App Open Ad showed full screen content: ${config.name}');
        _reloadAdIfNeeded(config);
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint(
            '[AdManager] App Open Ad dismissed full screen content: ${config.name}');
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint(
            '[AdManager] Failed to show app open ad (${config.name}): $error');
        ad.dispose();
        _reloadAdIfNeeded(config);
      },
    );
  }

  void _showOpenAppAd({
    required String name,
    required AdConfiguration config,
  }) {
    AppOpenAd ad = _removeFirstAdFromCache(name) as AppOpenAd;
    ad.fullScreenContentCallback =
        _createFullScreenContentCallbackOpenAppAd(config);
    ad.show();
    debugPrint('[AdManager] show open app ads');
  }

  // creates a full screen content callback to handle rewarded interstitial ad events.
  FullScreenContentCallback<RewardedInterstitialAd>
      _createFullScreenContentCallbackRewardedInterstitialAd(
          AdConfiguration config) {
    return FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint(
            '[AdManager] App Open Ad showed full screen content: ${config.name}');
        _reloadAdIfNeeded(config);
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint(
            '[AdManager] App Open Ad dismissed full screen content: ${config.name}');
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint(
            '[AdManager] Failed to show app open ad (${config.name}): $error');
        ad.dispose();
        _reloadAdIfNeeded(config);
      },
    );
  }

  void _showRewardedInterstitialAd(
      {required String name,
      required AdConfiguration config,
      required void Function(AdWithoutView, RewardItem) onUserEarnedReward}) {
    RewardedInterstitialAd ad =
        _removeFirstAdFromCache(name) as RewardedInterstitialAd;
    ad.fullScreenContentCallback =
        _createFullScreenContentCallbackRewardedInterstitialAd(config);
    ad.show(
      onUserEarnedReward: onUserEarnedReward,
    );
    debugPrint('[AdManager] show rewarded interstitial ads');
  }

  /// Cleans up resources
  void dispose() {
    _lifecycleListener?.dispose();
    _lifecycleListener = null;
    // Clean up other resources if needed
  }
}
