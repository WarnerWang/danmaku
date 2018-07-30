//
//  HBDanmakuView.m
//  HBDanmakuDemo
//
//  Created by HXJG-Applemini on 16/2/17.
//  Copyright © 2016年 WJ. All rights reserved.
//

#import "HBDanmakuView.h"
#import "HBDanmakuInfo.h"

#define X(view) view.frame.origin.x
#define Y(view) view.frame.origin.y
#define Width(view) view.frame.size.width
#define Height(view) view.frame.size.height
#define Left(view) X(view)
#define Right(view) (X(view) + Width(view))
#define Top(view) Y(view)
#define Bottom(view) (Y(view) + Height(view))
#define CenterX(view) (Left(view) + Right(view))/2
#define CenterY(view) (Top(view) + Bottom(view))/2

#define kRandomColor [UIColor colorWithRed:arc4random_uniform(256) / 255.0 green:arc4random_uniform(256) / 255.0 blue:arc4random_uniform(256) / 255.0 alpha:1]
#define font [UIFont systemFontOfSize:15]

@interface HBDanmakuView ()

@property(nonatomic, strong) NSMutableArray* danmakus;
@property(nonatomic, strong) NSMutableArray* currentDanmakus;
@property(nonatomic, strong) NSMutableArray* subDanmakuInfos;

@property(nonatomic, strong) NSMutableDictionary* linesDict;

@property (nonatomic,strong) NSTimer *timer;

/// 第一个弹幕的时间戳
@property (nonatomic,assign) NSTimeInterval firstTimePoint;
@property (nonatomic,assign) NSTimeInterval changeTime;

@property (nonatomic,strong) HBDanmakuSingleV *lastTapSingleV;

@property (nonatomic,assign) NSInteger curIndex;

@property (nonatomic,assign) NSTimeInterval waitTimeInterval;// 一轮循环结束以后等待的时间

@end

static NSTimeInterval const timeMargin = 0.5;
static NSInteger const viewPositionInTop = 2;
static NSInteger const viewPositionInDefault = 0;
@implementation HBDanmakuView

#pragma mark - lazy
- (NSMutableArray *)currentDanmakus
{
    if (!_currentDanmakus) {
        _currentDanmakus = [NSMutableArray array];
    }
    return _currentDanmakus;
}

- (NSMutableArray *)subDanmakuInfos
{
    if (!_subDanmakuInfos) {
        _subDanmakuInfos = [[NSMutableArray alloc] init];
    }
    return _subDanmakuInfos;
}

- (NSMutableDictionary *)linesDict
{
    if (!_linesDict) {
        _linesDict = [[NSMutableDictionary alloc] init];
    }
    return _linesDict;
}

#pragma mark - perpare

/**
 初始化弹幕数据
 @param danmakus HBDanmaku对象的数组
 */
- (void)prepareDanmakus:(NSArray *)danmakus
{
//    self.danmakus = [[danmakus sortedArrayUsingComparator:^NSComparisonResult(HBDanmaku* obj1, HBDanmaku* obj2) {
//        if (obj1.timePoint > obj2.timePoint) {
//            return NSOrderedDescending;
//        }
//        return NSOrderedAscending;
//    }] mutableCopy];
//
//    // 获得第一个弹幕的时间戳
//    HBDanmaku *firstDanmaku = self.danmakus[0];
//    self.firstTimePoint = firstDanmaku.timePoint;
    
    
    self.danmakus = [[danmakus sortedArrayUsingComparator:^NSComparisonResult(HBDanmaku* obj1, HBDanmaku* obj2) {
        if (obj1.timeInterval > obj2.timeInterval) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }] mutableCopy];
    
}

