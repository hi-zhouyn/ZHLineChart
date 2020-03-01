//
//  ZHLineChartView.m
//  ZHLineChart
//
//  Created by 周亚楠 on 2020/3/1.
//  Copyright © 2020 Zhou. All rights reserved.
//

#import "ZHLineChartView.h"
#import "UIBezierPath+ThroughPointsBezier.h"

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

@interface ZHLineChartView ()
@property (nonatomic, strong) NSMutableArray *pointArr;
@end

@implementation ZHLineChartView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

/**
 * 渲染折线图
 */
- (void)drawLineChart
{
    NSMutableArray *pointArr = [NSMutableArray array];
    CGFloat labelHeight = 10;
    NSInteger numSpace = (self.max.integerValue - self.min.integerValue) / self.splitCount;
    CGFloat spaceY = (self.frame.size.height - 25 - 40 - ((self.splitCount + 1) * labelHeight)) / self.splitCount;
    CGFloat minMidY = 0.0;
    CGFloat maxMidY;
    
    for (int i = 0; i < self.splitCount + 1; i ++) {
        //创建纵轴文本
        UILabel *leftLabel = [[UILabel alloc] init];
        leftLabel.frame = CGRectMake(15, 25 + (spaceY + labelHeight) * i, 25, labelHeight);
        leftLabel.textColor = KTextColor;
        leftLabel.textAlignment = NSTextAlignmentRight;
        leftLabel.font = [UIFont systemFontOfSize:10];
        leftLabel.text = [NSString stringWithFormat:@"%ld",self.max.integerValue - numSpace * i];
        [self addSubview:leftLabel];
        
        if (!i) {
            minMidY = CGRectGetMidY(leftLabel.frame);
        }
        
        UIBezierPath *linePath = [UIBezierPath bezierPath];
        CGFloat minX = CGRectGetMaxX(leftLabel.frame) + 5;
        CGFloat maxX = CGRectGetMaxX(self.frame) - 23;
        [linePath moveToPoint:CGPointMake(minX, CGRectGetMidY(leftLabel.frame))];
        [linePath addLineToPoint:CGPointMake(maxX, CGRectGetMidY(leftLabel.frame))];
        
        CAShapeLayer *maxLineLayer = [CAShapeLayer layer];
        if (i == self.splitCount) {
            maxLineLayer.strokeColor = kSetHEXColor(0x428eda).CGColor;
            maxLineLayer.lineWidth = 1;
            CGFloat spaceX = (maxX - minX) / (self.lables.count);
            maxMidY = CGRectGetMidY(leftLabel.frame);
            //创建刻度
            UIBezierPath *bezierPath = [UIBezierPath bezierPath];
            for (int j = 0 ; j < self.lables.count + 1; j ++) {
                [bezierPath moveToPoint:CGPointMake(minX + spaceX * j, maxMidY)];
                [bezierPath addLineToPoint:CGPointMake(minX + spaceX * j, maxMidY + 2)];
                [linePath appendPath:bezierPath];
            }
            //创建横轴文本
            CGFloat bottomLabelWidth = spaceX + 20;
            CGFloat ratio = (maxMidY - minMidY) / (self.max.floatValue - self.min.floatValue);
            for (int k = 0; k < self.lables.count; k ++) {
                CGFloat midX = minX + (spaceX * k) + spaceX / 2;
                UILabel *bottomLabel = [[UILabel alloc] init];
                bottomLabel.frame = CGRectMake(midX - bottomLabelWidth / 2, maxMidY + 20, bottomLabelWidth, labelHeight);
                bottomLabel.textColor = kColorTextGray6;
                bottomLabel.textAlignment = NSTextAlignmentCenter;
                bottomLabel.font = [UIFont systemFontOfSize:10];
                bottomLabel.text = self.lables[k];
                [self addSubview:bottomLabel];
                //旋转
                [bottomLabel setAngle:M_PI * 1.75];
                
                //构造关键点
                NSNumber *tempNum = self.dataAry[k];
                CGFloat y = maxMidY - (tempNum.integerValue - self.min.floatValue) * ratio;
                if (!k) {
                    NSValue *value = [NSValue valueWithCGPoint:CGPointMake(minX, y)];
                    [pointArr addObject:value];
                }
                NSValue *value = [NSValue valueWithCGPoint:CGPointMake(midX, y)];
                [pointArr addObject:value];
                if (k == self.dataAry.count - 1) {
                    NSValue *value = [NSValue valueWithCGPoint:CGPointMake(maxX, y)];
                    [pointArr addObject:value];
                }
            }
            //绘制折线
            [self drawLineLayerWithPointArr:pointArr layerFrom:CGRectMake(minX, minMidY, maxX - minX, maxMidY- minMidY) maxMidY:maxMidY];
            
        } else {
            maxLineLayer.strokeColor = kColorLine.CGColor;
            maxLineLayer.lineWidth = 0.5;
        }
        maxLineLayer.path = linePath.CGPath;
        maxLineLayer.fillColor = [UIColor clearColor].CGColor;
        maxLineLayer.lineCap = kCALineCapRound;
        maxLineLayer.lineJoin = kCALineJoinRound;
        maxLineLayer.contentsScale = [UIScreen mainScreen].scale;
        [self.layer addSublayer:maxLineLayer];
        
    }
}

