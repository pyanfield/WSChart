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

#import "WSColumnLayer.h"
#import "WSGlobalCore.h"

@implementation WSColumnLayer

@synthesize xStartPoint = _xStartPoint;
@synthesize yValue = _yValue;
@synthesize columnWidth = _columnWidth;
@synthesize color = _color;
@synthesize visualAngle = _visualAngle;
@synthesize visualDepth = _visualDepth;

- (id)init
{
    self = [super init];
    if (self) {
        self.visualDepth = DISTANCE_DEFAULT;
        self.visualAngle = ANGLE_DEFAULT;
    }
    return self;
}

- (void)drawInContext:(CGContextRef)ctx
{
    NSDictionary *colors = ConstructBrightAndDarkColors(self.color);
    CGPoint topLeftFront ,topLeftBack,topRightFront,topRightBack , bottomRightBack ,bottomRightFront;
    if (self.yValue>=0.0) {
        topLeftFront = CGPointMake(self.xStartPoint.x+(self.columnWidth >= 0.0 ? 0.0 : self.columnWidth), self.xStartPoint.y-self.yValue);
        topRightFront = CGPointMake(self.xStartPoint.x+(self.columnWidth >= 0.0 ? self.columnWidth : 0.0), self.xStartPoint.y-self.yValue);
        topLeftBack = CreateEndPoint(topLeftFront, self.visualAngle,self.visualDepth);
        topRightBack = CreateEndPoint(topRightFront, self.visualAngle, self.visualDepth);
        bottomRightBack = CGPointMake(topRightBack.x, topRightBack.y+self.yValue);
        bottomRightFront = CGPointMake(topRightFront.x, self.xStartPoint.y);
    }else{
        topLeftFront = CGPointMake(self.xStartPoint.x+(self.columnWidth >= 0.0 ? 0.0 : self.columnWidth), self.xStartPoint.y);
        topRightFront = CGPointMake(self.xStartPoint.x+(self.columnWidth >= 0.0 ? self.columnWidth : 0.0), self.xStartPoint.y);
        topLeftBack = CreateEndPoint(topLeftFront, self.visualAngle, self.visualDepth);
        topRightBack = CreateEndPoint(topRightFront, self.visualAngle, self.visualDepth);
        bottomRightBack = CGPointMake(topRightBack.x, topRightBack.y-self.yValue);
        bottomRightFront = CGPointMake(topRightFront.x, topLeftFront.y-self.yValue);
    }
    
    // front side
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(topLeftFront.x,topLeftFront.y, fabsf(self.columnWidth),fabsf(self.yValue)));
    UIColor *normalColor = [colors objectForKey:@"normalColor"];
    CGContextSetFillColorWithColor(ctx, normalColor.CGColor);
    CGContextSetLineWidth(ctx, 1.0);
    CGContextAddPath(ctx, path);
    CGContextDrawPath(ctx, kCGPathFill);
    CGPathRelease(path);
    
    if (self.visualDepth > 0.0) {
        // top side
        CGMutablePathRef topPath = CGPathCreateMutable();
        CGPathMoveToPoint(topPath, NULL, topLeftFront.x,topLeftFront.y);
        CGPathAddLineToPoint(topPath, NULL, topLeftBack.x,topLeftBack.y);
        CGPathAddLineToPoint(topPath, NULL, topRightBack.x, topRightBack.y);
        CGPathAddLineToPoint(topPath, NULL,topRightFront.x,topRightFront.y);
        CGPathCloseSubpath(topPath);
        UIColor *brightColor = [colors objectForKey:@"brightColor"];
        CGContextSetFillColorWithColor(ctx, brightColor.CGColor);
        CGContextSetLineWidth(ctx, 1.0);
        CGContextAddPath(ctx, topPath);
        CGContextDrawPath(ctx, kCGPathFill);
        CGPathRelease(topPath);
        
        // right side
        CGMutablePathRef rightPath = CGPathCreateMutable();
        CGPathMoveToPoint(rightPath, NULL, topRightBack.x,topRightBack.y);
        CGPathAddLineToPoint(rightPath, NULL, bottomRightBack.x, bottomRightBack.y);
        CGPathAddLineToPoint(rightPath, NULL, bottomRightFront.x, bottomRightFront.y);
        CGPathAddLineToPoint(rightPath, NULL, topRightFront.x, topRightFront.y);
        CGPathCloseSubpath(rightPath);
        UIColor *darkColor = [colors objectForKey:@"darkColor"];
        CGContextSetFillColorWithColor(ctx, darkColor.CGColor);
        CGContextSetLineWidth(ctx, 1.0);
        CGContextAddPath(ctx, rightPath);
        CGContextDrawPath(ctx, kCGPathFill);
        CGPathRelease(rightPath);
    }
}

@end

