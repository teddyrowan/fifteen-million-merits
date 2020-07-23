//
//  FMMAdvertisementView.h
//  fifteen-million-merits
//
//  Authored by Teddy Rowan
//  Copyright © 2020 teddyrowan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FMMAdvertisementView : UIView
{
    AVAudioPlayer  *adAudioPlayer;              // play a noise (resume_viewing.mp3) whenever view is obstructed
    
    int ad_duration;                            // total ad duration before the user can close it
    bool techDemo;                              // is this a tech demo. ie: do you want to show the coordinate labels
    double strictness;                          // [0-100] 25 default. how strict the user participation settings are.
}
@property (nonatomic) bool techDemo;
@property (nonatomic) double strictness;
@property (nonatomic) int ad_duration;
@property (nonatomic, strong) AVAudioPlayer *adAudioPlayer;

- (void) playSound;         // play the sound when the user's view is obstructed.
- (void) capture_0;         // capture the initial heading values for the advertisement.
- (void) startTimer;        // begin playing the advertisement

- (bool) checkUserParticipation:(NSDictionary*)currentHeadings;     // is the user watching the ad
- (void) setStrictness:(double)value;                               // override the strictness setter method to bound it between 0-100
- (void) setTechDemo:(bool)on_status;                               // override the setter for tech-demo to view/hide the axislabels
- (void) setAd_duration:(int)value;                                 // override tha ad_duration setter to force positive and update label.
- (void) setAdImage:(UIImage*)image;                                // set the image for the advertisement. + resize the imageView to match it.

- (void) setAdAudioWithName:(NSString*)name andExtenstion:(NSString*)ext;

@end

NS_ASSUME_NONNULL_END
