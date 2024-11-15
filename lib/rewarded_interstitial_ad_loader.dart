import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:infinity_ads_tracking_lib/ad_configuration.dart';

class RewardedInterstitialAdLoader {
  final AdConfiguration config;
  final Map<String, List<Ad>> adCache;
  int retryCount = 0;

  RewardedInterstitialAdLoader(this.config, this.adCache);

  Future<void> load() {
    final completer = Completer<void>();
    _loadRewardedInterstitialAdLoad(completer);
    return completer.future;
  }

  void _loadRewardedInterstitialAdLoad(Completer<void> completer) {
    RewardedInterstitialAd.load(
      adUnitId: config.id,
      request: config.adRequest,
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          adCache[config.name]?.add(ad);
          debugPrint('[RewardedAdLoader] Rewarded ad loaded: ${config.name}');
          completer.complete();
        },
        onAdFailedToLoad: (error) {
          debugPrint(
              '[RewardedAdLoader] Rewarded ad failed to load (${config.name}): $error');
          if (retryCount < config.retry) {
            retryCount++;
            debugPrint(
                '[RewardedAdLoader] Retrying to load Rewarded ad (${config.name}), attempt $retryCount');
            _loadRewardedInterstitialAdLoad(completer);
          } else {
            completer.completeError(error);
          }
        },
      ),
    );
  }
}
