//
//  ShortenedURLExpander.m
//  ShortenedURLExpander
//
//  Created by retriable on 2018/5/31.
//  Copyright © 2018 retriable. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ShortenedURLExpander.h"

static NSMapTable *sessions;

@interface ShortenedURLExpander () <NSURLSessionTaskDelegate>

@property (nonatomic,assign) bool(^isURLShortened)(NSURL *url);

@property (nonatomic,strong) NSMapTable          *table;
@property (nonatomic,strong) NSOperationQueue    *queue;
@property (nonatomic,strong) NSLock              *lock;

@end

@implementation ShortenedURLExpander

- (void)dealloc{
    [sessions removeObjectForKey:self];
}

- (instancetype)init{
    self=[self initWithConfiguration:nil isURLShortened:nil];
    if(!self) return nil;
    return self;
}

- (instancetype _Nullable)initWithConfiguration:(NSURLSessionConfiguration* _Nullable)configuration isURLShortened:(bool(^ _Nullable)(NSURL * _Nullable url))isURLShortened{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sessions=[NSMapTable weakToStrongObjectsMapTable];
    });
    self=[super init];
    if (!self) return nil;
    if(isURLShortened) self.isURLShortened = isURLShortened;
    else self.isURLShortened = ^bool(NSURL *url) {
        return false;
    };
    self.lock=[[NSLock alloc]init];
    self.queue=[[NSOperationQueue alloc]init];
    self.table=[NSMapTable weakToStrongObjectsMapTable];
    [sessions setObject:[NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[[NSOperationQueue alloc]init]] forKey:self];
    return self;
}

- (RetriableOperation* _Nullable)expand:(NSURL* _Nullable)url maximumRetries:(NSInteger)maximumRetries completion:(void(^ _Nullable)(NSURL * _Nullable originalUrl,NSURL *expandedUrl,NSError * _Nullable error))completion{
    if (!self.isURLShortened(url)){
        completion(url,url,nil);
        return nil;
    }
    __block NSURLSessionTask *task;
    __weak typeof(self) weakSelf=self;
    RetriableOperation *operation = [[RetriableOperation alloc]initWithCompletion:^(id  _Nullable response, NSError * _Nullable latestError) {
        completion(url,response,latestError);
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
        task=[[sessions objectForKey:weakSelf] dataTaskWithURL:url];
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

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler{
    [self.lock lock];
    void(^callback)(id,NSError*)=[self.table objectForKey:task];
    if (callback) callback(request.URL,nil);
    [self.table removeObjectForKey:task];
    [self.lock unlock];
    completionHandler(nil);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    [self.lock lock];
    void(^callback)(id,NSError*)=[self.table objectForKey:task];
    if (callback) callback(task.originalRequest.URL,error);
    [self.table removeObjectForKey:task];
    [self.lock unlock];
}

@end

































