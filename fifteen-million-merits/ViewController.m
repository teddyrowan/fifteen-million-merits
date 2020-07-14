//
//  ViewController.m
//  fifteen-million-merits
//
//  Created by TR on 2020-07-06.
//  Copyright © 2020 edwardrowan. All rights reserved.
//

#import "ViewController.h"

#define TAG_KEEP 1 // objects not to clear on subview clearance

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.05 alpha:1];
    
    // Mock background of a 2048 game. Just for the demo.
    UIImageView *demo_background = [[UIImageView alloc] initWithFrame:self.view.bounds];
    demo_background.image = [UIImage imageNamed:@"2048-demo-bg.png"];
    demo_background.tag = TAG_KEEP;
    [self.view addSubview:demo_background];
    
    // For demo. Button in bottom right corner to push an ad.
    UIButton *popAdButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-30, self.view.frame.size.height-30, 30, 30)];
    popAdButton.backgroundColor     = [UIColor colorWithWhite:0.10 alpha:1.0];
    popAdButton.tag = TAG_KEEP;
    [popAdButton addTarget:self action:@selector(loadAdvertisement:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:popAdButton];
}

// Load up whatever advertisement you choose.
- (void) loadAdvertisement:(UIButton*)sender{
    // Clear out other advertisements and the like. For testing. Just to keep max 1 ad on the screen.
    for (UIView *view in [self.view subviews]){
        if (view.tag != TAG_KEEP){
            [view removeFromSuperview];
        }
    }
    
    // Moutain Dew Ad -- replace w/ mountain dew advertisement video.
    AdvertisementView *advertisement = [[AdvertisementView alloc] initWithFrame:self.view.frame];
    //advertisement.adImageView.image = [UIImage imageNamed:@"mountain-dew.jpg"];
    advertisement.adImageView.image = [UIImage imageNamed:@"wraith-ad-edit.png"];
    //advertisement.techDemo = YES;
    advertisement.strictness = 100; // dystopia.
    advertisement.ad_duration = 15;
    [self.view addSubview:advertisement];
    [advertisement startTimer];
}


@end
