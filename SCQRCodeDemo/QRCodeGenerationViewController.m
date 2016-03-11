//
//  QRCodeGenerationViewController.m
//  SCQRCodeDemo
//
//  Created by chow on 16/3/11.
//  Copyright © 2016年 chow. All rights reserved.
//

#import "QRCodeGenerationViewController.h"

#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define QRCODE_WIDTH  192.0
#define QRCODE_HEIGHT 192.0

@interface QRCodeGenerationViewController () <UITextFieldDelegate>

@property (nonatomic, weak) UIImageView *QRCodeImageView;
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, weak) UITextField *textField;

@end

@implementation QRCodeGenerationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.title = @"生成二维码";
    [self setUpQRCodeImageView];
    [self setUpQRCodeInputTextField];
}

- (void)setUpQRCodeInputTextField
{
    UIView *containerView = [[UIView alloc] init];
    [containerView setBackgroundColor:[UIColor colorWithRed:246 / 255.0 green:246 / 255.0 blue:246 / 255.0 alpha:1.0]];
    [containerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:containerView];
    self.containerView = containerView;
    
    CALayer *line = [CALayer layer];
    [line setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    [line setBackgroundColor:[UIColor colorWithRed:220 / 255.0 green:220 / 255.0 blue:220 / 255.0 alpha:1.0].CGColor];
    [containerView.layer addSublayer:line];
    
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0 constant:50];
    [self.view addConstraints:@[left, right, bottom, height]];
    
    UITextField *textFiled = [[UITextField alloc] init];
    [textFiled setDelegate:self];
    [textFiled setPlaceholder:@"请输入二维码信息"];
    [textFiled setBorderStyle:UITextBorderStyleRoundedRect];
    [textFiled setReturnKeyType:UIReturnKeyDone];
    [textFiled setClearButtonMode:UITextFieldViewModeWhileEditing];
    [textFiled setEnablesReturnKeyAutomatically:YES];
    [textFiled setTranslatesAutoresizingMaskIntoConstraints:NO];
    [containerView addSubview:textFiled];
    self.textField = textFiled;
    
    left = [NSLayoutConstraint constraintWithItem:textFiled attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeLeading multiplier:1 constant:10];
    right = [NSLayoutConstraint constraintWithItem:textFiled attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-10];
    bottom = [NSLayoutConstraint constraintWithItem:textFiled attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeBottom multiplier:1 constant:-10];
    height = [NSLayoutConstraint constraintWithItem:textFiled attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeHeight multiplier:0 constant:30];
    [containerView addConstraints:@[left, right, bottom, height]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWillShowKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWillHideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)setUpQRCodeImageView
{
    UIImageView *QRCodeImageView = [[UIImageView alloc] init];
    [QRCodeImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [QRCodeImageView setUserInteractionEnabled:YES];
    [QRCodeImageView setHidden:YES];
    [QRCodeImageView.layer setBorderWidth:1.0];
    [self.view addSubview:QRCodeImageView];
    self.QRCodeImageView = QRCodeImageView;
    
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:QRCodeImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:84];
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:QRCodeImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:QRCodeImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0 constant:QRCODE_WIDTH];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:QRCodeImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0 constant:QRCODE_HEIGHT];
    [self.view addConstraints:@[top, centerX, width, height]];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [QRCodeImageView addGestureRecognizer:longPress];
}

- (void)longPressAction:(UILongPressGestureRecognizer *)longPress
{
    if (UIGestureRecognizerStateBegan == longPress.state)
    {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"保存图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            UIGraphicsBeginImageContextWithOptions(self.QRCodeImageView.bounds.size, YES, [UIScreen mainScreen].scale);
            CGContextRef context = UIGraphicsGetCurrentContext();
            [self.QRCodeImageView.layer renderInContext:context];
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            
        }];
        [actionSheet addAction:saveAction];
        
        UIAlertAction *scanAction = [UIAlertAction actionWithTitle:@"识别图中二维码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            UIImage *image = self.QRCodeImageView.image;
//            CIImage *qrcodeImage = [[CIImage alloc] initWithCGImage:image.CGImage options:nil];
            CIImage *qrcodeImage = image.CIImage;
            CIContext *context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(YES)}];
            CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
            NSArray *features = [detector featuresInImage:qrcodeImage];
            
            NSString *content = [NSString string];
            for (CIQRCodeFeature *feature in features)
            {
                content = [content stringByAppendingString:feature.messageString];
            }
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"二维码内容" message:content preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:cancelAction];
            [self presentViewController:alert animated:YES completion:nil];
            
        }];
        [actionSheet addAction:scanAction];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [actionSheet addAction:cancelAction];
        
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error)
    {
        NSLog(@"save failed");
    }
    else
    {
        NSLog(@"save success");
    }
}

- (UIImage *)generateQRCodeWithString:(NSString *)string width:(CGFloat)width height:(CGFloat)height
{
//    NSData *data = [string dataUsingEncoding:NSISOLatin1StringEncoding allowLossyConversion:NO];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    [filter setValue:data forKey:@"inputMessage"];
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    CIImage *qrcodeImage = [filter outputImage];
    CGFloat scaleWidth = width / qrcodeImage.extent.size.width;
    CGFloat scaleHeight = height / qrcodeImage.extent.size.height;
    CIImage *scaleImage = [qrcodeImage imageByApplyingTransform:CGAffineTransformScale(CGAffineTransformIdentity, scaleWidth, scaleHeight)];
    
    return [UIImage imageWithCIImage:scaleImage];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    UIImage *qrcodeImage = [self generateQRCodeWithString:textField.text width:QRCODE_WIDTH height:QRCODE_HEIGHT];
    [self.QRCodeImageView setImage:qrcodeImage];
    [self.QRCodeImageView setHidden:NO];
    
    [textField setText:nil];
    [textField resignFirstResponder];
    
    return YES;
}

- (void)handleWillShowKeyboard:(NSNotification *)notification
{
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.containerView.transform = CGAffineTransformMakeTranslation(0, -keyboardFrame.size.height);
}

- (void)handleWillHideKeyboard:(NSNotification *)notification
{
    [UIView animateWithDuration:0.35 animations:^{
        
        self.containerView.transform = CGAffineTransformIdentity;
        
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    UIView *touchView = touch.view;
    if ([touchView isEqual:self.view])
    {
        [self.textField resignFirstResponder];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
