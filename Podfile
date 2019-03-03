# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
ENV["COCOAPODS_DISABLE_STATS"] = "true"
target 'abtest' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for abtest
pod "GCDWebServer/WebUploader", "~> 3.0"
pod 'MarqueeLabel/Swift'
pod "ViewAnimator"
pod 'SnapKit', '~> 4.0.0'
pod 'BCColor'
pod 'NotificationBannerSwift'
pod 'SwiftyUI'
pod 'Eureka'
pod 'SPPermission'
pod 'Google-Mobile-Ads-SDK'
pod 'Firebase/Core'
pod 'SwiftyStoreKit'
pod 'SwiftKeychainWrapper'
pod 'PMAlertController'
pod 'ReachabilitySwift'
pod 'APlay'
pod 'KRProgressHUD'
end

post_install do |installer|
 installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            swiftPods = ['APlay']
            if swiftPods.include?(target.name)
                config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] =  '-Onone'
            end
        end
    end
end
