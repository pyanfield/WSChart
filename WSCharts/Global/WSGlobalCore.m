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

#import "WSGlobalCore.h"

/*
 Create the pie's sector path. Using this path to draw the pie.
 */
CGMutablePathRef CreatePiePathWithCenter(CGPoint center, CGFloat radius,CGFloat startAngle, CGFloat angle,CGAffineTransform *transform)
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, transform, center.x, center.y);
    CGPathAddRelativeArc(path, transform, center.x, center.y, radius, startAngle, angle);
    CGPathCloseSubpath(path);
    return path;
}

/*
 Extract different brightness colors from "color".
 */
NSDictionary* ConstructBrightAndDarkColors(UIColor *color)
{    
    CGFloat hue = 0.0, saturation = 0.0 , brightness = 0.0, alpha = 0.0;
    if ([color respondsToSelector:@selector(getHue:saturation:brightness:alpha:)]) {
        [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    }else{
        NSLog(@"Not support getHue:saturation:brightness:alpha:");
    }
    
    UIColor *brightColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
    UIColor *normalColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness*0.91 alpha:alpha];
    UIColor *darkColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness*0.78 alpha:alpha];
    NSDictionary *colors = [NSDictionary dictionaryWithObjectsAndKeys:brightColor,@"brightColor",normalColor,@"normalColor",darkColor,@"darkColor", nil];
    
    return colors;
}

/*
 Create a point that is away from "startPoint".
 */
CGPoint CreateEndPoint(CGPoint startPoint,CGFloat angle,CGFloat distance)
{
    float x = distance*sinf(angle);
    float y = distance*cosf(angle);
    CGPoint point = CGPointMake(startPoint.x+x,startPoint.y-y);
    return point;
}
/*
 Draw the string "text" at ponint "p1",with the "color".
 Alignment point is p1.
 */
void CreateTextAtPoint(CGContextRef ctx,NSString *text,CGPoint p1,UIColor *color,WSAliment alignment)
{
    UIGraphicsPushContext(ctx);
    CGContextSetFillColorWithColor(ctx,color.CGColor);
    UIFont *helveticated = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0];
    CGSize size = [text sizeWithFont:helveticated];
    switch (alignment) {
        case kWSTop:
            p1 = CGPointMake(p1.x-size.width/2, p1.y);
            break;
        case kWSLeft:
            p1 = CGPointMake(p1.x-size.width, p1.y-size.height/2);
            break;
        case kWSRight:
            p1 = CGPointMake(p1.x, p1.y-size.height/2);
            break;
        case kWSBottom:
            p1 = CGPointMake(p1.x-size.width/2, p1.y-size.height);
            break;
        case kWSTopRight:
            p1 = CGPointMake(p1.x-size.width, p1.y);
            break;
        case kWSBottomLeft:
            p1 = CGPointMake(p1.x, p1.y-size.height);
            break;
        case kWSBottomRight:
            p1 = CGPointMake(p1.x-size.width, p1.y-size.height);
            break;
        case kWSCenter:
            p1 = CGPointMake(p1.x-size.width/2, p1.y-size.height/2);
            break;
        case kWSTopLeft:
            break;
        default:
            break;
    }
    
    [text drawAtPoint:p1 withFont:helveticated];
    UIGraphicsPopContext();
}

/*
 Draw a line from "point".
 */
void CreateLineWithLengthFromPoint(CGContextRef ctx,BOOL isXAxis, CGPoint point, CGFloat length,BOOL isDash,UIColor *color)
{
    CGContextSaveGState(ctx);
    if (isDash) {
        CGFloat phase = 2.0;
        const CGFloat pattern[] = {5.0,5.0};
        size_t count = 2;
        CGContextSetLineDash(ctx,phase,pattern,count);
    }
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, point.x, point.y);
    if (isXAxis) {
        CGPathAddLineToPoint(path, NULL, point.x+length, point.y);
    }else{
        CGPathAddLineToPoint(path, NULL, point.x, point.y - length);
    }
    
    CGContextSetLineWidth(ctx, 1.0);
    CGContextSetStrokeColorWithColor(ctx, color.CGColor);
    CGContextAddPath(ctx, path);
    CGContextDrawPath(ctx, kCGPathStroke);
    CGPathRelease(path);
    CGContextRestoreGState(ctx);
}

