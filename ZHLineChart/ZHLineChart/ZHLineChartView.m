//
//  ZHLineChartView.m
//  ZHLineChart
//
//  Created by 周亚楠 on 2020/3/1.
//  Copyright © 2020 Zhou. All rights reserved.
//

#import "ZHLineChartView.h"
#import <objc/runtime.h>

@interface ZHLineChartView ()
@property (nonatomic, strong) NSMutableArray *pointArr;
@end

@implementation ZHLineChartView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.circleRadius = 3.f;
        self.lineWidth = 1.5f;
        self.horizontalLineWidth = 0.5f;
        self.horizontalBottomLineWidth = 1.f;
        self.scaleOffset = 0.f;
        self.bottomOffset = 20.f;
        self.lineToLeftOffset = 5;
        self.angle = M_PI * 1.75;
        self.textFontSize = 10;
        self.edge = UIEdgeInsetsMake(25, 5, 40, 15);
        
        self.circleStrokeColor = KLineColor;
        self.circleFillColor = [UIColor whiteColor];
        self.textColor = KTextColor;
        self.dataTextColor = KLineColor;
        self.lineColor = KLineColor;
        self.horizontalLineColor = KHorizontalLineColor;
        self.horizontalBottomLineColor = KHorizontalBottomLineColor;
        
        self.addCurve = YES;
        self.toCenter = YES;
        self.supplement = NO;
        self.showLineData = YES;
        self.showColorGradient = YES;
        self.colorArr = [NSArray arrayWithObjects:(id)[[self.lineColor colorWithAlphaComponent:0.4] CGColor],(id)[[[UIColor whiteColor] colorWithAlphaComponent:0.1] CGColor], nil];
        
    }
    return self;
}

/**
 * 渲染折线图
 */
