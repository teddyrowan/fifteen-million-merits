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
    
    // Moutain Dew Ad
    advertisement       = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x-150, self.view.center.y-190, 300, 180)];
    advertisement.image = [UIImage imageNamed:@"mountain-dew.jpg"];
    [self.view addSubview:advertisement];
    
    // Original accelerometer data
    rollLabel   = [[AxisLabel alloc] initWithFrame:CGRectMake(0, 350, 80, 60)];
    pitchLabel  = [[AxisLabel alloc] initWithFrame:CGRectMake(0, 420, 80, 60)];
    yawLabel    = [[AxisLabel alloc] initWithFrame:CGRectMake(0, 490, 80, 60)];
    rollLabel.text  = @"Roll\n0.0";
    pitchLabel.text = @"Pitch\n0.0";
    yawLabel.text   = @"Yaw\n0.0";
    [self.view addSubview:rollLabel];
    [self.view addSubview:pitchLabel];
    [self.view addSubview:yawLabel];
    
    // Inferred accelerometer data
    thetaLabel  = [[AxisLabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-80, 350, 80, 60)];
    phiLabel    = [[AxisLabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-80, 420, 80, 60)];
    tiltLabel   = [[AxisLabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-80, 490, 80, 60)];
    thetaLabel.text = @"𝛉\n0.0";
    phiLabel.text   = @"ɸ\n0.0";
    tiltLabel.text  = @"Tilt\n0.0";
    [self.view addSubview:thetaLabel];
    [self.view addSubview:phiLabel];
    [self.view addSubview:tiltLabel];
    
    
    // Clean this shit up. 
    
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

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(nonnull CLHeading *)newHeading{
    double aa = newHeading.magneticHeading;
    NSLog(@"heading: %.2f", aa);
    
    // Need to save this as an offset wrt theta / yaw.
    //directionOffsetRad = -newHeading.magneticHeading*M_PI/180;
    
    [self.locationManager stopUpdatingHeading];
}

- (void) updateRollPitchYaw{
    rollLabel.text = [NSString stringWithFormat:@"Roll\n%.2f", motionManager.deviceMotion.attitude.roll];
    pitchLabel.text = [NSString stringWithFormat:@"Pitch\n%.2f", motionManager.deviceMotion.attitude.pitch];
    yawLabel.text = [NSString stringWithFormat:@"Yaw\n%.2f", motionManager.deviceMotion.attitude.yaw];
    
    
    // Info on decomposing rotation matrices.
    // http://nghiaho.com/?page_id=846
    
    CMRotationMatrix mat = motionManager.deviceMotion.attitude.rotationMatrix;
    //NSLog(@"m11, m12, m13 : %.2f, %.2f, %.2f", mat.m11, mat.m12, mat.m13);
    //NSLog(@"m21, m22, m23 : %.2f, %.2f, %.2f", mat.m21, mat.m22, mat.m23);
    //NSLog(@"m31, m32, m33 : %.2f, %.2f, %.2f", mat.m31, mat.m32, mat.m33);
    //NSLog(@"-------------------------------");
    
    
    double Sx = atan2(mat.m32, mat.m33);                                        // Phi
    double Sy = atan2(-mat.m31, sqrt(mat.m32*mat.m32 + mat.m33*mat.m33));       // Theta
    double Sz = atan2(mat.m21, mat.m11);                                        // Tilt
    
    double directionOffsetRad = 0; // direction doesn't matter anymore
    int directionAngle = ((int)((Sy - directionOffsetRad)*180/M_PI)) % 360;     // this isn't quite right, idk need to play with it a bit.
    
    thetaLabel.text = [NSString stringWithFormat:@"𝛉\n%d°", directionAngle];          // theta is direction. theta = 0 should = North.
    phiLabel.text = [NSString stringWithFormat:@"ɸ\n%.2f", Sx];
    tiltLabel.text = [NSString stringWithFormat:@"Tilt\n%.2f", Sz];
    
    //compassView.layer.transform = CATransform3DMakeRotation(directionAngle/360.0*2*M_PI, 0, 0, 1.0);
    
    //[self updateImage:horizon_angle];
    
}


@end
