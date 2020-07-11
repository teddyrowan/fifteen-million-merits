//
//  AdvertisementView.m
//  fifteen-million-merits
//
//  Created by TR on 2020-07-09.
//  Copyright © 2020 edwardrowan. All rights reserved.
//

#import "AdvertisementView.h"

@interface AdvertisementView (){
    int time_remaining;
    bool is_paused;
}
@property (nonatomic) int time_remaining;
@property (nonatomic) bool is_paused;
@end

@implementation AdvertisementView
@synthesize adImageView, timerLabel, time_remaining, ad_duration, phi_0, pitch_0, theta_0, yaw_0, tilt_0, roll_0, is_paused;

- (id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        adImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:adImageView];
        
        ad_duration = 5;
        is_paused = NO;
        
        timerLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width-20, 0, 20, 20)];
        timerLabel.backgroundColor      = [UIColor colorWithWhite:0.10 alpha:0.15];
        timerLabel.text                 = [NSString stringWithFormat:@"%d", ad_duration];
        timerLabel.layer.borderColor    = UIColor.blackColor.CGColor;
        timerLabel.layer.borderWidth    = 1;
        timerLabel.layer.cornerRadius   = 10;
        timerLabel.clipsToBounds        = YES;
        timerLabel.font                 = [UIFont systemFontOfSize:12];
        timerLabel.textColor            = UIColor.blackColor;
        timerLabel.textAlignment        = NSTextAlignmentCenter;
        [self addSubview:timerLabel];
    }
    return self;
}

// Begin the ad timer countdown.
- (void) startTimer{
    time_remaining = ad_duration;
    
    NSTimer *countdownTimer = [[NSTimer alloc] init];
    countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countdown:) userInfo:nil repeats:YES];
}

// After mandatory watch period allow the user to kill the ad.
- (void)countdown:(NSTimer*)sender{
    if (!is_paused){
        time_remaining --;
        timerLabel.text = [NSString stringWithFormat:@"%d", time_remaining];
    } else {
        timerLabel.text = @"!";
    }
        
    if (time_remaining <= 0){
        [sender invalidate];
        [timerLabel removeFromSuperview];
        
        UIButton *endButton             = [[UIButton alloc] initWithFrame:timerLabel.frame];
        endButton.layer.cornerRadius    = timerLabel.layer.cornerRadius;
        endButton.layer.borderWidth     = 0;//timerLabel.layer.borderWidth;
        endButton.layer.borderColor     = UIColor.blackColor.CGColor;
        endButton.titleLabel.font       = [UIFont systemFontOfSize:12];
        endButton.backgroundColor       = [UIColor colorWithWhite:0.10 alpha:0.10];
        [endButton setTitle:@"X" forState:UIControlStateNormal];
        [endButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
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
    double pitchLimit = 0.35;   // basic 0.35   || strict 0.2
    double thetaLimit = 45;     // basic 45     || strict 25 degrees
    // might be able to use phi to check between turn of phone vs person rollover.
    is_paused = NO;
    
    if (fabs([[currentHeadings objectForKey:@"pitch"] doubleValue] - pitch_0) > pitchLimit){
        NSLog(@"maximum pitch exceeded");
        is_paused = YES;
        return NO;
    }
    if (fabs([[currentHeadings objectForKey:@"theta"] doubleValue] - theta_0) > thetaLimit){
        NSLog(@"maximum theta exceeded");
        is_paused = YES;
        return NO;
    }
    
    return YES;
}


@end
