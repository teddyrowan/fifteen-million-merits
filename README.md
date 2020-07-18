# Fifteen Million Merits / FMMAdvertisementView

This package FMMAdvertisementView is an accelerometer-based implementation of the dystopian advertising scheme featured in S01E02 of Black Mirror. The goal of the package is to detect user participation in watching pushed advertisements and pause the advertisement while the user is not participating. This should in theory increase the effectiveness of advertisements and increase the CPM towards app creators. 

That said, this is designed as a dystopian tech-demo not for commercial use. 

![alt text](./resources/screens/obstructed-view-1.png "Title")

Rather than tap into the front facing camera and use eye-tracking algorithms, this package takes a simpler, less computational, and less invasive approach by tapping into the device's accelerometers to capture the change in orientation of the device and detect likely changes in viewing. 

### The following screens are a preview of the demo application

[A video demo is available on Vimeo by clicking this link.](https://vimeo.com/439452030/6092b50826)

![Ad Demo](./app-screens/ad_demo.PNG "Ad Demo")  ![Obstructed Demo](./app-screens/obstructed_demo.PNG "Obstructed Demo")

## Getting Started

A quick demo project is attached: a simple mockup of a 2048 game with a button in the bottom right corner to launch a Black Mirror themed Wraith Girls advertisement. 

For your own application, create a FMMAdvertisementView object and set the image (video advertisement support coming soon) through the adImageView property. You are then able to set a custom mandatory watch length by modifying the ad_duration [seconds] parameter and you can set the strictness parameter [0,100] to determine how little of a change in the orientation data will trigger the obstructed view alert. If desired you also have the ability to set an audio backing to your ad that will pause during view obstructions. 

Once your properties are set add the advertisement to your view and call the startTimer() method for the FMMAdvertisingView object. 

```objective-c
FMMAdvertisementView *your_ad  = [[FMMAdvertisementView alloc] initWithFrame:example_superview.frame];
your_ad.adImageView.image      = [UIImage imageNamed:@"example.png"];  // replace with your ad image
your_ad.strictness             = 50;                                   // the default setting [0,100]
your_ad.duration               = 15;                                   // seconds
[your_ad setAdAudioWithName:@"example_audio" andExtension:@"mp3"];     // audio backing for your ad
[example_superview addSubview:your_ad];
[your_ad startTimer];                                                  // begin watch countdown
```

FMMAdvertisingView also has a parameter: (bool)techDemo that can be set which will push labels above the advertisement that display the orientation data both in principal aircraft coordinates and in spherical coordinates with a tilt parameter.

```objective-c
your_ad.techDemo              = YES;	// should show orientation labels
```

### Requirements:

CoreMotion: deviceMotionAvailable: iOS 4.0+


## Additional Notes

I haven't checked explicitly, but I imagine that advertising in this fashion would result in App Rejection by Apple. This package is designed as a dystopian tech demo, not for commercial use. 

## Authors

* **Teddy Rowan**
