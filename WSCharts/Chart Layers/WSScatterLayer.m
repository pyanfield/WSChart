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

#import "WSScatterLayer.h"
#import "WSGlobalCore.h"

#define RADIUS 5.0

@implementation WSScatterLayer

@synthesize color = _color;
@synthesize points = _points;
@synthesize radiusArr = _radiusArr;
@synthesize enableChangeRadius = _enableChangeRadius;

- (id)init
{
    return [super init];
}

- (void)drawInContext:(CGContextRef)ctx
{
    int count = [self.points count];
    if (self.enableChangeRadius) {
        for (int i=0; i<count; i++) {
            CGPoint point = [[self.points objectAtIndex:i] CGPointValue];
            CGMutablePathRef path = CGPathCreateMutable();
            CGFloat r = [[self.radiusArr objectAtIndex:i] floatValue];
            CGRect rect = CGRectMake(point.x-r, point.y-r, 2*r, 2*r);
            CGPathAddEllipseInRect(path, NULL, rect);
            UIColor *fillColor = CreateAlphaColor(self.color, 0.5);
            CGContextSetFillColorWithColor(ctx, fillColor.CGColor);
            CGContextSetLineWidth(ctx, 2.0);
            CGContextAddPath(ctx, path);
            CGContextDrawPath(ctx, kCGPathFill);
            CGPathRelease(path);
        }
    }else{
        for (int i=0; i<count; i++) {
            CGPoint point = [[self.points objectAtIndex:i] CGPointValue];
            CGMutablePathRef path = CGPathCreateMutable();
            CGRect rect = CGRectMake(point.x-RADIUS, point.y-RADIUS, 2*RADIUS, 2*RADIUS);
            CGPathAddEllipseInRect(path, NULL, rect);
            UIColor *fillColor = CreateAlphaColor(self.color, 0.5);
            CGContextSetFillColorWithColor(ctx, fillColor.CGColor);
            CGContextSetLineWidth(ctx, 2.0);
            CGContextAddPath(ctx, path);
            CGContextDrawPath(ctx, kCGPathFill);
            CGPathRelease(path);
        }
    }
}

@end