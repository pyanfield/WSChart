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

#import "WSBaseChartView.h"
#import <QuartzCore/QuartzCore.h>

#define Y_MARKS_COUNT 5
#define X_MARKS_COUNT 5
#define FRONT_LINE_COLOR [UIColor whiteColor]
#define BACK_LINE_COLOR [UIColor grayColor]
#define COORDINATE_BOTTOM_GAP 100.0
#define COORDINATE_TOP_GAP 50.0
#define COORDINATE_LEFT_GAP 80.0
#define TITLE_FONT_SIZE 22

#pragma mark - WSBaseChartView

@interface WSBaseChartView()

// max and min value of user data
@property (nonatomic) CGFloat maxYValue;
@property (nonatomic) CGFloat minYValue;
@property (nonatomic) CGFloat maxXValue;
@property (nonatomic) CGFloat minXValue;
@end

@implementation WSBaseChartView

@synthesize coordinateOriginalPoint = _coordinateOriginalPoint;
@synthesize xAxisLength = _xAxisLength;
/* 
 Get the max and min value from Area datas.
 */ 
@synthesize maxXValue = _maxXValue;
@synthesize minXValue = _minXValue;
@synthesize maxYValue = _maxYValue;
@synthesize minYValue = _minYValue;
@synthesize chartLayer = _chartLayer;
@synthesize xyAxesLayer = _xyAxesLayer;
@synthesize xAxisKey = _xAxisKey;
@synthesize title = _title;
@synthesize rowWidth = _rowWidth;
@synthesize titleLayer = _titleLayer;
@synthesize legendLayer = _legendLayer;
@synthesize yAxisLength = _yAxisLength;
@synthesize yMarksCount = _yMarksCount;
@synthesize zeroPoint = _zeroPoint;
@synthesize showZeroValueAtYAxis = _showZeroValueAtYAxis;
@synthesize xMarksCount = _xMarksCount;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.title = @"WSChart";

        // Initialization code
        self.maxXValue = CGFLOAT_MAX*(-1.0);
        self.minXValue = CGFLOAT_MAX;
        self.maxYValue = CGFLOAT_MAX*(-1.0);
        self.minYValue = CGFLOAT_MAX;
        self.coordinateOriginalPoint = CGPointMake(frame.origin.x + COORDINATE_LEFT_GAP, frame.size.height - COORDINATE_BOTTOM_GAP);
        self.zeroPoint = CGPointMake(frame.origin.x + COORDINATE_LEFT_GAP, frame.size.height - COORDINATE_BOTTOM_GAP);
        self.rowWidth = 20.0;
        self.chartLayer = [CALayer layer];
        self.xyAxesLayer = [[WSCoordinateLayer alloc] init];
        self.titleLayer = [CATextLayer layer];
        self.legendLayer = [CALayer layer];
        self.chartLayer.frame = frame;
        self.xyAxesLayer.frame = frame;
        self.yAxisLength = self.frame.size.height - COORDINATE_BOTTOM_GAP - COORDINATE_TOP_GAP;
        self.xAxisLength = self.frame.size.width - 2*COORDINATE_LEFT_GAP;
        self.yMarksCount = Y_MARKS_COUNT;
        self.showZeroValueAtYAxis = NO;
    }
    return self;
}

