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
#import "AdvertisementView.h"

@interface ViewController : UIViewController
{
    AdvertisementView   *advertisement;
    CMMotionManager     *motionManager;
}

@property (nonatomic, strong) AdvertisementView *advertisement;
@property (nonatomic, strong) CMMotionManager *motionManager;


@end

