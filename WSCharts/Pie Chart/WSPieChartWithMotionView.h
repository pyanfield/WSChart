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
#import "WSBaseChartDelegate.h"
/*
 The different with WSPieChartView are as below:
 1. moving drawing sector part from UIView to CALayer.
 2. adding animation to the pie when open the pie chart.
 3. adding transform pies when switch to new datas.
 4. removing indicator of pie data.
 */

@interface WSPieChartWithMotionView : UIView<WSBaseChartDelegate>

@property (nonatomic) BOOL touchEnabled;
@property (nonatomic) BOOL openEnabled;
/*
 Carefully use the showShadow property. This is a fake shadow for the pie. create duplicated sectors for the pies on UIView and CALayer.
 if the showShadow is true:
    1.will draw the shadow for the Opened/OpenOngoing/CloseOngoing pie on WSPieItem's layer (drawLayer:inContext:). 
      so that the shadow can rendered with the open and close animation.
    2.will draw the shadow for the Closed pies on UIView's drawRect: .In the UIView's drawRect: , we can use the CGContextBeginTransparencyLayer.
 So when open the showShadow property, maybe will impact your app's performance.
 */
@property (nonatomic) BOOL showShadow;
@property (nonatomic) BOOL hasLegends;

/*
 When you first time to draw the chart, you need to pass "arr" and "dict".
 But if you just switch data to new one, just pass "arr" and keep dict as nil.
 */
- (void)drawChart:(NSArray *)arr withColor:(NSDictionary *)dict;

@end