- (void)getCurrentTime
{
    
    [self.subDanmakuInfos enumerateObjectsUsingBlock:^(HBDanmakuInfo* obj, NSUInteger idx, BOOL *stop) {
        NSTimeInterval leftTime = obj.leftTime;
        leftTime -= timeMargin;
        obj.leftTime = leftTime;
    }];
    
    if (_curIndex == self.danmakus.count) {
        _waitTimeInterval += timeMargin;
        if ((_waitTimeInterval)/self.duration == 1) {
            _curIndex = 0;
            self.changeTime = 0;
            _waitTimeInterval = 0;
        }else {
            return;
        }
    }
    
    [self.currentDanmakus removeAllObjects];
    self.changeTime += 0.5;
    NSTimeInterval timeInterval = self.firstTimePoint + self.changeTime;
    NSString* timeStr = [NSString stringWithFormat:@"%0.1f", timeInterval];
    timeInterval = timeStr.floatValue;
    
//    [self.danmakus enumerateObjectsUsingBlock:^(HBDanmaku* obj, NSUInteger idx, BOOL *stop) {
//        if (obj.timePoint >= timeInterval && obj.timePoint < timeInterval + 20) {
//            if (![self.currentDanmakus containsObject:obj]) {
//                [self.currentDanmakus addObject:obj];
//            }
//            
//            //            NSLog(@"%f----%f--%zd", timeInterval, obj.timePoint, idx);
//        }else if( obj.timePoint > timeInterval){
//            *stop = YES;
//        }
//    }];
    
    [self.danmakus enumerateObjectsUsingBlock:^(HBDanmaku* obj, NSUInteger idx, BOOL *stop) {
        if (obj.timeInterval >= timeInterval && obj.timeInterval < timeInterval + timeMargin) {
            if (![self.currentDanmakus containsObject:obj]) {
                [self.currentDanmakus addObject:obj];
                _curIndex++;
            }
            
            //            NSLog(@"%f----%f--%zd", timeInterval, obj.timePoint, idx);
        }else if( obj.timeInterval > timeInterval){
            *stop = YES;
        }
    }];
    
    if (self.currentDanmakus.count > 0) {
        for (HBDanmaku* danmaku in self.currentDanmakus) {
            [self playDanmaku:danmaku];
        }
    }
}


- (void)postView{
    if (self.danmakus.count > 0) {
        NSDictionary *dict = nil;
        if (self.danmakus.count > _curIndex) {
            dict = self.danmakus[_curIndex];
            _curIndex++;
        } else {
            _curIndex = 0;
            dict = self.danmakus[_curIndex];
            _curIndex++;
        }
    }
}

#pragma mark - 准备弹幕
- (void)playDanmaku:(HBDanmaku *)danmaku
{
    HBDanmakuSingleV *singleV = [[HBDanmakuSingleV alloc]initWithFrame:CGRectMake(Width(self.bgView), self.topSpace, [HBDanmakuView getSizeWithText:danmaku.contentStr].width, [HBDanmakuView getSizeWithText:danmaku.contentStr].height)];
    singleV.isMoving = YES;
    singleV.text = danmaku.contentStr;
    singleV.userInteractionEnabled = YES;
    [self.bgView addSubview:singleV];
    
    [self playFromRightDanmaku:danmaku singleView:singleV];
}

#pragma mark - 计算弹幕位置
- (void)playFromRightDanmaku:(HBDanmaku *)danmaku singleView:(HBDanmakuSingleV *)singleV
{
    
    HBDanmakuInfo* newInfo = [[HBDanmakuInfo alloc] init];
    newInfo.singleV = singleV;
    newInfo.leftTime = self.duration;
    newInfo.danmaku = danmaku;
    
    singleV.frame = CGRectMake(Width(self.bgView), self.topSpace, Width(singleV), Height(singleV));
    
    NSInteger valueCount = self.linesDict.allKeys.count;
    if (valueCount == 0) {
        newInfo.lineCount = 0;
        [self addAnimationToViewWithInfo:newInfo];
        return;
    }
    
    for (int i = 0; i<valueCount; i++) {
        HBDanmakuInfo* oldInfo = self.linesDict[@(i)];
        if (!oldInfo) break;
        if (![self judgeIsRunintoWithFirstDanmakuInfo:oldInfo behindSingleV:singleV]) {
            newInfo.lineCount = i;
            [self addAnimationToViewWithInfo:newInfo];
            break;
        }else if (i == valueCount - 1){
            if (valueCount < self.maxShowLineCount) {
                
                newInfo.lineCount = i+1;
                [self addAnimationToViewWithInfo:newInfo];
            }else{
                [self.danmakus removeObject:danmaku];
                [singleV removeFromSuperview];
                NSLog(@"同一时间评论太多--排不开了--------------------------");
            }
        }
    }
}