- (void)drawLineChart
{
    NSMutableArray *pointArr = [NSMutableArray array];
    CGFloat labelHeight = self.textFontSize;
    NSInteger numSpace = (self.max.integerValue - self.min.integerValue) / self.splitCount;
    CGFloat spaceY = (self.frame.size.height - self.edge.top - self.edge.bottom - ((self.splitCount + 1) * labelHeight)) / self.splitCount;
    CGFloat minMidY = 0.f;
    CGFloat maxMidY;
    if (self.leftTextWidth <= 0) {
        self.leftTextWidth = [self getTextWidth:[NSString stringWithFormat:@"%ld",self.max.integerValue] fontSize:self.textFontSize];
    }
    
    for (int i = 0; i < self.splitCount + 1; i ++) {
        //创建纵轴文本
        UILabel *leftLabel = [self createLabelWithTextColor:self.textColor textAlignment:NSTextAlignmentRight];
        leftLabel.frame = CGRectMake(self.edge.left, self.leftTextWidth + (spaceY + labelHeight) * i, self.leftTextWidth, labelHeight);
        NSInteger leftNum = self.max.integerValue - numSpace * i;
        if (i == self.splitCount) {
            leftNum = self.min.integerValue;
        }
        leftLabel.text = [NSString stringWithFormat:@"%ld",leftNum];
        [self addSubview:leftLabel];
        
        if (!i) {
            minMidY = CGRectGetMidY(leftLabel.frame);
        }
        
        UIBezierPath *linePath = [UIBezierPath bezierPath];
        CGFloat minX = CGRectGetMaxX(leftLabel.frame) + self.lineToLeftOffset;
        CGFloat maxX = CGRectGetMaxX(self.frame) - self.edge.right;
        [linePath moveToPoint:CGPointMake(minX, CGRectGetMidY(leftLabel.frame))];
        [linePath addLineToPoint:CGPointMake(maxX, CGRectGetMidY(leftLabel.frame))];
        
        CAShapeLayer *hLineLayer = [CAShapeLayer layer];
        if (i == self.splitCount) {
            hLineLayer.strokeColor = self.horizontalBottomLineColor.CGColor;
            hLineLayer.lineWidth = self.horizontalBottomLineWidth;
            
            CGFloat spaceX = (maxX - minX) / (self.horizontalDataArr.count - (self.toCenter ? 0 : 1));
            maxMidY = CGRectGetMidY(leftLabel.frame);
            //创建刻度
            UIBezierPath *bezierPath = [UIBezierPath bezierPath];
            NSInteger count = self.horizontalDataArr.count;
            if (self.toCenter) {
                count = self.horizontalDataArr.count + 1;
            }
            for (int j = 0 ; j < count; j ++) {
                [bezierPath moveToPoint:CGPointMake(minX + spaceX * j, maxMidY + self.scaleOffset)];
                [bezierPath addLineToPoint:CGPointMake(minX + spaceX * j, maxMidY + 2 + self.scaleOffset)];
                [linePath appendPath:bezierPath];
            }
            
            //创建横轴文本
            CGFloat ratio = (maxMidY - minMidY) / (self.max.floatValue - self.min.floatValue);
            for (int k = 0; k < self.horizontalDataArr.count; k ++) {
                CGFloat midX = minX + (spaceX * k) + (self.toCenter ? spaceX / 2 : 0);
                
                //构造关键点
                NSNumber *tempNum = self.lineDataAry[k];
                CGFloat y = maxMidY - (tempNum.integerValue - self.min.floatValue) * ratio;
                if (self.toCenter && self.supplement && !k) {
                    NSValue *value = [NSValue valueWithCGPoint:CGPointMake(minX, y)];
                    [pointArr addObject:value];
                }
                NSValue *value = [NSValue valueWithCGPoint:CGPointMake(midX, y)];
                [pointArr addObject:value];
                if (self.toCenter && self.supplement && k == self.lineDataAry.count - 1) {
                    NSValue *value = [NSValue valueWithCGPoint:CGPointMake(maxX, y)];
                    [pointArr addObject:value];
                }
                
                //底部文本只显示首尾
                if (self.isShowHeadTail && (k > 0 && k < self.horizontalDataArr.count - 1)) {
                    continue;
                }
                if (![self.horizontalDataArr[k] length]) {
                    continue;
                }
                CGFloat bottomLabelWidth = [self getTextWidth:self.horizontalDataArr[k] fontSize:self.textFontSize];
                UILabel *bottomLabel = [self createLabelWithTextColor:self.textColor textAlignment:NSTextAlignmentCenter];
                bottomLabel.frame = CGRectMake(midX - bottomLabelWidth / 2, maxMidY + self.bottomOffset, bottomLabelWidth, labelHeight);
                bottomLabel.text = self.horizontalDataArr[k];
                [self addSubview:bottomLabel];
                //旋转
                bottomLabel.transform = CGAffineTransformMakeRotation(self.angle);
                
            }
            //绘制折线
            [self drawLineLayerWithPointArr:pointArr maxMidY:maxMidY];
            
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

/**
 * 绘制折线及渐变
 */
- (void)drawLineLayerWithPointArr:(NSMutableArray *)pointArr maxMidY:(CGFloat)maxMidY
{
    CGPoint startPoint = [[pointArr firstObject] CGPointValue];
    CGPoint endPoint = [[pointArr lastObject] CGPointValue];
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:startPoint];
    if (self.addCurve) {
        [linePath addBezierThroughPoints:pointArr];
    } else {
        [linePath addNormalBezierThroughPoints:pointArr];
    }
    
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.path = linePath.CGPath;
    lineLayer.strokeColor = self.lineColor.CGColor;
    lineLayer.fillColor = [UIColor clearColor].CGColor;
    lineLayer.lineWidth = self.lineWidth;
    lineLayer.lineCap = kCALineCapRound;
    lineLayer.lineJoin = kCALineJoinRound;
    lineLayer.contentsScale = [UIScreen mainScreen].scale;
    [self.layer addSublayer:lineLayer];
    
    //颜色渐变
    if (self.showColorGradient) {
        UIBezierPath *colorPath = [UIBezierPath bezierPath];
        colorPath.lineWidth = 1.f;
        [colorPath moveToPoint:startPoint];
        if (self.addCurve) {
            [colorPath addBezierThroughPoints:pointArr];
        } else {
            [colorPath addNormalBezierThroughPoints:pointArr];
        }
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
    }
    
    //绘制关键折线及关键点
    [self buildDotWithPointsArr:pointArr];
}

/**
 * 绘制关键点及关键点数据展示
 */
- (void)buildDotWithPointsArr:(NSMutableArray *)pointsArr
{
    for (int i = 0; i < pointsArr.count; i ++) {
        if (self.toCenter && self.supplement && (!i || i == pointsArr.count - 1)) {
            continue;
        }
        NSValue *point = pointsArr[i];
        
        //关键点绘制
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
        
        //关键点数据
        if (self.showLineData) {
            NSInteger index = i;
            if (self.toCenter && self.supplement) {
                index = i - 1;
            }
            UILabel *numLabel = [self createLabelWithTextColor:self.dataTextColor textAlignment:NSTextAlignmentCenter];
            numLabel.text = [NSString stringWithFormat:@"%@",self.lineDataAry[index]];
            if (self.dataTextWidth <= 0) {
                self.dataTextWidth = [self getTextWidth:numLabel.text fontSize:self.textFontSize];
            }
            numLabel.frame = CGRectMake(point.CGPointValue.x - self.dataTextWidth / 2, point.CGPointValue.y - 18, self.dataTextWidth, self.textFontSize);
            [self addSubview:numLabel];
        }
    }
}

/**
 * label创建
 */
- (UILabel *)createLabelWithTextColor:(UIColor *)textColor textAlignment:(NSTextAlignment)textAlignment
{
    UILabel *label = [[UILabel alloc] init];
    label.textColor = textColor;
    label.textAlignment = textAlignment;
    label.font = [UIFont systemFontOfSize:self.textFontSize];
    return label;
}

/**
 * 文本宽度计算(by vitasapple)
 */
- (CGFloat)getTextWidth:(NSString*)str fontSize:(CGFloat)fontSize{
    NSDictionary *attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:fontSize]};
    return [str boundingRectWithSize:CGSizeMake(300, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size.width + 5;
}

@end


/**
 UIBezierPath+ThroughPointsBezier
 */
@implementation UIBezierPath (ThroughPointsBezier)

- (void)setContractionFactor:(CGFloat)contractionFactor
{
    objc_setAssociatedObject(self, @selector(contractionFactor), @(contractionFactor), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)contractionFactor
{
    id contractionFactorAssociatedObject = objc_getAssociatedObject(self, @selector(contractionFactor));
    if (!contractionFactorAssociatedObject) {
        return 0.7;
    }
    return [contractionFactorAssociatedObject floatValue];
}

/**
 * 正常折线绘制
 * 必须将CGPoint结构体包装成NSValue对象并且至少一个点来画折线。
 */
- (void)addNormalBezierThroughPoints:(NSArray *)pointArray
{
    for (int i = 0; i < pointArray.count; i++) {
        
        NSValue * pointIValue = pointArray[i];
        CGPoint pointI = [pointIValue CGPointValue];
        [self addLineToPoint:pointI];
    }
}

- (void)addBezierThroughPoints:(NSArray *)pointArray
{
    NSAssert(pointArray.count > 0, @"You must give at least 1 point for drawing the curve.");
    
    if (pointArray.count < 3) {
        switch (pointArray.count) {
            case 1:
            {
                NSValue * point0Value = pointArray[0];
                CGPoint point0 = [point0Value CGPointValue];
                [self addLineToPoint:point0];
            }
                break;
            case 2:
            {
                NSValue * point0Value = pointArray[0];
                CGPoint point0 = [point0Value CGPointValue];
                NSValue * point1Value = pointArray[1];
                CGPoint point1 = [point1Value CGPointValue];
                [self addQuadCurveToPoint:point1 controlPoint:ControlPointForTheBezierCanThrough3Point(self.currentPoint, point0, point1)];
            }
                break;
            default:
                break;
        }
    }
    
    CGPoint previousPoint = CGPointZero;
    
    CGPoint previousCenterPoint = CGPointZero;
    CGPoint centerPoint = CGPointZero;
    CGFloat centerPointDistance = 0;
    
    CGFloat obliqueAngle = 0;
    
    CGPoint previousControlPoint1 = CGPointZero;
    CGPoint previousControlPoint2 = CGPointZero;
    CGPoint controlPoint1 = CGPointZero;

    previousPoint = self.currentPoint;
    
    for (int i = 0; i < pointArray.count; i++) {
        
        NSValue * pointIValue = pointArray[i];
        CGPoint pointI = [pointIValue CGPointValue];
        
        if (i > 0) {
            
            previousCenterPoint = CenterPointOf(self.currentPoint, previousPoint);
            centerPoint = CenterPointOf(previousPoint, pointI);
            
            centerPointDistance = DistanceBetweenPoint(previousCenterPoint, centerPoint);
            
            obliqueAngle = ObliqueAngleOfStraightThrough(centerPoint, previousCenterPoint);
            
            previousControlPoint2 = CGPointMake(previousPoint.x - 0.5 * self.contractionFactor * centerPointDistance * cos(obliqueAngle), previousPoint.y - 0.5 * self.contractionFactor * centerPointDistance * sin(obliqueAngle));
            controlPoint1 = CGPointMake(previousPoint.x + 0.5 * self.contractionFactor * centerPointDistance * cos(obliqueAngle), previousPoint.y + 0.5 * self.contractionFactor * centerPointDistance * sin(obliqueAngle));
        }
        
        if (i == 1) {
            
            [self addQuadCurveToPoint:previousPoint controlPoint:previousControlPoint2];
        }
        else if (i > 1 && i < pointArray.count - 1) {
        
            [self addCurveToPoint:previousPoint controlPoint1:previousControlPoint1 controlPoint2:previousControlPoint2];
        }
        else if (i == pointArray.count - 1) {
        
            [self addCurveToPoint:previousPoint controlPoint1:previousControlPoint1 controlPoint2:previousControlPoint2];
            [self addQuadCurveToPoint:pointI controlPoint:controlPoint1];
        }
        else {
        
        }
        
        previousControlPoint1 = controlPoint1;
        previousPoint = pointI;
    }
}

CGFloat ObliqueAngleOfStraightThrough(CGPoint point1, CGPoint point2)   //  [-π/2, 3π/2)
{
    CGFloat obliqueRatio = 0;
    CGFloat obliqueAngle = 0;
    
    if (point1.x > point2.x) {
    
        obliqueRatio = (point2.y - point1.y) / (point2.x - point1.x);
        obliqueAngle = atan(obliqueRatio);
    }
    else if (point1.x < point2.x) {
    
        obliqueRatio = (point2.y - point1.y) / (point2.x - point1.x);
        obliqueAngle = M_PI + atan(obliqueRatio);
    }
    else if (point2.y - point1.y >= 0) {
    
        obliqueAngle = M_PI/2;
    }
    else {
        obliqueAngle = -M_PI/2;
    }
    
    return obliqueAngle;
}

CGPoint ControlPointForTheBezierCanThrough3Point(CGPoint point1, CGPoint point2, CGPoint point3)
{
    return CGPointMake(2 * point2.x - (point1.x + point3.x) / 2, 2 * point2.y - (point1.y + point3.y) / 2);
}

CGFloat DistanceBetweenPoint(CGPoint point1, CGPoint point2)
{
    return sqrt((point1.x - point2.x) * (point1.x - point2.x) + (point1.y - point2.y) * (point1.y - point2.y));
}

CGPoint CenterPointOf(CGPoint point1, CGPoint point2)
{
    return CGPointMake((point1.x + point2.x) / 2, (point1.y + point2.y) / 2);
}

@end
