/*
 Copyright (C) 2012, pyanfield  - pyanfield@gmail.com
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 of the Software, and to permit persons to whom the Software is furnished to do
 so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

#import "WSScatterChartView.h"
#import "WSScatterLayer.h"

@implementation WSScatterChartView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.title = @"WSScatterChart";
    }
    return self;
}

- (void)drawChart:(NSArray *)arr withColor:(NSDictionary *)dict
{
    [super drawChart:arr withColor:dict];
}

- (void)createChartLayer
{
    NSArray *legendNames = [colorDict allKeys];
    for (int j=0; j<[legendNames count]; j++) {
        NSString *legendName = [legendNames objectAtIndex:j];
        NSMutableArray *points = [[NSMutableArray alloc] init];
        WSScatterLayer *layer = [[WSScatterLayer alloc] init];
        layer.color = [colorDict valueForKey:legendName];
        for (int i=0; i<[datas count]; i++) {
            NSDictionary *data = [datas objectAtIndex:i];
            WSChartObject *chartObj = [data valueForKey:legendName];
            CGFloat yValue = zeroPoint.y - ([chartObj.yValue floatValue] - correctionY) * propotionY;
            CGFloat xValue = zeroPoint.x + ([chartObj.xValue floatValue] - correctionX) * propotionX;
            CGPoint point = CGPointMake(xValue, yValue);
            [points addObject:[NSValue valueWithCGPoint:point]];
        }
        layer.points = [points copy];
        layer.frame = self.bounds;
        [layer setNeedsDisplay];
        [chartLayer addSublayer:layer];
    }
}

- (void)createCoordinateLayer
{
    xyAxesLayer.yMarkTitles = yMarkTitles;
    xyAxesLayer.xMarkDistance = xAxisLength/xMarksCount;
    xyAxesLayer.xMarkTitles = xMarkTitles;
    xyAxesLayer.zeroPoint = zeroPoint;
    xyAxesLayer.yMarksCount = yMarksCount;
    xyAxesLayer.yAxisLength = yAxisLength;
    xyAxesLayer.xAxisLength = xAxisLength;
    xyAxesLayer.originalPoint = self.coordinateOriginalPoint;
    xyAxesLayer.xMarkTitlePosition = kWSAtPoint;
    xyAxesLayer.xAxisName = self.xAxisName;
    xyAxesLayer.yAxisName = self.yAxisName;
    xyAxesLayer.showBorder = YES;
    [xyAxesLayer setNeedsDisplay];
}

- (void)manageAllLayersOrder
{
    [self.layer addSublayer:titleLayer];
    [self.layer addSublayer:legendLayer];
    [self.layer addSublayer:chartLayer];
    [self.layer addSublayer:xyAxesLayer];
}

@end
