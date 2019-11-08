//
//  TPPhotoLibraryManager.h
//  tpdoublerecordingdemo
//
//  Created by CNTP on 2019/8/6.
//  Copyright © 2019 TP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TPPhotoLibraryManager : NSObject

/**
 * @brief 获取相机权限
 * @param denied        获取权限失败回调
 * @param successful    获取权限成功回调
 */
+ (void)getCameraPermission:(void(^)(void))denied successful:(void(^)(void))successful;

/**
 * @brief 获取相册权限
 * @param denied        获取权限失败回调
 * @param successful    获取权限成功回调
 */
+ (void)getALAssetsLibraryPermission:(void(^)(void))denied successful:(void(^)(void))successful;

/**
 * @brief 获取麦克风权限
 * @param denied        获取权限失败回调
 * @param successful    获取权限成功回调
 */
+ (void)getAudioSessionPermission:(void(^)(void))denied successful:(void(^)(void))successful;

/**
 * @brief 保存照片
 * @param image             UImage
 * @param photoAlbumName    相册名字，不填默认为app名字+相册
 */
+ (void)savePhotoWithImage:(UIImage *)image photoAlbumName:(NSString *)photoAlbumName completion:(void(^)(UIImage *image, NSError *error))completion;

/**
 * @brief 保存视频
 * @param videoUrl          视频地址
 * @param photoAlbumName    相册名字，不填默认为app名字
 */
+ (void)saveVideoWithVideoUrl:(NSURL *)videoUrl photoAlbumName:(NSString *)photoAlbumName completion:(void(^)(NSURL *vedioUrl, NSError *error))completion;

//将mov文件转为MP4文件
+ (void)changeMovToMp4:(NSURL *)mediaURL complete:(void (^)(NSURL *videoUrl,UIImage *movieImage))complete;
//视频存放的地址
+ (NSString *)getVideoCachePathWithType:(NSString *)type fileType:(NSString *)fileType;
//获取视频的封面
+ (void)movieToImageWithVideoPath:(NSString *)videoPath seconds:(Float64)seconds Handler:(void (^)(UIImage *movieImage))handler;

//创建相册
+ (void)setPhotoWithAlbumName:(NSString *)photoAlbumName;

@end


NS_ASSUME_NONNULL_END