- (void)drawChart:(NSArray *)arr withColor:(NSDictionary *)dict
{
    // get the max and min value from user datas
    NSArray *datas = [arr copy];
    NSDictionary *colorDict = [dict copy];
    NSMutableArray *xValues = [[NSMutableArray alloc] init];
    int length = [datas count];
    for (int i=0; i<length; i++) {
        NSDictionary *data = [datas objectAtIndex:i];
        [xValues addObject:[data valueForKey:self.xAxisKey]];
        [data enumerateKeysAndObjectsUsingBlock:^(id key,id obj,BOOL *stop){
            if (![key isEqual:self.xAxisKey]) {
                self.maxYValue = self.maxYValue > [obj floatValue] ? self.maxYValue : [obj floatValue];
                self.minYValue = self.minYValue < [obj floatValue] ? self.minYValue : [obj floatValue];
            }
        }];
    }
    //store the marks' value that displayed on y axis
    NSMutableArray *yMarkTitles = [[NSMutableArray alloc] init];
    /*
     propotion: to convert the user data value to y axis' value.
     minValue, maxValue : which will be displayed as max and min value on y axis.
     correction : if the cross point bwteen y and x axis is not zero. should re-calculate the value that displayed on coordinate
     */
    float minY, maxY,offsetY,propotionY,correctionY;
    minY = CalculateAxisExtremePointValue(self.minYValue, NO);
    maxY = CalculateAxisExtremePointValue(self.maxYValue, YES);
    
    if (self.minYValue >= 0.0 && self.maxYValue > 0.0) {
        if (self.showZeroValueAtYAxis) minY = 0.0;
        offsetY = maxY - minY;
        propotionY = self.yAxisLength/offsetY;
        self.zeroPoint = CGPointMake(self.zeroPoint.x, self.coordinateOriginalPoint.y);
        yMarkTitles = CalculateValuesBetweenMinAndMax(minY, maxY, self.yMarksCount);
        correctionY = minY;
    }else if (self.minYValue < 0.0 && self.maxYValue >= 0.0){
        float bigDis = fabsf(minY)>fabsf(maxY)?fabsf(minY):fabsf(maxY);
        float markDis = bigDis/Y_MARKS_COUNT;
        float smallDis = fabsf(minY)<fabsf(maxY)?fabsf(minY):fabsf(maxY);
        int smallMarkCount = (int)ceilf(smallDis/markDis);
        self.yMarksCount = Y_MARKS_COUNT+smallMarkCount;
        offsetY = markDis*(float)self.yMarksCount;
        propotionY = self.yAxisLength/offsetY;
        if (fabsf(minY)<=fabsf(maxY)) {
            self.zeroPoint = CGPointMake(self.zeroPoint.x, self.coordinateOriginalPoint.y-self.yAxisLength*smallMarkCount/self.yMarksCount);
            yMarkTitles = CalculateValuesBetweenMinAndMax(-markDis*smallMarkCount, maxY, self.yMarksCount);
        }else{
            self.zeroPoint = CGPointMake(self.zeroPoint.x, self.coordinateOriginalPoint.y-self.yAxisLength*Y_MARKS_COUNT/self.yMarksCount);
            yMarkTitles = CalculateValuesBetweenMinAndMax(minY, markDis*smallMarkCount, self.yMarksCount);
        }
        correctionY = 0.0;
    }else if (self.minYValue < 0.0 && self.maxYValue <= 0.0){
        if (self.showZeroValueAtYAxis) maxY = 0.0;
        offsetY = maxY - minY;
        propotionY = self.yAxisLength/offsetY;
        self.zeroPoint = CGPointMake(self.zeroPoint.x, self.coordinateOriginalPoint.y-self.yAxisLength);
        yMarkTitles = CalculateValuesBetweenMinAndMax(minY, maxY, self.yMarksCount);
        correctionY = maxY;
    }
    
    // draw chart layer
    //yValue = ([obj floatValue]-correction)*propotion;
    [self createChartLayerWithDatas:datas colors:colorDict yValueCorrection:correctionY yValuePropotion:propotionY];
    // draw coordinate first
    [self createCoordinateLayerWithYTitles:yMarkTitles XTitles:xValues];
    
    // add the title layer
    self.titleLayer.string = self.title;
    self.titleLayer.fontSize = TITLE_FONT_SIZE;
    UIFont *helveticated = [UIFont fontWithName:@"HelveticaNeue-Bold" size:TITLE_FONT_SIZE];
    CGSize size = [self.title sizeWithFont:helveticated];
    self.titleLayer.frame = CGRectMake(COORDINATE_LEFT_GAP/2, COORDINATE_TOP_GAP/2, size.width, size.height);
    
    // add the lengedn layer
    __block int flag = 0;
    __block float legendWidth = 0.0;
    [colorDict enumerateKeysAndObjectsUsingBlock:^(id key,id obj,BOOL *stop){
        WSLegendLayer *layer = [[WSLegendLayer alloc] initWithColor:obj andTitle:key];
        layer.position  = CGPointMake(0.0, 20.0*flag);
        [layer setNeedsDisplay];
        [self.legendLayer addSublayer:layer];
        flag++;
        legendWidth = legendWidth > layer.frame.size.width ? legendWidth : layer.frame.size.width;
    }];
    self.legendLayer.frame = CGRectMake(self.bounds.size.width - legendWidth - COORDINATE_LEFT_GAP, 20.0, legendWidth, self.frame.size.height);
    
    // carefully about the adding order
    [self manageAllLayersOrder];
}

- (void)createChartLayerWithDatas:(NSArray*)datas colors:(NSDictionary*)colorDict yValueCorrection:(CGFloat)correction yValuePropotion:(CGFloat)propotion
{

}

- (void)createCoordinateLayerWithYTitles:(NSMutableArray*)yMarkTitles XTitles:(NSMutableArray*)xValues
{

}

- (void)manageAllLayersOrder
{

}

@end


