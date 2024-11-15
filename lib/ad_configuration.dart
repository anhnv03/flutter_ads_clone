import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Holds information about ad unit ID, name, type, preload count, ad request, and retry count.
class AdConfiguration {
  final String id;
  final String name;
  final AdType type;
  final int preload;
  final int retry; // Added retry parameter
  final AdRequest adRequest;

  /// Configuration class for ads.
  ///
  /// [id] Ad unit ID provided by the ad network.
  ///
  /// [name] Unique name for the ad configuration (no spaces allowed).
  ///
  /// [type] Type of the ad (Banner, Interstitial, Native).
  ///
  /// [preload] Number of ads to preload (default = 0).
  ///
  /// [retry] Number of times to retry loading the ad (default = 3, range 0-10).
  ///
  /// [adRequest] Ad request options (default AdRequest())
  AdConfiguration({
    required this.id,
    required this.name,
    required this.type,
    this.preload = 0,
    this.retry = 3, // Default retry value
    this.adRequest = const AdRequest(),
  })  : assert(!name.contains(' '), 'Name must not contain spaces'),
        assert(retry >= 0 && retry <= 10, 'Retry must be between 0 and 10');
}

/// Enum representing the types of ads supported.
enum AdType {
  banner,
  interstitial,
  native,
  rewarded,
  openApp,
  rewardedInterstitial,
}