/*
 Draw a line from "p1" to "p2".
 */
void CreateLinePointToPoint(CGContextRef ctx,CGPoint p1,CGPoint p2,BOOL isDash,UIColor *color)
{
    CGContextSaveGState(ctx);
    if (isDash) {
        CGFloat phase = 3.0;
        const CGFloat pattern[] = {3.0,3.0};
        size_t count = 2;
        CGContextSetLineDash(ctx,phase,pattern,count);
    }
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, p1.x, p1.y);
    CGPathAddLineToPoint(path, NULL, p2.x, p2.y);
    CGContextSetLineWidth(ctx, 1.0);
    CGContextSetStrokeColorWithColor(ctx, color.CGColor);
    CGContextAddPath(ctx, path);
    CGContextDrawPath(ctx, kCGPathStroke);
    CGPathRelease(path);
    CGContextRestoreGState(ctx);
}

/*
 Set color's alpha.
*/
UIColor* CreateAlphaColor(UIColor *color, CGFloat alphaValue)
{
    CGFloat hue = 0.0, saturation = 0.0 , brightness = 0.0, alpha = 0.0;
    if ([color respondsToSelector:@selector(getHue:saturation:brightness:alpha:)]) {
        [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    }else{
        NSLog(@"Not support getHue:saturation:brightness:alpha:");
    }
    
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alphaValue];
}

/*
 Calculate the marks' value which should be displayed on axis. 
 */
NSMutableArray* CalculateValuesBetweenMinAndMax(CGFloat min,CGFloat max, int count)
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [arr addObject:[NSNumber numberWithFloat:min]];
    float offset = (max - min)/count;
    for (int i=1; i<=count; i++) {
        [arr addObject:[NSNumber numberWithFloat:(min+offset*i)]];
    }
    return arr;
}

/*
 Calculate the user data's max and min value which should be displayed on axis.
 */
float CalculateAxisExtremePointValue(float value,BOOL max)
{
    if (max) {
        if (value > -100.0 && value <= 0.0) return 0.0;
    }else{
        if (value >= 0.0 && value < 100.0) return 0.0;
    }
    // value = fisrtStr*10^lastStr
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSNumberFormatter *numFormatter  = [[NSNumberFormatter alloc] init];
    [numFormatter setLocale:locale];
    [numFormatter setNumberStyle:NSNumberFormatterScientificStyle];
    NSString *numStr = [numFormatter stringFromNumber:[NSNumber numberWithFloat:value]];
    NSString *e = @"E";
    // also can use [[maxNumStr componentsSeparatedByString:e] lastObject] to get the substring after "e", but slower than using range
    NSRange range = [numStr rangeOfString:e];
    NSString *lastStr = [numStr substringFromIndex:range.location+1];
    NSString *firstStr = [numStr substringToIndex:range.location];
    float finalFirstNum = 0.0;
    if (max) {
        finalFirstNum = ceilf([firstStr floatValue]);
        if (finalFirstNum > ([firstStr floatValue]+0.5)) {
            finalFirstNum = (floorf([firstStr floatValue])+0.5);
        }
        if (finalFirstNum == floorf([firstStr floatValue])) {
            finalFirstNum += 0.5;
        }
    }else{
        finalFirstNum = floorf([firstStr floatValue]);
        if (finalFirstNum < ([firstStr floatValue]-0.5)) {
            finalFirstNum = (ceilf([firstStr floatValue])-0.5);
        }
        if (ceilf([firstStr floatValue]) == finalFirstNum) {
            finalFirstNum -= 0.5;
        }
    }
    NSString *finalStr = [NSString stringWithFormat:@"%fE%@",finalFirstNum,lastStr];
    [numFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *finalNum = [numFormatter numberFromString:finalStr];
    return [finalNum floatValue];
}










