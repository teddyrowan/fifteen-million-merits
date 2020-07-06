//
//  ARViewController.m
//  ARKit_with_ObjC
//
//  Created by Raju on 8/30/17.
//  Copyright © 2017 rajubd49. All rights reserved.
//

#import "ARViewController.h"
#import "ARAlertController.h"
#import "ARSCNViewControl.h"
#import "ARGestureControl.h"

#import <CoreMotion/CoreMotion.h>

@interface ARViewController (){
    CMMotionManager *motionManager;
    NSOperationQueue *opQ;
}

@property (nonatomic, strong) ARAlertController *alertController;
@property (nonatomic, strong) ARSCNViewControl *sceneControl;
@property (nonatomic, strong) ARGestureControl *gestureControl;

@end
    
@implementation ARViewController
@synthesize infoLayer, rollLabel, yawLabel, pitchLabel, angleResultLabel, distanceResultLabel, thetaLabel, phiLabel, tiltLabel, locationManager, directionOffsetRad, compassView, cnModel, currentImage;

#pragma mark - UIViewController LifeCycle

// CN Tower GPS.
// CLLocation *towerLoc = [[CLLocation alloc] initWithLatitude:43.642567 longitude:-79.387054];

// Location Compare:
// CLLocationDistance towerDistance = [self.latestLocation distanceFromLocation:towerLoc]; // in meters

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //GridDemoView *gridView = [[GridDemoView alloc] initWithFrame:self.view.frame andSpacing:50];
    //[self.view addSubview:gridView];
    
    infoLayer = [[UIView alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, 80)];
    infoLayer.backgroundColor = [UIColor colorWithWhite:1 alpha:0.75];
    [self.view addSubview:infoLayer];
    
    UILabel *angleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, infoLayer.frame.size.width-30, 20)];
    angleLabel.textAlignment = NSTextAlignmentLeft;
    angleLabel.text = @"Angle From Horizon (degrees):";
    angleLabel.textColor = UIColor.blackColor;
    angleLabel.font = [UIFont systemFontOfSize:14];
    [infoLayer addSubview:angleLabel];
    
    UILabel *distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 40, infoLayer.frame.size.width-30, 20)];
    distanceLabel.textAlignment = NSTextAlignmentLeft;
    distanceLabel.text = @"Estimated Distance To CN Tower (m):";
    distanceLabel.textColor = UIColor.blackColor;
    distanceLabel.font = [UIFont systemFontOfSize:14];
    [infoLayer addSubview:distanceLabel];
    
    angleResultLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-95, angleLabel.frame.origin.y, 80, angleLabel.frame.size.height)];
    angleResultLabel.textAlignment = NSTextAlignmentCenter;
    angleResultLabel.textColor = UIColor.blackColor;
    angleResultLabel.font = [UIFont systemFontOfSize:14];
    angleResultLabel.backgroundColor = UIColor.whiteColor;
    [infoLayer addSubview:angleResultLabel];
    
    distanceResultLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-95, distanceLabel.frame.origin.y, 80, distanceLabel.frame.size.height)];
    distanceResultLabel.textAlignment = NSTextAlignmentCenter;
    distanceResultLabel.textColor = UIColor.blackColor;
    distanceResultLabel.font = [UIFont systemFontOfSize:14];
    distanceResultLabel.backgroundColor = UIColor.whiteColor;
    [infoLayer addSubview:distanceResultLabel];
    
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
    //[self.view addSubview:thetaLabel];
    
    //compassView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-80, 250, 60, 60)];
    //compassView.image = [UIImage imageNamed:@"gray_compass.png"];
    //[self.view addSubview:compassView];
    
    
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
    
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = (id)self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    
    if([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    //[self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(nonnull CLHeading *)newHeading{
    double aa = newHeading.magneticHeading;
    NSLog(@"heading: %.2f", aa);
    
    // Need to save this as an offset wrt theta / yaw.
    directionOffsetRad = -newHeading.magneticHeading*M_PI/180;
    
    [self.locationManager stopUpdatingHeading];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (ARWorldTrackingConfiguration.isSupported) {
        [self startSession];
        self.sceneName = @"art.scnassets/cup.dae";
    } else {
        [self.alertController showUnsupportedAlert];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.sceneView.session pause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Configure ARSession

- (void)startSession {
    
    ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];
    [self.sceneView.session runWithConfiguration:configuration];
    [self checkMediaPermissionAndButtonState];
    
    
    cnModel = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 350)];
    cnModel.center = CGPointMake(self.view.center.x, self.view.center.y + 53);
    [cnModel setImage:[UIImage imageNamed:@"tower2.png"]];
    currentImage = 2;
    cnModel.alpha = 0.35;
    [self.view addSubview:cnModel];
    
    UIView *testView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 30)]; // location set after.
    testView.backgroundColor = [UIColor colorWithRed:0.4 green:0.8 blue:0.1 alpha:0.20];
    testView.center = CGPointMake(self.view.center.x, self.view.center.y);
    [self.view addSubview:testView];
    
    UIView *centerScreenDot = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-2, self.view.frame.size.height/2-2, 4, 4)];
    centerScreenDot.backgroundColor = [UIColor redColor];
    [self.view addSubview:centerScreenDot];
    

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


