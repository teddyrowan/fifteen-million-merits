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
#import "AxisLabel.h"
#import "AdvertisementView.h"

@interface ViewController : UIViewController
{
    AxisLabel *rollLabel, *pitchLabel, *yawLabel;         // plane coordinate scheme
    AxisLabel *thetaLabel, *phiLabel, *tiltLabel;         // spherical coordinate scheme
    
    AdvertisementView   *advertisement;
    CLLocationManager   *locationManager;
    CMMotionManager     *motionManager;
}


@property (nonatomic, strong) AdvertisementView *advertisement;
@property (nonatomic, strong) AxisLabel *rollLabel, *pitchLabel, *yawLabel;         // plane coordinate scheme
@property (nonatomic, strong) AxisLabel *thetaLabel, *phiLabel, *tiltLabel;         // spherical coordinate scheme
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CMMotionManager *motionManager;


@end

