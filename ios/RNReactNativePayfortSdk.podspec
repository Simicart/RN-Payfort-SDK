require 'json'
pjson = JSON.parse(File.read('package.json'))

Pod::Spec.new do |s|
  s.name         = "RNReactNativePayfortSdk"
  s.version      = pjson["version"]
  s.summary      = "RNReactNativePayfortSdk"
  s.summary         = pjson["description"]
  s.license         = pjson["license"]
  s.homepage     = "https://github.com/crabbynguyen/RN-Payfort-SDK/"
  s.author             = { "Glenn" => "glenn@simicart.com", "Chau" => "chau@simicart.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/author/RNReactNativePayfortSdk.git", :tag => "master" }
  s.source_files  = "RNReactNativePayfortSdk/**/*.{h,m}"
  s.requires_arc = true


  s.dependency "React"
  #s.dependency "others"

end

  