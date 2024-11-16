import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infinity_ads_tracking_lib/ad_configuration.dart';
import 'package:infinity_ads_tracking_lib/ads_manager.dart';
import 'package:infinity_ads_tracking_lib/banner_ad_widget.dart';
import 'package:infinity_ads_tracking_lib/infinity_ads_tracking_lib.dart';
import 'package:infinity_ads_tracking_lib/native_ad_widget.dart';
import 'package:infinity_ads_tracking_lib_example/ad_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AdManager.instance.initialize(
    configurations: [
      AdConfiguration(
        id: AdHelper.bannerAdUnitId,
        name: 'banner_ad_integration',
        type: AdType.banner,
        preload: 1,
      ),
      AdConfiguration(
        id: AdHelper.interstitialAdUnitId,
        name: 'interstitial_ad_integration',
        type: AdType.interstitial,
        preload: 1,
      ),
      AdConfiguration(
        id: AdHelper.nativeAdUnitId,
        name: 'native_ad_integration',
        type: AdType.native,
        preload: 1,
      ),
      AdConfiguration(
        id: AdHelper.rewardedAdUnitId,
        name: 'rewarded_ad_integration',
        type: AdType.rewarded,
        preload: 1,
      ),
      AdConfiguration(
        id: AdHelper.appOpenAddUnitId,
        name: 'app_open_ad_integration',
        type: AdType.openApp,
        preload: 1,
      ),
      AdConfiguration(
        id: AdHelper.rewardedInterstitialAdUnitId,
        name: "rewarded_interstitial_ad_integration",
        type: AdType.rewardedInterstitial,
        preload: 1,
      ),
    ],
    enableAppOpenAdTracking: true,
    appOpenAdName: 'app_open_ad_integration',
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _infinityAdsTrackingLibPlugin = InfinityAdsTrackingLib();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _infinityAdsTrackingLibPlugin.getPlatformVersion() ??
              'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    AdManager.instance.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                TextButton(
                  onPressed: () {
                    AdManager.instance
                        .showInterstitialAd("interstitial_ad_integration");
                  },
                  child: Text("show inter"),
                ),
                TextButton(
                  onPressed: () {
                    AdManager.instance.showRewardAd(
                      "rewarded_ad_integration",
                      onUserEarnedReward: (ad, reward) {
                        debugPrint(
                            '[AdManager] User earned reward: ${reward.amount} ${reward.type}');
                      },
                    );
                  },
                  child: Text("show rewarded"),
                ),
                TextButton(
                  onPressed: () {
                    AdManager.instance.showRewardedInterstitialAd(
                      "rewarded_interstitial_ad_integration",
                      onUserEarnedReward: (ad, reward) {
                        debugPrint(
                            '[AdManager] User earned rewarded interstitial: ${reward.amount} ${reward.type}');
                      },
                    );
                  },
                  child: Text("show rewarded interstitial"),
                ),
              ],
            ),
            const Align(
              alignment: Alignment.center,
              child: NativeAdWidget(adName: "native_ad_integration"),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: BannerAdWidget(adName: "banner_ad_integration"),
            ),
          ],
        ),
      ),
    );
  }
}
