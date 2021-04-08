# ZHLineChart
ZHLineChart,一款轻便可自定义的折线图。支持风格、内容、颜色、文本、排版等自定义设置，轻便简洁！
## 注意事项
由于默认开启了曲线平滑，所以当底部数值与最小数值同样大小时会出现越出底部的情况，如果想避免这种情况的话可以考虑以下两种任一方式：
1、将属性addCurve（贝赛尔曲线绘制，增加曲度控制）字段置为NO；  
2、将lineView.min的值设置为小于关键点中的最小值，保证最低点与底部有距离，以此避免出现越过底部的现象。
## 详细文章
更多了解可以查看：[简书文章](https://www.jianshu.com/p/ceda837000f5)

## 预览
![ZHLineChart](/image/line1.png)
![ZHLineChart](/image/line2.png)
![ZHLineChart](/image/line3.png)
![ZHLineChart](/image/line4.png)
![ZHLineChart](/image/line5.png)
![ZHLineChart](/image/line6.png)
## 使用示例
```
开始绘制
[self.lineView drawLineChart];
```
```
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
        _lineView.edge = UIEdgeInsetsMake(25, 15, 50, 25);
        _lineView.backgroundColor = [UIColor whiteColor];
        [self.scrollView addSubview:_lineView];
    }
    return _lineView;
}
```
## 意见建议
如果感觉此项目对你有帮助，欢迎Star！如果使用过程中遇到问题或者有更好的建议,欢迎在Issues提出！
## 更新记录
* 2020-04-01  文件合并，部分细节调整,增加底部横轴文本只显示首尾控制，文本宽度计算完善（感谢[@vitasapple](https://github.com/vitasapple)支持）
