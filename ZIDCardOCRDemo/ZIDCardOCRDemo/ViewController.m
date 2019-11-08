//
//  ViewController.m
//  ZIDCardOCRDemo
//
//  Created by CNTP on 2019/11/7.
//

#import "ViewController.h"
#import <ZIDCardOCR/ZIDCardOCR.h>
#import <AVFoundation/AVFoundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "TPMotionManager.h"
#import "TPPhotoLibraryManager.h"
#import "TPDeviceOrientationUtil.h"
#import "TPVideoRecordManager.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    @weakify(self)
    [[RACObserve([TPMotionManager sharedManager], deviceOrientation) takeUntil:self.rac_willDeallocSignal]
     subscribeNext:^(id  _Nullable x) {
         @strongify(self)
         [[TPVideoRecordManager sharedManager] updateLayerFrameOnView:self.view];
     }];

    /* --- 检测 --- */
    NSString *path = [[NSBundle mainBundle] resourcePath];
    ZIDCardOCRConfig *config = [[ZIDCardOCRConfig alloc] init];
    config.workPath = path;
    config.debug = YES;
    ZIDCardOCRManager *manager = ZIDCardOCRManager.sharedManager;
    [manager initWithConfig:config];
    [TPVideoRecordManager sharedManager].videoStreamWithSampleBufferRefBlock = ^(CMSampleBufferRef  _Nonnull sampleBuffer, CGFloat brightnessValue) {
//        AVCaptureDevicePosition position = [[TPVideoRecordManager sharedManager] getCaptureDevicePosition];
//        UIImageOrientation imageOrientation = [[TPDeviceOrientationUtil sharedManager] imageOrientationWithCaptureDevicePosition:position];

        ZIDCardInfo *iDInfo = [manager runDetectWithSampleBuffer:sampleBuffer];
        TPSafeDispatchOnMain(^{
            @strongify(self)
            NSString *type;
            if (iDInfo.type == ZIDCardTypeTypeFront) {
                type = @"正面";
            }else if(iDInfo.type == ZIDCardTypeTypeBack){
                type = @"背面";
            }else{
                type = @"未检测出";
            }
            self.logTextView.text = [NSString stringWithFormat:@"\n%@\n姓名：%@\n性别：%@\n民族：%@\n住址：%@\n公民身份证号码：%@\n\n反面\n签发机关：%@\n有效期限：%@",type,iDInfo.name,iDInfo.gender,iDInfo.nation,iDInfo.address,iDInfo.num,iDInfo.issue,iDInfo.valid];
        });

    };
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!TARGET_IPHONE_SIMULATOR) {
        @weakify(self)
        [TPPhotoLibraryManager getCameraPermission:^{

        } successful:^{
            TPSafeDispatchOnMain(^{
                @strongify(self)
                [[TPVideoRecordManager sharedManager] beginOnView:self.view];
                [[TPVideoRecordManager sharedManager] updateLayerFrameOnView:self.view];
            });
        }];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (!TARGET_IPHONE_SIMULATOR) {
        [TPPhotoLibraryManager getCameraPermission:^{

        } successful:^{
            TPSafeDispatchOnMain(^{
                [[TPVideoRecordManager sharedManager] stopRuning];
            });
        }];
    }
}

void TPSafeDispatchOnMain(dispatch_block_t block) {
    if (block == nil) return;
    if (NSThread.isMainThread) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

@end
