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

#import "WSBarChartView.h"
#import "WSBarLayer.h"
#import "WSTopLeftCoordinateLayer.h"

@interface WSBarChartView()

@property (nonatomic, strong) WSCoordinateLayer *sublineLayer;
@property (nonatomic) int columnCount;
@property (nonatomic) CGFloat yMarksDistance;

@end

@implementation WSBarChartView

@synthesize sublineLayer = _sublineLayer;
@synthesize columnCount = _columnCount;
@synthesize yMarksDistance = _yMarksDistance;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.title = @"WSBarChart";
        self.sublineLayer = [[WSCoordinateLayer alloc] init];
        self.sublineLayer.show3DXAxisSubline = YES;
        self.sublineLayer.frame = frame;
    }
    return self;
}

- (void)drawChart:(NSArray *)arr withColor:(NSDictionary *)dict
{
    self.columnCount = [[arr objectAtIndex:0] count];
    self.yMarksDistance = self.columnCount*self.rowHeight+self.rowDistance*(self.columnCount+1);
    
    [super drawChart:arr withColor:dict];
}

- (void)createChartLayer
{
    int length = [datas count];
    for (int i= 0; i < length; i++) {
        NSDictionary *data = [datas objectAtIndex:i];
        __block int flag = 0;//[data count];
        [data enumerateKeysAndObjectsUsingBlock:^(id key,id obj,BOOL *stop){
            WSBarLayer *layer = [[WSBarLayer alloc] init];
            WSChartObject *chartObj = obj;
            layer.color = [colorDict valueForKey:key];
            layer.xValue = ([chartObj.xValue floatValue]-correctionX)*propotionX;
            layer.columnHeight = self.rowHeight;
            layer.xStartPoint = CGPointMake(zeroPoint.x, zeroPoint.y-(self.yMarksDistance*i+flag*self.rowHeight+(flag+1)*self.rowDistance));
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
    xyAxesLayer.xMarkDistance = xAxisLength/xMarksCount;
    xyAxesLayer.xMarkTitles = xMarkTitles;
    xyAxesLayer.zeroPoint = zeroPoint;
    xyAxesLayer.yMarksCount = yMarksCount;
    xyAxesLayer.yAxisLength = self.yMarksDistance*yMarksCount;
    xyAxesLayer.xAxisLength = xAxisLength;
    xyAxesLayer.yMarkTitlePosition = kWSAtSection;
    xyAxesLayer.xMarkTitlePosition = kWSAtPoint;
    //xyAxesLayer.showBorder = YES;
    xyAxesLayer.originalPoint = self.coordinateOriginalPoint;
    [xyAxesLayer setNeedsDisplay];
    self.sublineLayer.zeroPoint = zeroPoint;
    self.sublineLayer.yMarksCount = yMarksCount;
    self.sublineLayer.yAxisLength = self.yMarksDistance*yMarksCount;
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

