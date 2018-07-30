//
//  HBDanmakuView.h
//  HBDanmakuDemo
//
//  Created by HXJG-Applemini on 16/2/17.
//  Copyright © 2016年 WJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HBDanmaku.h"

@interface HBDanmakuView : NSObject

@property (nonatomic, readonly, assign) BOOL isPrepared;
@property (nonatomic, readonly, assign) BOOL isPlaying;
@property(nonatomic, readonly, assign) BOOL isPauseing;

/**
 初始化弹幕数据
 @param danmakus HBDanmaku对象的数组
 */
- (void)prepareDanmakus:(NSArray *)danmakus;

// 以下属性都是必须配置的--------
// 弹幕动画时间
@property (nonatomic, assign) CGFloat duration;
// 中间上边/下边弹幕动画时间
@property (nonatomic, assign) CGFloat centerDuration;
// 弹幕弹道高度
@property (nonatomic, assign) CGFloat lineHeight;
// 弹幕弹道之间的间距
@property (nonatomic, assign) CGFloat lineMargin;
// 距离父视图顶部的高度
@property (nonatomic,assign) CGFloat topSpace;

// 弹幕弹道最大行数
@property (nonatomic, assign) NSInteger maxShowLineCount;

// 弹幕的背景视图
@property (nonatomic,strong) UIView *bgView;

// start 与 stop 对应  pause 与 resume 对应
- (void)start;
//- (void)pause;
//- (void)resume;
//- (void)stop;

- (void)clear;

// 发送一个弹幕
- (void)sendDanmakuSource:(HBDanmaku *)danmaku;

// 要想响应对弹幕的点击，此方法需在bgView的  - (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event  中调用
- (void)touchBeginWithTouches:(NSSet<UITouch *> *)touches;

@end
