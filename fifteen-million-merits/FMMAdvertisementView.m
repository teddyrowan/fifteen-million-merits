//
//  FMMAdvertisementView.m
//  fifteen-million-merits
//
//  Authored by Teddy Rowan
//  Copyright © 2020 teddyrowan. All rights reserved.
//

#import "FMMAdvertisementView.h"
#import <CoreMotion/CoreMotion.h>

@interface FMMAdvertisementView (){
    bool is_paused;                             // is the ad paused ie: is the view obstructed
    int capture_attempts;                       // retry limit for capturing non-zero accelerometer data
    int time_remaining;                         // how much advertisement time is remaining
    bool ad_has_audio;                          // does the advertisement have audio
    
    AVAudioPlayer       *obstructedAudioPlayer; // play a noise (resume_viewing.mp3) whenever view is obstructed
    CMMotionManager     *motionManager;         // capture the accelerometer data
    UIImageView         *adImageView;           // the image (video support to be added) for the advertisement
    UIImageView         *arrowPhi;              // arrow to guide user back for phi direction
    UIImageView         *arrowTheta;            // arrow to guide user back for theta direction
    UIImageView         *obstructed_view;       // view to hide the whole screen and alert the user
    UILabel             *timerLabel;            // label that counts down the ad time remaining
    
    double pitch_0, roll_0, yaw_0;              // initial values for principal aircraft coordinates
    double theta_0, phi_0, tilt_0;              // initial values for spherical coordinates
    
}
@property (nonatomic) bool is_paused;
@property (nonatomic) double pitch_0, roll_0, yaw_0, theta_0, phi_0, tilt_0;
@property (nonatomic) int time_remaining, capture_attempts;
@property (strong) AVAudioPlayer *obstructedAudioPlayer;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) UIImageView *obstructed_view, *adImageView, *arrowPhi, *arrowTheta;
@property (nonatomic, strong) UILabel *timerLabel;
@end

@implementation FMMAdvertisementView
@synthesize adImageView, timerLabel, time_remaining, ad_duration, phi_0, pitch_0, theta_0, yaw_0, tilt_0, roll_0, is_paused, motionManager, capture_attempts, obstructed_view, obstructedAudioPlayer, strictness, adAudioPlayer, arrowPhi, arrowTheta;

#pragma mark - Initialization and Essential Loading Methods

- (id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        self.backgroundColor = [UIColor colorWithWhite:0.05 alpha:0.85];
        
        adImageView = [[UIImageView alloc] init]; // frame to be resized when image is added.
        [self addSubview:adImageView];
        
        // Advertisement Variables that are required whether motionManager is available or not
        [self loadTimerLabel];
        ad_duration = 10;       // default duration.
        
        // Manager for the orientation detection. This takes about 0.2s to initialize so call it earlier than later.
        motionManager = [[CMMotionManager alloc] init];
        if (motionManager.deviceMotionAvailable) {
            motionManager.deviceMotionUpdateInterval = 1.0/70.0;
            [motionManager startDeviceMotionUpdates];
        } else {
            NSLog(@"deviceMotion Is Not Available"); // Simulator.
            return self; // play a normal ad if there is no orientation detection support
        }
        
        // Variables / setup that are only required if motionManager is available
        strictness          = 50;   // default
        is_paused           = NO;
        capture_attempts    = 0;
        ad_has_audio        = NO;
        
        [self capture_0];
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
    obstructed_view         = [[UIImageView alloc] initWithFrame:self.bounds];
    obstructed_view.image   = [UIImage imageNamed:@"blocked_view.png"];
    [obstructed_view setHidden:YES];
    [self addSubview:obstructed_view];
    
    UILabel *resumeLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 200, self.frame.size.width-150, 80)];
    resumeLabel.text                = @"RESUME VIEWING";
    resumeLabel.font                = [UIFont boldSystemFontOfSize:16];
    resumeLabel.alpha               = 0.85;
    resumeLabel.clipsToBounds       = YES;
    resumeLabel.textAlignment       = NSTextAlignmentCenter;
    resumeLabel.textColor           = UIColor.whiteColor;
    resumeLabel.layer.cornerRadius  = 10;
    resumeLabel.layer.borderColor   = [UIColor colorWithWhite:1 alpha:0.75].CGColor;
    resumeLabel.layer.borderWidth   = 3;
    resumeLabel.backgroundColor     = [UIColor colorWithRed:1.0 green:0.5 blue:0.66 alpha:0.80];
    [obstructed_view addSubview:resumeLabel];
    
    arrowTheta = [[UIImageView alloc] initWithFrame:CGRectMake(10, obstructed_view.frame.size.height/2-25, 65, 50)];
    arrowTheta.image = [UIImage imageNamed:@"arrow_left_default"];
    [obstructed_view addSubview:arrowTheta];
    
    arrowPhi = [[UIImageView alloc] initWithFrame:CGRectMake(obstructed_view.frame.size.width/2 - 32, 20, 65, 50)];
    arrowPhi.image = [UIImage imageNamed:@"arrow_left_default"];
    [obstructed_view addSubview:arrowPhi];
    
    // Setup the obstructed view audio.
    NSURL *soundFileURL = [[NSBundle mainBundle] URLForResource:@"resume_viewing" withExtension:@"mp3"];
    obstructedAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    obstructedAudioPlayer.numberOfLoops = 0;
}

