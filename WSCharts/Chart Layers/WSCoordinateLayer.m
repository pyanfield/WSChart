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

#import "WSCoordinateLayer.h"
#import "WSGlobalCore.h"

@implementation WSCoordinateLayer

@synthesize yAxisLength = _yAxisLength;
@synthesize originalPoint = _originalPoint;
@synthesize xAxisLength = _xAxisLength;
@synthesize xMarkTitles = _xMarkTitles;
@synthesize xMarkDistance = _xMarkDistance;
@synthesize yMarkTitles = _yMarkTitles;
@synthesize yMarksCount = _yMarksCount;
@synthesize xMarksCount = _xMarksCount;
@synthesize show3DXAxisSubline = _show3DXAxisSubline;
@synthesize zeroPoint = _zeroPoin;
@synthesize sublineColor = _sublineColor;
@synthesize axisColor = _axisColor;
@synthesize sublineAngle = _sublineAngle;
@synthesize sublineDistance = _sublineDistance;
@synthesize showXAxisSubline = _showXAxisSubline;
@synthesize showYAxisSubline = _showYAxisSubline;
@synthesize xMarkTitlePosition = _xMarkTitlePosition;
@synthesize yMarkTitlePosition = _yMarkTitlePosition;
@synthesize showBorder = _showBorder;
@synthesize showTopRightBorder = _showTopRightBorder;
@synthesize showBottomLeftBorder = _showBottomLeftBorder;
@synthesize xAxisName = _xAxisName;
@synthesize yAxisName = _yAxisName;

- (id)init
{
    self = [super init];
    if (self!= nil) {
        // set the default value of below properties.
        self.sublineColor = [UIColor grayColor];
        self.axisColor = [UIColor whiteColor];
        self.sublineDistance = 15.0;
        self.sublineAngle = M_PI/4.0;
        self.showYAxisSubline = NO;
        self.showXAxisSubline = NO;
        self.show3DXAxisSubline = NO;
        self.showBorder = NO;
        self.showBottomLeftBorder = NO;
        self.showTopRightBorder = NO;
        self.xMarkTitlePosition = kWSAtSection;
        self.yMarkTitlePosition = kWSAtPoint;
    }
    return self;
}

