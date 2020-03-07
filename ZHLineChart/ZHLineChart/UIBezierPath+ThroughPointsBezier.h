//
//  UIBezierPath+ThroughPointsBezier.h
//  ZHLineChart
//
//  Created by 周亚楠 on 2020/3/1.
//  Copyright © 2020 Zhou. All rights reserved.
//

//#import <AppKit/AppKit.h>


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIBezierPath (ThroughPointsBezier)

/**
 *  曲线的弯曲水平。优值区间约为0.6 ~ 0.8。默认值和推荐值是0.7。
 */
@property (nonatomic) CGFloat contractionFactor;

/**
 * 正常折线绘制
 * 必须将CGPoint结构体包装成NSValue对象并且至少一个点来画折线。
 */
- (void)addNormalBezierThroughPoints:(NSArray *)pointArray;

/**
 * 三次贝塞尔曲线绘制折线
 * 必须将CGPoint结构体包装成NSValue对象并且至少一个点来画曲线。
 */
- (void)addBezierThroughPoints:(NSArray *)pointArray;

@end

NS_ASSUME_NONNULL_END
