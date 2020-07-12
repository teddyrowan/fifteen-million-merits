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
    
    
    // For tech demo. Testing button to pop the advertisement -- add a gradient or something. highlight on click.
    UIButton *popAdButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.center.x-100, 580, 200, 60)];
    [popAdButton setTitle:@"Test Advertisement" forState:UIControlStateNormal];
    popAdButton.backgroundColor     = [UIColor colorWithWhite:0.10 alpha:1.0];
    popAdButton.layer.borderColor   = UIColor.whiteColor.CGColor;
    popAdButton.layer.cornerRadius  = 10;
    popAdButton.layer.borderWidth   = 1;
    popAdButton.tag = TAG_KEEP;
    [popAdButton addTarget:self action:@selector(loadAdvertisement:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:popAdButton];
}

// Load up whatever advertisement you choose.
- (void) loadAdvertisement:(UIButton*)sender{
    // Clear out other advertisements and the like.
    for (UIView *view in [self.view subviews]){
        if (view.tag != TAG_KEEP){
            [view removeFromSuperview];
        }
    }
    
    
    // Moutain Dew Ad -- replace w/ mountain dew advertisement video.
    AdvertisementView *advertisement = [[AdvertisementView alloc] initWithFrame:self.view.frame];
    advertisement.adImageView.image = [UIImage imageNamed:@"mountain-dew.jpg"];
    [advertisement setTechDemo:YES];
    [self.view addSubview:advertisement];
    [advertisement startTimer];
    
    [self.view bringSubviewToFront:sender];
}


@end
