//
//  ZHLineChartView.h
//  ZHLineChart
//
//  Created by 周亚楠 on 2020/3/1.
//  Copyright © 2020 Zhou. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  HEX 16进制 设置颜色
 */
#define KBaseSetHEXColor(rgbValue,al) ([UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(al)])

#define KSetHEXColorWithAlpha(rgbValue,al) KBaseSetHEXColor(rgbValue,al)
#define KSetHEXColor(rgbValue) KBaseSetHEXColor(rgbValue,1)

#define KHorizontalLineColor             KSetHEXColor(0xe8e8e8)
#define KTextColor                       KSetHEXColor(0x666666)
#define KLineColor                       KSetHEXColor(0x428eda)
#define KHorizontalBottomLineColor       KSetHEXColor(0x428eda)

NS_ASSUME_NONNULL_BEGIN

@interface ZHLineChartView : UIView

/** 折线关键点用来显示的数据 */
@property (nonatomic, strong) NSArray <NSNumber *> *lineDataAry;
/** 底部横向显示文字 */
@property (nonatomic, strong) NSArray <NSString *> *horizontalDataArr;
/** 纵轴最大值 */
@property (nonatomic, strong) NSNumber *max;
/** 纵轴最小值 */
@property (nonatomic, strong) NSNumber *min;
/** Y轴分割个数*/
@property (nonatomic, assign) NSUInteger splitCount;

/** 关键点圆半径（默认3） */
@property (nonatomic, assign) CGFloat circleRadius;
/** 折线宽（默认1.5） */
@property (nonatomic, assign) CGFloat lineWidth;
/** 横向分割线宽（默认0.5） */
@property (nonatomic, assign) CGFloat horizontalLineWidth;
/** 底部横向分割线宽（默认1） */
@property (nonatomic, assign) CGFloat horizontalBottomLineWidth;
/** 关键点数据文本显示宽度（默认为文本值的宽） */
@property (nonatomic, assign) CGFloat dataTextWidth;
/** 纵轴文本显示宽度（默认为传入最大值max的宽） */
@property (nonatomic, assign) CGFloat leftTextWidth;
/** 刻度上下偏移（默认0） */
@property (nonatomic, assign) CGFloat scaleOffset;
/** 底部文本上下偏移（默认20） */
@property (nonatomic, assign) CGFloat bottomOffset;
/** 横向分割线距离左边文本偏移距离（默认5） */
@property (nonatomic, assign) CGFloat lineToLeftOffset;
/** 底部文本旋转角度（默认M_PI * 1.75） */
@property (nonatomic, assign) CGFloat angle;
/** 文本字号（默认10） */
@property (nonatomic, assign) CGFloat textFontSize;
/** 边界（默认UIEdgeInsetsMake(25, 5, 40, 15)） */
@property (nonatomic, assign) UIEdgeInsets edge;

/** 关键点边框颜色（默认0x428eda） */
@property (nonatomic, strong) UIColor *circleStrokeColor;
/** 关键点填充颜色（默认whiteColor） */
@property (nonatomic, strong) UIColor *circleFillColor;
/** 纵向横向显示文本颜色（默认0x666666） */
@property (nonatomic, strong) UIColor *textColor;
/** 关键点文本颜色（默认0x428eda） */
@property (nonatomic, strong) UIColor *dataTextColor;
/** 折线颜色（默认0x428eda） */
@property (nonatomic, strong) UIColor *lineColor;
/** 横向分割线颜色（默认0xe8e8e8） */
@property (nonatomic, strong) UIColor *horizontalLineColor;
/** 底部横向分割线颜色（默认0x428eda） */
@property (nonatomic, strong) UIColor *horizontalBottomLineColor;

/** 是否只显示X轴头尾,无需显示的文本赋空值可达到同样效果（默认NO,也就是全部显示）(by vitasapple)*/
@property (nonatomic, assign) BOOL isShowHeadTail;
/** 贝塞尔曲线绘制，增加曲度控制（默认YES） */
@property (nonatomic, assign) BOOL addCurve;
/** 关键点居中显示（默认YES） */
@property (nonatomic, assign) BOOL toCenter;
/** toCenter=YES时是否补充前后显示（默认NO） */
@property (nonatomic, assign) BOOL supplement;
/** 折线关键点数据是否显示（默认YES） */
@property (nonatomic, assign) BOOL showLineData;
/** 是否填充颜色渐变（默认YES） */
@property (nonatomic, assign) BOOL showColorGradient;
/** 渐变颜色集合 (默认0.4 0x428eda + 0.1 whiteColor)*/
@property (nonatomic, strong) NSArray *colorArr;

/**
 * 渲染折线图(传参后调用才会生效)
 */
- (void)drawLineChart;

@end


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
