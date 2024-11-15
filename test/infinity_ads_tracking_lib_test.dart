import 'package:flutter_test/flutter_test.dart';
import 'package:infinity_ads_tracking_lib/infinity_ads_tracking_lib.dart';
import 'package:infinity_ads_tracking_lib/infinity_ads_tracking_lib_platform_interface.dart';
import 'package:infinity_ads_tracking_lib/infinity_ads_tracking_lib_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockInfinityAdsTrackingLibPlatform
    with MockPlatformInterfaceMixin
    implements InfinityAdsTrackingLibPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final InfinityAdsTrackingLibPlatform initialPlatform = InfinityAdsTrackingLibPlatform.instance;

  test('$MethodChannelInfinityAdsTrackingLib is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelInfinityAdsTrackingLib>());
  });

  test('getPlatformVersion', () async {
    InfinityAdsTrackingLib infinityAdsTrackingLibPlugin = InfinityAdsTrackingLib();
    MockInfinityAdsTrackingLibPlatform fakePlatform = MockInfinityAdsTrackingLibPlatform();
    InfinityAdsTrackingLibPlatform.instance = fakePlatform;

    expect(await infinityAdsTrackingLibPlugin.getPlatformVersion(), '42');
  });
}
