import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:infinity_ads_tracking_lib/ads_manager.dart';
import 'ad_configuration.dart';

/// Widget that manages the loading and displaying of a banner ad.
class BannerAdWidget extends StatefulWidget {
  final String adName;

  /// Creates a [BannerAdWidget] for the given [adName].
  const BannerAdWidget({super.key, required this.adName});

  @override
  _BannerAdWidgetState createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();

    // Get the AdConfiguration from AdManager
    AdConfiguration? config =
        AdManager.instance.getConfiguration(widget.adName);

    if (config == null) {
      debugPrint(
          '[BannerAdWidget] Ad configuration not found for name: ${widget.adName}');
      return;
    }

    if (config.type != AdType.banner) {
      debugPrint(
          '[BannerAdWidget] Ad configuration is not for a Banner Ad: ${widget.adName}');
      return;
    }

    // Try to get ad from cache
    _bannerAd = AdManager.instance.getAdFromCache(widget.adName) as BannerAd?;

    if (_bannerAd != null) {
      debugPrint(
          '[BannerAdWidget] found cached ad');
      setState(() {
        _isAdLoaded = true;
      });
    } else {
      // Load the ad
      debugPrint(
          '[BannerAdWidget] no cached ad, loading new and show banner ad');
      loadAndShowAd(config);
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdLoaded && _bannerAd != null) {
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    } else {
      return const SizedBox.shrink(); // Return an empty widget or placeholder
    }
  }

  Future<void> loadAndShowAd(AdConfiguration config) async {
    await AdManager.instance.loadAd(config);
    // load ad
    _bannerAd = AdManager.instance.getAdFromCache(widget.adName) as BannerAd?;
    if (_bannerAd != null) {
      setState(() {
        _isAdLoaded = true;
      });
    }
  }
}
