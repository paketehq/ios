platform :ios, '8.0'
use_frameworks!

plugin 'cocoapods-keys', {
  project: "Pakete",
  target: "Pakete",
  keys: [
    "PaketeAPIKey",
    "AdMobBannerAdUnitIDKey",
    "AdMobInterstitialAdUnitIDKey",
    "AdMobNativeAdUnitIDKey",
    "SmoochAppTokenKey",
    "MixpanelTokenKey",
    "CountlyAppKey"
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
 pod 'Smooch'
 pod 'CryptoSwift'
 pod 'Mixpanel'
 pod 'Fabric'
 pod 'Crashlytics'
 pod 'TwitterKit'
 pod 'SwiftyStoreKit'
 pod 'Siren'
 pod 'Appirater'
 pod 'FBSDKCoreKit'
 pod 'FBSDKShareKit'
 pod 'Countly'

 target 'PaketeTests' do
  inherit! :search_paths
  pod 'Mockingjay'
 end
end
