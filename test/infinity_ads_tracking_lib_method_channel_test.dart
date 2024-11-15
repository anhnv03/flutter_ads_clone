import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinity_ads_tracking_lib/infinity_ads_tracking_lib_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelInfinityAdsTrackingLib platform = MethodChannelInfinityAdsTrackingLib();
  const MethodChannel channel = MethodChannel('infinity_ads_tracking_lib');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
