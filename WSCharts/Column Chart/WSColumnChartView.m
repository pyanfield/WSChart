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

#import "WSColumnChartView.h"
#import "WSColumnLayer.h"


@interface WSColumnChartView()

@property (nonatomic, strong) WSCoordinateLayer *sublineLayer;
@property (nonatomic) int columnCount;

@end

@implementation WSColumnChartView

@synthesize sublineLayer = _sublineLayer;
@synthesize columnCount = _columnCount;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.title = @"WSColumnChart";
        self.sublineLayer = [[WSCoordinateLayer alloc] init];
        self.sublineLayer.show3DXAxisSubline = YES;
        self.sublineLayer.frame = frame;
    }
    return self;
}

- (void)drawChart:(NSArray *)arr withColor:(NSDictionary *)dict
{
    self.columnCount = [[arr objectAtIndex:0] count];
    [super drawChart:arr withColor:dict];
}

- (void)createChartLayer
{
    int length = [datas count];
    for (int i=0; i<length; i++) {
        NSDictionary *data = [datas objectAtIndex:i];
        __block int flag = 0.0;
        [data enumerateKeysAndObjectsUsingBlock:^(id key,id obj,BOOL *stop){
            WSColumnLayer *layer = [[WSColumnLayer alloc] init];
            WSChartObject *chartObj = obj;
            layer.color = [colorDict valueForKey:key];
            layer.yValue = ([chartObj.yValue floatValue]-correctionY)*propotionY;
            layer.columnWidth = self.rowWidth;
            layer.xStartPoint = CGPointMake(self.rowWidth*(self.columnCount+2)*i+self.rowWidth*(flag+1)+zeroPoint.x, 
                                            zeroPoint.y);
            layer.frame = self.bounds;
            [layer setNeedsDisplay];
            [chartLayer addSublayer:layer];
            flag++;
        }];
    }
}

- (void)createCoordinateLayer
{
    xyAxesLayer.yMarkTitles = yMarkTitles;
    xyAxesLayer.xMarkDistance = self.rowWidth*(self.columnCount+2);
    xyAxesLayer.xMarkTitles = xMarkTitles;
    xyAxesLayer.zeroPoint = zeroPoint;
    xyAxesLayer.yMarksCount = yMarksCount;
    xyAxesLayer.yAxisLength = yAxisLength;
    xyAxesLayer.xAxisLength = xAxisLength;
    xyAxesLayer.originalPoint = self.coordinateOriginalPoint;
    [xyAxesLayer setNeedsDisplay];
    self.sublineLayer.zeroPoint = zeroPoint;
    self.sublineLayer.yMarksCount = yMarksCount;
    self.sublineLayer.yAxisLength = yAxisLength;
    self.sublineLayer.xAxisLength = xAxisLength;
    self.sublineLayer.originalPoint = self.coordinateOriginalPoint;
    [self.sublineLayer setNeedsDisplay];
}

- (void)manageAllLayersOrder
{
    [self.layer addSublayer:self.sublineLayer];
    [self.layer addSublayer:titleLayer];
    [self.layer addSublayer:legendLayer];
    [self.layer addSublayer:chartLayer];
    [self.layer addSublayer:xyAxesLayer];
}

@end
