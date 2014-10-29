//
//  ViewController.m
//  MoonRiseAndSet
//
//  Created by Larry on 14/10/28.
//  Copyright (c) 2014年 MAXMAX. All rights reserved.
//

#import "ViewController.h"
#import "MoonRiseAndSet.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [MoonRiseAndSet getMoonWithLatitude:59.913 withLongitude:10.740];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *test = [def objectForKey:@"moon"];
    NSLog(@"%@",test);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
