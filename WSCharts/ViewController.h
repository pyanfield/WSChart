//
//  ViewController.h
//  WSCharts
//
//  Created by han pyanfield on 12-2-2.
//  Copyright (c) 2012年 pyanfield. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITabBarDelegate>

@property (weak, nonatomic) IBOutlet UIButton *switchBtn;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;
- (IBAction)switchData:(id)sender;
@end
