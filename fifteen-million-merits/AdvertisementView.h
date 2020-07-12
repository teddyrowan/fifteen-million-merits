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
    UIImageView *adImageView;                   // the image (video support to be added) for the advertisement
    int ad_duration;                            // total ad duration before the user can close it
    bool techDemo;                              // is this a tech demo. ie: do you want to show the coordinate labels
}
@property (nonatomic) bool techDemo;
@property (nonatomic) int ad_duration;
@property (nonatomic, strong) UIImageView *adImageView;

- (void) playSound;         // play the sound when the user's view is obstructed.
- (void) capture_0;         // capture the initial heading values for the advertisement.
- (void) startTimer;        // begin playing the advertisement

- (void) setTechDemo:(bool)on_status;                               // is this a tech demo.
- (bool) checkUserParticipation:(NSDictionary*)currentHeadings;     // is the user watching the ad


@end

NS_ASSUME_NONNULL_END
