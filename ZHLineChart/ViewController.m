//
//  ViewController.m
//  ZHLineChart
//
//  Created by 周亚楠 on 2020/2/28.
//  Copyright © 2020 Zhou. All rights reserved.
//

#import "ViewController.h"
#import "ZHLineChartView.h"

@interface ViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) ZHLineChartView *lineView;
@property (nonatomic, strong) ZHLineChartView *lineView1;
@property (nonatomic, strong) ZHLineChartView *lineView2;
@property (nonatomic, strong) ZHLineChartView *lineView3;
@property (nonatomic, strong) ZHLineChartView *lineView4;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"ZHLineChart";
    [self.lineView drawLineChart];
    [self.lineView1 drawLineChart];
    [self.lineView2 drawLineChart];
    [self.lineView3 drawLineChart];
    [self.lineView4 drawLineChart];
}


- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _scrollView.backgroundColor = [UIColor lightGrayColor];
        _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), 1100);
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

- (ZHLineChartView *)lineView
{
    if (!_lineView) {
        _lineView = [[ZHLineChartView alloc] initWithFrame:CGRectMake(0, 10, CGRectGetWidth(self.view.frame), 200)];
        _lineView.max = @600;
        _lineView.min = @300;
        _lineView.horizontalDataArr = @[@"2020-02", @"2020-03", @"2020-04", @"2020-05", @"2020-06", @"2020-07"];
        _lineView.lineDataAry = @[@502, @523, @482, @455, @473, @546];
        _lineView.splitCount = 3;
        _lineView.toCenter = NO;
//        _lineView.angle = 0;
        _lineView.edge = UIEdgeInsetsMake(25, 15, 50, 25);
        _lineView.backgroundColor = [UIColor whiteColor];
        [self.scrollView addSubview:_lineView];
    }
    return _lineView;
}

- (ZHLineChartView *)lineView1
{
    if (!_lineView1) {
        _lineView1 = [[ZHLineChartView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.lineView.frame) + 10, CGRectGetWidth(self.view.frame), 200)];
        _lineView1.max = @600;
        _lineView1.min = @300;
        _lineView1.horizontalDataArr = @[@"2020-02", @"2020-03", @"2020-04", @"2020-05", @"2020-06", @"2020-07"];
        _lineView1.lineDataAry = @[@502, @523, @482, @455, @473, @546];
        _lineView1.splitCount = 3;
        _lineView1.supplement = YES;
//        _lineView1.angle = 0;
        _lineView1.bottomOffset = 15;
        _lineView1.backgroundColor = [UIColor whiteColor];
        [self.scrollView addSubview:_lineView1];
    }
    return _lineView1;
}

- (ZHLineChartView *)lineView2
{
    if (!_lineView2) {
        _lineView2 = [[ZHLineChartView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.lineView1.frame) + 10, CGRectGetWidth(self.view.frame), 200)];
        _lineView2.max = @1000;
        _lineView2.min = @400;
        _lineView2.horizontalDataArr = @[@"2020-02", @"2020-03", @"2020-04", @"2020-05", @"2020-06", @"2020-07", @"2020-08"];
        _lineView2.lineDataAry = @[@502, @723, @682, @955, @473, @546, @846];
        _lineView2.splitCount = 4;
        _lineView2.angle = 0;
        _lineView2.bottomOffset = 10;
        _lineView2.addCurve = NO;
        _lineView2.edge = UIEdgeInsetsMake(25, 15, 30, 25);
//        _lineView2.textColor = [UIColor magentaColor];
        _lineView2.lineColor = [UIColor redColor];
        _lineView2.colorArr = [NSArray arrayWithObjects:(id)[[[UIColor redColor] colorWithAlphaComponent:0.4] CGColor],(id)[[[UIColor whiteColor] colorWithAlphaComponent:0.1] CGColor], nil];
        _lineView2.backgroundColor = [UIColor whiteColor];
        [self.scrollView addSubview:_lineView2];
    }
    return _lineView2;
}

- (ZHLineChartView *)lineView3
{
    if (!_lineView3) {
        _lineView3 = [[ZHLineChartView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.lineView2.frame) + 10, CGRectGetWidth(self.view.frame), 200)];
        _lineView3.max = @700;
        _lineView3.min = @300;
        _lineView3.horizontalDataArr = @[@"2020-02", @"2020-03", @"2020-04", @"2020-05", @"2020-06", @"2020-07"];
        _lineView3.lineDataAry = @[@502, @623, @482, @355, @473, @546];
        _lineView3.splitCount = 2;
        _lineView3.textColor = [UIColor orangeColor];
//        _lineView3.showColorGradient = NO;
        _lineView3.circleStrokeColor = [UIColor redColor];
        _lineView3.horizontalLineColor = [UIColor redColor];
        _lineView3.horizontalBottomLineColor = [UIColor redColor];
        _lineView3.colorArr = [NSArray arrayWithObjects:(id)[[[UIColor redColor] colorWithAlphaComponent:0.4] CGColor],(id)[[[UIColor whiteColor] colorWithAlphaComponent:0.1] CGColor], nil];
//        _lineView3.toCenter = NO;
//        _lineView.angle = 0;
//        _lineView3.edge = UIEdgeInsetsMake(25, 15, 50, 25);
        _lineView3.backgroundColor = [UIColor whiteColor];
        [self.scrollView addSubview:_lineView3];
    }
    return _lineView3;
}

- (ZHLineChartView *)lineView4
{
    if (!_lineView4) {
        _lineView4 = [[ZHLineChartView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.lineView3.frame) + 10, CGRectGetWidth(self.view.frame), 200)];
        _lineView4.max = @700;
        _lineView4.min = @300;
        _lineView4.horizontalDataArr = @[@"2020-02", @"2020-03", @"2020-04", @"2020-05", @"2020-06", @"2020-07"];
        _lineView4.lineDataAry = @[@502, @623, @482, @555, @473, @546];
        _lineView4.splitCount = 2;
        _lineView4.showColorGradient = NO;
        _lineView4.circleStrokeColor = [UIColor orangeColor];
        _lineView4.horizontalBottomLineColor = [UIColor orangeColor];
        _lineView4.edge = UIEdgeInsetsMake(25, 5, 50, 15);
        _lineView4.backgroundColor = [UIColor whiteColor];
        [self.scrollView addSubview:_lineView4];
    }
    return _lineView4;
}

@end
