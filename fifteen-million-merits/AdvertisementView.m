//
//  AdvertisementView.m
//  fifteen-million-merits
//
//  Created by TR on 2020-07-09.
//  Copyright © 2020 edwardrowan. All rights reserved.
//

#import "AdvertisementView.h"
#import "AxisLabel.h"
#import <CoreMotion/CoreMotion.h>

@interface AdvertisementView (){
    int time_remaining;
    bool is_paused;
    int capture_attempts;
    
    CMMotionManager     *motionManager;
    
    // tech-demo variables
    AxisLabel *rollLabel, *pitchLabel, *yawLabel;         // aircraft principal axes
    AxisLabel *thetaLabel, *phiLabel, *tiltLabel;         // spherical coordinate scheme
}
@property (nonatomic) int time_remaining, capture_attempts;
@property (nonatomic) bool is_paused;
@property (nonatomic, strong) CMMotionManager *motionManager;

@property (nonatomic, strong) AxisLabel *rollLabel, *pitchLabel, *yawLabel;         // aircraft principal axes
@property (nonatomic, strong) AxisLabel *thetaLabel, *phiLabel, *tiltLabel;         // spherical coordinate sc
@end

@implementation AdvertisementView
@synthesize adImageView, timerLabel, time_remaining, ad_duration, phi_0, pitch_0, theta_0, yaw_0, tilt_0, roll_0, is_paused, techDemo;
@synthesize rollLabel, pitchLabel, yawLabel, thetaLabel, phiLabel, tiltLabel, motionManager, capture_attempts;;

- (id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        adImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.center.x-150, self.center.y-190, 300, 180)];
        [self addSubview:adImageView];
        
        // Manager for the orientation detection -- motionManager needs to get moved into the advertisementView
        // This takes about 0.2s to initialize so call it earlier than later.
        motionManager = [[CMMotionManager alloc] init];
        if (motionManager.deviceMotionAvailable) {
            motionManager.deviceMotionUpdateInterval = 1.0/70.0;
            [motionManager startDeviceMotionUpdates];
        } // else {this is the whole point of the demo, so we doneskies. for framework move this to the start and pop exit out.}
        
        
        ad_duration = 5;
        is_paused = NO;
        capture_attempts = 0;
        
        [self techDemoSetup];
        [self setTechDemo:NO];
        [self capture_0];
        
        timerLabel = [[UILabel alloc] initWithFrame:CGRectMake(adImageView.frame.size.width-20, 0, 20, 20)];
        timerLabel.backgroundColor      = [UIColor colorWithWhite:0.10 alpha:0.15];
        timerLabel.text                 = [NSString stringWithFormat:@"%d", ad_duration];
        timerLabel.layer.borderColor    = UIColor.blackColor.CGColor;
        timerLabel.layer.borderWidth    = 1;
        timerLabel.layer.cornerRadius   = 10;
        timerLabel.clipsToBounds        = YES;
        timerLabel.font                 = [UIFont systemFontOfSize:12];
        timerLabel.textColor            = UIColor.blackColor;
        timerLabel.textAlignment        = NSTextAlignmentCenter;
        [adImageView addSubview:timerLabel];
        
        
        // Timer to update the heading labels.
        NSTimer *labelTimer = [[NSTimer alloc] init];
        labelTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0
                                                      target:self
                                                    selector:@selector(updateHeadingLabels)
                                                    userInfo:nil
                                                     repeats:YES];
    }
    return self;
}

