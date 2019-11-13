//
//  TPMotionManager.h
//  tpdoublerecordingdemo
//
//  Created by CNTP on 2019/11/13.
//  Copyright © 2019 TP. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TPMotionManager : NSObject

@property (assign, nonatomic) UIDeviceOrientation deviceOrientation;//拍摄中的手机方向

+ (instancetype)sharedManager;
+ (instancetype)manager;

- (void)startListeningOrientation;
- (void)stopListeningOrientation;

@end

NS_ASSUME_NONNULL_END
