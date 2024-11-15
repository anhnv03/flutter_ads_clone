import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_configuration.dart';

class BannerAdLoader {
  final AdConfiguration config;
  final Map<String, List<Ad>> adCache;
  int retryCount = 0;

  BannerAdLoader(this.config, this.adCache);

  Future<void> load() {
    final completer = Completer<void>();
    _loadBannerAd(completer);
    return completer.future;
  }

  void _loadBannerAd(Completer<void> completer) {
    BannerAd bannerAd = BannerAd(
      adUnitId: config.id,
      size: AdSize.banner,
      request: config.adRequest,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          adCache[config.name]?.add(ad);
          debugPrint('[BannerAdLoader] Banner ad loaded: ${config.name}');
          completer.complete();
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          debugPrint('[BannerAdLoader] Banner ad failed to load (${config.name}): $error');
          if (retryCount < config.retry) {
            retryCount++;
            debugPrint(
                '[BannerAdLoader] Retrying to load Banner ad (${config.name}), attempt $retryCount');
            _loadBannerAd(completer);
          } else {
            completer.completeError(error);
          }
        },
      ),
    );
    bannerAd.load();
  }
}
