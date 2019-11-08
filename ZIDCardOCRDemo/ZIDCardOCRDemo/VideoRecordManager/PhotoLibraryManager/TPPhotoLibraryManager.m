//
//  TPPhotoLibraryManager.m
//  tpdoublerecordingdemo
//
//  Created by CNTP on 2019/8/6.
//  Copyright © 2019 TP. All rights reserved.
//

#import "TPPhotoLibraryManager.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@implementation TPPhotoLibraryManager

#pragma mark --- 获取相机权限 ---
+ (void)getCameraPermission:(void(^)(void))denied successful:(void(^)(void))successful{
    //获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!device) {
        if (denied) {
            denied();
        }
        NSLog(@"模拟器中无法打开照相机,请在真机中使用");
        return;
    }
    // 判断授权状态
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authStatus) {
        case AVAuthorizationStatusRestricted:
        {
            if (denied) {
                denied();
            }
            NSLog(@"此应用程序没有被授权访问的照片数据。可能是家长控制权限。");
        }
            break;
        case AVAuthorizationStatusDenied:// 用户拒绝当前应用访问相机
        {
            if (denied) {
                denied();
            }
            NSLog(@"用户拒绝当前应用访问相机");
        }
            break;
        case AVAuthorizationStatusAuthorized:// 用户允许当前应用访问相机
        {
            if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
                if (successful) {
                    successful();
                }
            }
        }
            break;
        case AVAuthorizationStatusNotDetermined:// 用户还没有做出选择
        {
            // 弹框请求用户授权
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) { //用户授权接受
                    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
                        if (successful) {
                            successful();
                        }
                    }
                }else{
                    if (denied) {
                        denied();
                    }
                }
            }];
        }
            break;

        default:
            break;
    }
}

#pragma mark --- 获取相册权限 ---
+ (void)getALAssetsLibraryPermission:(void(^)(void))denied successful:(void(^)(void))successful{
    // 判断授权状态
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
        case PHAuthorizationStatusRestricted:// 此应用程序没有被授权访问的照片数据。可能是家长控制权限。
        {
            if (denied) {
                denied();
            }
            NSLog(@"此应用程序没有被授权访问的照片数据。可能是家长控制权限。");
        }
            break;
        case PHAuthorizationStatusDenied: //用户拒绝访问相册
        {
            if (denied) {
                denied();
            }
            NSLog(@"用户拒绝访问相册");
        }
            break;
        case PHAuthorizationStatusAuthorized:// 用户允许访问相册
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                if (successful) {
                    successful();
                }
            }
        }
            break;
        case PHAuthorizationStatusNotDetermined:// 用户还没有做出选择
        {
            // 弹框请求用户授权
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) { //用户点击了同意
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                        if (successful) {
                            successful();
                        }
                    }
                }else{
                    if (denied) {
                        denied();
                    }
                }
            }];
        }
            break;

        default:
            break;
    }
}

