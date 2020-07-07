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
    // Do any additional setup after loading the view.
    UIView *testView = [[UIView alloc] initWithFrame:CGRectMake(50, 100, 100, 100)];
    testView.backgroundColor = UIColor.greenColor;
    [self.view addSubview:testView]; // shows up. good.
    
    rollLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 250, 80, 60)];
    rollLabel.numberOfLines = 2;
    rollLabel.textAlignment = NSTextAlignmentCenter;
    rollLabel.backgroundColor = [UIColor colorWithWhite:1 alpha:0.25];
    rollLabel.text = @"Roll\n0.0";
    [self.view addSubview:rollLabel];
    
    pitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 320, 80, 60)];
    pitchLabel.numberOfLines = 2;
    pitchLabel.textAlignment = NSTextAlignmentCenter;
    pitchLabel.backgroundColor = [UIColor colorWithWhite:1 alpha:0.25];
    pitchLabel.text = @"Pitch\n0.0";
    [self.view addSubview:pitchLabel];
    
    yawLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 390, 80, 60)];
    yawLabel.numberOfLines = 2;
    yawLabel.textAlignment = NSTextAlignmentCenter;
    yawLabel.backgroundColor = [UIColor colorWithWhite:1 alpha:0.25];
    yawLabel.text = @"Yaw\n0.0";
    [self.view addSubview:yawLabel];
    
    
    
    thetaLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-80, 250, 80, 60)];
    thetaLabel.numberOfLines = 2;
    thetaLabel.textAlignment = NSTextAlignmentCenter;
    thetaLabel.backgroundColor = [UIColor colorWithWhite:1 alpha:0.25];
    thetaLabel.text = @"𝛉\n0.0"; //ɸ
    [self.view addSubview:thetaLabel];
    
    
    phiLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-80, 320, 80, 60)];
    phiLabel.numberOfLines = 2;
    phiLabel.textAlignment = NSTextAlignmentCenter;
    phiLabel.backgroundColor = [UIColor colorWithWhite:1 alpha:0.25];
    phiLabel.text = @"ɸ\n0.0";
    [self.view addSubview:phiLabel];
    
    tiltLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-80, 390, 80, 60)];
    tiltLabel.numberOfLines = 2;
    tiltLabel.textAlignment = NSTextAlignmentCenter;
    tiltLabel.backgroundColor = [UIColor colorWithWhite:1 alpha:0.25];
    tiltLabel.text = @"Tilt\n0.0";
    [self.view addSubview:tiltLabel];
    
    
    
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
