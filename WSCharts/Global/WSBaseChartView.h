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

#import <UIKit/UIKit.h>
#import "WSCoordinateLayer.h"
#import "WSLegendLayer.h"
#import "WSCoordinateLayer.h"
#import "WSGlobalCore.h"
#import "WSChartObject.h"
#import "WSBaseChartDelegate.h"

@interface WSBaseChartView : UIView <WSBaseChartDelegate>
{
    @protected
    NSArray *datas;
    NSDictionary *colorDict;
    NSMutableArray *yMarkTitles;
    NSMutableArray *xMarkTitles;
    // the point that display zero user data value on y axis
    CGPoint zeroPoint;
    CALayer *chartLayer;
    WSCoordinateLayer *xyAxesLayer;
    CATextLayer *titleLayer;
    CALayer *legendLayer;
    /*
     TODO:yMarksCount and xMarksCount are equal to yMarkTitles' count.
     It should be sections number on x and y axes.
     yMarksCount = [yMarkTitles count];
     */
    int yMarksCount;
    int xMarksCount;
    // the length of x and y axis
    CGFloat xAxisLength;
    CGFloat yAxisLength;
    /*
     propotion: to convert the user data value to y axis' value.
     minValue, maxValue : which will be displayed as max and min value on y axis.
     correction : if the cross point bwteen y and x axis is not zero. should re-calculate the value that displayed on coordinate
     */
    float minY, maxY,offsetY,propotionY,correctionY;
    float minX, maxX,offsetX,propotionX,correctionX;
}

// the name of x and y axes
@property (nonatomic, strong) NSString *xAxisName;
@property (nonatomic, strong) NSString *yAxisName;
// the chart view's title.
@property (nonatomic, strong) NSString *title;
/*
 If rowWidth value > 0.0 , the x marks are same as WSChartObject's xValue.
 If not, will calculate the xMark automatically. The chart view will calculate the min and max x value that display on the x axis.
 Then create a array (xMarkTitles) to store all marks.
 For now,it means that rowWidth is used in area, line ,column and combo charts. And the value must be > 0
 In scatter chart view, please don't set rowWidth.
 */
@property (nonatomic) CGFloat rowWidth;
@property (nonatomic) CGFloat rowHeight;
@property (nonatomic) CGFloat rowDistance;
//show zero value on y axis
@property (nonatomic) BOOL showZeroValueOnYAxis;
//show zero value on x axis. it is available when you don't set rowWidth.
@property (nonatomic) BOOL showZeroValueOnXAxis;
//coordinate view's origianl point , that bottom left of that frame.
@property (nonatomic) CGPoint coordinateOriginalPoint;
// the chart's title's position and size
@property (nonatomic) CGRect titleFrame;
// the legend's frame
@property (nonatomic) CGRect legendFrame;

- (void)drawChart:(NSArray*)arr withColor:(NSDictionary*)dict;

@end
