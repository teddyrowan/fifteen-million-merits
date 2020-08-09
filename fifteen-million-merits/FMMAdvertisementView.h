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
    AVAudioPlayer  *adAudioPlayer;  // play a noise (resume_viewing.mp3) whenever view is obstructed
    
    double strictness;              // [0-100] 25 default. how strict the user participation settings are.
    int ad_duration;                // total ad duration before the user can close it
}
@property (nonatomic) double strictness;
@property (nonatomic) int ad_duration;
@property (nonatomic, strong) AVAudioPlayer *adAudioPlayer;

- (void) captureInitialOrientation;
// Capture the initial heading values for the advertisement.

- (bool) checkUserParticipation:(NSDictionary*)currentHeadings;
// Compare the accelerometer data to the initial data and determine if the user is looking at the device

- (void) playSound;
// Play the sound when the user's view is obstructed.

- (void) setAdAudioWithName:(NSString*)name andExtenstion:(NSString*)ext;
// Set the audio for the advertisement

- (void) setAd_duration:(int)value;
// Override tha ad_duration setter to force positive and update label.

- (void) setAdImage:(UIImage*)image;
// Set the image for the advertisement. + resize the imageView to match it.


- (void) setStrictness:(double)value;
// Override the strictness setter method to bound it between 0-100

- (void) startTimer;
// Begin playing the advertisement

@end

NS_ASSUME_NONNULL_END
