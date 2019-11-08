//
//  TPVideoRecordManager.m
//  tpdoublerecordingdemo
//
//  Created by CNTP on 2019/8/6.
//  Copyright © 2019 TP. All rights reserved.
//

#import "TPVideoRecordManager.h"
#import <CoreMedia/CoreMedia.h>
#import <CoreImage/CoreImage.h>
#import "TPDeviceOrientationUtil.h"

@interface TPVideoRecordManager ()<AVCaptureVideoDataOutputSampleBufferDelegate>

// 捕获视频流
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *videoDeviceInput;//视频输入
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;//视频输出
@property (nonatomic, strong) dispatch_queue_t videoQueueBuffer;
// 图层显示
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

//录制
@property (nonatomic, assign) BOOL isRecord; //是否为录制

@end

@implementation TPVideoRecordManager

//因为项目中主要业务就是视频  搞成单例
+ (instancetype)sharedManager{
    static TPVideoRecordManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [self manager];
    });
    return sharedManager;
}

//初始化方法
+ (instancetype)manager{
    TPVideoRecordManager *manager = [[TPVideoRecordManager alloc] init];
    return manager;
}

- (instancetype)init{
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)beginOnView:(UIView *)view{
    [self.session beginConfiguration];
    if ([self.session canAddInput:self.videoDeviceInput]) {
        [self.session addInput:self.videoDeviceInput];
    }
    if ([self.session canAddOutput:self.videoDataOutput]) {
        [self.session addOutput:self.videoDataOutput];
    }
    [self.session commitConfiguration];
    if (!self.videoPreviewLayer) {
        self.videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        self.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.videoPreviewLayer.frame = CGRectInset(view.frame, 0, 0);
        [view.layer insertSublayer:self.videoPreviewLayer atIndex:0];
    }
    [self.session startRunning];
}

//#warning --- 先固定一个方向 方向转来转去 太乱了 ----
- (void)updateLayerFrameOnView:(UIView *)view{
    [self.session commitConfiguration];
    self.videoPreviewLayer.frame = CGRectInset(view.frame, 0, 0);
    self.videoPreviewLayer.connection.videoOrientation = [[TPDeviceOrientationUtil sharedManager] setupVideoOrientation];
    [self.session startRunning];
}

- (BOOL)isRuning{
    return self.session.isRunning;
}

- (void)stopRuning{
    if (self.session) {
        [self.session beginConfiguration];
        [self.session removeOutput:self.videoDataOutput];
        [self.session removeInput:self.videoDeviceInput];
        [self.session commitConfiguration];
        if ([self.session isRunning]) {
            [self.session stopRunning];
        }
        self.videoPreviewLayer = nil;
        self.session = nil;
    }
}

#pragma mark - Setter and Getter - Video Session
- (AVCaptureDevice *)device {
    if (_device == nil) {
        NSArray<AVCaptureDevice *> *devices = nil;
        if (@available(iOS 10.0, *)) {
            NSArray *types = @[AVCaptureDeviceTypeBuiltInWideAngleCamera];
            AVCaptureDeviceDiscoverySession *discoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:types mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
            devices = [discoverySession devices];
        } else {
            devices = [AVCaptureDevice devices];
        }
        for (AVCaptureDevice *device in devices) {
            if ([device hasMediaType:AVMediaTypeVideo]) {
                if ([device position] == AVCaptureDevicePositionFront) {
                    _device = device;
                }
            }
        }
        NSError *error = nil;
        if ([_device lockForConfiguration:&error]) {
            _device.activeVideoMaxFrameDuration = [self frameDuration];
            _device.activeVideoMinFrameDuration = _device.activeVideoMaxFrameDuration;
            if ([_device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
                [_device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            } else if ([_device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
                [_device setFocusMode:AVCaptureFocusModeAutoFocus];
            } else if ([_device isFocusModeSupported:AVCaptureFocusModeLocked]) {
                [_device setFocusMode:AVCaptureFocusModeLocked];
            }
            [_device unlockForConfiguration];
        }
    }
    return _device;
}

- (AVCaptureSession *)session {
    if (_session == nil) {
        _session = [[AVCaptureSession alloc] init];
        if ([self isSingleCoreDevice]) {
            // iPhone 4
            _session.sessionPreset = AVCaptureSessionPresetLow;
        } else {
            // iPhone 4S, +
//            _session.sessionPreset = AVCaptureSessionPreset640x480;
//            _session.sessionPreset = AVCaptureSessionPreset1280x720;
            _session.sessionPreset = AVCaptureSessionPreset1920x1080;
        }
    }
    return _session;
}

- (AVCaptureVideoDataOutput *)videoDataOutput {
    if (_videoDataOutput == nil) {
        NSDictionary *videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)};
        _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        [_videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
        [_videoDataOutput setVideoSettings:videoSettings];
        [_videoDataOutput setSampleBufferDelegate:self queue:self.videoQueueBuffer];
    }
    return _videoDataOutput;
}

- (AVCaptureDeviceInput *)videoDeviceInput {
    if (_videoDeviceInput == nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error = nil;
        _videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        NSAssert(error == nil, @"视频输入设备获取失败");
    }
    return _videoDeviceInput;
}

- (dispatch_queue_t)videoQueueBuffer {
    if (_videoQueueBuffer == nil) {
        _videoQueueBuffer = dispatch_queue_create("com.tpdoublerecordingdemo.videoQueueBuffer", DISPATCH_QUEUE_SERIAL);
    }
    return _videoQueueBuffer;
}

#pragma mark - Setter and Getter - Assistant
// 是否是单核设备
- (BOOL)isSingleCoreDevice {
    return ([NSProcessInfo processInfo].processorCount == 1);
}

// 帧率
- (CMTime)frameDuration {
    int frameRate;
    CMTime frameDuration = kCMTimeInvalid;
    // For single core systems like iPhone 4 and iPod Touch 4th Generation
    // we use a lower resolution and framerate to maintain real-time performance.
    frameRate = [self isSingleCoreDevice] ? 15 : 30;
    frameDuration = CMTimeMake(1, frameRate);
    return frameDuration;
}

#pragma mark --- delegate ---
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    @autoreleasepool {
        //根据光线判断是否开启闪光灯
        if (connection == [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo] ) {
            @synchronized (self) {
                CGFloat brightnessValue = [self getBrightnessValueWithOutputSampleBuffer:sampleBuffer];
                if(self.videoStreamWithSampleBufferRefBlock){
                    self.videoStreamWithSampleBufferRefBlock(sampleBuffer, brightnessValue);
                }
            }
        }
    }
}

#pragma mark --- 获取环境光感参数 ---
- (CGFloat)getBrightnessValueWithOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[ NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    CGFloat brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    return brightnessValue;
}

#pragma mark --- 是否打开闪光灯 ---
- (BOOL)hasTorch{
    return [self.device hasTorch];
}

- (void)turnOnFlash:(BOOL)on{
    if ([self.device hasTorch] && [self.device hasFlash]) {
        [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
            if (on) {
                [captureDevice setTorchMode:AVCaptureTorchModeOn];
                [captureDevice setFlashMode:AVCaptureFlashModeOn];
            }else{
                [captureDevice setTorchMode:AVCaptureTorchModeOff];
                [captureDevice setFlashMode:AVCaptureFlashModeOff];
            }
        }];
    }
}