- (void)drawLineLayerWithPointArr:(NSMutableArray *)pointArr layerFrom:(CGRect)layerFrom maxMidY:(CGFloat)maxMidY
{
    CGPoint startPoint = [[pointArr firstObject] CGPointValue];
    CGPoint endPoint = [[pointArr lastObject] CGPointValue];
    UIBezierPath *maxPath = [UIBezierPath bezierPath];
    [maxPath moveToPoint:startPoint];
    [maxPath addBezierThroughPoints:pointArr];
    
    CAShapeLayer *maxLineLayer = [CAShapeLayer layer];
    maxLineLayer.path = maxPath.CGPath;
    maxLineLayer.strokeColor = kSetHEXColor(0x428eda).CGColor;
    maxLineLayer.fillColor = KColorClear.CGColor;
    maxLineLayer.lineWidth = 1.5;
    maxLineLayer.lineCap = kCALineCapRound;
    maxLineLayer.lineJoin = kCALineJoinRound;
    maxLineLayer.contentsScale = [UIScreen mainScreen].scale;
    [self.layer addSublayer:maxLineLayer];
    
    UIBezierPath *colorPath = [UIBezierPath bezierPath];
    colorPath.lineWidth = 1.f;
    [colorPath moveToPoint:startPoint];
    [colorPath addBezierThroughPoints:pointArr];
    [colorPath addLineToPoint:CGPointMake(endPoint.x, maxMidY)];
    [colorPath addLineToPoint:CGPointMake(startPoint.x, maxMidY)];
    [colorPath addLineToPoint:CGPointMake(startPoint.x, startPoint.y)];
    
    CAShapeLayer *bgLayer = [CAShapeLayer layer];
    bgLayer.path = colorPath.CGPath;
    bgLayer.frame = self.bounds;
    
    CAGradientLayer *colorLayer = [CAGradientLayer layer];
    colorLayer.frame = bgLayer.frame;
    colorLayer.mask = bgLayer;
    colorLayer.startPoint = CGPointMake(0, 0);
    colorLayer.endPoint = CGPointMake(0, 1);
    colorLayer.colors = [NSArray arrayWithObjects:(id)[[kSetHEXColor(0x428eda) colorWithAlphaComponent:0.4] CGColor],(id)[[KColorWhite colorWithAlphaComponent:0.1] CGColor], nil];
    [self.layer addSublayer:colorLayer];
    
    
//    CABasicAnimation *maxPathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
//    maxPathAnimation.duration = 12;
//    maxPathAnimation.repeatCount = 1;
//    maxPathAnimation.removedOnCompletion = YES;
//    maxPathAnimation.fromValue = @0.f;
//    maxPathAnimation.toValue = @1;
//    [maxLineLayer addAnimation:maxPathAnimation forKey:@"strokeEnd"];
    
    [self buildDotWithPointsArr:pointArr];
}

- (void)buildDotWithPointsArr:(NSMutableArray *)pointsArr
{
    for (int i = 0; i < pointsArr.count; i ++) {
        if (!i || i == pointsArr.count - 1) {
            continue;
        }
        NSValue *point = pointsArr[i];
        
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(point.CGPointValue.x, point.CGPointValue.y) radius:3 startAngle:0 endAngle:M_PI * 2 clockwise:NO];
        CAShapeLayer *circleLayer = [CAShapeLayer layer];
        circleLayer.path = path.CGPath;
        circleLayer.strokeColor = kSetHEXColor(0x428eda).CGColor;
        circleLayer.fillColor = KColorWhite.CGColor;
        circleLayer.lineWidth = 1.5;
        circleLayer.lineCap = kCALineCapRound;
        circleLayer.lineJoin = kCALineJoinRound;
        circleLayer.contentsScale = [UIScreen mainScreen].scale;
        [self.layer addSublayer:circleLayer];
        
        UILabel *numLabel = [[UILabel alloc] init];
        numLabel.textColor = kSetHEXColor(0x428eda);
        numLabel.textAlignment = NSTextAlignmentRight;
        numLabel.font = [UIFont systemFontOfSize:10];
        numLabel.text = [NSString stringWithFormat:@"%@",self.dataAry[i - 1]];
        [self addSubview:numLabel];
        [numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(point.CGPointValue.x - 9);
            make.top.mas_equalTo(point.CGPointValue.y - 18);
        }];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
