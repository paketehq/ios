platform :ios, '8.0'
use_frameworks!

plugin 'cocoapods-keys', {
  project: "Pakete",
  target: "Pakete",
  keys: [
    "AdMobAdUnitIDKey"
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
 pod 'VTAcknowledgementsViewController'
 pod 'Google-Mobile-Ads-SDK'
 pod 'NSDate+TimeAgo'
 pod 'Smooch'
 pod 'CryptoSwift'
end

target 'PaketeTests' do

end

# Copy pods acknowledgements
post_install do | installer |
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-Pakete/Pods-Pakete-Acknowledgements.plist', 'Pakete/Pods-acknowledgements.plist', :remove_destination => true)
end
