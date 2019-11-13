//
//  TPMotionManager.m
//  tpdoublerecordingdemo
//
//  Created by CNTP on 2019/11/13.
//  Copyright © 2019 TP. All rights reserved.
//

#import "TPMotionManager.h"

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

- (void)startListeningOrientation{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)orientationChanged:(NSNotification *)notification {
    UIDevice *device = notification.object;
    self.deviceOrientation = device.orientation;
}

- (void)stopListeningOrientation{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
