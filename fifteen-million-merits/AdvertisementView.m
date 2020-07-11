//
//  AdvertisementView.m
//  fifteen-million-merits
//
//  Created by TR on 2020-07-09.
//  Copyright © 2020 edwardrowan. All rights reserved.
//

#import "AdvertisementView.h"

@implementation AdvertisementView
@synthesize adImageView, timerLabel, timeRemaining, phi_0, pitch_0, theta_0, yaw_0, tilt_0, roll_0;

- (id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        adImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:adImageView];
        
        timeRemaining = 5; // for now.
        
        timerLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width-20, 0, 20, 20)];
        timerLabel.backgroundColor      = [UIColor colorWithWhite:0.10 alpha:0.25];
        timerLabel.text                 = [NSString stringWithFormat:@"%d", timeRemaining];
        timerLabel.layer.borderColor    = UIColor.blackColor.CGColor;
        timerLabel.layer.borderWidth    = 1;
        timerLabel.layer.cornerRadius   = 10;
        timerLabel.clipsToBounds        = YES;
        timerLabel.font                 = [UIFont systemFontOfSize:12];
        timerLabel.textColor            = UIColor.blackColor;
        timerLabel.textAlignment        = NSTextAlignmentCenter;
        [self addSubview:timerLabel];
        
        NSTimer *countdownTimer = [[NSTimer alloc] init];
        countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countdown:) userInfo:nil repeats:YES];
    }
    return self;
}

// After mandatory watch period allow the user to kill the ad.
- (void)countdown:(NSTimer*)sender{
    timeRemaining --;
    timerLabel.text = [NSString stringWithFormat:@"%d", timeRemaining];
    
    if (timeRemaining <= 0){
        [sender invalidate];
        [timerLabel removeFromSuperview];
        
        UIButton *endButton             = [[UIButton alloc] initWithFrame:timerLabel.frame];
        endButton.layer.cornerRadius    = timerLabel.layer.cornerRadius;
        endButton.layer.borderWidth     = timerLabel.layer.borderWidth;
        endButton.layer.borderColor     = UIColor.whiteColor.CGColor;
        endButton.titleLabel.font       = [UIFont systemFontOfSize:12];
        endButton.backgroundColor       = [UIColor colorWithRed:1.0 green:0.2 blue:0.2 alpha:0.25];
        [endButton setTitle:@"X" forState:UIControlStateNormal];
        [endButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [endButton addTarget:self action:@selector(terminateAd) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:endButton];
    }
}

// Close the advertisement.
- (void)terminateAd{
    [self removeFromSuperview];
}

// Store the initial values for the orientation when the advertisement starts playing.
- (void) capture_0:(NSDictionary*)headingDict{
    phi_0   = [[headingDict objectForKey:@"phi"] doubleValue];
    yaw_0   = [[headingDict objectForKey:@"yaw"] doubleValue];
    theta_0 = [[headingDict objectForKey:@"theta"] doubleValue];
    tilt_0  = [[headingDict objectForKey:@"tilt"] doubleValue];
    pitch_0 = [[headingDict objectForKey:@"pitch"] doubleValue];
    roll_0  = [[headingDict objectForKey:@"roll"] doubleValue];
}

// Check whether the user is still looking at the screen
- (bool) checkUserParticipation:(NSDictionary*)currentHeadings{
    double pitchLimit = 0.35;
    double thetaLimit = 45;
    
    if (fabs([[currentHeadings objectForKey:@"pitch"] doubleValue] - pitch_0) > pitchLimit){
        NSLog(@"maximum pitch exceeded");
        return NO;
    }
    if (fabs([[currentHeadings objectForKey:@"theta"] doubleValue] - theta_0) > thetaLimit){
        NSLog(@"maximum theta exceeded");
        return NO;
    }
    
    
    return YES;
}

// pitchLimit ~ 0.35 pitch constrained and continuous from -pi/2 to pi/2
// thetaLimit ~ 45degrees constrained and continuous from -90 to 90 degrees
//
// and then strict settings:
// pitchLimit ~ 0.20
// thetaLimit ~ 25degrees

// might be able to use phi to check between turn of phone vs person rollover.

@end
