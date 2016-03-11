//
//  ViewController.m
//  SCQRCodeDemo
//
//  Created by chow on 16/3/9.
//  Copyright © 2016年 chow. All rights reserved.
//

#import "ViewController.h"
#import "QRCodeScanViewController.h"
#import "QRCodeGenerationViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"SCQRCodeDemo";
    
    [self setUpScanButton];
    [self setUpGenerateButton];
}

- (void)setUpScanButton
{
    UIButton *scanButton = [[UIButton alloc] init];
    [scanButton setTitle:@"扫描二维码/条码" forState:UIControlStateNormal];
    [scanButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [scanButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [scanButton.layer setBorderWidth:1.0];
    [scanButton.layer setMasksToBounds:YES];
    [scanButton.layer setCornerRadius:15.0];
    [scanButton addTarget:self action:@selector(scanButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scanButton];
    
    NSLayoutConstraint *scanButtonCenterX = [NSLayoutConstraint constraintWithItem:scanButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *scanButtonCenterY = [NSLayoutConstraint constraintWithItem:scanButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:-40];
    NSLayoutConstraint *scanButtonWidth = [NSLayoutConstraint constraintWithItem:scanButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0 constant:280];
    NSLayoutConstraint *scanButtonHeight = [NSLayoutConstraint constraintWithItem:scanButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0 constant:60];
    [self.view addConstraints:@[scanButtonCenterX, scanButtonCenterY, scanButtonWidth, scanButtonHeight]];
}

- (void)scanButtonAction
{
    [self.navigationController pushViewController:[[QRCodeScanViewController alloc] init] animated:YES];
}

- (void)setUpGenerateButton
{
    UIButton *generateButton = [[UIButton alloc] init];
    [generateButton setTitle:@"生成二维码" forState:UIControlStateNormal];
    [generateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [generateButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [generateButton.layer setBorderWidth:1.0];
    [generateButton.layer setMasksToBounds:YES];
    [generateButton.layer setCornerRadius:15.0];
    [generateButton addTarget:self action:@selector(generateButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:generateButton];
    
    NSLayoutConstraint *generateButtonCenterX = [NSLayoutConstraint constraintWithItem:generateButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *generateButtonCenterY = [NSLayoutConstraint constraintWithItem:generateButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:40];
    NSLayoutConstraint *generateButtonWidth = [NSLayoutConstraint constraintWithItem:generateButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0 constant:280];
    NSLayoutConstraint *generateButtonHeight = [NSLayoutConstraint constraintWithItem:generateButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0 constant:60];
    [self.view addConstraints:@[generateButtonCenterX, generateButtonCenterY, generateButtonWidth, generateButtonHeight]];
}

- (void)generateButtonAction
{
    [self.navigationController pushViewController:[[QRCodeGenerationViewController alloc] init] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
