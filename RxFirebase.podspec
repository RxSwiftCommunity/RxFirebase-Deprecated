#
# Be sure to run `pod lib lint RxFirebase.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "RxFirebase"
  s.version          = "0.1.0"
  s.summary          = "RxSwift Helpers for the New Firebase Libraries"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This is a library to help you use RxSwift 2.5 or higher with Firebase 3.0 or higher.
                       DESC

  s.homepage         = "https://github.com/RxSwiftCommunity/RxFirebase"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Maximilian Alexander" => "max@zinkpulse.com" }
  s.source           = { :git => "https://github.com/RxSwiftCommunity/RxFirebase.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/maxofeden'

  s.ios.deployment_target = '8.0'

  s.source_files = 'RxFirebase/Classes/**/*'

    s.frameworks = 'UIKit'
    s.dependency 'RxSwift', '~> 2.5'
    s.dependency 'Firebase/Database'

    s.xcconfig = {
        "FRAMEWORK_SEARCH_PATHS": "'$(PODS_ROOT)/FirebaseDatabase'"
    }
    s.vendored_frameworks = ["${PODS_ROOT}/FirebaseDatabase/Frameworks/FirebaseDatabase.framework"]
end
