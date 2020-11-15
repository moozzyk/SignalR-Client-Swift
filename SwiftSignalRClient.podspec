Pod::Spec.new do |s|
  s.name                   = "SwiftSignalRClient"
  s.version                = "0.8.0"
  s.summary                = "Swift SignalR Client for the ASP.Net Core version of SignalR."
  s.homepage               = "https://github.com/moozzyk/SignalR-Client-Swift"
  s.license                = { :type => "Attribution License", :file => "LICENSE" }
  s.source                 = { :git => "https://github.com/moozzyk/SignalR-Client-Swift.git", :tag => s.version.to_s }
  s.authors                = { "Pawel Kadluczka" => "moozzyk@gmail.com" }
  s.social_media_url       = "https://twitter.com/moozzyk"
  s.swift_version          = "5.0"
  s.ios.deployment_target  = "9.0"
  s.osx.deployment_target  = "10.13"
  s.tvos.deployment_target = "9.0"
  s.source_files           = "Sources/SignalRClient/*.swift"
  s.requires_arc           = true
  s.libraries              = 'z'
end
