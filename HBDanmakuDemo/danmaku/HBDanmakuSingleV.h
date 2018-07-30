//
//  HBDanmakuSingleV.h
//  HBDanmakuDemo
//
//  Created by HXJG-Applemini on 16/2/17.
//  Copyright © 2016年 WJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HBDanmakuSingleV : UIView

@property (nonatomic,copy) NSAttributedString* text;

// 是否重复出现
@property(nonatomic, assign) BOOL isRepeat;
// 是否正在移动
@property(nonatomic, assign) BOOL isMoving;


@end
