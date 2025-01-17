#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint native_image_picker_macos.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
    s.name             = 'native_image_picker_macos'
    s.version          = '0.0.1'
    s.summary          = 'A Flutter plugin for picking images using the native macOS system picker.'
    s.description      = <<-DESC
  A macOS platform implementation of image_picker using the native system picker instead of file_selector.
  Downloaded by pub (not CocoaPods).
                         DESC
    s.homepage         = 'https://github.com/CompileKernel/native-image-picker-macos'
    s.license          = { :type => 'MIT', :file => '../LICENSE' }
    s.author           = { 'CompileKernel' => 'https://github.com/CompileKernel/' }
    s.source           = { :http => 'https://github.com/CompileKernel/native-image-picker-macos' }
    s.source_files = 'native_image_picker_macos/Sources/native_image_picker_macos/**/*.swift'
    s.dependency 'FlutterMacOS'
  
    s.platform = :osx, '10.14'
    s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
    s.swift_version = '5.0'
  
    s.resource_bundles = {'native_image_picker_macos_privacy' => ['native_image_picker_macos/Sources/native_image_picker_macos/Resources/PrivacyInfo.xcprivacy']}
  end