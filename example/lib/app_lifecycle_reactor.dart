import 'package:flutter/material.dart';
import 'package:infinity_ads_tracking_lib/ads_manager.dart';

class AppLifecycleReactor extends WidgetsBindingObserver {
  final AdManager adManager;
  bool _showAdWhenAppOpened = false;
  DateTime? _pausedTime;

  // Minimum duration app should be in background before showing ad
  static const Duration _minimumBackgroundDuration = Duration(seconds: 5);

  AppLifecycleReactor({required this.adManager}) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _pausedTime = DateTime.now();
        _showAdWhenAppOpened = true;
        debugPrint('[AppLifecycleReactor] App paused');
        break;

      case AppLifecycleState.resumed:
        if (_showAdWhenAppOpened && _pausedTime != null) {
          final pauseDuration = DateTime.now().difference(_pausedTime!);
          if (pauseDuration >= _minimumBackgroundDuration) {
            debugPrint(
                '[AppLifecycleReactor] Showing ad after background duration: ${pauseDuration.inSeconds}s');
            adManager.showAppOpenAd("app_open_ad_integration");
          } else {
            debugPrint(
                '[AppLifecycleReactor] Skip showing ad - background duration too short: ${pauseDuration.inSeconds}s');
          }
        }
        _showAdWhenAppOpened = false;
        _pausedTime = null;
        break;

      default:
        break;
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
