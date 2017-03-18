#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
# we can safely specify both a semantic and numeric version here, each respective routine will ignore the other
  s.version          = "0.0.0"
  s.version          = "0"

  s.platform     = :ios, '6.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*.[hm]'
  s.resources = "Pod/Assets/*.{xib}"

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
end