//
//  ZIDCardOCRManager.m
//  ZIDCardOCR
//
//  Created by CNTP on 2019/11/13.
//

#import "ZIDCardOCRManager.h"
#import "ZIDCardInfo.h"
#import "excards.h"

@interface ZIDCardOCRManager()

@property (nonatomic, strong) ZIDCardOCRConfig *config;

@end

@implementation ZIDCardOCRManager

+ (ZIDCardOCRManager *)sharedManager {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init{
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)initWithConfig:(ZIDCardOCRConfig *__nonnull)config{
    if (!config) {
        config = [[ZIDCardOCRConfig alloc] init];
    }
    self.config = config;
    NSString *workPath = [NSString stringWithFormat:@"%@/%@",self.config.workPath,@"Frameworks/ZIDCardOCR.framework"];
    const char *thePath = [workPath UTF8String];
    int ret = EXCARDS_Init(thePath);
    if (ret != 0) {
        [self printLog:@"初始化失败"];
    }else{
        [self printLog:@"初始化成功"];
    }
}

- (ZIDCardInfo *)runDetectWithSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    ZIDCardInfo *idCardInfo = [[ZIDCardInfo alloc] init];
    if (!sampleBuffer) {
        [self printLog:@"请传入sampleBuffer"];
    }
    CFRetain(sampleBuffer);
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//    CVBufferRetain(imageBuffer);
//    idCardInfo.image = [self getImageStream:imageBuffer];
    // Lock the image buffer
    if (CVPixelBufferLockBaseAddress(imageBuffer, 0) != kCVReturnSuccess) {
        [self printLog:@"sampleBuffer缺省"];
//        CVBufferRelease(imageBuffer);
        CFRelease(sampleBuffer);
        return idCardInfo;
    }

    size_t width= CVPixelBufferGetWidth(imageBuffer);// 1920
    size_t height = CVPixelBufferGetHeight(imageBuffer);// 1080
    CVPlanarPixelBufferInfo_YCbCrBiPlanar *planar = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t offset = NSSwapBigIntToHost(planar->componentInfoY.offset);
    size_t rowBytes = NSSwapBigIntToHost(planar->componentInfoY.rowBytes);

    unsigned char* baseAddress = (unsigned char *)CVPixelBufferGetBaseAddress(imageBuffer);
    unsigned char* pixelAddress = baseAddress + offset;
    static unsigned char *buffer = NULL;
    if (buffer == NULL) {
        buffer = (unsigned char *)malloc(sizeof(unsigned char) * width * height);
    }
    memcpy(buffer, pixelAddress, sizeof(unsigned char) * width * height);
    unsigned char pResult[1024];
    int ret = EXCARDS_RecoIDCardData(buffer, (int)width, (int)height, (int)rowBytes, (int)8, (char*)pResult, sizeof(pResult));
    if (ret > 0) {
        [self printLog:@"识别成功！"];
        char ctype;
        char content[256];
        int xlen;
        int i = 0;
        ctype = pResult[i++];
        while(i < ret){
            ctype = pResult[i++];
            for(xlen = 0; i < ret; ++i){
                if(pResult[i] == ' ') { ++i; break; }
                content[xlen++] = pResult[i];
            }
            content[xlen] = 0;
            if(xlen) {
                NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                if(ctype == 0x21) {
                    idCardInfo.num = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                } else if(ctype == 0x22) {
                    idCardInfo.name = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                } else if(ctype == 0x23) {
                    idCardInfo.gender = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                } else if(ctype == 0x24) {
                    idCardInfo.nation = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                } else if(ctype == 0x25) {
                    idCardInfo.address = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                } else if(ctype == 0x26) {
                    idCardInfo.issue = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                } else if(ctype == 0x27) {
                    idCardInfo.valid = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                }
            }
        }
        if (idCardInfo.name.length > 0 || idCardInfo.num.length > 0) {
            idCardInfo.type = ZIDCardTypeTypeFront;
        }else{
            idCardInfo.type = ZIDCardTypeTypeBack;
        }
    }else{
        [self printLog:@"识别失败！"];
    }

    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
//    CVBufferRelease(imageBuffer);
    CFRelease(sampleBuffer);
    return idCardInfo;
}

- (void)printLog:(NSString *)log{
    if (self.config.debug) {
        NSLog(@"---%@---",log);
    }
}

- (UIImage *)getImageStream:(CVImageBufferRef)imageBuffer {
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext createCGImage:ciImage fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(imageBuffer), CVPixelBufferGetHeight(imageBuffer))];

    UIImage *image = [[UIImage alloc] initWithCGImage:videoImage];

    CGImageRelease(videoImage);
    return image;
}

@end

@implementation ZIDCardOCRConfig

- (instancetype)init{
    self = [super init];
    if (self) {
        self.debug = NO;
        self.workPath = [[NSBundle mainBundle] resourcePath];
    }
    return self;
}

@end
