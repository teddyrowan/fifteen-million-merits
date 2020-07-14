//
//  ViewController.m
//  fifteen-million-merits
//
//  Created by TR on 2020-07-06.
//  Copyright © 2020 edwardrowan. All rights reserved.
//

#import "ViewController.h"
#import "FMMAdvertisementView.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.05 alpha:1];
    
    // Mock background of a 2048 game. Just for the demo.
    UIImageView *demo_background = [[UIImageView alloc] initWithFrame:self.view.bounds];
    demo_background.image = [UIImage imageNamed:@"2048-demo-bg.png"];
    [self.view addSubview:demo_background];
    
    // info text to prompt user to hit the popAdButton
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-30, self.view.frame.size.width-30, 30)];
    infoLabel.text = @"CLICK FOR AD -->  -->   .";
    infoLabel.font = [UIFont boldSystemFontOfSize:13];
    infoLabel.backgroundColor = UIColor.whiteColor;
    infoLabel.textColor = UIColor.blackColor;
    infoLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:infoLabel];
    
    // For demo. Button in bottom right corner to push an ad.
    UIButton *popAdButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-30, self.view.frame.size.height-30, 30, 30)];
    popAdButton.backgroundColor     = [UIColor colorWithWhite:0.10 alpha:1.0];
    [popAdButton addTarget:self action:@selector(loadAdvertisement:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:popAdButton];
}

// Load up whatever advertisement you choose.
- (void) loadAdvertisement:(UIButton*)sender{
    
    // Moutain Dew Ad -- replace w/ mountain dew advertisement video.
    FMMAdvertisementView *advertisement = [[FMMAdvertisementView alloc] initWithFrame:self.view.frame];
    //advertisement.adImageView.image = [UIImage imageNamed:@"mountain-dew.jpg"];
    advertisement.adImageView.image = [UIImage imageNamed:@"wraith-ad-edit.png"];
    //advertisement.techDemo = YES;
    advertisement.strictness = 100; // dystopia.
    advertisement.ad_duration = 15;
    [self.view addSubview:advertisement];
    [advertisement startTimer];
}


@end
