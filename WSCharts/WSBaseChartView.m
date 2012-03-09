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
#define FRONT_LINE_COLOR [UIColor whiteColor]
#define BACK_LINE_COLOR [UIColor grayColor]
#define COORDINATE_BOTTOM_GAP 100.0
#define COORDINATE_TOP_GAP 50.0
#define COORDINATE_LEFT_GAP 80.0
#define TITLE_FONT_SIZE 22

#pragma mark - WSBaseChartView

@interface WSBaseChartView()

// max and min value of user data
@property (nonatomic) float maxDataValue;
@property (nonatomic) float minDataValue;

@end

@implementation WSBaseChartView

@synthesize coordinateOriginalPoint = _coordinateOriginalPoint;
@synthesize xAxisLength = _xAxisLength;
/* 
 Get the max and min value from Area datas.
 */ 
@synthesize maxDataValue = _maxDataValue;
@synthesize minDataValue = _minDataValue;
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


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.coordinateOriginalPoint = CGPointMake(frame.origin.x + COORDINATE_LEFT_GAP, frame.size.height - COORDINATE_BOTTOM_GAP);
        self.maxDataValue= CGFLOAT_MAX*(-1.0);
        self.minDataValue = CGFLOAT_MAX;
        self.rowWidth = 20.0;
        self.title = @"WSChart";
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
                self.maxDataValue = self.maxDataValue > [obj floatValue] ? self.maxDataValue : [obj floatValue];
                self.minDataValue = self.minDataValue < [obj floatValue] ? self.minDataValue : [obj floatValue];
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
    float minValue, maxValue,offsetValue,propotion,correction;
    minValue = CalculateAxisExtremePointValue(self.minDataValue, NO);
    maxValue = CalculateAxisExtremePointValue(self.maxDataValue, YES);
    
    if (self.minDataValue >= 0.0 && self.maxDataValue > 0.0) {
        if (self.showZeroValueAtYAxis) minValue = 0.0;
        offsetValue = maxValue - minValue;
        propotion = self.yAxisLength/offsetValue;
        self.zeroPoint = self.coordinateOriginalPoint;
        yMarkTitles = CalculateValuesBetweenMinAndMax(minValue, maxValue, self.yMarksCount);
        correction = minValue;
    }else if (self.minDataValue < 0.0 && self.maxDataValue >= 0.0){
        float bigDis = fabsf(minValue)>fabsf(maxValue)?fabsf(minValue):fabsf(maxValue);
        float markDis = bigDis/Y_MARKS_COUNT;
        float smallDis = fabsf(minValue)<fabsf(maxValue)?fabsf(minValue):fabsf(maxValue);
        int smallMarkCount = (int)ceilf(smallDis/markDis);
        self.yMarksCount = Y_MARKS_COUNT+smallMarkCount;
        offsetValue = markDis*(float)self.yMarksCount;
        propotion = self.yAxisLength/offsetValue;
        if (fabsf(minValue)<=fabsf(maxValue)) {
            self.zeroPoint = CGPointMake(self.coordinateOriginalPoint.x, self.coordinateOriginalPoint.y-self.yAxisLength*smallMarkCount/self.yMarksCount);
            yMarkTitles = CalculateValuesBetweenMinAndMax(-markDis*smallMarkCount, maxValue, self.yMarksCount);
        }else{
            self.zeroPoint = CGPointMake(self.coordinateOriginalPoint.x, self.coordinateOriginalPoint.y-self.yAxisLength*Y_MARKS_COUNT/self.yMarksCount);
            yMarkTitles = CalculateValuesBetweenMinAndMax(minValue, markDis*smallMarkCount, self.yMarksCount);
        }
        correction = 0.0;
    }else if (self.minDataValue < 0.0 && self.maxDataValue <= 0.0){
        if (self.showZeroValueAtYAxis) maxValue = 0.0;
        offsetValue = maxValue - minValue;
        propotion = self.yAxisLength/offsetValue;
        self.zeroPoint = CGPointMake(self.coordinateOriginalPoint.x, self.coordinateOriginalPoint.y-self.yAxisLength);
        yMarkTitles = CalculateValuesBetweenMinAndMax(minValue, maxValue, self.yMarksCount);
        correction = maxValue;
    }
    
    // draw chart layer
    //yValue = ([obj floatValue]-correction)*propotion;
    [self createChartLayerWithDatas:datas colors:colorDict yValueCorrection:correction yValuePropotion:propotion];
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


