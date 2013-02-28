//
//  ViewController.h
//  WSChartsDemo
//
//  Created by Weishuai Han on 2/28/13.
//  Copyright (c) 2013 pyanfield. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITabBarDelegate>

@property (weak, nonatomic) IBOutlet UIButton *switchBtn;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;
- (IBAction)switchData:(id)sender;

@end
