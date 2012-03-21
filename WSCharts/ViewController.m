//
//  ViewController.m
//  WSCharts
//
//  Created by han pyanfield on 12-2-2.
//  Copyright (c) 2012年 pyanfield. All rights reserved.
//

#import "ViewController.h"
#import "WSPieChartView.h"
#import "WSPieChartWithMotionView.h"
#import "WSColumnChartView.h"
#import "WSLineChartView.h"
#import "WSAreaChartView.h"
#import "WSScatterChartView.h"
#import "WSChartObject.h"
#import "WSComboChartView.h"

@interface ViewController()

@property (nonatomic, strong) NSMutableDictionary *pieData;
@property (nonatomic, strong) NSMutableDictionary *pieData2;
@property (nonatomic, strong) WSPieChartWithMotionView *pieChart;
@property (nonatomic, strong) WSColumnChartView *columnChart;
@property (nonatomic, strong) WSLineChartView *lineChart;
@property (nonatomic, strong) WSAreaChartView *areaChart;
@property (nonatomic, strong) WSScatterChartView *scatterChart;
@property (nonatomic, strong) WSComboChartView *comboChart;
@property (nonatomic) BOOL flag;

@end

@implementation ViewController

@synthesize pieData,pieData2,pieChart;
@synthesize areaChart;
@synthesize lineChart;
@synthesize columnChart;
@synthesize scatterChart;
@synthesize comboChart;