- (void)drawInContext:(CGContextRef)ctx
{
    CGPoint backOriginalPoint = CreateEndPoint(self.originalPoint, self.sublineAngle, self.sublineDistance);
    CGPoint backZeroPoint = CreateEndPoint(self.zeroPoint, self.sublineAngle, self.sublineDistance);
    CGFloat yMarkLength = self.yAxisLength/self.yMarksCount;
    
    if (self.show3DXAxisSubline) {
        // draw back y Axis
        CreateLineWithLengthFromPoint(ctx, NO, backOriginalPoint, self.yAxisLength, YES, self.sublineColor);
        // draw back x Axis
        CreateLineWithLengthFromPoint(ctx, YES, backZeroPoint, self.xAxisLength, YES, self.sublineColor);
        // draw bridge line between front and back original point
        CreateLinePointToPoint(ctx, self.zeroPoint, backZeroPoint, NO, self.sublineColor);
        CGPoint xMaxPoint = CGPointMake(self.zeroPoint.x + self.xAxisLength, self.zeroPoint.y);
        CGPoint xMaxPoint2 = CreateEndPoint(xMaxPoint, self.sublineAngle, self.sublineDistance);
        CreateLinePointToPoint(ctx, xMaxPoint, xMaxPoint2, NO, self.sublineColor);
        //draw assist line 
        for (int i=0; i<= self.yMarksCount; i++) {
            CGPoint p1 = CGPointMake(self.originalPoint.x, self.originalPoint.y-yMarkLength*i);
            CGPoint p2 = CreateEndPoint(p1, self.sublineAngle, self.sublineDistance);
            CreateLinePointToPoint(ctx, p1, p2, NO, self.sublineColor);
            CreateLineWithLengthFromPoint(ctx, YES, p2, self.xAxisLength, YES, self.sublineColor);
        }
    }else{
        // draw front y Axis
        CGPoint yStartPoint = CGPointMake(self.zeroPoint.x, self.originalPoint.y);
        CreateLineWithLengthFromPoint(ctx, NO, yStartPoint, self.yAxisLength, NO, self.axisColor);
        // draw front x Axis
        CGPoint xStattPoint = CGPointMake(self.originalPoint.x, self.zeroPoint.y);
        CreateLineWithLengthFromPoint(ctx, YES, xStattPoint, self.xAxisLength, NO, self.axisColor);
        //draw y axis mark's title
        for (int i=0; i<[self.yMarkTitles count]; i++) {
            CGPoint p1 = CGPointMake(self.originalPoint.x-6.0, self.originalPoint.y-yMarkLength*i);
            NSString *mark;
            if ([[self.yMarkTitles objectAtIndex:i] isKindOfClass:[NSString class]]) {
                mark = [NSString stringWithFormat:@"%@",[self.yMarkTitles objectAtIndex:i]];
            }else {
                mark = [NSString stringWithFormat:@"%.1f ",[[self.yMarkTitles objectAtIndex:i] floatValue]];
            }
            if (self.yMarkTitlePosition == kWSAtPoint) {
                CreateTextAtPoint(ctx, mark, p1, self.axisColor, kWSLeft);
            }else {
                CreateTextAtPoint(ctx, mark, CGPointMake(p1.x, p1.y-yMarkLength/2), self.axisColor, kWSLeft);
            }
            
            CreateLineWithLengthFromPoint(ctx, YES, p1, 6.0, NO, self.axisColor);
        }
        //draw x axis mark and title
        for (int i=0; i<[self.xMarkTitles count]; i++) {
            CGPoint p1 = CGPointMake(self.xMarkDistance*i+self.originalPoint.x, self.originalPoint.y);
            CGPoint p2 = CGPointMake(p1.x, p1.y+4.0);
            CreateLinePointToPoint(ctx, p1, p2, NO, self.axisColor);
            NSString *mark;
            if ([[self.xMarkTitles objectAtIndex:i] isKindOfClass:[NSString class]]) {
                mark = [NSString stringWithFormat:@"%@",[self.xMarkTitles objectAtIndex:i]];
            }else {
                mark = [NSString stringWithFormat:@"%.1f",[[self.xMarkTitles objectAtIndex:i] floatValue]];
            }
            
            if (self.xMarkTitlePosition == kWSAtSection) {
                CreateTextAtPoint(ctx, mark, CGPointMake(p1.x+self.xMarkDistance/2, p1.y), self.axisColor, kWSTop);
            }else{
                CreateTextAtPoint(ctx, mark, CGPointMake(p1.x, p1.y+2), self.axisColor, kWSTop);
            }
        }
    }
    
    // draw x axis subline
    if (self.showYAxisSubline) {
        for (int i=0; i<=self.yMarksCount; i++) {
            CGPoint p1 = CGPointMake(self.originalPoint.x, self.originalPoint.y-yMarkLength*i);
            if (self.zeroPoint.y != p1.y) {
                CreateLineWithLengthFromPoint(ctx, YES, p1, self.xAxisLength, YES, self.sublineColor);
            }
            
        }
    }
    // draw y axis subline
    if (self.showXAxisSubline) {
        for (int i=0; i<self.xMarksCount; i++) {
            CGPoint p = CGPointMake(self.xMarkDistance*(i+1)+self.originalPoint.x, self.originalPoint.y);
            CreateLineWithLengthFromPoint(ctx, NO, p, self.yAxisLength, YES, self.sublineColor);
        }
    }
    
    // draw the border
    if (self.showBorder || self.showBottomLeftBorder) {
        CreateLineWithLengthFromPoint(ctx, YES, self.originalPoint, self.xAxisLength, NO, self.axisColor);
        CreateLineWithLengthFromPoint(ctx, NO, self.originalPoint, self.yAxisLength, NO, self.axisColor);
    }
    
    if (self.showTopRightBorder || self.showBorder) {
        CreateLineWithLengthFromPoint(ctx, YES, CGPointMake(self.originalPoint.x, self.originalPoint.y-self.yAxisLength), self.xAxisLength, NO, self.axisColor);
        CreateLineWithLengthFromPoint(ctx, NO, CGPointMake(self.originalPoint.x+self.xAxisLength, self.originalPoint.y), self.yAxisLength, NO, self.axisColor);
    }
    
    // draw xy axes's name
    if (self.xAxisName != nil || ![self.xAxisName isEqualToString:@""]) {
        CreateTextAtPoint(ctx, self.xAxisName, CGPointMake(self.originalPoint.x+self.xAxisLength, self.zeroPoint.y), self.axisColor, kWSRight);
    }
    if (self.yAxisName != nil || ![self.yAxisName isEqualToString:@""]) {
        CreateTextAtPoint(ctx, self.yAxisName, CGPointMake(self.zeroPoint.x, self.originalPoint.y-self.yAxisLength), self.axisColor, kWSBottom);
    }
    
}

@end
