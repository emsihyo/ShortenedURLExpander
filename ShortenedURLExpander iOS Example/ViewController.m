//
//  ViewController.m
//  ShortenedURLExpander iOS Example
//
//  Created by emsihyo on 2018/5/31.
//  Copyright © 2018 ouyanghua. All rights reserved.
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
    self.operation=[self.expander expand:[NSURL URLWithString:@"http://t.cn/RnWLQVx"] maximumRetries:2 completion:^(NSURL *url, NSError *error) {
        NSLog(@"%@",url);
    }];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
