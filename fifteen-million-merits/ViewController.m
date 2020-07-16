//
//  ViewController.m
//  fifteen-million-merits
//
//  Authored by Teddy Rowan
//  Copyright © 2020 teddyrowan. All rights reserved.
//

#import "ViewController.h"
#import "FMMAdvertisementView.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor       = [UIColor colorWithWhite:0.05 alpha:1];
    
    // Mock background of a 2048 game. Just for the demo.
    UIImageView *demo_background    = [[UIImageView alloc] initWithFrame:self.view.bounds];
    demo_background.image           = [UIImage imageNamed:@"2048-demo-bg.png"];
    [self.view addSubview:demo_background];
    
    double box_height = 30; // height of the button in the bottom right corner
    
    // info text to prompt user to hit the popAdButton
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-box_height, self.view.frame.size.width-box_height, box_height)];
    infoLabel.text              = @"CLICK FOR AD -->  -->   .";
    infoLabel.font              = [UIFont boldSystemFontOfSize:13];
    infoLabel.backgroundColor   = UIColor.whiteColor;
    infoLabel.textColor         = UIColor.blackColor;
    infoLabel.textAlignment     = NSTextAlignmentRight;
    [self.view addSubview:infoLabel];
    
    // For demo. Button in bottom right corner to push an ad.
    UIButton *popAdButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-box_height, self.view.frame.size.height-box_height, box_height, box_height)];
    popAdButton.backgroundColor     = [UIColor colorWithWhite:0.10 alpha:1.0];
    [popAdButton addTarget:self action:@selector(loadAdvertisement:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:popAdButton];
}

// Load up whatever advertisement you choose.
- (void) loadAdvertisement:(UIButton*)sender{
    FMMAdvertisementView *advertisement = [[FMMAdvertisementView alloc] initWithFrame:self.view.frame];
    advertisement.adImageView.image     = [UIImage imageNamed:@"wraith-ad-edit.png"];
    [advertisement setAdAudioWithName:@"wraith-ad-audio" andExtenstion:@"mp3"];     // audio to accompany the photo
    
    //advertisement.techDemo    = YES;
    advertisement.strictness    = 100;      // dystopian settings
    advertisement.ad_duration   = 15;       // 15 seconds is really long for a photo ad, but better for testing purposes
    [self.view addSubview:advertisement];
    [advertisement startTimer];
}

@end
