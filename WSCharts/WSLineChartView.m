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

#import "WSLineChartView.h"

#pragma mark - WSLineLayer

@interface WSLineLayer:CAShapeLayer

@property (nonatomic, strong) NSArray* points;
@property (nonatomic) CGFloat rowWidth;
@property (nonatomic, strong) UIColor *color;

@end

@implementation WSLineLayer

@synthesize points = _points;
@synthesize rowWidth = _rowWidth;
@synthesize color = _color;


- (id)init
{
    self = [super init];
    return self;
}

- (void)drawInContext:(CGContextRef)ctx
{   
    size_t count = [self.points count];
    CGPoint p[count];
    for (int i=0; i<count; i++) {
        CGPoint point = [[self.points objectAtIndex:i] CGPointValue];
        p[i] = point;
    }
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddLines(path, NULL, p, count);
    CGContextSetStrokeColorWithColor(ctx, self.color.CGColor);
    CGContextSetLineWidth(ctx, 2.0);
    CGContextAddPath(ctx, path);
    CGContextDrawPath(ctx, kCGPathStroke);
    CGPathRelease(path);
}

@end


#pragma mark - WSLineChartView

@implementation WSLineChartView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.title = @"WSLineChart";
    }
    return self;
}

- (void)drawChart:(NSArray *)arr withColor:(NSDictionary *)dict
{
    [super drawChart:arr withColor:dict];
}

- (void)createChartLayerWithDatas:(NSArray *)datas colors:(NSDictionary *)colorDict yValueCorrection:(CGFloat)correction yValuePropotion:(CGFloat)propotion
{
    NSArray *legendNames = [colorDict allKeys];
    for (int j=0; j<[legendNames count]; j++) {
        NSString *legendName = [legendNames objectAtIndex:j];
        NSMutableArray *points = [[NSMutableArray alloc] init];
        WSLineLayer *layer = [[WSLineLayer alloc] init];
        layer.color = [colorDict valueForKey:legendName];
        for (int i=0; i<[datas count]; i++) {
            NSDictionary *data = [datas objectAtIndex:i];
            
            CGFloat yValue = self.zeroPoint.y - ([[data valueForKey:legendName] floatValue]-correction)*propotion;
            CGPoint point = CGPointMake(self.rowWidth*i+self.zeroPoint.x, yValue);
            [points addObject:[NSValue valueWithCGPoint:point]];
        }
        layer.points = [points copy];
        layer.frame = self.bounds;
        [layer setNeedsDisplay];
        [self.chartLayer addSublayer:layer];
    }
}

- (void)createCoordinateLayerWithYTitles:(NSMutableArray *)yMarkTitles XTitles:(NSMutableArray *)xValues
{
    self.xyAxesLayer.yMarkTitles = yMarkTitles;
    self.xyAxesLayer.xMarkDistance = self.rowWidth;
    self.xyAxesLayer.xMarkTitles = xValues;
    self.xyAxesLayer.zeroPoint = self.zeroPoint;
    self.xyAxesLayer.yMarksCount = self.yMarksCount;
    self.xyAxesLayer.yAxisLength = self.yAxisLength;
    self.xyAxesLayer.xAxisLength = self.rowWidth*[xValues count];
    self.xyAxesLayer.originalPoint = self.coordinateOriginalPoint;
    self.xyAxesLayer.xMarkTitlePosition = WSAtPoint;
    [self.xyAxesLayer setNeedsDisplay];
}

- (void)manageAllLayersOrder
{
    [self.layer addSublayer:self.titleLayer];
    [self.layer addSublayer:self.legendLayer];
    [self.layer addSublayer:self.chartLayer];
    [self.layer addSublayer:self.xyAxesLayer];
}

@end