#pragma mark --- 切换摄像头 ---
- (void)switchCameras{
    AVCaptureDevicePosition position = [self getCaptureDevicePosition];
    //获取需要改变的方向
    AVCaptureDevicePosition changePosition = position == AVCaptureDevicePositionFront?AVCaptureDevicePositionBack:AVCaptureDevicePositionFront;
    //获取改变的摄像头设备
    AVCaptureDevice *newDevice = [self cameraWithPosition:changePosition];
    //获取改变的摄像头输入设备
    AVCaptureDeviceInput *newDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:newDevice error:nil];

    //移除之前摄像头输入设备
    [self.session removeInput:self.videoDeviceInput];

    //添加新的摄像头输入设备
    [self.session addInput:newDeviceInput];
    //记录当前摄像头输入设备
    self.videoDeviceInput = newDeviceInput;
    [self.session commitConfiguration];
}

- (void)switchCamerasIsFront:(BOOL)isFront{
//    AVCaptureDevicePosition position = [self getCaptureDevicePosition];
    //获取需要改变的方向
    AVCaptureDevicePosition changePosition;
    if (isFront) {
        changePosition = AVCaptureDevicePositionFront;
    }else{
        changePosition = AVCaptureDevicePositionBack;
    }
    //获取改变的摄像头设备
    AVCaptureDevice *newDevice = [self cameraWithPosition:changePosition];
    //获取改变的摄像头输入设备
    AVCaptureDeviceInput *newDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:newDevice error:nil];

    //移除之前摄像头输入设备
    [self.session removeInput:self.videoDeviceInput];

    //添加新的摄像头输入设备
    [self.session addInput:newDeviceInput];
    //记录当前摄像头输入设备
    self.videoDeviceInput = newDeviceInput;
    [self.session commitConfiguration];
}

//获取摄像头方向
- (AVCaptureDevicePosition)getCaptureDevicePosition{
    return self.videoDeviceInput.device.position;
}

//通过摄像头方法找到device
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices ){
        if ( device.position == position ){
            return device;
        }
    }
    return nil;
}

#pragma mark --- 设置聚焦点  手动聚焦 ----
//外部点击屏幕某一点  进行聚焦
- (void)setFocusCursorWithPoint:(CGPoint)tapPoint{
    CGPoint cameraPoint = [self.videoPreviewLayer captureDevicePointOfInterestForPoint:tapPoint];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
}

-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:point];
        }
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        if ([captureDevice isExposurePointOfInterestSupported]) {
            [captureDevice setExposurePointOfInterest:point];
        }
    }];
}

- (void)changeDeviceProperty:(void(^)(AVCaptureDevice *captureDevice))propertyChange{
    AVCaptureDevice *captureDevice = [self.videoDeviceInput device];
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    }else{
        NSLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
    }
}

#pragma mark --- 视频录制 ---

//开始录制
- (void)startRecord{
    self.isRecord = YES;
}

//结束录制
- (void)stopRecord{
    self.isRecord = NO;
}

@end
