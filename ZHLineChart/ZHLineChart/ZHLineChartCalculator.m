//
//  ZHLineChartCalculator.m
//  PearRich
//
//  Created by Jinniu on 2020/3/31.
//  Copyright © 2020 谢黎鹏. All rights reserved.
//

#import "ZHLineChartCalculator.h"

@implementation ZHLineChartCalculator
+ (BOOL)isPureFloat:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    float val;
    return[scan scanFloat:&val] && [scan isAtEnd];
}
@end
