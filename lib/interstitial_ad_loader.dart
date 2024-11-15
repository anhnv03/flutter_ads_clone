import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_configuration.dart';

class InterstitialAdLoader {
  final AdConfiguration config;
  final Map<String, List<Ad>> adCache;
  int retryCount = 0;

  InterstitialAdLoader(this.config, this.adCache);

  Future<void> load() {
    final completer = Completer<void>();
    _loadInterstitialAd(completer);
    return completer.future;
  }

  void _loadInterstitialAd(Completer<void> completer) {
    InterstitialAd.load(
      adUnitId: config.id,
      request: config.adRequest,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          adCache[config.name]?.add(ad);
          debugPrint('[InterstitialAdLoader] Interstitial ad loaded: ${config.name}');
          completer.complete();
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('[InterstitialAdLoader] Interstitial ad failed to load (${config.name}): $error');
          if (retryCount < config.retry) {
            retryCount++;
            debugPrint(
                '[InterstitialAdLoader] Retrying to load Interstitial ad (${config.name}), attempt $retryCount');
            _loadInterstitialAd(completer);
          } else {
            completer.completeError(error);
          }
        },
      ),
    );
  }
}
