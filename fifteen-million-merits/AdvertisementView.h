//
//  AdvertisementView.h
//  fifteen-million-merits
//
//  Created by TR on 2020-07-09.
//  Copyright © 2020 edwardrowan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdvertisementView : UIView
{
    UIImageView *adImageView;
    UILabel *timerLabel;
    
    int ad_duration;
    
    // Variables for tracking relative movement
    double pitch_0, roll_0, yaw_0;
    double theta_0, phi_0, tilt_0;
    
    // App Demo variables
    bool techDemo;      // pop labels that show the pitch-roll-yaw-theta-phi-tilt
}

@property (nonatomic, strong) UIImageView *adImageView;
@property (nonatomic, strong) UILabel *timerLabel;
@property (nonatomic) int ad_duration;
@property (nonatomic) double pitch_0, roll_0, yaw_0, theta_0, phi_0, tilt_0;

@property (nonatomic) bool techDemo;

- (void) capture_0;

- (bool) checkUserParticipation:(NSDictionary*)currentHeadings;
- (void) startTimer;

- (void) setTechDemo:(bool)on_status;

@end

NS_ASSUME_NONNULL_END
