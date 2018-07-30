//
//  HBDanmakuSingleV.m
//  HBDanmakuDemo
//
//  Created by HXJG-Applemini on 16/2/17.
//  Copyright © 2016年 WJ. All rights reserved.
//

#import "HBDanmakuSingleV.h"

@interface HBDanmakuSingleV ()<UIGestureRecognizerDelegate>

@property (nonatomic,strong) UILabel *content;
@property (nonatomic,strong) UIButton *btn;

@end

@implementation HBDanmakuSingleV

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView{
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = YES;
    _content = [[UILabel alloc]initWithFrame:self.bounds];
    _content.textColor = [UIColor blackColor];
    [self addSubview:_content];
    
    
    
}

- (void)setText:(NSAttributedString *)text{
    _content.attributedText = text;
}

- (NSAttributedString *)text{
    return _content.attributedText;
}


@end
