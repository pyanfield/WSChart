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

/*
 generate the key values for drawing x and y axes. e.g. minX,maxX,correctionX,propotionX.
 */
- (void)generateXAxisInfos;
- (void)generateYAxisInfos;

@end

@implementation WSBaseChartView
/* 
 Get the max and min value from Area datas.
 */ 
@synthesize maxXValue = _maxXValue;
@synthesize minXValue = _minXValue;
@synthesize maxYValue = _maxYValue;
@synthesize minYValue = _minYValue;
@synthesize coordinateOriginalPoint = _coordinateOriginalPoint;
@synthesize xAxisName = _xAxisName;
@synthesize yAxisName = _yAxisName;
@synthesize title = _title;
@synthesize rowWidth = _rowWidth;
@synthesize rowHeight = _rowHeight;
@synthesize rowDistance = _rowDistance;
@synthesize showZeroValueOnYAxis = _showZeroValueOnYAxis;
@synthesize showZeroValueOnXAxis = _showZeroValueOnXAxis;
@synthesize titleFrame = _titleFrame;
@synthesize legendFrame = _legendFrame;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.title = @"WSChart";
        self.maxXValue = CGFLOAT_MAX*(-1.0);
        self.minXValue = CGFLOAT_MAX;
        self.maxYValue = CGFLOAT_MAX*(-1.0);
        self.minYValue = CGFLOAT_MAX;
        self.coordinateOriginalPoint = CGPointMake(frame.origin.x + COORDINATE_LEFT_GAP, frame.size.height - COORDINATE_BOTTOM_GAP);
        zeroPoint = CGPointMake(frame.origin.x + COORDINATE_LEFT_GAP, frame.size.height - COORDINATE_BOTTOM_GAP);
        self.rowWidth = 0.0;
        self.rowHeight = 0.0;
        self.rowDistance = 0.0;
        chartLayer = [CALayer layer];
        xyAxesLayer = [[WSCoordinateLayer alloc] init];
        titleLayer = [CATextLayer layer];
        legendLayer = [CALayer layer];
        chartLayer.frame = frame;
        xyAxesLayer.frame = frame;
        yAxisLength = self.frame.size.height - COORDINATE_BOTTOM_GAP - COORDINATE_TOP_GAP;
        xAxisLength = self.frame.size.width - 2*COORDINATE_LEFT_GAP;
        yMarksCount = Y_MARKS_COUNT;
        xMarksCount = X_MARKS_COUNT;
        self.showZeroValueOnYAxis = NO;
        self.showZeroValueOnXAxis = NO;
        self.xAxisName = @"";
        self.yAxisName = @"";
        _titleFrame = CGRectZero;
        _legendFrame = CGRectZero;
    }
    return self;
}

- (void)drawChart:(NSArray *)arr withColor:(NSDictionary *)dict
{
    datas = [arr copy];
    colorDict = [dict copy];

    [self generateYAxisInfos];
    [self generateXAxisInfos];
    
    // draw chart layer
    [self createChartLayer];
    
    // draw coordinate first
    [self createCoordinateLayer];
    
    // add the title layer
    titleLayer.string = self.title;
    titleLayer.fontSize = TITLE_FONT_SIZE;
    UIFont *helveticated = [UIFont fontWithName:@"HelveticaNeue-Bold" size:TITLE_FONT_SIZE];
    CGSize size = [self.title sizeWithFont:helveticated];
    if (CGRectEqualToRect(self.titleFrame, CGRectZero)) {
        titleLayer.frame = CGRectMake(COORDINATE_LEFT_GAP/2, COORDINATE_TOP_GAP/2, size.width, size.height);
    }else{
        titleLayer.frame = self.titleFrame;
    }
    
    // add the lengedn layer
    __block int flag = 0;
    __block float legendWidth = 0.0;
    [colorDict enumerateKeysAndObjectsUsingBlock:^(id key,id obj,BOOL *stop){
        WSLegendLayer *layer = [[WSLegendLayer alloc] initWithColor:obj andTitle:key];
        layer.position  = CGPointMake(0.0, 20.0*flag);
        [layer setNeedsDisplay];
        [legendLayer addSublayer:layer];
        flag++;
        legendWidth = legendWidth > layer.frame.size.width ? legendWidth : layer.frame.size.width;
    }];
    if (CGRectEqualToRect(self.legendFrame, CGRectZero)) {
        legendLayer.frame = CGRectMake(self.bounds.size.width - legendWidth - COORDINATE_LEFT_GAP, 20.0, legendWidth, self.frame.size.height);
    }else{
        legendLayer.frame = self.legendFrame;
    }
   
    // carefully about the adding order
    [self manageAllLayersOrder];
}

