//
//  TPMotionManager.m
//  tpdoublerecordingdemo
//
//  Created by CNTP on 2019/8/23.
//  Copyright © 2019 TP. All rights reserved.
//

#import "TPMotionManager.h"
//#import <CoreMotion/CoreMotion.h>

@interface TPMotionManager()

//@property (nonatomic, strong) CMMotionManager *motionManager;//监听屏幕方向

@end

@implementation TPMotionManager

+ (instancetype)sharedManager{
    static TPMotionManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [self manager];
    });
    return sharedManager;
}

+ (instancetype)manager{
    TPMotionManager *motionManager = [[TPMotionManager alloc] init];
    return motionManager;
}

//- (CMMotionManager *)motionManager
//{
//    if (!_motionManager){
//        _motionManager = [[CMMotionManager alloc] init];
//    }
//    return _motionManager;
//}

#pragma mark --- 开始监听屏幕方向 ---
//- (void)startUpdateAccelerometer
//{
//    if ([self.motionManager isAccelerometerAvailable] == YES)
//    {
//        @weakify(self)
//        [self.motionManager setAccelerometerUpdateInterval:1/40.f]; //调用时间
//        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error)
//         {
//             @strongify(self)
//             double x = accelerometerData.acceleration.x;
//             double y = accelerometerData.acceleration.y;
//             if ((fabs(y) + 0.1f) >= fabs(x))
//             {
//                 if (y >= 0.1f)
//                 {
//                     // Down
//                     NSLog(@"Down");
//                     self.deviceOrientation = UIDeviceOrientationPortraitUpsideDown;
//                 }
//                 else
//                 {
//                     // Portrait
//                     NSLog(@"Portrait");
//                     self.deviceOrientation = UIDeviceOrientationPortrait;
//                 }
//             }
//             else
//             {
//                 if (x >= 0.1f)
//                 {
//                     // Right
//                     NSLog(@"Right");
//                     self.deviceOrientation = UIDeviceOrientationLandscapeRight;
//                 }
//                 else if (x <= 0.1f)
//                 {
//                     // Left
//                     NSLog(@"Left");
//                     self.deviceOrientation = UIDeviceOrientationLandscapeLeft;
//                 }
//                 else
//                 {
//                     // Portrait
//                     NSLog(@"Portrait");
//                     self.deviceOrientation = UIDeviceOrientationPortrait;
//                 }
//             }
//         }];
//    }
//}

- (void)startListeningOrientation{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)orientationChanged:(NSNotification *)notification {
    UIDevice *device = notification.object;
    self.deviceOrientation = device.orientation;
//    NSLog(@"---deviceOrientation:%@----",@(self.deviceOrientation));
}

#pragma mark --- 停止监听屏幕方向 ---
//- (void)stopUpdateAccelerometer
//{
//    if ([self.motionManager isAccelerometerActive] == YES)
//    {
//        [self.motionManager stopAccelerometerUpdates];
//        _motionManager = nil;
//    }
//}

- (void)stopListeningOrientation{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