- (void)addAnimationToViewWithInfo:(HBDanmakuInfo *)info
{
    HBDanmakuSingleV* singleV = info.singleV;
    NSInteger lineCount = info.lineCount;
    
    singleV.frame = CGRectMake(Width(self.bgView), (Height(singleV) + self.lineMargin) * lineCount + self.topSpace, Width(singleV), Height(singleV));
    
    [self.subDanmakuInfos addObject:info];
    self.linesDict[@(lineCount)] = info;
    
    [self performAnimationWithDuration:info.leftTime danmakuInfo:info];
}

- (void)performAnimationWithDuration:(NSTimeInterval)duration danmakuInfo:(HBDanmakuInfo *)info
{
    _isPlaying = YES;
    _isPauseing = NO;
    
    HBDanmakuSingleV* singleV = info.singleV;
    CGRect endFrame = CGRectMake(-Width(singleV), Y(singleV), Width(singleV), Height(singleV));
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear |UIViewAnimationOptionAllowUserInteraction animations:^{
        singleV.frame = endFrame;
    } completion:^(BOOL finished) {
        if (finished) {
            singleV.isMoving = NO;
            [singleV removeFromSuperview];
            [self.subDanmakuInfos removeObject:info];
        }
    }];
    
    
}

// 检测碰撞 -- 默认从右到左
- (BOOL)judgeIsRunintoWithFirstDanmakuInfo:(HBDanmakuInfo *)info behindSingleV:(HBDanmakuSingleV *)lastSingleV
{
    HBDanmakuSingleV* firstSingleV = info.singleV;
    CGFloat firstSpeed = [self getSpeedFromSingleV:firstSingleV];
    CGFloat lastSpeed = [self getSpeedFromSingleV:lastSingleV];
    if (!firstSingleV.isMoving) {
        return NO;
    }
//    NSLog(@"---%d",firstSingleV.isMoving);
//    if(!firstSingleV.isMoving) return YES;
//    NSLog(@"firstS:%f    -----     lastS:%f",firstSpeed,lastSpeed);
    
    //    CGRect firstFrame = info.labelFrame;
    CGFloat firstFrameRight = info.leftTime * firstSpeed;
//    CGFloat right = ((CALayer *)firstSingleV.layer.presentationLayer).frame.origin.x + Width(firstSingleV);
//    NSLog(@"right:%f ========== firstFrameRight:%f",right,firstFrameRight);
//    if (fabs(firstFrameRight - right) > 1) {
//        firstFrameRight = right;
//    }
//    firstFrameRight = right;
    
    CGFloat lastFrameLeft = Left(lastSingleV);
//    NSLog(@"firstFrameRight :%f   ------     lastFrameLeft:%f",firstFrameRight,lastFrameLeft);
    if(info.leftTime <= 1) return NO;
    if(lastFrameLeft - firstFrameRight > 10) {
        
        if( lastSpeed <= firstSpeed)
        {
            return NO;
        }else{
            CGFloat lastEndLeft = lastFrameLeft - lastSpeed * info.leftTime;
            if (lastEndLeft >  10) {
                return NO;
            }
        }
    }
    
    return YES;
}

// 计算速度
- (CGFloat)getSpeedFromSingleV:(HBDanmakuSingleV *)singleV
{
    return (self.bgView.bounds.size.width + singleV.bounds.size.width) / self.duration;
}

#pragma mark - 公共方法

- (BOOL)isPrepared
{
    NSAssert(self.duration && self.maxShowLineCount, @"必须先设置弹幕的时间\\最大行数\\弹幕行高");
    if (self.danmakus.count && self.duration && self.maxShowLineCount) {
        return YES;
    }
    return NO;
}

