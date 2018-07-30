//
//  HBDanmakuInfo.h
//  HBDanmakuDemo
//
//  Created by HXJG-Applemini on 16/2/17.
//  Copyright © 2016年 WJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HBDanmakuSingleV.h"
#import "HBDanmaku.h"

@interface HBDanmakuInfo : NSObject

// 弹幕内容view
@property (nonatomic,strong) HBDanmakuSingleV *singleV;
// 弹幕动画时间
@property(nonatomic, assign) NSTimeInterval leftTime;

@property(nonatomic, strong) HBDanmaku* danmaku;
@property(nonatomic, assign) NSInteger lineCount;

@end
