import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'infinity_ads_tracking_lib_method_channel.dart';

abstract class InfinityAdsTrackingLibPlatform extends PlatformInterface {
  /// Constructs a InfinityAdsTrackingLibPlatform.
  InfinityAdsTrackingLibPlatform() : super(token: _token);

  static final Object _token = Object();

  static InfinityAdsTrackingLibPlatform _instance = MethodChannelInfinityAdsTrackingLib();

  /// The default instance of [InfinityAdsTrackingLibPlatform] to use.
  ///
  /// Defaults to [MethodChannelInfinityAdsTrackingLib].
  static InfinityAdsTrackingLibPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [InfinityAdsTrackingLibPlatform] when
  /// they register themselves.
  static set instance(InfinityAdsTrackingLibPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
