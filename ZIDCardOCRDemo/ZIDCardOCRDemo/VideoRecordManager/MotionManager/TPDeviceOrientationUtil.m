//
//  TPDeviceOrientationUtil.m
//  tpdoublerecordingdemo
//
//  Created by CNTP on 2019/11/13.
//  Copyright © 2019 TP. All rights reserved.
//

#import "TPDeviceOrientationUtil.h"

@interface TPDeviceOrientationUtil()

@property (nonatomic, assign) AVCaptureVideoOrientation videoOrientation;

@end

@implementation TPDeviceOrientationUtil

+ (instancetype)sharedManager{
    static TPDeviceOrientationUtil *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [self manager];
    });
    return sharedManager;
}

+ (instancetype)manager{
    TPDeviceOrientationUtil *manager = [[TPDeviceOrientationUtil alloc] init];
    return manager;
}

- (AVCaptureVideoOrientation)videoOrientation{
    if (!_videoOrientation) {
        _videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    return _videoOrientation;
}

//根据设备方向返回 需要旋转的视频流方向
- (AVCaptureVideoOrientation)setupVideoOrientation{
    AVCaptureVideoOrientation videoOrientation;
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    switch (deviceOrientation) {
        case UIDeviceOrientationFaceUp:
        {
            videoOrientation = self.videoOrientation;
        }
            break;
        case UIDeviceOrientationFaceDown: //手机正面向上、向下 固定下方向
        {
            videoOrientation = self.videoOrientation;
        }
            break;
        case UIDeviceOrientationPortrait: //正向
        {
            videoOrientation = AVCaptureVideoOrientationPortrait;
        }
            break;
        case UIDeviceOrientationPortraitUpsideDown: //倒立 固定正向
        {
            videoOrientation = AVCaptureVideoOrientationPortrait;
        }
            break;
        case UIDeviceOrientationLandscapeLeft:// 因为有镜像  orz
        {
            videoOrientation = AVCaptureVideoOrientationLandscapeRight;
        }
            break;
        case UIDeviceOrientationLandscapeRight: // 因为有镜像  orz
        {

            videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
        }
            break;
        default:
        {
            videoOrientation = AVCaptureVideoOrientationPortrait;
        }
            break;
    }
    self.videoOrientation = videoOrientation;
    return videoOrientation;
}

//根据设备方向返回 需要旋转的图片方向
- (UIImageOrientation)imageOrientationWithCaptureDevicePosition:(AVCaptureDevicePosition)position{
    return [self imageOrientationWithCaptureDevicePosition:position detectType:TPDetectTypeFace];
}

- (UIImageOrientation)imageOrientationWithCaptureDevicePosition:(AVCaptureDevicePosition)position detectType:(TPDetectType)detectType{
    UIImageOrientation imageOrientation;
    //    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    //视频的方向
    AVCaptureVideoOrientation videoOrientation = [self setupVideoOrientation];
    switch (videoOrientation) {
        case AVCaptureVideoOrientationPortrait:
        {
            if (position == AVCaptureDevicePositionBack) {
                imageOrientation = UIImageOrientationRight;
            }else{
                if (detectType == TPDetectTypeText) {
                    imageOrientation = UIImageOrientationRight;
                }else{
                    imageOrientation = UIImageOrientationLeftMirrored;
                }
            }
        }
            break;
        case AVCaptureVideoOrientationLandscapeRight:
        {
            if (position == AVCaptureDevicePositionBack) {
                imageOrientation = UIImageOrientationUp;
            }else{
                if (detectType == TPDetectTypeText) {
                    imageOrientation = UIImageOrientationDown;
                }else{
                    imageOrientation = UIImageOrientationDownMirrored;
                }
            }
        }
            break;
        case AVCaptureVideoOrientationLandscapeLeft:
        {
            if (position == AVCaptureDevicePositionBack) {
                imageOrientation = UIImageOrientationDown;
            }else{
                if (detectType == TPDetectTypeText) {
                    imageOrientation = UIImageOrientationUp;
                }else{
                    imageOrientation = UIImageOrientationUpMirrored;
                }
            }
        }
            break;

        default:
        {
            if (position == AVCaptureDevicePositionBack) {
                imageOrientation = UIImageOrientationRight;
            }else{
                if (detectType == TPDetectTypeText) {
                    imageOrientation = UIImageOrientationRight;
                }else{
                    imageOrientation = UIImageOrientationLeftMirrored;
                }
            }
        }
            break;
    }
    return imageOrientation;
}

@end
