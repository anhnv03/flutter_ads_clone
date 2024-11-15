import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ads_manager.dart';
import 'ad_configuration.dart';

/// Widget that manages the loading and displaying of a native ad.
class NativeAdWidget extends StatefulWidget {
  final String adName;

  /// Creates a [NativeAdWidget] for the given [adName].
  const NativeAdWidget({super.key, required this.adName});

  @override
  _NativeAdWidgetState createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();

    // Get the AdConfiguration from AdManager
    AdConfiguration? config =
        AdManager.instance.getConfiguration(widget.adName);

    if (config == null) {
      debugPrint(
          '[NativeAdWidget] Ad configuration not found for name: ${widget.adName}');
      return;
    }

    if (config.type != AdType.native) {
      debugPrint(
          '[NativeAdWidget] Ad configuration is not for a Native Ad: ${widget.adName}');
      return;
    }

    // Try to get ad from cache
    _nativeAd = AdManager.instance.getAdFromCache(widget.adName) as NativeAd?;

    if (_nativeAd == null) {
      // Load the ad
      AdManager.instance.loadAd(config).then((_) => _notifyChange());
    }
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Try to get ad from cache
    _nativeAd = AdManager.instance.getAdFromCache(widget.adName) as NativeAd?;
    if (_isAdLoaded && _nativeAd != null) {
      return ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 320, // minimum recommended width
            minHeight: 320, // minimum recommended height
            maxWidth: 400,
            maxHeight: 400,
          ),
          child: AdWidget(ad: _nativeAd!)
      );
    } else {
      return const SizedBox.shrink(); // Return an empty widget or placeholder
    }
  }

  void _notifyChange() {
    setState(() {
      _isAdLoaded = true;
    });
  }
}
