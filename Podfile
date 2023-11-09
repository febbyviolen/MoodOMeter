# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

target 'MoodOMeter' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for MoodOMeter
	# Add the Firebase pod for Google Analytics
	#pod 'FirebaseAnalytics'

	# Add the pods for any other Firebase products you want to use in your app
	# For example, to use Firebase Authentication and Cloud Firestore
	#pod 'FirebaseAuth'
	#pod 'FirebaseFirestore'

	pod 'JTAppleCalendar', '~> 7.1'
	pod 'KTCenterFlowLayout'
	pod 'GoogleSignIn'
	pod 'NVActivityIndicatorView'
	#pod 'Google-Mobile-Ads-SDK'

end

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
               end
          end
   end
end