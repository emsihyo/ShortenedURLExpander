//
//  ViewController.m
//  ShortenedURLExpander iOS Example
//
//  Created by retriable on 2018/5/31.
//  Copyright © 2018 retriable. All rights reserved.
//
@import ShortenedURLExpander;

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic,strong)ShortenedURLExpander *expander;
@property (nonatomic,strong)RetriableOperation   *operation;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.expander=[[ShortenedURLExpander alloc] initWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] isURLShortened:^bool(NSURL *url) {
        return [url.host isEqualToString:@"t.cn"];
    }];
    self.operation=[self.expander expand:[NSURL URLWithString:@"http://t.cn/RnWLQVx"] maximumRetries:2 completion:^(NSURL * _Nullable originalUrl, NSURL *expandedUrl, NSError * _Nullable error) {
        NSLog(@"%@",expandedUrl);
    }];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
