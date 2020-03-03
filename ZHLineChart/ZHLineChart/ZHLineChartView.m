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
        self.circleRadius = 3.f;
        self.lineWidth = 1.5f;
        self.horizontalLineWidth = 0.5f;
        self.horizontalBottomLineWidth = 1.f;
        self.scaleOffset = 0.f;
        self.bottomOffset = 20.f;
        self.angle = M_PI * 1.75;
        
        self.circleStrokeColor = KLineColor;
        self.circleFillColor = [UIColor whiteColor];
        self.textColor = KTextColor;
        self.lineColor = KLineColor;
        self.horizontalLineColor = KHorizontalLineColor;
        self.horizontalBottomLineColor = KHorizontalBottomLineColor;
        
        self.toCenter = YES;
        self.supplement = NO;
        self.showLineData = YES;
        self.showColorGradient = YES;
        self.colorArr = [NSArray arrayWithObjects:(id)[[KLineColor colorWithAlphaComponent:0.4] CGColor],(id)[[[UIColor whiteColor] colorWithAlphaComponent:0.1] CGColor], nil];
        
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
    CGFloat minMidY = 0.f;
    CGFloat maxMidY;
    
    for (int i = 0; i < self.splitCount + 1; i ++) {
        //创建纵轴文本
        UILabel *leftLabel = [[UILabel alloc] init];
        leftLabel.frame = CGRectMake(15, 25 + (spaceY + labelHeight) * i, 25, labelHeight);
        leftLabel.textColor = self.textColor;
        leftLabel.textAlignment = NSTextAlignmentRight;
        leftLabel.font = [UIFont systemFontOfSize:self.textFontSize];
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
        
        CAShapeLayer *hLineLayer = [CAShapeLayer layer];
        if (i == self.splitCount) {
            hLineLayer.strokeColor = self.horizontalBottomLineColor.CGColor;
            hLineLayer.lineWidth = self.horizontalBottomLineWidth;
            CGFloat spaceX = (maxX - minX) / (self.horizontalDataArr.count);
            maxMidY = CGRectGetMidY(leftLabel.frame);
            //创建刻度
            UIBezierPath *bezierPath = [UIBezierPath bezierPath];
            for (int j = 0 ; j < self.horizontalDataArr.count + 1; j ++) {
                [bezierPath moveToPoint:CGPointMake(minX + spaceX * j, maxMidY)];
                [bezierPath addLineToPoint:CGPointMake(minX + spaceX * j, maxMidY + 2)];
                [linePath appendPath:bezierPath];
            }
            //创建横轴文本
            CGFloat bottomLabelWidth = spaceX + 20;
            CGFloat ratio = (maxMidY - minMidY) / (self.max.floatValue - self.min.floatValue);
            for (int k = 0; k < self.horizontalDataArr.count; k ++) {
                CGFloat midX = minX + (spaceX * k) + spaceX / 2;
                UILabel *bottomLabel = [[UILabel alloc] init];
                bottomLabel.frame = CGRectMake(midX - bottomLabelWidth / 2, maxMidY + 20, bottomLabelWidth, labelHeight);
                bottomLabel.textColor = self.textColor;
                bottomLabel.textAlignment = NSTextAlignmentCenter;
                bottomLabel.font = [UIFont systemFontOfSize:self.textFontSize];
                bottomLabel.text = self.horizontalDataArr[k];
                [self addSubview:bottomLabel];
                //旋转
                bottomLabel.transform = CGAffineTransformMakeRotation(self.angle);
                
                //构造关键点
                NSNumber *tempNum = self.lineDataAry[k];
                CGFloat y = maxMidY - (tempNum.integerValue - self.min.floatValue) * ratio;
                if (!k) {
                    NSValue *value = [NSValue valueWithCGPoint:CGPointMake(minX, y)];
                    [pointArr addObject:value];
                }
                NSValue *value = [NSValue valueWithCGPoint:CGPointMake(midX, y)];
                [pointArr addObject:value];
                if (k == self.lineDataAry.count - 1) {
                    NSValue *value = [NSValue valueWithCGPoint:CGPointMake(maxX, y)];
                    [pointArr addObject:value];
                }
            }
            //绘制折线
            [self drawLineLayerWithPointArr:pointArr layerFrom:CGRectMake(minX, minMidY, maxX - minX, maxMidY- minMidY) maxMidY:maxMidY];
            
        } else {
            hLineLayer.strokeColor = self.horizontalLineColor.CGColor;
            hLineLayer.lineWidth = self.horizontalLineWidth;
        }
        hLineLayer.path = linePath.CGPath;
        hLineLayer.fillColor = [UIColor clearColor].CGColor;
        hLineLayer.lineCap = kCALineCapRound;
        hLineLayer.lineJoin = kCALineJoinRound;
        hLineLayer.contentsScale = [UIScreen mainScreen].scale;
        [self.layer addSublayer:hLineLayer];
        
    }
}

- (void)drawLineLayerWithPointArr:(NSMutableArray *)pointArr layerFrom:(CGRect)layerFrom maxMidY:(CGFloat)maxMidY
{
    CGPoint startPoint = [[pointArr firstObject] CGPointValue];
    CGPoint endPoint = [[pointArr lastObject] CGPointValue];
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:startPoint];
    [linePath addBezierThroughPoints:pointArr];
    
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.path = linePath.CGPath;
    lineLayer.strokeColor = self.lineColor.CGColor;
    lineLayer.fillColor = [UIColor clearColor].CGColor;
    lineLayer.lineWidth = self.lineWidth;
    lineLayer.lineCap = kCALineCapRound;
    lineLayer.lineJoin = kCALineJoinRound;
    lineLayer.contentsScale = [UIScreen mainScreen].scale;
    [self.layer addSublayer:lineLayer];
    
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
    colorLayer.colors = self.colorArr;
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
        
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(point.CGPointValue.x, point.CGPointValue.y) radius:self.circleRadius startAngle:0 endAngle:M_PI * 2 clockwise:NO];
        CAShapeLayer *circleLayer = [CAShapeLayer layer];
        circleLayer.path = path.CGPath;
        circleLayer.strokeColor = self.circleStrokeColor.CGColor;
        circleLayer.fillColor = self.circleFillColor.CGColor;
        circleLayer.lineWidth = self.lineWidth;
        circleLayer.lineCap = kCALineCapRound;
        circleLayer.lineJoin = kCALineJoinRound;
        circleLayer.contentsScale = [UIScreen mainScreen].scale;
        [self.layer addSublayer:circleLayer];
        
        UILabel *numLabel = [[UILabel alloc] init];
        numLabel.textColor = self.textColor;
        numLabel.textAlignment = NSTextAlignmentRight;
        numLabel.font = [UIFont systemFontOfSize:self.textFontSize];
        numLabel.text = [NSString stringWithFormat:@"%@",self.lineDataAry[i - 1]];
        [self addSubview:numLabel];
//        [numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(point.CGPointValue.x - 9);
//            make.top.mas_equalTo(point.CGPointValue.y - 18);
//        }];
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
