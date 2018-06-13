//
//  ShortenedURLExpander.h
//  ShortenedURLExpander
//
//  Created by emsihyo on 2018/5/31.
//  Copyright © 2018 ouyanghua. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <Retriable/Retriable.h>

//! Project version number for ShortenedURLExpander.
FOUNDATION_EXPORT double ShortenedURLExpanderVersionNumber;

//! Project version string for ShortenedURLExpander.
FOUNDATION_EXPORT const unsigned char ShortenedURLExpanderVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <ShortenedURLExpander/PublicHeader.h>

@interface ShortenedURLExpander: NSObject

@property (readonly)NSOperationQueue * _Nonnull queue;

- (instancetype _Nullable)initWithConfiguration:(NSURLSessionConfiguration* _Nullable)configuration isURLShortened:(bool(^ _Nullable)(NSURL * _Nullable url))isURLShortened NS_DESIGNATED_INITIALIZER;

- (RetriableOperation* _Nullable)expand:(NSURL* _Nullable)url maximumRetries:(NSInteger)maximumRetries completion:(void(^ _Nullable)(NSURL * _Nullable originalUrl,NSURL *expandedUrl,NSError * _Nullable error))completion;

@end
