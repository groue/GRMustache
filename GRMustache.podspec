Pod::Spec.new do |s|
  s.name     = 'GRMustache'
  s.version  = '8.0.0'
  s.license  = { :type => 'MIT', :file => 'LICENSE' }
  s.summary  = 'Flexible and production-ready Mustache templates for MacOS Cocoa and iOS.'
  s.homepage = 'https://github.com/groue/GRMustache'
  s.author   = { 'Gwendal Roué' => 'gr@pierlis.com' }
  s.source   = { :git => 'https://github.com/groue/GRMustache.git', :tag => 'v7.3.2' }
  s.source_files = 'GRMustache/**/*.{h,m}'
  s.private_header_files = 'GRMustache/**/*_private.h'
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.requires_arc = false
  s.framework = 'Foundation'
end
