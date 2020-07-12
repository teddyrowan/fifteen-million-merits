//
//  AdvertisementView.m
//  fifteen-million-merits
//
//  Created by TR on 2020-07-09.
//  Copyright © 2020 edwardrowan. All rights reserved.
//

#import "AdvertisementView.h"
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>

@interface AdvertisementView (){
    bool is_paused;                             // is the ad paused ie: is the view obstructed
    int capture_attempts;                       // retry limit for capturing non-zero accelerometer data
    int time_remaining;                         // how much advertisement time is remaining
    
    AVAudioPlayer       *audioPlayer;           // play a noise (resume_viewing.mp3) whenever view is obstructed
    CMMotionManager     *motionManager;         // capture the accelerometer data
    UIImageView         *obstructed_view;       // view to hide the whole screen and alert the user
    UILabel *timerLabel;                        // label that counts down the ad time remaining
    
    double pitch_0, roll_0, yaw_0;              // initial values for principal aircraft coordinates
    double theta_0, phi_0, tilt_0;              // initial values for spherical coordinates
    
    // tech-demo variables
    UILabel *rollLabel, *pitchLabel, *yawLabel;         // aircraft principal axes
    UILabel *thetaLabel, *phiLabel, *tiltLabel;         // spherical coordinate scheme
}
@property (nonatomic) bool is_paused;
@property (nonatomic) double pitch_0, roll_0, yaw_0, theta_0, phi_0, tilt_0;
@property (nonatomic) int time_remaining, capture_attempts;
@property (strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) UIImageView *obstructed_view;
@property (nonatomic, strong) UILabel *timerLabel, *rollLabel, *pitchLabel, *yawLabel, *thetaLabel, *phiLabel, *tiltLabel;
@end

@implementation AdvertisementView
@synthesize adImageView, timerLabel, time_remaining, ad_duration, phi_0, pitch_0, theta_0, yaw_0, tilt_0, roll_0, is_paused, techDemo;
@synthesize rollLabel, pitchLabel, yawLabel, thetaLabel, phiLabel, tiltLabel, motionManager, capture_attempts, obstructed_view;
@synthesize audioPlayer;

#pragma mark - Initialization and Essential Loading Methods

- (id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        adImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.center.x-150, self.center.y-190, 300, 180)];
        [self addSubview:adImageView];
        
        // Manager for the orientation detection. This takes about 0.2s to initialize so call it earlier than later.
        motionManager = [[CMMotionManager alloc] init];
        if (motionManager.deviceMotionAvailable) {
            motionManager.deviceMotionUpdateInterval = 1.0/70.0;
            [motionManager startDeviceMotionUpdates];
        } // else {this is the whole point of the demo, so we doneskies. for framework move this to the start and pop exit out.}
        
        ad_duration = 10; // default duration. 
        is_paused = NO;
        capture_attempts = 0;
        
        [self techDemoSetup];
        [self capture_0];
        [self loadTimerLabel];
        [self loadObstructedView];
        
        // Superloop for checking the orientation of the device and checking the participation of the user
        NSTimer *superloopTimer = [[NSTimer alloc] init];
        superloopTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0
                                                      target:self
                                                    selector:@selector(updateHeadings)
                                                    userInfo:nil
                                                     repeats:YES];
    }
    return self;
}

// Initialization and setup for the timer label that countsdown the remaining mandatory watch time.
- (void) loadTimerLabel{
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
}


// View for when the user is not looking at the view
- (void) loadObstructedView{
    obstructed_view = [[UIImageView alloc] initWithFrame:self.bounds];
    obstructed_view.image = [UIImage imageNamed:@"blocked_view.png"];
    [obstructed_view setHidden:YES];
    [self addSubview:obstructed_view];
    
    UILabel *resumeLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 200, self.frame.size.width-150, 80)];
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
    [obstructed_view addSubview:resumeLabel];
    
    // Setup the obstructed view audio.
    NSURL *soundFileURL = [[NSBundle mainBundle] URLForResource:@"resume_viewing" withExtension:@"mp3"];
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    audioPlayer.numberOfLoops = 0;
}

#pragma mark - Core Methods

// Play the view obstructed obnoxious high pitched sound w/ "Resume Viewing" in the background
- (void) playSound{
    if (!audioPlayer.isPlaying){
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil]; // play on silent.
        [audioPlayer play];
    }
}

