#
#  Be sure to run `pod spec lint OctreePalette.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  spec.name         = "OctreePalette"
  spec.version      = "0.0.1"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.homepage     = "http://github.com/RagOfJoes/OctreePalette"
  spec.author       = { "Victor Ragojos" => "vhsvragojos@gmail.com" }
  spec.summary      = "Extract colors from UIImage using the Octree color quantization algorithm."
  
  # Supported plateforms
  spec.ios.deployment_target = "9.0"
  # spec.osx.deployment_target = "10.7"
  # spec.watchos.deployment_target = "2.0"
  # spec.tvos.deployment_target = "9.0"
  spec.source_files  = "OctreePalette/Sources/*.swift"
  spec.source       = { :git => "https://github.com/RagOfJoes//OctreePalette.git", :tag => "#{spec.version}" }

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.
  spec.requires_arc = true
  spec.swift_versions = "5.0"
end