// Bound the ad_duration minimum and also update the timerLabel immediately. 
- (void) setAd_duration:(int)value{
    if (value < 1){
        ad_duration = 1;
    } else {
        ad_duration = value;
    }
    
    timerLabel.text = [NSString stringWithFormat:@"%d", ad_duration];
}

// If the advertisement is a photo and has accompagnying audio, set that up.
- (void) setAdAudioWithName:(NSString*)name andExtenstion:(NSString*)ext{
    ad_has_audio        = YES;
    NSURL *adAudioUrl   = [[NSBundle mainBundle] URLForResource:name withExtension:ext];
    adAudioPlayer       = [[AVAudioPlayer alloc] initWithContentsOfURL:adAudioUrl error:nil];
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil]; // play on silent.
    adAudioPlayer.numberOfLoops = -1;
}

// Set the image for the advertisement and rescale the size of the adImageView to the fill the view.
- (void) setAdImage:(UIImage*)image{
    adImageView.image = image;
    double coverage_percent = 0.98;
    
    // now resize the imageview
    CGSize image_size = adImageView.image.size; // okay this is the size of the image.
    CGSize frame_size = CGSizeMake(self.frame.size.width, self.frame.size.height*0.95); // don't allow to fully cover top
    
    // Find out whether the image is vertically or horizontally constrained.
    bool isVertConstrained = YES;
    if (image_size.width/frame_size.width > image_size.height/frame_size.height){
        isVertConstrained = NO;
    }
    
    // Now resize the image to the bounds of the view while keeping the proportions
    if (isVertConstrained){
        adImageView.frame = CGRectMake(0, 0, image_size.width/image_size.height*frame_size.height*coverage_percent, frame_size.height*coverage_percent);
    } else {
        adImageView.frame = CGRectMake(0, 0, frame_size.width*coverage_percent, image_size.height/image_size.width*frame_size.width*coverage_percent);
    }
    
    adImageView.center = self.center;
    timerLabel.frame = CGRectMake(adImageView.frame.size.width-20, 0, 20, 20);
}

#pragma mark - Core Accelerometer Methods