@synthesize flag;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    /*
    // demo data for WSPieChartWithMotionView
    pieData = [[NSMutableDictionary alloc] init];
    NSMutableArray *colors = [[NSMutableArray alloc] init];
    pieData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSNumber alloc] initWithFloat:20],@"test1",[[NSNumber alloc] initWithFloat:34],@"test2",[[NSNumber alloc] initWithFloat:55],@"test3",[[NSNumber alloc] initWithFloat:12],@"test4",[[NSNumber alloc] initWithFloat:78],@"test5",[[NSNumber alloc] initWithFloat:110],@"test6",nil];
    colors = [[NSMutableArray alloc] initWithObjects:[UIColor purpleColor],[UIColor blueColor],[UIColor greenColor],[UIColor redColor],[UIColor yellowColor],[UIColor brownColor], nil]; 
    
    pieChart = [[WSPieChartWithMotionView alloc] initWithFrame:CGRectMake(10.0, 10.0, 500.0, 500.0)];
    pieChart.data = pieData;
    pieChart.colors = colors;
    pieChart.touchEnabled = YES;
    //pieChart.showIndicator = YES;
    pieChart.openEnabled = YES;
    pieChart.showShadow = YES;
    pieChart.hasLegends = YES;
    pieChart.backgroundColor = [UIColor blackColor];
    [self.view addSubview:pieChart];
    
    pieData2 = [[NSMutableDictionary alloc] init];
    pieData2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSNumber alloc] initWithFloat:15],@"test5",[[NSNumber alloc] initWithFloat:80],@"test3",[[NSNumber alloc] initWithFloat:5],@"test2",[[NSNumber alloc] initWithFloat:5],@"test1",[[NSNumber alloc] initWithFloat:5],@"test4",[[NSNumber alloc] initWithFloat:5],@"test6",nil];
     
     */
    /*
    // demo data for WSPieChartView
    WSPieChartView *pieChart = [[WSPieChartView alloc] initWithFrame:CGRectMake(10.0, 10.0, 500.0, 500.0)];
    pieChart.data = pieData;
    pieChart.colors = colors;
    pieChart.touchEnabled = YES;
    pieChart.showIndicator = YES;
    //pieChart.openEnabled = YES;
    [self.view addSubview:pieChart];
     */
    
    
    // demo data for WSColumnChartView
    /*
    columnChart = [[WSColumnChartView alloc] initWithFrame:CGRectMake(10.0, 50.0, 900.0, 400.0)];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (int i=0; i<5; i++) {
        WSChartObject *lfcObj = [[WSChartObject alloc] init];
        lfcObj.name = @"Liverpool";
        lfcObj.xValue = [NSString stringWithFormat:@"%d",i];
        lfcObj.yValue = arc4random() % 400;
        WSChartObject *chObj = [[WSChartObject alloc] init];
        chObj.name = @"Chelsea";
        chObj.xValue = [NSString stringWithFormat:@"%d",i];
        chObj.yValue = (int)(arc4random() % 400) - 140;
        WSChartObject *muObj = [[WSChartObject alloc] init];
        muObj.name = @"MU";
        muObj.xValue = [NSString stringWithFormat:@"%d",i];
        muObj.yValue = (int)(arc4random() % 200) - 30;
        WSChartObject *mcObj = [[WSChartObject alloc] init];
        mcObj.name = @"ManCity";
        mcObj.xValue = [NSString stringWithFormat:@"%d",i];
        mcObj.yValue = (int)(arc4random() % 100) - 150;
        NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:lfcObj,@"Liverpool",
                              muObj,@"MU",
                              chObj,@"Chelsea",
                              mcObj,@"ManCity",nil];
        [arr addObject:data];
    }
    NSDictionary *colorDict = [[NSDictionary alloc] initWithObjectsAndKeys:[UIColor redColor],@"Liverpool",
                               [UIColor purpleColor],@"MU",
                               [UIColor greenColor],@"Chelsea",
                               [UIColor orangeColor],@"ManCity", nil];
    columnChart.rowWidth = 20.0;
    columnChart.title = @"Test the Column Chart";
    columnChart.showZeroValueOnYAxis = YES;
    [columnChart drawChart:arr withColor:colorDict];
    columnChart.backgroundColor = [UIColor blackColor];
    [self.view addSubview:columnChart];
     */
    
    // demo data for WSLineChartView
    /*
    lineChart = [[WSLineChartView alloc] initWithFrame:CGRectMake(10.0, 50.0, 900.0, 400.0)];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (int i=0; i<30; i++) {
        WSChartObject *lfcObj = [[WSChartObject alloc] init];
        lfcObj.name = @"Liverpool";
        lfcObj.xValue = [NSString stringWithFormat:@"%d",i];
        lfcObj.yValue = arc4random() % 400;
        WSChartObject *chObj = [[WSChartObject alloc] init];
        chObj.name = @"Chelsea";
        chObj.xValue = [NSString stringWithFormat:@"%d",i];
        chObj.yValue = (int)(arc4random() % 400) - 140;
        WSChartObject *muObj = [[WSChartObject alloc] init];
        muObj.name = @"MU";
        muObj.xValue = [NSString stringWithFormat:@"%d",i];
        muObj.yValue = (int)(arc4random() % 200) - 30;
        WSChartObject *mcObj = [[WSChartObject alloc] init];
        mcObj.name = @"ManCity";
        mcObj.xValue = [NSString stringWithFormat:@"%d",i];
        mcObj.yValue = (int)(arc4random() % 100) - 150;
        NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:lfcObj,@"Liverpool",
                              muObj,@"MU",
                              chObj,@"Chelsea",
                              mcObj,@"ManCity",nil];
        [arr addObject:data];
    }
    NSDictionary *colorDict = [[NSDictionary alloc] initWithObjectsAndKeys:[UIColor redColor],@"Liverpool",
                               [UIColor purpleColor],@"MU",
                               [UIColor greenColor],@"Chelsea",
                               [UIColor orangeColor],@"ManCity", nil];

    lineChart.xAxisKey = @"Year";
    lineChart.rowWidth = 20.0;
    lineChart.title = @"Pyanfield's Line Chart";
    lineChart.showZeroValueOnYAxis = YES;
    [lineChart drawChart:arr withColor:colorDict];
    lineChart.backgroundColor = [UIColor blackColor];
    [self.view addSubview:lineChart];
    */ 
    /*
    // demo for area chart
    areaChart  = [[WSAreaChartView alloc] initWithFrame:CGRectMake(10.0, 50.0, 900.0, 400.0)];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (int i=0; i<30; i++) {
        WSChartObject *lfcObj = [[WSChartObject alloc] init];
        lfcObj.name = @"Liverpool";
        lfcObj.xValue = [NSString stringWithFormat:@"%d",i];
        lfcObj.yValue = arc4random() % 400;
        WSChartObject *chObj = [[WSChartObject alloc] init];
        chObj.name = @"Chelsea";
        chObj.xValue = [NSString stringWithFormat:@"%d",i];
        chObj.yValue = (int)(arc4random() % 400) - 140;
        WSChartObject *muObj = [[WSChartObject alloc] init];
        muObj.name = @"MU";
        muObj.xValue = [NSString stringWithFormat:@"%d",i];
        muObj.yValue = (int)(arc4random() % 200) - 30;
        WSChartObject *mcObj = [[WSChartObject alloc] init];
        mcObj.name = @"ManCity";
        mcObj.xValue = [NSString stringWithFormat:@"%d",i];
        mcObj.yValue = (int)(arc4random() % 100) - 150;
        NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:lfcObj,@"Liverpool",
                              muObj,@"MU",
                              chObj,@"Chelsea",
                              mcObj,@"ManCity",nil];
        [arr addObject:data];
    }
    NSDictionary *colorDict = [[NSDictionary alloc] initWithObjectsAndKeys:[UIColor redColor],@"Liverpool",
                               [UIColor purpleColor],@"MU",
                               [UIColor greenColor],@"Chelsea",
                               [UIColor orangeColor],@"ManCity", nil];
    
    areaChart.rowWidth = 20.0;
    areaChart.title = @"Pyanfield's Area Chart";
    areaChart.showZeroValueOnYAxis = YES;
    [areaChart drawChart:arr withColor:colorDict];
    areaChart.backgroundColor = [UIColor blackColor];
    [self.view addSubview:areaChart];
     */
    /*
    //demo code for scatter chart
    scatterChart  = [[WSScatterChartView alloc] initWithFrame:CGRectMake(10.0, 50.0, 900.0, 400.0)];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (int i=0; i<5; i++) {
        WSChartObject *lfcObj = [[WSChartObject alloc] init];
        lfcObj.name = @"Liverpool";
        lfcObj.xValue = [NSNumber numberWithInt:(int)(arc4random() % 600) - 300 ];
        lfcObj.yValue = arc4random() % 400;
        WSChartObject *chObj = [[WSChartObject alloc] init];
        chObj.name = @"Chelsea";
        chObj.xValue = [NSNumber numberWithInt: arc4random() % 600];
        chObj.yValue = (int)(arc4random() % 400) - 140;
        WSChartObject *muObj = [[WSChartObject alloc] init];
        muObj.name = @"MU";
        muObj.xValue = [NSNumber numberWithInt: (int)(arc4random() % 600) - 300];
        muObj.yValue = (int)(arc4random() % 200) - 30;
        WSChartObject *mcObj = [[WSChartObject alloc] init];
        mcObj.name = @"ManCity";
        mcObj.xValue = [NSNumber numberWithInt: (int)(arc4random() % 600) - 250];
        mcObj.yValue = (int)(arc4random() % 100) - 150;
        NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:lfcObj,@"Liverpool",
                              muObj,@"MU",
                              chObj,@"Chelsea",
                              mcObj,@"ManCity",nil];
        [arr addObject:data];
    }
    NSDictionary *colorDict = [[NSDictionary alloc] initWithObjectsAndKeys:[UIColor redColor],@"Liverpool",
                               [UIColor purpleColor],@"MU",
                               [UIColor greenColor],@"Chelsea",
                               [UIColor orangeColor],@"ManCity", nil];
    scatterChart.title = @"Pyanfield's Scatter Chart";
    scatterChart.showZeroValueOnYAxis = YES;
    scatterChart.yAxisName = @"Y Axis";
    scatterChart.xAxisName = @"X Axis";
    [scatterChart drawChart:arr withColor:colorDict];
    scatterChart.backgroundColor = [UIColor blackColor];
    [self.view addSubview:scatterChart];
     */
    
    comboChart = [[WSComboChartView alloc] initWithFrame:CGRectMake(10.0, 50.0, 900.0, 400.0)];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (int i=0; i<5; i++) {
        WSChartObject *lfcObj = [[WSChartObject alloc] init];
        lfcObj.name = @"Liverpool";
        lfcObj.xValue = [NSString stringWithFormat:@"%d",i];
        lfcObj.yValue = arc4random() % 400;
        WSChartObject *chObj = [[WSChartObject alloc] init];
        chObj.name = @"Chelsea";
        chObj.xValue = [NSString stringWithFormat:@"%d",i];
        chObj.yValue = (int)(arc4random() % 400) - 140;
        WSChartObject *muObj = [[WSChartObject alloc] init];
        muObj.name = @"MU";
        muObj.xValue = [NSString stringWithFormat:@"%d",i];
        muObj.yValue = (int)(arc4random() % 200) - 30;
        WSChartObject *mcObj = [[WSChartObject alloc] init];
        mcObj.name = @"ManCity";
        mcObj.xValue = [NSString stringWithFormat:@"%d",i];
        mcObj.yValue = (int)(arc4random() % 100) - 150;
        
        WSChartObject *avgObj = [[WSChartObject alloc] init];
        avgObj.name = @"Average";
        avgObj.xValue = [NSString stringWithFormat:@"%d",i];
        avgObj.yValue = (lfcObj.yValue + chObj.yValue + muObj.yValue + muObj.yValue)/4.0;
        
        NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:lfcObj,@"Liverpool",
                              muObj,@"MU",
                              chObj,@"Chelsea",
                              mcObj,@"ManCity",
                              avgObj,@"Average",nil];
        [arr addObject:data];
    }
    NSDictionary *colorDict = [[NSDictionary alloc] initWithObjectsAndKeys:[UIColor redColor],@"Liverpool",
                               [UIColor purpleColor],@"MU",
                               [UIColor greenColor],@"Chelsea",
                               [UIColor orangeColor],@"ManCity",
                               [UIColor blueColor],@"Average", nil];
    comboChart.rowWidth = 20.0;
    comboChart.rowDistance = 6.0;
    comboChart.title = @"Pyanfield's Combo Chart";
    comboChart.showZeroValueOnYAxis = YES;
    comboChart.lineKeyName = @"Average";
    [comboChart drawChart:arr withColor:colorDict];
    comboChart.backgroundColor = [UIColor blackColor];
    [self.view addSubview:comboChart];
}

- (IBAction)switchData:(id)sender {
    //flag?[pieChart switchData:pieData]:[pieChart switchData:pieData2];
    flag = !flag;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}


@end
