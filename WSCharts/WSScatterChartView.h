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

@interface WSScatterChartView : UIView

// the key value in the user data which will be displayed on x axis
//@property (nonatomic, strong) NSString *xAxisKey;
@property (nonatomic, strong) NSString *title;
//@property (nonatomic) CGFloat rowWidth;
//cross point between x and y axis, always display zero user data value.
@property (nonatomic) BOOL showZeroValueAtYAxis;
// coordinate view's origianl point , that bottom left of that frame.
@property (nonatomic) CGPoint coordinateOriginalPoint;
// the point that display zero user data value on y axis
@property (nonatomic) CGPoint zeroPoint;
// layers for different part of Area chart view
@property (nonatomic, strong) CALayer *chartLayer;
@property (nonatomic, strong) WSCoordinateLayer *xyAxesLayer;
@property (nonatomic, strong) CATextLayer *titleLayer;
@property (nonatomic, strong) CALayer *legendLayer;
// mark's count that are on y axis
@property (nonatomic) int yMarksCount;
@property (nonatomic) int xMarksCount;
// the length of x and y axis
@property (nonatomic) CGFloat xAxisLength;
@property (nonatomic) CGFloat yAxisLength;


- (void)drawChart:(NSArray*)arr withColor:(NSDictionary*)dict;
/*
 Create Chart Layer for the view. Then add it to self.chartLayer.
 */
- (void)createChartLayerWithDatas:(NSArray*)datas colors:(NSDictionary*)colorDict yCorrection:(CGFloat)correctionY yPropotion:(CGFloat)propotionY xCorrection:(CGFloat)correctionX xPropotion:(CGFloat)propotionX;
/*
 Create the coordinate layer and add it to self.xyAxesLayer
 */
- (void)createCoordinateLayerWithYTitles:(NSMutableArray*)yMarkTitles XTitles:(NSMutableArray*)xMarkTitles;
/*
 Manage all layers order.
 */
- (void)manageAllLayersOrder;

@end