- (void)start
{
    
//    if(_isPauseing) [self resume];
    
    if ([self isPrepared]) {
        if (!_timer) {
            _changeTime = 0;
            _timer = [NSTimer timerWithTimeInterval:timeMargin target:self selector:@selector(getCurrentTime) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
            [_timer fire];
        }
    }
}
//- (void)pause
//{
//    if(!_timer || !_timer.isValid) return;
//    
//    _isPauseing = YES;
//    _isPlaying = NO;
//    
//    [_timer invalidate];
//    _timer = nil;
//    
//    for (UIView *subView in self.bgView.subviews) {
//        if ([subView isKindOfClass:[HBDanmakuSingleV class]]) {
//            HBDanmakuSingleV* singleV = (HBDanmakuSingleV *)subView;
//            CALayer *layer = singleV.layer;
//            CGRect rect = singleV.frame;
//            if (layer.presentationLayer) {
//                rect = ((CALayer *)layer.presentationLayer).frame;
//            }
//            singleV.frame = rect;
//            [singleV.layer removeAllAnimations];
//        }
//        
//    }
//}

- (void)pauseWithSingleV:(HBDanmakuSingleV *)singleV{
    if (!singleV || !_timer || !_timer.isValid) {
        return;
    }
    _lastTapSingleV = singleV;
//    CALayer *layer = singleV.layer;
//    CGRect rect = singleV.frame;
//    if (layer.presentationLayer) {
//        rect = ((CALayer *)layer.presentationLayer).frame;
//    }
//    singleV.frame = rect;
//    [singleV.layer removeAllAnimations];
    singleV.isMoving = NO;
    CALayer *layer = singleV.layer;
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
//    [singleV bringSubviewToFront:self.bgView];
    layer.borderColor = [UIColor purpleColor].CGColor;
    layer.borderWidth = 1;
    layer.zPosition = viewPositionInTop;
    
}

//- (void)resume
//{
//    if( ![self isPrepared] || _isPlaying || !_isPauseing) return;
//    for (HBDanmakuInfo* info in self.subDanmakuInfos) {
//        [self performAnimationWithDuration:info.leftTime danmakuInfo:info];
//    }
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeMargin * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self start];
//    });
//}

- (void)resumeWithSingleV:(HBDanmakuSingleV *)singleV{
    if (!singleV || singleV.layer.zPosition != viewPositionInTop) {
        return;
    }
    singleV.isMoving = YES;
    CALayer *layer = singleV.layer;
    CFTimeInterval pausedTime = layer.timeOffset;
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
    layer.borderColor = [UIColor clearColor].CGColor;
    layer.borderWidth = 0;
//    [singleV sendSubviewToBack:self.bgView];
    layer.zPosition = viewPositionInDefault;
    
}

//- (void)stop
//{
//    _isPauseing = NO;
//    _isPlaying = NO;
//    
//    [_timer invalidate];
//    _timer = nil;
//    [self.danmakus removeAllObjects];
//    self.linesDict = nil;
//}

- (void)clear
{
    [_timer invalidate];
    _timer = nil;
    self.linesDict = nil;
    _isPauseing = YES;
    _isPlaying = NO;
    for (UIView *subView in self.bgView.subviews) {
        if ([subView isKindOfClass:[HBDanmakuSingleV class]]) {
            HBDanmakuSingleV* singleV = (HBDanmakuSingleV *)subView;
            [singleV removeFromSuperview];
        }
        
    }
}

- (void)sendDanmakuSource:(HBDanmaku *)danmaku
{
    [self playDanmaku:danmaku];
}

+(CGSize)getSizeWithText:(NSAttributedString *)text{
    UILabel *label = [[UILabel alloc]init];
    label.attributedText = text;
    NSDictionary *attribute = @{NSFontAttributeName: font};
    CGSize retSize = [label.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                              options:\
                      NSStringDrawingTruncatesLastVisibleLine |
                      NSStringDrawingUsesLineFragmentOrigin |
                      NSStringDrawingUsesFontLeading
                                           attributes:attribute
                                              context:nil].size;
    return retSize;
}

// 弹幕的触摸点击
- (void)touchBeginWithTouches:(NSSet<UITouch *> *)touches{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.bgView];
    NSInteger tapCount = 0;
    for (UIView *subView in self.bgView.subviews) {
        if ([subView isKindOfClass:[HBDanmakuSingleV class]]) {
            HBDanmakuSingleV *singleV = (HBDanmakuSingleV *)subView;
            if (!singleV.isMoving) {
                [self resumeWithSingleV:singleV];
            }
            if ([[singleV.layer presentationLayer] hitTest:touchPoint]) {
                tapCount++;
                if (tapCount == 1) {
                    [self touchOnSingleV:singleV];
                }
                
            }
        }
        
    }
}

- (void)touchOnSingleV:(HBDanmakuSingleV *)singleV{
    if (singleV.isMoving) {
        if (singleV == _lastTapSingleV) {
            NSLog(@"++++++++++++++");
        }
        
        [self pauseWithSingleV:singleV];
    }else {
        [self resumeWithSingleV:singleV];
    }
}

@end