- (void) techDemoSetup{
    // Attitude accelerometer data
    rollLabel   = [[AxisLabel alloc] initWithFrame:CGRectMake(0, 350, 60, 45)];
    pitchLabel  = [[AxisLabel alloc] initWithFrame:CGRectMake(0, 410, 60, 45)];
    yawLabel    = [[AxisLabel alloc] initWithFrame:CGRectMake(0, 470, 60, 45)];
    rollLabel.text  = @"Roll\n0.0";
    pitchLabel.text = @"Pitch\n0.0";
    yawLabel.text   = @"Yaw\n0.0";
    [self addSubview:rollLabel];
    [self addSubview:pitchLabel];
    [self addSubview:yawLabel];
    
    // Spherical coordinates accelerometer data
    thetaLabel  = [[AxisLabel alloc] initWithFrame:CGRectMake(self.frame.size.width-60, 350, 60, 45)];
    phiLabel    = [[AxisLabel alloc] initWithFrame:CGRectMake(self.frame.size.width-60, 410, 60, 45)];
    tiltLabel   = [[AxisLabel alloc] initWithFrame:CGRectMake(self.frame.size.width-60, 470, 60, 45)];
    thetaLabel.text = @"𝛉\n0.0";
    phiLabel.text   = @"ɸ\n0.0";
    tiltLabel.text  = @"Tilt\n0.0";
    [self addSubview:thetaLabel];
    [self addSubview:phiLabel];
    [self addSubview:tiltLabel];
    
}

// Update the labels on the sides for the tech demo. the logic for this only makes sense if the headings only show during the ad.
- (void) updateHeadingLabels{
    NSDictionary *headings = [self extrapolateHeadings:motionManager];
    bool isParticipating = [self checkUserParticipation:headings];
    if (!isParticipating){
        NSLog(@"user not watching the ad");
    }
    
    rollLabel.text      = [NSString stringWithFormat:@"Roll\n%.2f", [[headings objectForKey:@"roll"] doubleValue]];
    pitchLabel.text     = [NSString stringWithFormat:@"Pitch\n%.2f", [[headings objectForKey:@"pitch"] doubleValue]];
    yawLabel.text       = [NSString stringWithFormat:@"Yaw\n%.2f", [[headings objectForKey:@"yaw"] doubleValue]];
    
    phiLabel.text       = [NSString stringWithFormat:@"ɸ\n%.2f", [[headings objectForKey:@"phi"] doubleValue]];
    thetaLabel.text     = [NSString stringWithFormat:@"𝛉\n%.2f", [[headings objectForKey:@"theta"] doubleValue]];
    tiltLabel.text      = [NSString stringWithFormat:@"Tilt\n%.2f°", [[headings objectForKey:@"tilt"] doubleValue]];
}

// Calculate all the heading information for the six directions and return them as a dictionary.
- (NSDictionary*) extrapolateHeadings:(CMMotionManager*)manager{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithDouble:manager.deviceMotion.attitude.pitch] forKey:@"pitch"];
    [dict setObject:[NSNumber numberWithDouble:manager.deviceMotion.attitude.roll] forKey:@"roll"];
    [dict setObject:[NSNumber numberWithDouble:manager.deviceMotion.attitude.yaw] forKey:@"yaw"];
    
    CMRotationMatrix mat = manager.deviceMotion.attitude.rotationMatrix;
    // http://nghiaho.com/?page_id=846 // info on decomposing rotation matrices
    //NSLog(@"m11, m12, m13 : %.2f, %.2f, %.2f", mat.m11, mat.m12, mat.m13);
    //NSLog(@"m21, m22, m23 : %.2f, %.2f, %.2f", mat.m21, mat.m22, mat.m23);
    //NSLog(@"m31, m32, m33 : %.2f, %.2f, %.2f", mat.m31, mat.m32, mat.m33);
    
    double Sx = atan2(mat.m32, mat.m33);                                        // Phi
    double Sy = atan2(-mat.m31, sqrt(mat.m32*mat.m32 + mat.m33*mat.m33));       // Theta
    double Sz = atan2(mat.m21, mat.m11);                                        // Tilt
    
    [dict setObject:[NSNumber numberWithDouble:(Sx*180/M_PI)] forKey:@"phi"];
    [dict setObject:[NSNumber numberWithDouble:(Sy*180/M_PI)] forKey:@"theta"];
    [dict setObject:[NSNumber numberWithDouble:(Sz*180/M_PI)] forKey:@"tilt"];
    
    return dict;
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
        
    NSLog(@"did countdown: %d", time_remaining);
    
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
        [adImageView setUserInteractionEnabled:YES];
        [adImageView addSubview:endButton];
    }
}