- (void)generateXAxisInfos
{
    int length = [datas count];
    if (self.rowWidth > 0.0) {
        //for line, area, combo and column charts
        NSString *oneName = [[colorDict allKeys] objectAtIndex:0];
        xMarkTitles = [[NSMutableArray alloc] init];
        for (int i=0; i<[datas count]; i++) {
            NSDictionary *data = [datas objectAtIndex:i];
            WSChartObject *chartObj = [data valueForKey:oneName];
            [xMarkTitles addObject:chartObj.xValue];
        }
        xMarksCount = [xMarkTitles count];
    }else {
        //for scatter chart
        for (int i=0; i<length; i++) {
            NSDictionary *data = [datas objectAtIndex:i];
            [data enumerateKeysAndObjectsUsingBlock:^(id key,id obj,BOOL *stop){
                WSChartObject *chartObj = (WSChartObject*)obj;
                self.maxXValue = self.maxXValue > [chartObj.xValue floatValue] ? self.maxXValue : [chartObj.xValue floatValue];
                self.minXValue = self.minXValue < [chartObj.xValue floatValue] ? self.minXValue : [chartObj.xValue floatValue];
            }];
        }
        
        xMarkTitles = [[NSMutableArray alloc] init];
        minX = CalculateAxisExtremePointValue(self.minXValue, NO);
        maxX = CalculateAxisExtremePointValue(self.maxXValue, YES);
        
        if (self.minXValue >= 0.0 && self.maxXValue > 0.0) {
            if (self.showZeroValueOnXAxis) minX = 0.0;
            offsetX = maxX - minX;
            propotionX = xAxisLength/offsetX;
            zeroPoint = CGPointMake(self.coordinateOriginalPoint.x, zeroPoint.y);
            xMarkTitles = CalculateValuesBetweenMinAndMax(minX, maxX, xMarksCount);
            correctionX = minX;
        }else if (self.minXValue < 0.0 && self.maxXValue >= 0.0){
            float bigDis = fabsf(minX)>fabsf(maxX)?fabsf(minX):fabsf(maxX);
            float markDis = bigDis/X_MARKS_COUNT;
            float smallDis = fabsf(minX)<fabsf(maxX)?fabsf(minX):fabsf(maxX);
            int smallMarkCount = (int)ceilf(smallDis/markDis);
            xMarksCount = X_MARKS_COUNT+smallMarkCount;
            offsetX = markDis*(float)xMarksCount;
            propotionX = xAxisLength/offsetX;
            if (fabsf(minX)<=fabsf(maxX)) {
                zeroPoint = CGPointMake(self.coordinateOriginalPoint.x+xAxisLength*smallMarkCount/xMarksCount,zeroPoint.y);
                xMarkTitles = CalculateValuesBetweenMinAndMax(-markDis*smallMarkCount, maxX, xMarksCount);
            }else{
                zeroPoint = CGPointMake(self.coordinateOriginalPoint.x+xAxisLength*X_MARKS_COUNT/xMarksCount, zeroPoint.y);
                xMarkTitles = CalculateValuesBetweenMinAndMax(minX, markDis*smallMarkCount, xMarksCount);
            }
            correctionX = 0.0;
        }else if (self.minXValue < 0.0 && self.maxXValue <= 0.0){
            if (self.showZeroValueOnXAxis) maxX = 0.0;
            offsetX = maxX - minX;
            propotionX = xAxisLength/offsetX;
            zeroPoint = CGPointMake(self.coordinateOriginalPoint.x+xAxisLength, zeroPoint.y);
            xMarkTitles = CalculateValuesBetweenMinAndMax(minX, maxX, xMarksCount);
            correctionX = maxX;
        }
    }
}

