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

#import <QuartzCore/QuartzCore.h>

typedef enum{
    kWSAtPoint,
    kWSAtSection,
} WSMarkTitlePosition;

/*
 The original point is at Bottom Left of the coordinator. like below.
    A
    |
    |
    |
    |
    o -------->
(0,0) 
 
 */

@interface WSCoordinateLayer : CAShapeLayer

@property (nonatomic) CGFloat yAxisLength;
@property (nonatomic) CGPoint originalPoint;
@property (nonatomic) CGPoint zeroPoint;
@property (nonatomic) CGFloat xAxisLength;
@property (nonatomic,strong) NSMutableArray *xMarkTitles;
@property (nonatomic,strong) NSMutableArray *yMarkTitles;
@property (nonatomic) CGFloat xMarkDistance;
@property (nonatomic) int yMarksCount;
@property (nonatomic) int xMarksCount;
// if we should display the subline in coordinate
@property (nonatomic) BOOL show3DXAxisSubline;
@property (nonatomic, strong) UIColor *sublineColor;
@property (nonatomic, strong) UIColor *axisColor;
@property (nonatomic) CGFloat sublineAngle;
@property (nonatomic) CGFloat sublineDistance;
@property (nonatomic) BOOL showXAxisSubline;
@property (nonatomic) BOOL showYAxisSubline;
@property (nonatomic) WSMarkTitlePosition xMarkTitlePosition;
@property (nonatomic) WSMarkTitlePosition yMarkTitlePosition;
@property (nonatomic) BOOL showBottomLeftBorder;
@property (nonatomic) BOOL showTopRightBorder;
@property (nonatomic) BOOL showBorder;
@property (nonatomic, strong) NSString *xAxisName;
@property (nonatomic, strong) NSString *yAxisName;

@end
