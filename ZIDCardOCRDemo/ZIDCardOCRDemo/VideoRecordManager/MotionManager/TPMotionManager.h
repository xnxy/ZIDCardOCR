//
//  TPMotionManager.h
//  tpdoublerecordingdemo
//
//  Created by CNTP on 2019/8/23.
//  Copyright © 2019 TP. All rights reserved.
//
//  监听屏幕方向  单独放到这里面吧

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TPMotionManager : NSObject

@property (assign, nonatomic) UIDeviceOrientation deviceOrientation;//拍摄中的手机方向

+ (instancetype)sharedManager;

+ (instancetype)manager;

//开始监听屏幕方向
//- (void)startUpdateAccelerometer;
- (void)startListeningOrientation;
//停止监听屏幕方向
//- (void)stopUpdateAccelerometer;
- (void)stopListeningOrientation;

@end

NS_ASSUME_NONNULL_END
