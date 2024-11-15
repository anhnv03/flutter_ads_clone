import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:infinity_ads_tracking_lib/ad_configuration.dart';

class AdOpenLoader {
  final AdConfiguration config;
  final Map<String, List<Ad>> adCache;
  int retryCount = 0;

  AdOpenLoader(this.config, this.adCache);

  Future<void> load() {
    final completer = Completer<void>();
    _loadAdOpenAppLoad(completer);
    return completer.future;
  }

  Future<void> _loadAdOpenAppLoad(Completer<void> completer) async {
    AppOpenAd.load(
      adUnitId: config.id,
      request: config.adRequest,
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          adCache[config.name]?.add(ad);
          debugPrint('[AppOpenAdLoader] App open ad loaded: ${config.name}');
          completer.complete();
        },
        onAdFailedToLoad: (error) {
          debugPrint(
              '[AppOpenAdLoader]  App open ad failed to load (${config.name}): $error');
          if (retryCount < config.retry) {
            retryCount++;
            debugPrint(
                '[AppOpenAdLoader] Retrying to load App open ad (${config.name}), attempt $retryCount');
            _loadAdOpenAppLoad(completer);
          } else {
            completer.completeError(error);
          }
        },
      ),
    );
  }
}
