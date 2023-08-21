# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'stepin' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  post_install do |installer|
      installer.generated_projects.each do |project|
            project.targets.each do |target|
                target.build_configurations.each do |config|
                    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
                 end
            end
     end
  end

  # Pods for stepin
  pod 'SnapKit'
  pod 'Then'
  pod 'Alamofire'
  pod 'lottie-ios'
  pod 'Kingfisher'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxGesture'
  pod 'RxDataSources'
  pod 'CropViewController'
  pod 'FSCalendar'
  pod 'MarqueeLabel'
  pod 'RealmSwift'
  pod 'Realm'
  pod 'GoogleSignIn'
  pod 'FirebaseCore'
  pod 'FirebaseAuth'
  pod 'Firebase'
  pod 'Firebase/Analytics'
  pod 'Firebase/DynamicLinks'
  pod 'ffmpeg-kit-ios-full-gpl', '4.5.1'
  pod 'onnxruntime-objc'
  pod 'OpenCV'
  pod "SkeletonView"
  pod 'SwiftPublicIP', '~> 0.0.2'
  pod 'Sentry', :git => 'https://github.com/getsentry/sentry-cocoa.git', :tag => '8.8.0'

end