- (void)generateYAxisInfos
{
    if (self.rowHeight > 0.0) {
        //for bar chart
        NSString *oneName = [[colorDict allKeys] objectAtIndex:0];
        yMarkTitles = [[NSMutableArray alloc] init];
        for (int i=0; i<[datas count]; i++) {
            NSDictionary *data = [datas objectAtIndex:i];
            WSChartObject *chartObj = [data valueForKey:oneName];
            [yMarkTitles addObject:chartObj.yValue];
        }
        yMarksCount = [yMarkTitles count];
    }else {
        //get the max and min value of WSChartObject's yValue
        int length = [datas count];
        for (int i=0; i<length; i++) {
            NSDictionary *data = [datas objectAtIndex:i];
            [data enumerateKeysAndObjectsUsingBlock:^(id key,id obj,BOOL *stop){
                WSChartObject *chartObj = (WSChartObject*)obj;
                self.maxYValue = self.maxYValue > [chartObj.yValue floatValue] ? self.maxYValue : [chartObj.yValue floatValue];
                self.minYValue = self.minYValue < [chartObj.yValue floatValue] ? self.minYValue : [chartObj.yValue floatValue];
            }];
        }
        //store the marks' value that displayed on y axis
        yMarkTitles = [[NSMutableArray alloc] init];
        
        //get the max and min data should be displayed on the y axis
        minY = CalculateAxisExtremePointValue(self.minYValue, NO);
        maxY = CalculateAxisExtremePointValue(self.maxYValue, YES);
        
        if (self.minYValue >= 0.0 && self.maxYValue > 0.0) {
            if (self.showZeroValueOnYAxis) minY = 0.0;
            offsetY = maxY - minY;
            propotionY = yAxisLength/offsetY;
            zeroPoint = CGPointMake(zeroPoint.x, self.coordinateOriginalPoint.y);
            yMarkTitles = CalculateValuesBetweenMinAndMax(minY, maxY, yMarksCount);
            correctionY = minY;
        }else if (self.minYValue < 0.0 && self.maxYValue >= 0.0){
            float bigDis = fabsf(minY)>fabsf(maxY)?fabsf(minY):fabsf(maxY);
            float markDis = bigDis/Y_MARKS_COUNT;
            float smallDis = fabsf(minY)<fabsf(maxY)?fabsf(minY):fabsf(maxY);
            int smallMarkCount = (int)ceilf(smallDis/markDis);
            yMarksCount = Y_MARKS_COUNT+smallMarkCount;
            offsetY = markDis*(float)yMarksCount;
            propotionY = yAxisLength/offsetY;
            if (fabsf(minY)<=fabsf(maxY)) {
                zeroPoint = CGPointMake(zeroPoint.x, self.coordinateOriginalPoint.y-yAxisLength*smallMarkCount/yMarksCount);
                yMarkTitles = CalculateValuesBetweenMinAndMax(-markDis*smallMarkCount, maxY, yMarksCount);
            }else{
                zeroPoint = CGPointMake(zeroPoint.x, self.coordinateOriginalPoint.y-yAxisLength*Y_MARKS_COUNT/yMarksCount);
                yMarkTitles = CalculateValuesBetweenMinAndMax(minY, markDis*smallMarkCount, yMarksCount);
            }
            correctionY = 0.0;
        }else if (self.minYValue < 0.0 && self.maxYValue <= 0.0){
            if (self.showZeroValueOnYAxis) maxY = 0.0;
            offsetY = maxY - minY;
            propotionY = yAxisLength/offsetY;
            zeroPoint = CGPointMake(zeroPoint.x, self.coordinateOriginalPoint.y-yAxisLength);
            yMarkTitles = CalculateValuesBetweenMinAndMax(minY, maxY, yMarksCount);
            correctionY = maxY;
        }
    }
}

@end


