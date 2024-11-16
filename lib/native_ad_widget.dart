import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_configuration.dart';
import 'ads_manager.dart';

class NativeAdWidget extends StatefulWidget {
  final String adName;

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
    _initializeNativeAd();
  }

  void _initializeNativeAd() {
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

    _nativeAd = AdManager.instance.getAdFromCache(widget.adName) as NativeAd?;

    if (_nativeAd == null) {
      AdManager.instance.loadAd(config).then((_) {
        if (mounted) {
          _notifyChange();
        }
      });
    } else {
      _notifyChange();
    }
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _nativeAd = AdManager.instance.getAdFromCache(widget.adName) as NativeAd?;
    if (_isAdLoaded && _nativeAd != null) {
      return Container(
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: Platform.isIOS ? 180 : 320, // Adjusted for iOS layout
          maxHeight: Platform.isIOS ? 200 : 400, // Adjusted for iOS layout
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AdWidget(ad: _nativeAd!),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  void _notifyChange() {
    if (mounted) {
      setState(() {
        _isAdLoaded = true;
      });
    }
  }
}
