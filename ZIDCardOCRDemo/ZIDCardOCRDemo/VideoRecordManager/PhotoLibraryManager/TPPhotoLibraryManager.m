//
//  TPPhotoLibraryManager.m
//  tpdoublerecordingdemo
//
//  Created by CNTP on 2019/11/13.
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
