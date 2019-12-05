//
//  ZIDCardOCRManager.h
//  ZIDCardOCR
//
//  Created by CNTP on 2019/11/13.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class ZIDCardOCRConfig,ZIDCardInfo;

NS_ASSUME_NONNULL_BEGIN

@interface ZIDCardOCRManager : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@property(class, readonly, strong) ZIDCardOCRManager *sharedManager;

- (void)initWithConfig:(ZIDCardOCRConfig *__nonnull)config;

- (ZIDCardInfo *)runDetectWithSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end

@interface ZIDCardOCRConfig : NSObject

@property (nonatomic, assign) BOOL debug;
@property (nonatomic, copy) NSString *workPath;

@end

NS_ASSUME_NONNULL_END
