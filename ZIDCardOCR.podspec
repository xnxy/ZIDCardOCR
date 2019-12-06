#
#  Be sure to run `pod spec lint ZIDCardOCR.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "ZIDCardOCR"
  spec.version      = "1.0"
  spec.summary      = "中国二代身份证本地识别."
  spec.description  = <<-DESC
    ZIDCardOCR是基于libexidcard封装的本地身份证识别的第三方库，能准确地识别出身份证的正面和反面信息。
                   DESC

  spec.homepage     = "https://github.com/xnxy/ZIDCardOCR"
  spec.license      = { :type => "MIT" }
  spec.author             = { "伟 周" => "1661583063@qq.com" }
  spec.social_media_url   = "https://xnxy.github.io"
  spec.source       = { :http => "http://zocr.oss-cn-beijing.aliyuncs.com/ZIDCardOCR-1.0.zip" }
  spec.requires_arc = true
  spec.ios.deployment_target = '8.0'
  spec.vendored_frameworks ='ZIDCardOCR.framework'

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # spec.dependency "JSONKit", "~> 1.4"

end
