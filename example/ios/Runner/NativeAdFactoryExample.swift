// NativeAdFactoryExample.swift

import Foundation
import google_mobile_ads

class NativeAdFactoryExample: FLTNativeAdFactory {
    func createNativeAd(_ nativeAd: GADNativeAd,
                       customOptions: [AnyHashable : Any]? = nil) -> GADNativeAdView? {
        // Create GADNativeAdView programmatically instead of using NIB
        let nativeAdView = GADNativeAdView()
        nativeAdView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create and setup the headline view
        let headlineLabel = UILabel()
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        headlineLabel.text = nativeAd.headline
        headlineLabel.font = .systemFont(ofSize: 16, weight: .bold)
        headlineLabel.numberOfLines = 1
        nativeAdView.headlineView = headlineLabel
        nativeAdView.addSubview(headlineLabel)
        
        // Create and setup the body view
        let bodyLabel = UILabel()
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.text = nativeAd.body
        bodyLabel.font = .systemFont(ofSize: 14)
        bodyLabel.numberOfLines = 2
        nativeAdView.bodyView = bodyLabel
        nativeAdView.addSubview(bodyLabel)
        
        // Create and setup the call to action button
        let callToActionButton = UIButton()
        callToActionButton.translatesAutoresizingMaskIntoConstraints = false
        callToActionButton.setTitle(nativeAd.callToAction, for: .normal)
        callToActionButton.setTitleColor(.white, for: .normal)
        callToActionButton.backgroundColor = .systemBlue
        callToActionButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        callToActionButton.layer.cornerRadius = 8
        nativeAdView.callToActionView = callToActionButton
        nativeAdView.addSubview(callToActionButton)
        
        // Create and setup the icon view
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = nativeAd.icon?.image
        iconImageView.layer.cornerRadius = 8
        iconImageView.clipsToBounds = true
        nativeAdView.iconView = iconImageView
        nativeAdView.addSubview(iconImageView)
        
        // Add advertiser view
        let advertiserLabel = UILabel()
        advertiserLabel.translatesAutoresizingMaskIntoConstraints = false
        advertiserLabel.text = nativeAd.advertiser
        advertiserLabel.font = .systemFont(ofSize: 14)
        advertiserLabel.numberOfLines = 1
        nativeAdView.advertiserView = advertiserLabel
        nativeAdView.addSubview(advertiserLabel)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Icon image constraints
            iconImageView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: 16),
            iconImageView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: 16),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            // Headline constraints
            headlineLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            headlineLabel.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: 16),
            headlineLabel.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -16),
            
            // Advertiser constraints
            advertiserLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            advertiserLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 4),
            advertiserLabel.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -16),
            
            // Body constraints
            bodyLabel.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: 16),
            bodyLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 8),
            bodyLabel.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -16),
            
            // Call to action button constraints
            callToActionButton.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: 16),
            callToActionButton.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -16),
            callToActionButton.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 8),
            callToActionButton.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor, constant: -16),
            callToActionButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Set the native ad reference
        nativeAdView.nativeAd = nativeAd
        
        return nativeAdView
    }
}
