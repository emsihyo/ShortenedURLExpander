Pod::Spec.new do |spec|
    spec.name     = 'ShortenedURLExpander'
    spec.version  = '1.0.3'
    spec.license  = 'MIT'
    spec.summary  = 'Shortened URL Expander'
    spec.homepage = 'https://github.com/retriable/ShortenedURLExpander'
    spec.author   = { 'retriable' => 'retriable@retriable.com' }
    spec.source   = { :git => 'https://github.com/retriable/ShortenedURLExpander.git',:tag => "#{spec.version}" }
    spec.description = 'Shortened URL Expander.'
    spec.requires_arc = true
    spec.ios.deployment_target = '8.0'
    spec.watchos.deployment_target = '2.0'
    spec.tvos.deployment_target = '9.0'
    spec.osx.deployment_target = '10.9'
    spec.source_files = 'ShortenedURLExpander/*.{h,m}'
    spec.dependency 'Retriable'
end
