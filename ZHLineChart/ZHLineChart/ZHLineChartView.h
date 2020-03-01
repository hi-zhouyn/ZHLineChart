//
//  ZHLineChartView.h
//  ZHLineChart
//
//  Created by 周亚楠 on 2020/3/1.
//  Copyright © 2020 Zhou. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZHLineChartView : UIView
/** 折线关键点用来显示的数据 */
@property (nonatomic, strong) NSArray <NSNumber *> *lineDataAry;
/** 横向显示文字 */
@property (nonatomic, strong) NSArray <NSString *> *horizontalLables;
/** 纵轴最大值 */
@property (nonatomic, strong) NSNumber *max;
/** 纵轴最小值 */
@property (nonatomic, strong) NSNumber *min;
/** Y轴分割个数*/
@property (nonatomic, assign) NSUInteger splitCount;
/** 折线宽（默认1.5） */
@property (nonatomic, assign) CGFloat lineWidth;
/** 横向分割线宽（默认0.5） */
@property (nonatomic, assign) CGFloat horizontalLineWidth;
/** 底部横向分割线宽（默认1） */
@property (nonatomic, assign) CGFloat horizontalBottomLineWidth;

/** 纵向横向显示文本颜色 */
@property (nonatomic, strong) UIColor *textColor;
/** 折线颜色 */
@property (nonatomic, strong) UIColor *lineColor;
/** 横向分割线颜色 */
@property (nonatomic, strong) UIColor *horizontalLineColor;
/** 底部横向分割线颜色 */
@property (nonatomic, strong) UIColor *horizontalBottomLineColor;

/** 折线关键点数据是否显示（默认YES） */
@property (nonatomic, assign) BOOL showLineData;
/** 颜色渐变（默认YES） */
@property (nonatomic, assign) BOOL showColorGradient;
/** 渐变颜色集合 */
@property (nonatomic, strong) NSArray *colorArr;


/**
 * 渲染折线图(传参后调用才会生效)
 */
- (void)drawLineChart;
@end

NS_ASSUME_NONNULL_END
