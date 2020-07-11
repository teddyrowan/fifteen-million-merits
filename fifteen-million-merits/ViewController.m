//
//  ViewController.m
//  fifteen-million-merits
//
//  Created by TR on 2020-07-06.
//  Copyright © 2020 edwardrowan. All rights reserved.
//

#import "ViewController.h"
#import "AxisLabel.h"

@interface ViewController (){
    AxisLabel *rollLabel, *pitchLabel, *yawLabel;         // aircraft principal axes
    AxisLabel *thetaLabel, *phiLabel, *tiltLabel;         // spherical coordinate scheme
}

@property (nonatomic, strong) AxisLabel *rollLabel, *pitchLabel, *yawLabel;         // aircraft principal axes
@property (nonatomic, strong) AxisLabel *thetaLabel, *phiLabel, *tiltLabel;         // spherical coordinate scheme
@end

@implementation ViewController
@synthesize  rollLabel, pitchLabel, yawLabel, thetaLabel, phiLabel, tiltLabel, advertisement, motionManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.05 alpha:1];
    
    // Attitude accelerometer data
    rollLabel   = [[AxisLabel alloc] initWithFrame:CGRectMake(0, 350, 60, 45)];
    pitchLabel  = [[AxisLabel alloc] initWithFrame:CGRectMake(0, 410, 60, 45)];
    yawLabel    = [[AxisLabel alloc] initWithFrame:CGRectMake(0, 470, 60, 45)];
    rollLabel.text  = @"Roll\n0.0";
    pitchLabel.text = @"Pitch\n0.0";
    yawLabel.text   = @"Yaw\n0.0";
    [self.view addSubview:rollLabel];
    [self.view addSubview:pitchLabel];
    [self.view addSubview:yawLabel];
    
    // Spherical coordinates accelerometer data
    thetaLabel  = [[AxisLabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-60, 350, 60, 45)];
    phiLabel    = [[AxisLabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-60, 410, 60, 45)];
    tiltLabel   = [[AxisLabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-60, 470, 60, 45)];
    thetaLabel.text = @"𝛉\n0.0";
    phiLabel.text   = @"ɸ\n0.0";
    tiltLabel.text  = @"Tilt\n0.0";
    [self.view addSubview:thetaLabel];
    [self.view addSubview:phiLabel];
    [self.view addSubview:tiltLabel];
    
    
    // For tech demo. Testing button to pop the advertisement -- add a gradient or something. highlight on click.
    UIButton *popAdButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.center.x-100, 580, 200, 60)];
    [popAdButton setTitle:@"Test Advertisement" forState:UIControlStateNormal];
    popAdButton.backgroundColor     = [UIColor colorWithWhite:0.10 alpha:1.0];
    popAdButton.layer.borderColor   = UIColor.whiteColor.CGColor;
    popAdButton.layer.cornerRadius  = 10;
    popAdButton.layer.borderWidth   = 1;
    [popAdButton addTarget:self action:@selector(loadAdvertisement) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:popAdButton];
    
    // Manager for the orientation detection -- motionManager needs to get moved into the advertisementView
    motionManager = [[CMMotionManager alloc] init];
    if (motionManager.deviceMotionAvailable) {
        motionManager.deviceMotionUpdateInterval = 1.0/70.0;
        [motionManager startDeviceMotionUpdates];
    } // else {this is the whole point of the demo, so we doneskies. for framework move this to the start and pop exit out.}
    
    // Timer to update the heading labels.
    NSTimer *labelTimer = [[NSTimer alloc] init];
    labelTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0
                                                  target:self
                                                selector:@selector(updateHeadingLabels)
                                                userInfo:nil
                                                 repeats:YES];
}

// Load up whatever advertisement you choose.
- (void) loadAdvertisement{
    // Moutain Dew Ad -- replace w/ mountain dew advertisement video.
    advertisement = [[AdvertisementView alloc] initWithFrame:CGRectMake(self.view.center.x-150, self.view.center.y-190, 300, 180)];
    advertisement.adImageView.image = [UIImage imageNamed:@"mountain-dew.jpg"];
    [advertisement capture_0:[self extrapolateHeadings:motionManager]];
    [self.view addSubview:advertisement];
    [advertisement startTimer];
}

// Update the labels on the sides for the tech demo. the logic for this only makes sense if the headings only show during the ad. 
- (void) updateHeadingLabels{
    NSDictionary *headings = [self extrapolateHeadings:motionManager];
    bool isParticipating = [advertisement checkUserParticipation:headings];
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

@end
