//
//  TPVideoRecordManager.h
//  tpdoublerecordingdemo
//
//  Created by CNTP on 2019/11/13.
//  Copyright © 2019 TP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TPVideoStreamWithSampleBufferRef)(CMSampleBufferRef sampleBuffer, CGFloat brightnessValue);

@interface TPVideoRecordManager : NSObject

@property (nonatomic, copy) TPVideoStreamWithSampleBufferRef videoStreamWithSampleBufferRefBlock;
//单例
+ (instancetype)sharedManager;
//初始化方法
+ (instancetype)manager;
- (void)beginOnView:(UIView *)view;
//横竖屏切换时 更新视频流方向
- (void)updateLayerFrameOnView:(UIView *)view;
- (void)stopRuning;
- (BOOL)isRuning;

/*--- 是否打开闪光灯 --- */
//是否有闪光灯
- (BOOL)hasTorch;
- (void)turnOnFlash:(BOOL)on;

/* --- 切换摄像头 --- */
//获取摄像头方向
- (AVCaptureDevicePosition)getCaptureDevicePosition;
//切换摄像头
- (void)switchCameras;
- (void)switchCamerasIsFront:(BOOL)isFront;

/* --- 设置聚焦点  手动聚焦 --- */
- (void)setFocusCursorWithPoint:(CGPoint)tapPoint;

@end

NS_ASSUME_NONNULL_END
