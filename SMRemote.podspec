#
# Be sure to run `pod lib lint SMRemote.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SMRemote'
  s.version          = '1.0.1'
  s.summary          = 'Sản phẩm thuộc về ONEWEEK STUDIO'
  s.swift_versions   = '4.2'
# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  TODO: Add long description of the pod here. Add long description of the pod here
  Add long description of the pod here
  Add long description of the pod here
  Add long description of the pod here
                       DESC

  s.homepage         = 'https://github.com/oneweekstudio/SMRemote'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'oneweekstudio' => '48544624+oneweekstudio@users.noreply.github.com' }
  s.source           = { :git => 'https://github.com/oneweekstudio/SMRemote.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'SMRemote/Classes/**/*'
  
  # s.resource_bundles = {
  #   'SMRemote' => ['SMRemote/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
   s.frameworks = 'UIKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.static_framework = true

  s.ios.dependency 'Firebase/Core'
  s.ios.dependency 'Firebase/RemoteConfig'
  s.ios.dependency 'Firebase/Analytics'
  s.ios.dependency 'MagicMapper'
  s.ios.dependency 'Google-Mobile-Ads-SDK'
  s.ios.dependency 'FBAudienceNetwork'
#  s.ios.dependency 'PKHUD'
  s.ios.dependency 'iProgressHUD'
#  s.frameworks = [
#    'Firebase'
#  ]
end
