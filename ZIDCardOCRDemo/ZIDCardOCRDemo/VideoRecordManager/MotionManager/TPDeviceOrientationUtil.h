//
//  TPDeviceOrientationUtil.h
//  tpdoublerecordingdemo
//
//  Created by CNTP on 2019/11/13.
//  Copyright © 2019 TP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TPDetectType) {
    TPDetectTypeFace = 0, //人脸
    TPDetectTypeText = 1, //文本、身份证  前置摄像头会有镜像
};

@interface TPDeviceOrientationUtil : NSObject

+ (instancetype)sharedManager;
+ (instancetype)manager;

//根据设备方向返回 需要旋转的视频流方向
- (AVCaptureVideoOrientation)setupVideoOrientation;

//根据设备方向返回 需要旋转的图片方向
//- (UIImageOrientation)imageOrientation;
- (UIImageOrientation)imageOrientationWithCaptureDevicePosition:(AVCaptureDevicePosition)position;

- (UIImageOrientation)imageOrientationWithCaptureDevicePosition:(AVCaptureDevicePosition)position detectType:(TPDetectType)detectType;


@end

NS_ASSUME_NONNULL_END
