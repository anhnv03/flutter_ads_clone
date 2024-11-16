import UIKit
import Flutter
import google_mobile_ads

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        // Initialize Google Mobile Ads SDK
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        // Register native ad factory
        let nativeAdFactory = NativeAdFactoryExample()
        FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
            self,
            factoryId: "listTile",
            nativeAdFactory: nativeAdFactory)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func applicationWillTerminate(_ application: UIApplication) {
        FLTGoogleMobileAdsPlugin.unregisterNativeAdFactory(self, factoryId: "listTile")
    }
}
