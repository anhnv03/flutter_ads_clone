import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_configuration.dart';

class NativeAdLoader {
  final AdConfiguration config;
  final Map<String, List<Ad>> adCache;
  int retryCount = 0;

  NativeAdLoader(this.config, this.adCache);

  Future<void> load() {
    final completer = Completer<void>();
    _loadNativeAd(completer);
    return completer.future;
  }

  void _loadNativeAd(Completer<void> completer) {
    NativeAd nativeAd = NativeAd(
      adUnitId: config.id,
      factoryId: 'adFactoryExample', // Replace with your actual factory ID
      request: config.adRequest,
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          adCache[config.name]?.add(ad);
          debugPrint('[NativeAdLoader] Native ad loaded: ${config.name}');
          completer.complete();
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          debugPrint('[NativeAdLoader] Native ad failed to load (${config.name}): $error');
          if (retryCount < config.retry) {
            retryCount++;
            debugPrint(
                '[NativeAdLoader] Retrying to load Native ad (${config.name}), attempt $retryCount');
            _loadNativeAd(completer);
          } else {
            completer.completeError(error);
          }
        },
      ),
    );
    nativeAd.load();
  }
}