#pragma mark --- 获取麦克风权限 ---
+ (void)getAudioSessionPermission:(void(^)(void))denied successful:(void(^)(void))successful{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (authStatus) {
        case AVAuthorizationStatusDenied:
        {//没有询问是否开启麦克风
            NSLog(@"没有询问是否开启麦克风");
            if (denied) {
                denied();
            }
        }
            break;
        case AVAuthorizationStatusRestricted:
        {//未授权，家长限制
            NSLog(@"未授权，家长限制");
            if (denied) {
                denied();
            }
        }
            break;
        case AVAuthorizationStatusNotDetermined:
        {//玩家未授权
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                if (granted) {
                    NSLog(@"获取权限成功");
                    if (successful) {
                        successful();
                    }
                }else{
                    NSLog(@"获取权限失败");
                    if (denied) {
                        denied();
                    }
                }
            }];
        }
            break;
        case AVAuthorizationStatusAuthorized:
        {//玩家授权
            if (successful) {
                successful();
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark --- 保存图片 ---
+ (void)savePhotoWithImage:(UIImage *)image photoAlbumName:(NSString *)photoAlbumName completion:(void(^)(UIImage *image, NSError *error))completion{

    if (photoAlbumName == nil)
    {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];

        photoAlbumName = [infoDictionary objectForKey:@"CFBundleDisplayName"];

        if (photoAlbumName == nil)
        {
            photoAlbumName = @"视频相册";
        }
    }

    __block NSString *savePhotoAlbumName = photoAlbumName;
    __block UIImage *saveImage = image;
    __block NSString *assetId = nil;

    PHPhotoLibrary *library = [PHPhotoLibrary sharedPhotoLibrary];

    // 1. 存储图片到"相机胶卷"
    [library performChanges:^{ // 这个block里保存一些"修改"性质的代码
        // 新建一个PHAssetCreationRequest对象, 保存图片到"相机胶卷"
        // 返回PHAsset(图片)的字符串标识
        if (@available(iOS 9.0, *)) {
            assetId = [PHAssetCreationRequest creationRequestForAssetFromImage:saveImage].placeholderForCreatedAsset.localIdentifier;
        } else {
            // Fallback on earlier versions
        }
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error1%@", error);
            return;
        }

        NSLog(@"成功保存图片到相机胶卷中");

        // 2. 获得相册对象
        // 获取曾经创建过的自定义视频相册名字
        PHAssetCollection *createdAssetCollection = nil;
        PHFetchResult <PHAssetCollection*> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        for (PHAssetCollection *assetCollection in assetCollections)
        {
            if ([assetCollection.localizedTitle isEqualToString:savePhotoAlbumName])
            {
                createdAssetCollection = assetCollection;
                break;
            }
        }

        //如果这个自定义框架没有创建过
        if (createdAssetCollection == nil)
        {
            //创建新的[自定义的 Album](相簿\相册)
            [library performChangesAndWait:^{

                assetId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:savePhotoAlbumName].placeholderForCreatedAssetCollection.localIdentifier;

            } error:&error];

            NSLog(@"error2: %@", error);
            //抓取刚创建完的视频相册对象
            createdAssetCollection = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[assetId] options:nil].firstObject;

        }

        // 3. 将“相机胶卷”中的图片添加到新的相册
//                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
//                    PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:createdAssetCollection];
//
//                    // 根据唯一标示获得相片对象
//                    PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].firstObject;
//                    // 添加图片到相册中
//                    [request addAssets:@[asset]];
//                } completionHandler:^(BOOL success, NSError * _Nullable error) {
//                    if (error)
//                    {
//                        NSLog(@"添加图片到相册中失败");
//                        return;
//                    }
//
//                    NSLog(@"成功添加图片到相册中");
//                }];

        // 将【Camera Roll】(相机胶卷)的视频 添加到【自定义Album】(相簿\相册)中
        [library performChangesAndWait:^{
            PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:createdAssetCollection];
            [request addAssets:[PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil]];
        } error:&error];

        NSLog(@"error3: %@", error);
        // 提示信息
        if (completion)
        {
            if (error)
            {
                NSLog(@"保存照片失败!");

                completion(nil, error);
            }
            else
            {
                NSLog(@"保存照片成功!");
                completion(saveImage, nil);
            }
        }
    }];
}

#pragma mark --- 保存视频 ---
+ (void)saveVideoWithVideoUrl:(NSURL *)videoUrl photoAlbumName:(NSString *)photoAlbumName completion:(void(^)(NSURL *vedioUrl, NSError *error))completion{

    if (photoAlbumName.length < 1){
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        photoAlbumName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
        if (photoAlbumName.length < 1){
            photoAlbumName = @"视频相册";
        }
    }

    __block NSString *blockAssetCollectionName = photoAlbumName;
    __block NSURL *blockVideoUrl = videoUrl;
    PHPhotoLibrary *library = [PHPhotoLibrary sharedPhotoLibrary];

    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *error = nil;
        __block NSString *assetId = nil;
        __block NSString *assetCollectionId = nil;
        // 保存视频到【Camera Roll】(相机胶卷)
        [library performChangesAndWait:^{

            assetId = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:blockVideoUrl].placeholderForCreatedAsset.localIdentifier;

        } error:&error];
        NSLog(@"error1: %@", error);
        // 获取曾经创建过的自定义视频相册名字
        PHAssetCollection *createdAssetCollection = nil;
        PHFetchResult <PHAssetCollection*> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        for (PHAssetCollection *assetCollection in assetCollections)
        {
            if ([assetCollection.localizedTitle isEqualToString:blockAssetCollectionName])
            {
                createdAssetCollection = assetCollection;
                break;
            }
        }
        //如果这个自定义框架没有创建过
        if (createdAssetCollection == nil)
        {
            //创建新的[自定义的 Album](相簿\相册)
            [library performChangesAndWait:^{
                assetCollectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:blockAssetCollectionName].placeholderForCreatedAssetCollection.localIdentifier;
            } error:&error];

            NSLog(@"error2: %@", error);
            //抓取刚创建完的视频相册对象
            createdAssetCollection = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[assetCollectionId] options:nil].firstObject;
        }
        // 将【Camera Roll】(相机胶卷)的视频 添加到【自定义Album】(相簿\相册)中
        [library performChangesAndWait:^{
            PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:createdAssetCollection];
            [request addAssets:[PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil]];

        } error:&error];
        NSLog(@"error3: %@", error);
        // 提示信息
        if (completion){
            if (error){
                NSLog(@"保存视频失败!");
                completion(nil, error);
            }else{
                NSLog(@"保存视频成功!");
                completion(blockVideoUrl, nil);
            }
        }
    });
}

