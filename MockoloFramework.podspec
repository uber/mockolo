Pod::Spec.new do |s|
  s.name             = 'MockoloFramework'
  s.version          = '1.1.1'
  s.summary          = 'Efficient Mock Generator for Swift'
  s.description      = 'MockoloFramework provides a fast and easy way to autogenerate mock objects that can be tested in your code. It is optimized for efficiency and speed and supports both SourceKit and SwiftSyntax for source file parsing. Try MockoloFramework and enhance your project test coverage in an effective, performant way.'

  s.homepage         = 'https://github.com/uber/mockolo'
  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE.txt' }
  s.author           = { 'Ellie Shin' => 'ellie@uber.com' }
  s.social_media_url   = "https://twitter.com/ellsk1"
  s.source           = { :git => 'https://github.com/uber/mockolo.git', :tag => s.version.to_s }
  s.osx.deployment_target = '10.14'
  s.swift_version    = '5.1'
  s.dependency 'SourceKittenFramework', '~>0.26.0'
  s.source         = { :http => "#{s.homepage}/archive/#{s.version}.zip" }
end
