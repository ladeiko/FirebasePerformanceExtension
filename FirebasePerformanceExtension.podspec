Pod::Spec.new do |s|
    s.name = 'FirebasePerformanceExtension'
    s.version = '1.0.0'
    s.summary = 'Utils for FirebasePerformance iOS SDK, helps to improve app performance'
    s.homepage = 'https://github.com/ladeiko/FirebasePerformanceExtension'
    s.license = { :type => 'CUSTOM', :file => 'LICENSE' }
    s.author = { 'Siarhei Ladzeika' => 'sergey.ladeiko@gmail.com' }
    s.platform = :ios, '11.0'
    s.source = { :git => 'https://github.com/ladeiko/FirebasePerformanceExtension.git', :tag => "#{s.version}" }
    s.requires_arc = true
    s.swift_versions = '4.0', '4.2', '5.0', '5.1', '5.2', '5.5', '5.7'

    s.source_files = 'Sources/**/*.{swift}'
    s.frameworks = 'UIKIt'
    s.dependency 'FirebasePerformance'
end
