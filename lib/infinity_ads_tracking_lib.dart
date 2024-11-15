
import 'infinity_ads_tracking_lib_platform_interface.dart';

class InfinityAdsTrackingLib {
  Future<String?> getPlatformVersion() {
    return InfinityAdsTrackingLibPlatform.instance.getPlatformVersion();
  }
}
