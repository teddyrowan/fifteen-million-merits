//
//  ViewController.m
//  fifteen-million-merits
//
//  Created by TR on 2020-07-06.
//  Copyright © 2020 edwardrowan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIView *testView = [[UIView alloc] initWithFrame:CGRectMake(50, 100, 100, 100)];
    testView.backgroundColor = UIColor.greenColor;
    [self.view addSubview:testView]; // shows up. good. 
}


@end
