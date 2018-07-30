//
//  HBDanmaku.h
//  HBDanmakuDemo
//
//  Created by HXJG-Applemini on 16/2/17.
//  Copyright © 2016年 WJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HBDanmaku : NSObject

// 对应说话的时间戳
@property(nonatomic, assign) NSTimeInterval timePoint;
// 弹幕内容
@property(nonatomic, copy) NSAttributedString* contentStr;
// 弹幕显示时间
@property(nonatomic, assign) CGFloat timeInterval;


@end
