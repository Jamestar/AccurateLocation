//
//  ViewController.m
//  AccurateLocation
//
//  Created by vochi on 2017/2/22.
//  Copyright © 2017年 vochi. All rights reserved.
//

#import "ViewController.h"
#import "LocationTool.h"

@interface ViewController ()

@property (nonatomic, strong) UILabel *locationLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *getLocationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    getLocationBtn.frame = CGRectMake(20, 64, 100, 50);
    getLocationBtn.layer.cornerRadius = 5.0f;
    [getLocationBtn setBackgroundColor:[UIColor redColor]];
    [getLocationBtn setTitle:@"获取位置" forState:UIControlStateNormal];
    [getLocationBtn addTarget:self action:@selector(getLocationBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:getLocationBtn];
    
    self.locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 130, 280, 200)];
    self.locationLabel.textColor = [UIColor blackColor];
    self.locationLabel.backgroundColor = [UIColor greenColor];
    self.locationLabel.textAlignment = NSTextAlignmentCenter;
    self.locationLabel.font = [UIFont systemFontOfSize:16];
    self.locationLabel.numberOfLines = 0;
    [self.view addSubview:self.locationLabel];
    
}

- (void)getLocationBtnClick
{
    [[LocationTool shareLocation] getLocationPointSuccess:^(NSString *address) {
        NSLog(@"%@", address);
        
        self.locationLabel.text = address;
        
    } failure:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