#pragma --- 将mov文件转为MP4文件 ---
+ (void)changeMovToMp4:(NSURL *)mediaURL complete:(void (^)(NSURL *videoUrl,UIImage *movieImage))complete{

    NSString *basePath=[self getVideoCachePath];
    NSString *videoPath = [basePath stringByAppendingPathComponent:[self getUploadFileNameWithtype:@"video" fileType:@"mp4"]];
    NSURL *videoUrl = [NSURL fileURLWithPath:videoPath];

    AVAsset *video = [AVAsset assetWithURL:mediaURL];
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:video
                                                                            presetName:AVAssetExportPreset1280x720];
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.outputURL = videoUrl;
//    @weakify(self)
    NSLog(@"正在压缩视频……");
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
//        @strongify(self)
        [self movieToImageWithVideoPath:videoPath seconds:1 Handler:^(UIImage *movieImage) {
            NSLog(@"视频压缩成功……");
            if (complete) {
                complete(videoUrl,movieImage);
            }
        }];
    }];
}

+ (NSString *)getVideoCachePathWithType:(NSString *)type fileType:(NSString *)fileType{
    NSString *basePath=[self getVideoCachePath];
    NSString *videoPath = [basePath stringByAppendingPathComponent:[self getUploadFileNameWithtype:type fileType:fileType]];
    return videoPath;
}

#pragma --- 视频存放的地址 ---
+ (NSString *)getVideoCachePath {
    NSString *videoCache = [NSTemporaryDirectory() stringByAppendingPathComponent:@"videos"] ;
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:videoCache isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) ) {
        [fileManager createDirectoryAtPath:videoCache withIntermediateDirectories:YES attributes:nil error:nil];
    };
    return videoCache;
}

#pragma --- 重新设置视频名称 ---
+ (NSString *)getUploadFileNameWithtype:(NSString *)type fileType:(NSString *)fileType {
    NSTimeInterval nowTimeInterval = [[NSDate date] timeIntervalSince1970];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy年MM月dd日 HH:mm:ss"];
    NSDate *nowDate = [NSDate dateWithTimeIntervalSince1970:nowTimeInterval];
    NSString *timeStr = [formatter stringFromDate:nowDate];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.%@",type,timeStr,fileType];
    return fileName;
}

#pragma --- 获取视频的封面 ---
+ (void)movieToImageWithVideoPath:(NSString *)videoPath seconds:(Float64)seconds Handler:(void (^)(UIImage *movieImage))handler {
    NSURL *url = [NSURL fileURLWithPath:videoPath];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = TRUE;
    double duration = asset.duration.value / asset.duration.timescale; //视频的总时间 秒
    NSAssert(duration < seconds, @"视频过短……");
    if (duration < seconds) {
        NSLog(@"--- 视频过短 ---");
        return;
    }
    /*
     AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
     double duration = urlAsset.duration.value / urlAsset.duration.timescale; //视频的总时间

     CMTime CMTimeMakeWithSeconds(
     Float64 seconds,   //第几秒的截图,是当前视频播放到的帧数的具体时间
     int32_t preferredTimeScale //首选的时间尺度 "每秒的帧数"
     );
     */
    CMTime thumbTime = CMTimeMakeWithSeconds(seconds, 60);
    generator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    AVAssetImageGeneratorCompletionHandler generatorHandler =
    ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        if (result == AVAssetImageGeneratorSucceeded) {
            UIImage *thumbImg = [UIImage imageWithCGImage:im];
            if (handler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(thumbImg);
                });
            }
        }
    };
    [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]]
                                    completionHandler:generatorHandler];
}

+ (void)setPhotoWithAlbumName:(NSString *)photoAlbumName{
    [self getALAssetsLibraryPermission:^{

    } successful:^{
        PHAssetCollection *createdAssetCollection = nil;
        PHFetchResult <PHAssetCollection*> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        for (PHAssetCollection *assetCollection in assetCollections)
        {
            if ([assetCollection.localizedTitle isEqualToString:photoAlbumName])
            {
                createdAssetCollection = assetCollection;
                break;
            }
        }
        if (createdAssetCollection == nil) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:photoAlbumName];
            } error:nil];
        }
    }];
}



@end
