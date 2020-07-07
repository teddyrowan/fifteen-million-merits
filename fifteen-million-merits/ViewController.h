//
//  ViewController.h
//  fifteen-million-merits
//
//  Created by TR on 2020-07-06.
//  Copyright © 2020 edwardrowan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>

@interface ViewController : UIViewController
{
    UILabel *rollLabel, *pitchLabel, *yawLabel;         // plane coordinate scheme
    UILabel *thetaLabel, *phiLabel, *tiltLabel;         // spherical coordinate scheme
    
    UIImageView *advertisement; // to be replaced by custom class
    CLLocationManager *locationManager;
    CMMotionManager *motionManager;
}

@property (nonatomic, strong) UILabel *rollLabel, *pitchLabel, *yawLabel;         // plane coordinate scheme
@property (nonatomic, strong) UILabel *thetaLabel, *phiLabel, *tiltLabel;         // spherical coordinate scheme
@property (nonatomic, strong) UIImageView *advertisement;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CMMotionManager *motionManager;


@end

