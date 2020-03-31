//
//  ZHLineChartView.m
//  ZHLineChart
//
//  Created by 周亚楠 on 2020/3/1.
//  Copyright © 2020 Zhou. All rights reserved.
//

#import "ZHLineChartView.h"
#import "UIBezierPath+ThroughPointsBezier.h"
#import "ZHLineChartCalculator.h"
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
        self.dataTextWidth = 20;
        self.leftTextWidth = 25;
        self.scaleOffset = 0.f;
        self.bottomOffset = 20.f;
        self.lineToLeftOffset = 5;
        self.angle = M_PI * 1.75;
        self.textFontSize = 10;
        self.edge = UIEdgeInsetsMake(25, 5, 40, 15);
        
        self.circleStrokeColor = KLineColor;
        self.circleFillColor = [UIColor whiteColor];
        self.textColor = KTextColor;
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
- (void)setIsShowHeadTail:(BOOL)isShowHeadTail{
    _isShowHeadTail = isShowHeadTail;
}

//对最大值最小值进行向上向下取整
- (void)setMax:(NSNumber *)max{
    CGFloat maxNum = [max doubleValue];
    int count = 0;
    while (maxNum>10) {
        count  ++ ;
        maxNum /= 10.0;
    }
    if ([ZHLineChartCalculator isPureFloat:[NSString stringWithFormat:@"%lf",maxNum]]) {
        maxNum = ceil(maxNum);
    }
    _max = [NSNumber numberWithInteger:maxNum * pow(10,count)];
}

- (void)setMin:(NSNumber *)min{
    CGFloat minNum = [min doubleValue];
    if(minNum ==0){
        _min = min;
    }else{
        int count = 0;
        while (minNum>10) {
            count  ++ ;
            minNum /= 10.0;
        }
        if ([ZHLineChartCalculator isPureFloat:[NSString stringWithFormat:@"%lf",minNum]]) {
            minNum = floor(minNum);
        }else{
            minNum --;
        }
        _min = [NSNumber numberWithInteger:minNum * pow(10,count)];
    }
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
    
    NSMutableArray * nameArr = [NSMutableArray new];
    for (int i = 0; i < self.splitCount + 1; i ++) {
        NSInteger leftNum = self.max.integerValue - numSpace * i;
        NSString * yVal = [NSString stringWithFormat:@"%ld",leftNum];
        yVal = [self getYText:yVal];
        [nameArr addObject:yVal];
        CGFloat w = [self getTextWidth:yVal fontSize:self.textFontSize];
        if (w > self.leftTextWidth) {
            self.leftTextWidth = w;
        }
    }
    for (int i = 0; i < self.splitCount + 1; i ++) {
        //创建纵轴文本
        UILabel *leftLabel = [[UILabel alloc] init];
        leftLabel.frame = CGRectMake(self.edge.left, self.leftTextWidth + (spaceY + labelHeight) * i, self.leftTextWidth, labelHeight);
        leftLabel.textColor = self.textColor;
        leftLabel.textAlignment = NSTextAlignmentRight;
        leftLabel.font = [UIFont systemFontOfSize:self.textFontSize];
        
        leftLabel.text = nameArr[i];
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
            CGFloat bottomLabelWidth = spaceX + 20;
            CGFloat ratio = (maxMidY - minMidY) / (self.max.floatValue - self.min.floatValue);
            for (int k = 0; k < self.horizontalDataArr.count; k ++) {
                CGFloat midX = minX + (spaceX * k) + (self.toCenter ? spaceX / 2 : 0);
                if (self.isShowHeadTail) {//增加只显示头尾的判断控制
                    if (k == 0 || k == self.horizontalDataArr.count - 1) {
                        UILabel *bottomLabel = [[UILabel alloc] init];
                        bottomLabel.frame = CGRectMake(midX - bottomLabelWidth / 2, maxMidY + self.bottomOffset, bottomLabelWidth, labelHeight);
                        bottomLabel.textColor = self.textColor;
                        bottomLabel.textAlignment = NSTextAlignmentCenter;
                        bottomLabel.font = [UIFont systemFontOfSize:self.textFontSize];
                        bottomLabel.text = self.horizontalDataArr[k];
                        [self addSubview:bottomLabel];
                        //旋转
                        bottomLabel.transform = CGAffineTransformMakeRotation(self.angle);
                    }
                }else{
                    UILabel *bottomLabel = [[UILabel alloc] init];
                    bottomLabel.frame = CGRectMake(midX - bottomLabelWidth / 2, maxMidY + self.bottomOffset, bottomLabelWidth, labelHeight);
                    bottomLabel.textColor = self.textColor;
                    bottomLabel.textAlignment = NSTextAlignmentCenter;
                    bottomLabel.font = [UIFont systemFontOfSize:self.textFontSize];
                    bottomLabel.text = self.horizontalDataArr[k];
                    [self addSubview:bottomLabel];
                    //旋转
                    bottomLabel.transform = CGAffineTransformMakeRotation(self.angle);
                }
                
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
    
    
    //    CABasicAnimation *maxPathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    //    maxPathAnimation.duration = 12;
    //    maxPathAnimation.repeatCount = 1;
    //    maxPathAnimation.removedOnCompletion = YES;
    //    maxPathAnimation.fromValue = @0.f;
    //    maxPathAnimation.toValue = @1;
    //    [maxLineLayer addAnimation:maxPathAnimation forKey:@"strokeEnd"];
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
        CGFloat val = [self.lineDataAry[i] floatValue];
        if (self.showLineData && val > 0) {
            NSInteger index = i;
            if (self.toCenter && self.supplement) {
                index = i - 1;
            }
            NSString * val = [NSString stringWithFormat:@"%@",self.lineDataAry[index]];
            CGFloat tw = [self getTextWidth:val fontSize:self.textFontSize];
            if (tw > self.dataTextWidth) {//增加y轴文本宽度自适应
                self.dataTextWidth = tw;
            }
            CGFloat xPoint = point.CGPointValue.x - self.dataTextWidth / 2;
            if (xPoint + self.dataTextWidth> [UIScreen mainScreen].bounds.size.width) {
                //增加超出屏幕文本偏移
                CGFloat delta = xPoint + self.dataTextWidth - [UIScreen mainScreen].bounds.size.width;
                xPoint -= delta;
            }
            UILabel *numLabel = [[UILabel alloc] init];
            numLabel.frame = CGRectMake(xPoint, point.CGPointValue.y - 18, self.dataTextWidth, self.textFontSize);
            numLabel.textColor = self.textColor;
            numLabel.textAlignment = NSTextAlignmentRight;
            numLabel.font = [UIFont systemFontOfSize:self.textFontSize];
            numLabel.text = val;
            [self addSubview:numLabel];
        }
    }
}
-(CGFloat)getTextWidth:(NSString*)str fontSize:(CGFloat)fontSize{
    NSDictionary *attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:fontSize]};
    return [str boundingRectWithSize:CGSizeMake(300, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size.width;
}
-(NSString*)getYText:(NSString *)str{//增加大数处理
    NSInteger val = [str integerValue];
    if (val<10000) {
        return [NSString stringWithFormat:@"%ld",val];
    }else if (10000 <= val && val < 1000000){
        return [NSString stringWithFormat:@"%ldK",val/1000];
    }else{
        return [NSString stringWithFormat:@"%ldM",val/1000000];
    }
}
@end
