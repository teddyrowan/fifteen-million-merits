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
@synthesize  rollLabel, pitchLabel, yawLabel, thetaLabel, phiLabel, tiltLabel, advertisement, locationManager, motionManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.05 alpha:1];
    
    // Attitude accelerometer data
    rollLabel   = [[AxisLabel alloc] initWithFrame:CGRectMake(0, 350, 80, 60)];
    pitchLabel  = [[AxisLabel alloc] initWithFrame:CGRectMake(0, 420, 80, 60)];
    yawLabel    = [[AxisLabel alloc] initWithFrame:CGRectMake(0, 490, 80, 60)];
    rollLabel.text  = @"Roll\n0.0";
    pitchLabel.text = @"Pitch\n0.0";
    yawLabel.text   = @"Yaw\n0.0";
    [self.view addSubview:rollLabel];
    [self.view addSubview:pitchLabel];
    [self.view addSubview:yawLabel];
    
    // Spherical coordinates accelerometer data
    thetaLabel  = [[AxisLabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-80, 350, 80, 60)];
    phiLabel    = [[AxisLabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-80, 420, 80, 60)];
    tiltLabel   = [[AxisLabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-80, 490, 80, 60)];
    thetaLabel.text = @"𝛉\n0.0";
    phiLabel.text   = @"ɸ\n0.0";
    tiltLabel.text  = @"Tilt\n0.0";
    [self.view addSubview:thetaLabel];
    [self.view addSubview:phiLabel];
    [self.view addSubview:tiltLabel];
    
    // Testing button to pop the advertisement -- add a gradient or something. highlight on click.
    UIButton *popAdButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.center.x-100, 580, 200, 60)];
    [popAdButton setTitle:@"Test Advertisement" forState:UIControlStateNormal];
    popAdButton.backgroundColor     = [UIColor colorWithWhite:0.10 alpha:1.0];
    popAdButton.layer.borderColor   = UIColor.whiteColor.CGColor;
    popAdButton.layer.cornerRadius  = 10;
    popAdButton.layer.borderWidth   = 1;
    [popAdButton addTarget:self action:@selector(loadAdvertisement) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:popAdButton];
    
    
    
    // Clean up everything below this.
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = (id)self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    
    if([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
        [locationManager requestWhenInUseAuthorization];
    }
    
    [locationManager startUpdatingHeading];
    
    
    motionManager = [[CMMotionManager alloc] init];
    if (motionManager.deviceMotionAvailable) {
        motionManager.deviceMotionUpdateInterval = 1.0/70.0;
        [motionManager startDeviceMotionUpdates];
        NSLog(@"ARViewController :: startSession :: Device Motion Manager Started");
    }
    
    // Timer to update the labels.
    NSTimer *myTimer = [[NSTimer alloc] init];
    myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(updateRollPitchYaw) userInfo:nil repeats:YES];
}

// Helper function for now, change to a custom class soon
- (void) loadAdvertisement{
    // Moutain Dew Ad -- replace w/ mountain dew advertisement video.
    advertisement       = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x-150, self.view.center.y-190, 300, 180)];
    advertisement.image = [UIImage imageNamed:@"mountain-dew.jpg"];
    [self.view addSubview:advertisement];
    
    UILabel *timerLabel = [[UILabel alloc] initWithFrame:CGRectMake(advertisement.frame.size.width-20, 0, 20, 20)];
    timerLabel.backgroundColor      = [UIColor colorWithWhite:0.10 alpha:0.25];
    timerLabel.text                 = @"10";
    timerLabel.layer.borderColor    = UIColor.blackColor.CGColor;
    timerLabel.layer.borderWidth    = 1;
    timerLabel.layer.cornerRadius   = 10;
    timerLabel.clipsToBounds        = YES;
    timerLabel.font                 = [UIFont systemFontOfSize:12];
    timerLabel.textColor            = UIColor.blackColor;
    timerLabel.textAlignment        = NSTextAlignmentCenter;
    [advertisement addSubview:timerLabel];
    
    // NSTimer w/ 1 second period. drop down the time on the timerLabel by one second.
    // advertisement class needs a counter as well as the timerLabel to be accessable to change the value.
    // When counter hits zero cancel the timer, hide the label, and replace it with a button.
    // well actually the timerLabel should just be a button to begin with.
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(nonnull CLHeading *)newHeading{
    double aa = newHeading.magneticHeading;
    NSLog(@"heading: %.2f", aa);
    
    // Need to save this as an offset wrt theta / yaw.
    //directionOffsetRad = -newHeading.magneticHeading*M_PI/180;
    
    [self.locationManager stopUpdatingHeading];
}


- (void) updateRollPitchYaw{
    rollLabel.text  = [NSString stringWithFormat:@"Roll\n%.2f", motionManager.deviceMotion.attitude.roll];
    pitchLabel.text = [NSString stringWithFormat:@"Pitch\n%.2f", motionManager.deviceMotion.attitude.pitch];
    yawLabel.text   = [NSString stringWithFormat:@"Yaw\n%.2f", motionManager.deviceMotion.attitude.yaw];
        
    CMRotationMatrix mat = motionManager.deviceMotion.attitude.rotationMatrix;
    // http://nghiaho.com/?page_id=846 // info on decomposing rotation matrices
    //NSLog(@"m11, m12, m13 : %.2f, %.2f, %.2f", mat.m11, mat.m12, mat.m13);
    //NSLog(@"m21, m22, m23 : %.2f, %.2f, %.2f", mat.m21, mat.m22, mat.m23);
    //NSLog(@"m31, m32, m33 : %.2f, %.2f, %.2f", mat.m31, mat.m32, mat.m33);
    
    double Sx = atan2(mat.m32, mat.m33);                                        // Phi
    double Sy = atan2(-mat.m31, sqrt(mat.m32*mat.m32 + mat.m33*mat.m33));       // Theta
    double Sz = atan2(mat.m21, mat.m11);                                        // Tilt
    
    // Relative coordinates. Absolute doesn't matter anymore.
    thetaLabel.text     = [NSString stringWithFormat:@"𝛉\n%.2f°", Sy*180/M_PI];
    phiLabel.text       = [NSString stringWithFormat:@"ɸ\n%.2f°", Sx*180/M_PI];
    tiltLabel.text      = [NSString stringWithFormat:@"Tilt\n%.2f°", Sz*180/M_PI];
    
}

// compare the current phone orientation to the one when the ad started playing. 
//- (bool) checkWatchStatus.


@end
