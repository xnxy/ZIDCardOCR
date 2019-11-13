//
//  TPPhotoLibraryManager.h
//  tpdoublerecordingdemo
//
//  Created by CNTP on 2019/11/13.
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
 * @brief 保存照片
 * @param image             UImage
 * @param photoAlbumName    相册名字，不填默认为app名字+相册
 */
+ (void)savePhotoWithImage:(UIImage *)image photoAlbumName:(NSString *)photoAlbumName completion:(void(^)(UIImage *image, NSError *error))completion;

/**
 * @brief 创建相册
 * @param photoAlbumName    相册名字，不填默认为app名字+相册
 */
+ (void)setPhotoWithAlbumName:(NSString *)photoAlbumName;

@end


NS_ASSUME_NONNULL_END
