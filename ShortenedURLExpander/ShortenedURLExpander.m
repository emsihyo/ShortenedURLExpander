//
//  ShortenedURLExpander.m
//  ShortenedURLExpander
//
//  Created by emsihyo on 2018/5/31.
//  Copyright © 2018 ouyanghua. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <Foundation/Foundation.h>

#import "ShortenedURLExpander.h"

@interface ShortenedURLExpander ()

@property (nonatomic,assign) bool(^isURLShortened)(NSURL *url);

@property (nonatomic,strong) AFURLSessionManager *sessionManager;
@property (nonatomic,strong) NSMapTable          *table;
@property (nonatomic,strong) NSOperationQueue    *queue;
@property (nonatomic,strong) NSLock              *lock;

@end

@implementation ShortenedURLExpander

- (instancetype)init{
    self=[self initWithConfiguration:nil isURLShortened:nil];
    if(!self) return nil;
    return self;
}

- (instancetype _Nullable)initWithConfiguration:(NSURLSessionConfiguration* _Nullable)configuration isURLShortened:(bool(^ _Nullable)(NSURL * _Nullable url))isURLShortened{
    self=[super init];
    if (!self) return nil;
    if(isURLShortened) self.isURLShortened = isURLShortened;
    else self.isURLShortened = ^bool(NSURL *url) {
        return false;
    };
    self.lock=[[NSLock alloc]init];
    self.queue=[[NSOperationQueue alloc]init];
    self.table=[NSMapTable weakToStrongObjectsMapTable];
    self.sessionManager=[[AFURLSessionManager alloc]initWithSessionConfiguration:configuration?configuration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    __weak typeof(self) weakSelf=self;
    [self.sessionManager setTaskWillPerformHTTPRedirectionBlock:^NSURLRequest * _Nullable(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSURLResponse * _Nonnull response, NSURLRequest * _Nonnull request) {
        [weakSelf.lock lock];
        void(^callback)(id _Nullable, NSError * _Nullable)=[weakSelf.table objectForKey:task];
        if (callback) callback(request.URL,nil);
        [weakSelf.lock unlock];
        return nil;
    }];
    return self;
}

- (RetriableOperation* _Nullable)expand:(NSURL* _Nullable)url maximumRetries:(NSInteger)maximumRetries completion:(void(^ _Nullable)(NSURL * _Nullable url,NSError * _Nullable error))completion{
    if (!self.isURLShortened(url)){
        completion(url,nil);
        return nil;
    }
    __block NSURLSessionTask *task;
    __weak typeof(self) weakSelf=self;
    RetriableOperation *operation = [[RetriableOperation alloc]initWithCompletion:^(id  _Nullable response, NSError * _Nullable latestError) {
        completion(response,latestError);
    } retryAfter:^NSTimeInterval(NSInteger currentRetryTime, NSError * _Nullable latestError) {
        if (![latestError.domain isEqualToString:NSURLErrorDomain]) return 0;
        if (currentRetryTime>=maximumRetries) return 0;
        switch (latestError.code) {
            case NSURLErrorTimedOut:
            case NSURLErrorNotConnectedToInternet:
            case NSURLErrorNetworkConnectionLost:
            case NSURLErrorCannotFindHost: return 1;break;
            default:break;
        }
        return 0;
    } start:^(void (^ _Nonnull callback)(id _Nullable, NSError * _Nullable)) {
        task=[weakSelf.sessionManager dataTaskWithRequest:[NSURLRequest requestWithURL:url] uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id _Nullable responseObject, NSError * _Nullable error) {
            if (error) callback(url,error);
            else callback(url,error);
            [weakSelf.lock lock];
            [weakSelf.table removeObjectForKey:task];
            [weakSelf.lock unlock];
        }];
        [weakSelf.lock lock];
        [weakSelf.table setObject:callback forKey:task];
        [weakSelf.lock unlock];
        [task resume];
    } cancel:^{
        if (!task) return;
        [task cancel];
        task=nil;
    } cancelledErrorTemplates:nil];
    [self.queue addOperation:operation];
    return operation;
}

@end
