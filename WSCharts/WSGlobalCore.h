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

#import <Foundation/Foundation.h>

typedef enum {
    kWSTopLeft,
    kWSTopRight,
    kWSBottomLeft,
    kWSBottomRight,
    kWSRight,
    kWSLeft,
    kWSTop,
    kWSBottom,
    kWSCenter,
} WSAliment;


/*
 Create the pie's sector path. Using this path to draw the pie.
 */
CGMutablePathRef CreatePiePathWithCenter(CGPoint center, CGFloat radius,CGFloat startAngle, CGFloat angle,CGAffineTransform *transform);
/*
 Extract different brightness colors from "color".
 */
NSDictionary* ConstructBrightAndDarkColors(UIColor *color);
/*
 Create a point that is away from "startPoint".
 */
CGPoint CreateEndPoint(CGPoint startPoint,CGFloat angle,CGFloat distance);
/*
 Draw the string "text" at ponint "p1",with the "color".
 */
void CreateTextAtPoint(CGContextRef ctx,NSString *text,CGPoint p1,UIColor *color,WSAliment alignment);
/*
 Draw a line from "point".
 */
void CreateLineWithLengthFromPoint(CGContextRef ctx,BOOL isXAxis, CGPoint point, CGFloat length,BOOL isDash,UIColor *color);
/*
 Draw a line from "p1" to "p2".
 */
void CreateLinePointToPoint(CGContextRef ctx,CGPoint p1,CGPoint p2,BOOL isDash,UIColor *color);
/*
 Get a alpha color.
*/
UIColor* CreateAlphaColor(UIColor *color, CGFloat alphaValue);
/*
 Calculate the user data's max and min value which should be displayed on axis.
 */
float CalculateAxisExtremePointValue(float value,BOOL max);
/*
 Calculate the marks' value which should be displayed on axis. 
 */
NSMutableArray* CalculateValuesBetweenMinAndMax(CGFloat min,CGFloat max, int count);






