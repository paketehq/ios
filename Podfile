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
 pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git', :branch => 'swift2'
 pod 'RxSwift', :git => 'https://github.com/ReactiveX/RxSwift.git', :branch => 'rxswift-2.0'
 pod 'RxCocoa'
 pod 'NSObject+Rx'
 pod 'SVProgressHUD'
 pod 'BigBrother'
 pod 'Smooch'
 pod 'CryptoSwift', :git => 'https://github.com/krzyzanowskim/CryptoSwift', :branch => 'swift2'
 pod 'Mixpanel'
 pod 'Fabric'
 pod 'Crashlytics'
 pod 'TwitterKit'
 pod 'SwiftyStoreKit', :git => 'https://github.com/bizz84/SwiftyStoreKit.git', :branch => 'swift-2.2'
 pod 'Siren', :git => 'https://github.com/ArtSabintsev/Siren.git', :branch => 'swift2.3'
 pod 'Appirater'
 pod 'FBSDKCoreKit'
 pod 'FBSDKShareKit'
 pod 'Countly'

 target 'PaketeTests' do
  inherit! :search_paths
  pod 'Mockingjay'
 end
end

post_install do |installer|
   installer.pods_project.targets.each do |target|
     target.build_configurations.each do |config|
        if config.name == 'Debug' and target.name == 'RxSwift'
           config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D', 'TRACE_RESOURCES']
        end
        config.build_settings['SWIFT_VERSION'] = '2.3'
     end
   end
end
