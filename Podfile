platform :ios, '9.0'
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
 pod 'RxSwift', '~> 3.0.0-beta.1'
 pod 'RxCocoa', '~> 3.0.0-beta.1'
 pod 'NSObject+Rx'
 pod 'SVProgressHUD'
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
  pod 'Mockingjay', :git => 'https://github.com/kylef/Mockingjay.git', :branch => 'kylef/swift-3.0'
 end
end

post_install do |installer|
   installer.pods_project.targets.each do |target|
     target.build_configurations.each do |config|
        if config.name == 'Debug' and target.name == 'RxSwift'
           config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D', 'TRACE_RESOURCES']
        end
        config.build_settings['SWIFT_VERSION'] = '3.0'
     end
   end
end
