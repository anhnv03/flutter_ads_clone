import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:infinity_ads_tracking_lib/ad_configuration.dart';

class RewardedAdLoader {
  final AdConfiguration config;
  final Map<String, List<Ad>> adCache;
  int retryCount = 0;

  RewardedAdLoader(this.config, this.adCache);

  Future<void> load() {
    final completer = Completer<void>();
    _loadRewardedAdLoad(completer);
    return completer.future;
  }

  void _loadRewardedAdLoad(Completer<void> completer) {
    RewardedAd.load(
      adUnitId: config.id,
      request: config.adRequest,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          adCache[config.name]?.add(ad);
          debugPrint('[RewardedAdLoader] Rewarded ad loaded: ${config.name}');
          completer.complete();
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint(
              '[RewardedAdLoader] Rewarded ad failed to load (${config.name}): $error');
          if (retryCount < config.retry) {
            retryCount++;
            debugPrint(
                '[RewardedAdLoader] Retrying to load Rewarded ad (${config.name}), attempt $retryCount');
            _loadRewardedAdLoad(completer);
          } else {
            completer.completeError(error);
          }
        },
      ),
    );
  }
}
