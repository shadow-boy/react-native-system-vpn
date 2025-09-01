require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))
folly_version = '2021.07.22.00'

Pod::Spec.new do |s|
  s.name         = "SystemVpn"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => min_ios_version_supported }
  s.source       = { :git => "https://github.com/wangly/react-native-system-vpn.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,mm,cpp,swift}"
  s.private_header_files = "ios/**/*.h"

  # Add NetworkExtension framework for VPN functionality
  s.frameworks = 'NetworkExtension', 'Security'
  
  # Required for Keychain access in Swift
  s.dependency 'KeychainAccess', '~> 4.2'

  # Fabric and Turbo Module setup for new architecture
  install_modules_dependencies(s)
  
  # Enable codegen for the new architecture
  s.pod_target_xcconfig = {
    'HEADER_SEARCH_PATHS' => '"$(PODS_ROOT)/boost" "$(PODS_ROOT)/boost-for-react-native" "$(PODS_ROOT)/DoubleConversion" "$(PODS_ROOT)/RCT-Folly"',
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17'
  }
end