// Grab the new headings information, check for the user's participation, and then if it's a tech demo update the labels
- (void) updateHeadings{
    NSDictionary *headings  = [self extrapolateHeadings:motionManager];
    bool isParticipating    = [self checkUserParticipation:headings];
    if (!isParticipating){
        NSLog(@"WARNING: User may not be watching the advertisement.");
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
    // the lower bounds are a little bit too firm still.
    double thetaLimit   = 60 - 40.0*strictness/100;     // bound between 20 and 60. default = 40
    double phiLimit     = 45 - 30*strictness/100;       // bound between 15 and 45. default = 30
    
    is_paused = NO;
    
    // If the user has watched all the mandatory ad then their participation is no longer required.
    if (!time_remaining){
        [obstructed_view setHidden:YES];
        return YES;
    }
    
    if (fabs([[currentHeadings objectForKey:@"phi"] doubleValue] - phi_0) > phiLimit){
        NSLog(@"Maximum Phi Exceeded: phi_0: %.2f°  || phi: %.2f°", phi_0, [[currentHeadings objectForKey:@"phi"] doubleValue]);
        is_paused = YES;
        [obstructed_view setHidden:NO];
        [self playSound];
        [arrowPhi setHidden:NO];
        if ([[currentHeadings objectForKey:@"phi"] doubleValue] > phi_0){
            arrowPhi.layer.transform = CATransform3DMakeRotation(-90*3.1415/180, 0, 0, 1.0);
            arrowPhi.frame = CGRectMake(obstructed_view.frame.size.width/2 - 32, obstructed_view.frame.size.height - arrowPhi.frame.size.height - 10, arrowPhi.frame.size.width, arrowPhi.frame.size.height);
        } else {
            arrowPhi.layer.transform = CATransform3DMakeRotation(-270*3.1415/180, 0, 0, 1.0);
            arrowPhi.frame = CGRectMake(obstructed_view.frame.size.width/2 - 32, 20, arrowPhi.frame.size.width, arrowPhi.frame.size.height);
        }
    } else {
        [arrowPhi setHidden:YES];
    }
    
    if (fabs([[currentHeadings objectForKey:@"theta"] doubleValue] - theta_0) > thetaLimit){
        NSLog(@"Maximum Theta Exceeded: theta_0: %.2f°  || theta: %.2f°", theta_0, [[currentHeadings objectForKey:@"theta"] doubleValue]);
        is_paused = YES;
        [obstructed_view setHidden:NO];
        [self playSound];
        [arrowTheta setHidden:NO];
        if ([[currentHeadings objectForKey:@"theta"] doubleValue] > theta_0){
            arrowTheta.layer.transform = CATransform3DMakeRotation(-180*3.1415/180, 0, 0, 1.0);
            arrowTheta.frame = CGRectMake(obstructed_view.frame.size.width-arrowTheta.frame.size.width-10, arrowTheta.frame.origin.y, arrowTheta.frame.size.width, arrowTheta.frame.size.height);
        } else {
            arrowTheta.layer.transform = CATransform3DMakeRotation(0, 0, 0, 1.0);
            arrowTheta.frame = CGRectMake(10, arrowTheta.frame.origin.y, arrowTheta.frame.size.width, arrowTheta.frame.size.height);
        }
    } else {
        [arrowTheta setHidden:YES];
    }
    
    if (is_paused){ // move out here so that both arrows can be visible
        return NO;
    }
    
    // Device orientation is acceptable, continue the ad
    [obstructed_view setHidden:YES];
    if (obstructedAudioPlayer.isPlaying){
        [obstructedAudioPlayer stop];
    }
    if (!adAudioPlayer.isPlaying){
        [adAudioPlayer play];
    }
    return YES;
}

#pragma mark - Core (Non-Accelerometer) Methods

// Play the view obstructed obnoxious high pitched sound w/ "Resume Viewing" in the background
- (void) playSound{
    if (!obstructedAudioPlayer.isPlaying){
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil]; // play on silent.
        [adAudioPlayer stop];
        [obstructedAudioPlayer play];
    }
}

// Begin the ad timer countdown.
- (void) startTimer{
    time_remaining = ad_duration;
    if (ad_has_audio){
        [adAudioPlayer play];
    }
        
    NSTimer *countdownTimer = [[NSTimer alloc] init];
    countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(countdown:)
                                                    userInfo:nil
                                                     repeats:YES];
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
    [adAudioPlayer stop];
    [self removeFromSuperview];
}

// Set the strictness but bound it from 0-100.
- (void) setStrictness:(double)value{
    if (value < 0){
        strictness = 0;
        NSLog(@"WARNING: Attempt to set strictness < 0. Strictness set to zero.");
    } else if (value > 100){
        strictness = 100;
        NSLog(@"WARNING: Attempt to set strictness > 100. Strictness set to 100.");
    } else {
        strictness = value;
    }
}

@end
