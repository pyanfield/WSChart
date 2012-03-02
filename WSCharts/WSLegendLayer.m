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

#import "WSLegendLayer.h"
#import <QuartzCore/QuartzCore.h>

@implementation WSLegendLayer
@synthesize color = _color;
@synthesize title = _title;
@synthesize titleStartPoint = _titleStartPoint, rectStartPoint = _rectStartPoint;
@synthesize font = _font;

- (id)initWithColor:(UIColor *)color andTitle:(NSString *)title
{
    self = [super init];
    if (self != nil) {
        self.color = color;
        self.title = title;
        self.titleStartPoint = CGPointMake(20.0, 0.0);
        self.rectStartPoint = CGPointMake(0.0, 4.0);
        self.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0];
        CGSize size = [self.title sizeWithFont:self.font];
        self.bounds = CGRectMake(0.0, 0.0, size.width+self.titleStartPoint.x, size.height);
        self.anchorPoint = CGPointMake(0.0, 0.0);
        CGPathRef path = CGPathCreateWithRect(CGRectMake(self.rectStartPoint.x,self.rectStartPoint.y, 15.0, 15.0), NULL);
        self.path = path;
        self.fillColor = self.color.CGColor;
        CFRelease(path);
	}
	return self;
}
/*
 Draw the legend title.
 */
- (void)drawInContext:(CGContextRef)ctx
{
    CGContextSetFillColorWithColor(ctx, self.color.CGColor);
    UIGraphicsPushContext(ctx);
    [self.title drawAtPoint:self.titleStartPoint withFont:self.font];
    UIGraphicsPopContext();
}

@end