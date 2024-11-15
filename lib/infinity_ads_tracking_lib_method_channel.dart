import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'infinity_ads_tracking_lib_platform_interface.dart';

/// An implementation of [InfinityAdsTrackingLibPlatform] that uses method channels.
class MethodChannelInfinityAdsTrackingLib extends InfinityAdsTrackingLibPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('infinity_ads_tracking_lib');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
