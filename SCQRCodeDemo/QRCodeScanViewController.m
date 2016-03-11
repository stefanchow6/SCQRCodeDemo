//
//  QRCodeScanViewController.m
//  SCQRCodeDemo
//
//  Created by chow on 16/3/9.
//  Copyright © 2016年 chow. All rights reserved.
//

#import "QRCodeScanViewController.h"
#import <AVFoundation/AVFoundation.h>

#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCAN_AREA_RECT   CGRectMake((SCREEN_WIDTH - SCAN_AREA_WIDTH) / 2, (SCREEN_HEIGHT - SCAN_AREA_HEIGHT) / 2, SCAN_AREA_WIDTH, SCAN_AREA_HEIGHT)
#define SCAN_AREA_WIDTH  280.0
#define SCAN_AREA_HEIGHT 280.0

@interface QRCodeScanViewController () <AVCaptureMetadataOutputObjectsDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) NSTimer *animationTimer;
@property (nonatomic, strong) UIView *scrollLineView;

@end

@implementation QRCodeScanViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.title = @"二维码/条码";
    
    [self setUpPhotoBarButtonItem];
    [self setUpBackgroundView];
    [self setUpScanView];
    [self setUpScanner];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.captureSession && ![self.captureSession isRunning])
    {
        [self.captureSession startRunning];
        [self startAnimation];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.captureSession && [self.captureSession isRunning])
    {
        [self.captureSession stopRunning];
        [self stopAnimation];
    }
}

- (void)setUpPhotoBarButtonItem
{
    UIBarButtonItem *photoBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(photoBarButtonItemAction)];
    self.navigationItem.rightBarButtonItem = photoBarButtonItem;
}

- (void)setUpBackgroundView
{
    UIView *bgView = [[UIView alloc] initWithFrame:self.view.bounds];
    [bgView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
    [self.view addSubview:bgView];
    
    // bezierPathByReversingPath属性，生成一个跟当前路径相反的路径
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.view.bounds];
    [maskPath appendPath:[[UIBezierPath bezierPathWithRect:SCAN_AREA_RECT] bezierPathByReversingPath]];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = maskPath.CGPath;
    bgView.layer.mask = maskLayer;
    
    UILabel *tipsLabel = [[UILabel alloc] init];
    [tipsLabel setFrame:CGRectMake(CGRectGetMinX(SCAN_AREA_RECT), CGRectGetMaxY(SCAN_AREA_RECT) + 10, SCAN_AREA_WIDTH, 30)];
    [tipsLabel setText:@"将二维码/条码放入框内，即可自动扫描"];
    [tipsLabel setTextColor:[UIColor whiteColor]];
    [tipsLabel setFont:[UIFont systemFontOfSize:14.0]];
    [tipsLabel setTextAlignment:NSTextAlignmentCenter];
    [bgView addSubview:tipsLabel];
}

- (void)setUpScanView
{
    UIView *scanView = [[UIView alloc] initWithFrame:SCAN_AREA_RECT];
    [scanView setBackgroundColor:[UIColor clearColor]];
    [scanView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [scanView.layer setBorderWidth:1.0];
    [self.view addSubview:scanView];
    
    self.scrollLineView = [[UIView alloc] init];
    [self.scrollLineView setFrame:CGRectMake(0, 0, SCAN_AREA_WIDTH, 1)];
    [self.scrollLineView setBackgroundColor:[UIColor greenColor]];
    [scanView addSubview:self.scrollLineView];
}

- (void)setUpScanner
{
    // 获取摄像设备
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 创建输入流
    AVCaptureDeviceInput *captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:nil];
    
    // 创建输出流
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    // 设置代理 在主线程里刷新
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // 初始化链接对象
    self.captureSession = [[AVCaptureSession alloc] init];
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPresetHigh])
    {
        // 高质量采集率
        [self.captureSession setSessionPreset:AVCaptureSessionPresetHigh];
    }
    if ([self.captureSession canAddInput:captureDeviceInput])
    {
        [self.captureSession addInput:captureDeviceInput];
    }
    if ([self.captureSession canAddOutput:captureMetadataOutput])
    {
        [self.captureSession addOutput:captureMetadataOutput];
        
        // 设置扫码支持的编码格式(如下设置条形码和二维码兼容)
        // 一定要在session对象添加输出流后才设置
        [captureMetadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]];
    }
    
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    [captureVideoPreviewLayer setFrame:self.view.bounds];
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.view.layer insertSublayer:captureVideoPreviewLayer atIndex:0];
    
    // 设置识别区域
    // 有系统方法把当前坐标系坐标转换成output类型所需的坐标interestRect
    CGRect interestRect = [captureVideoPreviewLayer metadataOutputRectOfInterestForRect:SCAN_AREA_RECT];
    [captureMetadataOutput setRectOfInterest:interestRect];
}

- (void)startAnimation
{
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(animationTimerAction) userInfo:nil repeats:YES];
}

- (void)stopAnimation
{
    if ([self.animationTimer isValid])
    {
        [self.animationTimer invalidate];
    }
}

- (void)animationTimerAction
{
    CGRect newRect = self.scrollLineView.frame;
    newRect.origin.y += 1;
    if (newRect.origin.y > SCAN_AREA_HEIGHT)
    {
        newRect.origin.y = 0;
    }
    self.scrollLineView.frame = newRect;
}

- (void)photoBarButtonItemAction
{
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    [ipc setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [ipc setDelegate:self];
    [self presentViewController:ipc animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    CIImage *qrcodeImage = [[CIImage alloc] initWithCGImage:image.CGImage options:nil];
    CIContext *context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(YES)}];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
    NSArray *features = [detector featuresInImage:qrcodeImage];
    
    NSString *content = [NSString string];
    for (CIQRCodeFeature *feature in features)
    {
        content = [content stringByAppendingString:feature.messageString];
    }
    
    [self showAlertWithMessage:content];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count > 0)
    {
        [self.captureSession stopRunning];
        [self stopAnimation];
        
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects firstObject];
        
        // 以下为解析二维码后的操作，可以自定义
        [self showAlertWithMessage:metadataObject.stringValue];
    }
}

- (void)showAlertWithMessage:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"二维码内容" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        [self.captureSession startRunning];
        [self startAnimation];
        
    }];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
