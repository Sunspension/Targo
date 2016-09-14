platform :ios, ‘8.4’
use_frameworks!

target 'Targo' do

#Network
pod 'Alamofire', '~> 3.4'

#PhoneNumbers
pod 'PhoneNumberKit', '~> 0.8'
pod 'SHSPhoneComponent'

#Colors
pod 'DynamicColor', '~> 2.4.0'

#JSON
pod 'ObjectMapper', '~> 1.3'
pod 'AlamofireObjectMapper', '~> 3.0'

#Images
pod 'AlamofireImage', '~> 2.0'

#DB
#pod 'RealmSwift'

pod 'Realm', git: 'https://github.com/realm/realm-cocoa.git', branch: 'master', submodules: true
pod 'RealmSwift', git: 'https://github.com/realm/realm-cocoa.git', branch: 'master', submodules: true

#UI
pod 'SwiftOverlays', '~> 2.0.0'
pod 'SCLAlertView'
pod 'CircleProgressView', :git => 'https://github.com/CardinalNow/iOS-CircleProgressView.git'
pod 'ActionSheetPicker-3.0'

#Date
pod 'Timepiece'

#Text
pod 'SwiftString'

#Keychain
pod 'KeychainSwift', '~> 3.0'

#Events
pod 'BrightFutures'
pod 'Bond', '~> 4.0'

#Loggin
pod 'Timberjack', '~> 0.0'

#Menu
#pod 'SideMenu'

#Maps
source 'https://github.com/CocoaPods/Specs.git'
pod 'GoogleMaps'

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '2.3'
        end
    end
end

end
