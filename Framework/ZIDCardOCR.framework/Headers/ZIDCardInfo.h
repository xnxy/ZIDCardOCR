//
//  ZIDCardInfo.h
//  ZIDCardOCR
//
//  Created by CNTP on 2019/11/13.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ZIDCardType){
    ZIDCardTypeTypeUnknown = 0,  //未知
    ZIDCardTypeTypeFront   = 1,//身份证正面
    ZIDCardTypeTypeBack    = 2,//身份证背面
};

@interface ZIDCardInfo : NSObject

@property (nonatomic, assign) ZIDCardType type;//身份证 1正面/2反面
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *num; //身份证号
@property (nonatomic, copy) NSString *name; //姓名
@property (nonatomic, copy) NSString *gender; //性别
@property (nonatomic, copy) NSString *nation; //民族
@property (nonatomic, copy) NSString *address; //地址
@property (nonatomic, copy) NSString *issue; //签发机关
@property (nonatomic, copy) NSString *valid; //有效期

@end

NS_ASSUME_NONNULL_END
