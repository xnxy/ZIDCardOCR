//
//  ZIDCardInfo.m
//  ZIDCardOCR
//
//  Created by CNTP on 2019/11/7.
//

#import "ZIDCardInfo.h"

@implementation ZIDCardInfo

- (instancetype)init{
    self = [super init];
    if (self) {
        self.type = ZIDCardTypeTypeUnknown;
    }
    return self;
}

@end