// Close the advertisement.
- (void)terminateAd{
    NSLog(@"Terminating Advertisement");
    [self removeFromSuperview];
}

// Store the initial values for the orientation when the advertisement starts playing.
- (void) capture_0{
    NSDictionary *headingDict = [self extrapolateHeadings:motionManager];
    
    phi_0   = [[headingDict objectForKey:@"phi"] doubleValue];
    yaw_0   = [[headingDict objectForKey:@"yaw"] doubleValue];
    theta_0 = [[headingDict objectForKey:@"theta"] doubleValue];
    tilt_0  = [[headingDict objectForKey:@"tilt"] doubleValue];
    pitch_0 = [[headingDict objectForKey:@"pitch"] doubleValue];
    roll_0  = [[headingDict objectForKey:@"roll"] doubleValue];
    
    // The motionManager takes about 0.2s to intialize so the first couple of attempts to capture the orientation usually fail.
    if (fabs(phi_0) < 0.01 && fabs(pitch_0) < 0.01 && fabs(theta_0) < 0.01){
        capture_attempts ++;
        NSLog(@"Error Capturing Initial Orientation. Attempt %d/10", capture_attempts);
        if (capture_attempts >= 10){
            NSLog(@"Failed to capture initial orientation.");
            return;
        }
        [NSThread sleepForTimeInterval:0.1f];
        [self capture_0];
        return;
    }
    NSLog(@"Successful Capture Of Initial Orientation.");
}

// Check whether the user is still looking at the screen
- (bool) checkUserParticipation:(NSDictionary*)currentHeadings{
    double pitchLimit = 0.35;   // basic 0.35   || strict 0.2
    double thetaLimit = 45;     // basic 45     || strict 25 degrees
    // might be able to use phi to check between turn of phone vs person rollover.
    // i think i actually want to look at phi instead of pitch. 
    
    is_paused = NO;
    
    if (fabs([[currentHeadings objectForKey:@"pitch"] doubleValue] - pitch_0) > pitchLimit){
        NSLog(@"maximum pitch exceeded:: pitch_0: %.2f  || pitch: %.2f", pitch_0, [[currentHeadings objectForKey:@"pitch"] doubleValue]);
        is_paused = YES;
        
        /*
        UIImageView *testBlock = [[UIImageView alloc] initWithFrame:CGRectMake(-100, -150, 600, 800)];
        testBlock.image = [UIImage imageNamed:@"blocked_view.png"];
        [self addSubview:testBlock];
        
        UILabel *resumeLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 50, self.frame.size.width-100, self.frame.size.height-100)];
        resumeLabel.text = @"RESUME VIEWING";
        resumeLabel.font = [UIFont boldSystemFontOfSize:16];
        resumeLabel.alpha = 0.85;
        resumeLabel.clipsToBounds = YES;
        resumeLabel.textAlignment = NSTextAlignmentCenter;
        resumeLabel.textColor = UIColor.whiteColor;
        resumeLabel.layer.cornerRadius = 10;
        resumeLabel.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.75].CGColor;
        resumeLabel.layer.borderWidth = 3;
        resumeLabel.backgroundColor = [UIColor colorWithRed:1.0 green:0.5 blue:0.66 alpha:0.80];
        [self addSubview:resumeLabel];
        */
        
        return NO;
    }
    if (fabs([[currentHeadings objectForKey:@"theta"] doubleValue] - theta_0) > thetaLimit){
        NSLog(@"maximum theta exceeded:: theta_0: %.2f  || theta: %.2f", theta_0, [[currentHeadings objectForKey:@"theta"] doubleValue]);
        is_paused = YES;
        return NO;
    }
    
    return YES;
}


- (void) setTechDemo:(bool)on_status{
    techDemo = on_status;
    [rollLabel  setHidden:!on_status];
    [pitchLabel setHidden:!on_status];
    [yawLabel   setHidden:!on_status];
    [thetaLabel setHidden:!on_status];
    [phiLabel   setHidden:!on_status];
    [tiltLabel  setHidden:!on_status];
}


@end