// Update the labels displaying the orientation of the device

// the issue right now with roll pitch yaw is that they're measurements for like planes and stuff. assume the phone is laying flat, but our use is rotated up by pi/2 so it's not all that stable.
// want to convert roll pitch yaw into euler angles.

// for headings maybe?
// https://stackoverflow.com/questions/9264838/use-native-ios-compass-within-an-app
- (void) updateRollPitchYaw{
    rollLabel.text = [NSString stringWithFormat:@"Roll\n%.2f", motionManager.deviceMotion.attitude.roll];
    pitchLabel.text = [NSString stringWithFormat:@"Pitch\n%.2f", motionManager.deviceMotion.attitude.pitch];
    yawLabel.text = [NSString stringWithFormat:@"Yaw\n%.2f", motionManager.deviceMotion.attitude.yaw];
    
    
    double distance = 350*tan(motionManager.deviceMotion.attitude.pitch);
    double horizon_angle = 90 - motionManager.deviceMotion.attitude.pitch*180/M_PI;
    
    angleResultLabel.text = [NSString stringWithFormat:@"%.2f", horizon_angle];
    distanceResultLabel.text = [NSString stringWithFormat:@"%d", (int)distance];
    
    
    
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
    
    int directionAngle = ((int)((Sy - directionOffsetRad)*180/M_PI)) % 360;     // this isn't quite right, idk need to play with it a bit.
    
    thetaLabel.text = [NSString stringWithFormat:@"𝛉\n%d°", directionAngle];          // theta is direction. theta = 0 should = North.
    phiLabel.text = [NSString stringWithFormat:@"ɸ\n%.2f", Sx];
    tiltLabel.text = [NSString stringWithFormat:@"Tilt\n%.2f", Sz];
    
    //compassView.layer.transform = CATransform3DMakeRotation(directionAngle/360.0*2*M_PI, 0, 0, 1.0);
    
    [self updateImage:horizon_angle];
    
}

// I need to calibrate this outside
- (void) updateImage:(double)angle{
    int desiredImage = 0;
    if (angle < 15){
        desiredImage = 0;
    } else if (angle < 25){
        desiredImage = 1;
    } else if (angle < 35){
        desiredImage = 2;
    } else {
        desiredImage = 3;
    }
    
    if (desiredImage != currentImage){
        currentImage = desiredImage;
        switch (currentImage) {
            case 0:
                [cnModel setImage:[UIImage imageNamed:@"tower0.png"]];
                break;
            case 1:
                [cnModel setImage:[UIImage imageNamed:@"tower1.png"]];
                break;
            case 2:
                [cnModel setImage:[UIImage imageNamed:@"tower2.png"]];
                break;
            case 3:
                [cnModel setImage:[UIImage imageNamed:@"tower3.png"]];
                break;
            default:
                break;
        }
    }
}


#pragma mark - Media Premission Check

-(void)checkMediaPermissionAndButtonState {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(status == AVAuthorizationStatusAuthorized || status == AVAuthorizationStatusNotDetermined) {
            [self.alertController showOverlyText:@"STARTING A NEW SESSION, TRY MOVING LEFT OR RIGHT" withDuration:2];
        } else {
            NSString *accessDescription = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSCameraUsageDescription"];
            [self.alertController showPermissionAlertWithDescription:accessDescription];
        }
        
        self.currentYAngle = 0.0;
        self.removeButton.hidden = YES;
        self.addNodeButton.hidden = YES;
        self.snapshotButton.hidden = YES;
    });
}


@end