// Grab the new headings information, check for the user's participation, and then if it's a tech demo update the labels
- (void) updateHeadings{
    NSDictionary *headings = [self extrapolateHeadings:motionManager];
    bool isParticipating = [self checkUserParticipation:headings];
    if (!isParticipating){
        NSLog(@"WARNING: User may not be watching the advertisement.");
    }
    
    if (techDemo){
        [self updateHeadingLabels:headings];
    }
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
    }
        
    NSLog(@"Advertisement Time Remaining: %ds", time_remaining);
    
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
    //double pitchLimit = 0.35;   // basic 0.35   || strict 0.2 // using phi instead of pitch for now.
    double thetaLimit = 40;     // basic 45     || strict 25 degrees
    double phiLimit = 30;       // basic 35     || strict 20 degrees
    
    is_paused = NO;
    
    // If the user has watched all the mandatory ad then their participation is no longer required.
    if (!time_remaining){
        [obstructed_view setHidden:YES];
        return YES;
    }
    
    if (fabs([[currentHeadings objectForKey:@"phi"] doubleValue] - phi_0) > phiLimit){
        NSLog(@"maximum phi exceeded:: phi_0: %.2f  || phi: %.2f", phi_0, [[currentHeadings objectForKey:@"phi"] doubleValue]);
        is_paused = YES;
        [obstructed_view setHidden:NO];
        [self playSound];
        return NO;
    }
    
    if (fabs([[currentHeadings objectForKey:@"theta"] doubleValue] - theta_0) > thetaLimit){
        NSLog(@"maximum theta exceeded:: theta_0: %.2f  || theta: %.2f", theta_0, [[currentHeadings objectForKey:@"theta"] doubleValue]);
        is_paused = YES;
        [obstructed_view setHidden:NO];
        [self playSound];
        return NO;
    }
    
    [obstructed_view setHidden:YES];
    [audioPlayer stop];
    return YES;
}

#pragma mark - Tech Demo Methods

// Should the tech demo labels be hidden or visible to the user.
- (void) setTechDemo:(bool)on_status{
    techDemo = on_status;
    [rollLabel  setHidden:!on_status];
    [pitchLabel setHidden:!on_status];
    [yawLabel   setHidden:!on_status];
    [thetaLabel setHidden:!on_status];
    [phiLabel   setHidden:!on_status];
    [tiltLabel  setHidden:!on_status];
}

// If this framework is running as a tech demo and you want to show the user what is happening under the hood, we add labels that display the accelerometer data for the device with both coordinate schemes.
- (void) techDemoSetup{
    // Attitude accelerometer data
    rollLabel   = [[UILabel alloc] initWithFrame:CGRectMake(0, 350, 60, 45)];
    pitchLabel  = [[UILabel alloc] initWithFrame:CGRectMake(0, 410, 60, 45)];
    yawLabel    = [[UILabel alloc] initWithFrame:CGRectMake(0, 470, 60, 45)];
    [self defaultAxisLabelSettings:rollLabel];
    [self defaultAxisLabelSettings:pitchLabel];
    [self defaultAxisLabelSettings:yawLabel];
    rollLabel.text  = @"Roll\n0.0";
    pitchLabel.text = @"Pitch\n0.0";
    yawLabel.text   = @"Yaw\n0.0";
    [self addSubview:rollLabel];
    [self addSubview:pitchLabel];
    [self addSubview:yawLabel];
    
    // Spherical coordinates accelerometer data
    thetaLabel  = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-60, 350, 60, 45)];
    phiLabel    = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-60, 410, 60, 45)];
    tiltLabel   = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-60, 470, 60, 45)];
    [self defaultAxisLabelSettings:thetaLabel];
    [self defaultAxisLabelSettings:phiLabel];
    [self defaultAxisLabelSettings:tiltLabel];
    thetaLabel.text = @"𝛉\n0.0";
    phiLabel.text   = @"ɸ\n0.0";
    tiltLabel.text  = @"Tilt\n0.0";
    [self addSubview:thetaLabel];
    [self addSubview:phiLabel];
    [self addSubview:tiltLabel];
    
    [self setTechDemo:NO];
    
}

// This function takes in a UILabel and pushes the standard settings for a tech-demo label (formerly AxisLabel object)
- (void) defaultAxisLabelSettings:(UILabel*)label{
    label.numberOfLines      = 2;
    label.textAlignment      = NSTextAlignmentCenter;
    label.backgroundColor    = [UIColor colorWithWhite:1 alpha:0.15];
    label.font               = [UIFont systemFontOfSize:12];
}

// Update the labels on the sides for the tech demo.
- (void) updateHeadingLabels:(NSDictionary*)headings{
    rollLabel.text      = [NSString stringWithFormat:@"Roll\n%.2f", [[headings objectForKey:@"roll"] doubleValue]];
    pitchLabel.text     = [NSString stringWithFormat:@"Pitch\n%.2f", [[headings objectForKey:@"pitch"] doubleValue]];
    yawLabel.text       = [NSString stringWithFormat:@"Yaw\n%.2f", [[headings objectForKey:@"yaw"] doubleValue]];
    
    phiLabel.text       = [NSString stringWithFormat:@"ɸ\n%.2f", [[headings objectForKey:@"phi"] doubleValue]];
    thetaLabel.text     = [NSString stringWithFormat:@"𝛉\n%.2f", [[headings objectForKey:@"theta"] doubleValue]];
    tiltLabel.text      = [NSString stringWithFormat:@"Tilt\n%.2f°", [[headings objectForKey:@"tilt"] doubleValue]];
}

@end
