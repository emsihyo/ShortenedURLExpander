# ShortenedURLExpander

[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://raw.githubusercontent.com/retriable/ShortenedURLExpander/master/LICENSE)
[![Build Status](http://img.shields.io/travis/retriable/RetriableAFNetworking/master.svg?style=flat)](https://travis-ci.org/retriable/ShortenedURLExpander)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/retriable/ShortenedURLExpander)
[![Pod Version](http://img.shields.io/cocoapods/v/ShortenedURLExpander.svg?style=flat)](http://cocoapods.org/pods/ShortenedURLExpander)
[![Pod Platform](http://img.shields.io/cocoapods/p/ShortenedURLExpander.svg?style=flat)](http://cocoapods.org/pods/ShortenedURLExpander)

Shortened URL Expander

#### Cocoapods

Add the following to your project's Podfile:
```ruby
pod 'ShortenedURLExpander'
```

#### Carthage

Add the following to your project's Cartfile:
```ruby
github "retriable/ShortenedURLExpander"
```

#### Example

```objc
    self.expander=[[ShortenedURLExpander alloc] initWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] isURLShortened:^bool(NSURL *url) {
        return [url.host isEqualToString:@"t.cn"];
    }];
    self.operation=[self.expander expand:[NSURL URLWithString:@"http://t.cn/RnWLQVx"] maximumRetries:2 completion:^(NSURL *originalUrl,NSURL *expandedUrl, NSError *error) {
        NSLog(@"%@",expandedUrl);
    }];
```
