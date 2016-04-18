platform :ios, '8.0'
use_frameworks!

plugin 'cocoapods-keys', {
  project: "Pakete",
  target: "Pakete",
  keys: [
    "PaketeAPIKey",
    "AdMobBannerAdUnitIDKey",
    "AdMobInterstitialAdUnitIDKey",
    "SmoochAppTokenKey",
    "MixpanelTokenKey"
  ]
}

target 'Pakete' do
 pod 'Alamofire'
 pod 'RealmSwift'
 pod 'SwiftyJSON'
 pod 'RxSwift'
 pod 'RxCocoa'
 pod 'NSObject+Rx'
 pod 'SVProgressHUD'
 pod 'BigBrother'
 pod 'Google-Mobile-Ads-SDK'
 pod 'NSDate+TimeAgo'
 pod 'Smooch'
 pod 'CryptoSwift'
 pod 'Mixpanel'
 pod 'Fabric'
 pod 'Crashlytics'
end

target 'PaketeTests', :exclusive => true do
 pod 'Mockingjay'
end
