# Fifteen Million Merits

This package FMMAdvertisementView is an accelerometer-based implementation of the dystopian advertising scheme featured in S01E02 of Black Mirror. The goal of the package is to detect user participation in watching pushed advertisements.

[Black Mirror Example](./resources/screens/obstructed-view-1.png)

Rather than tap into the front facing camera and use eye-tracking algorithms, this package takes a simpler, less computational, and less invasive approach by tapping into the device's accelerometers to capture the change in orientation of the device and detect likely changes in viewing. 

[Example Advertisement](./app-screens/ad_demo.PNG) || [Obstructed Demo](./app-screens/obstructed_demo.PNG)

## Getting Started

A quick demo project is attached: a simple mockup of a 2048 game with a button in the bottom right corner to launch a Black Mirror themed Wraith Girls advertisement. 

For your own application, create a FMMAdvertisementView object and set the image (video advertisement support coming soon) through the adImageView property. You are then able to set a custom mandatory watch length by modifying the ad_duration [seconds] parameter and you can set the strictness parameter [0,100] to determine how little of a change in the orientation data will trigger the obstructed view alert. 

Once your properties are set add the advertisement to your view and call the startTimer() method for the FMMAdvertisingView object. 

```objective-c
FMMAdvertisementView *your_ad = [[FMMAdvertisementView alloc] initWithFrame:example_superview.frame];
your_ad.image = [UIImage imageNamed:@"example.png"];
your_ad.strictness = 50; // the default setting
your_ad.duration = 15; // seconds
[example_superview addSubview:your_ad];
[your_ad startTimer];
```

FMMAdvertisingView also has a parameter: (bool) techDemo that can be set which will push labels above the advertisement that display the orientation data both in principal aircraft coordinates and in spherical coordinates with a tilt parameter.

### Requirements:

CoreMotion: deviceMotionAvailable: iOS 4.0+


## Additional Notes

I haven't checked explicitly, but I imagine that advertising in this fashion would result in App Rejection by Apple. This package is designed as a dystopian tech demo, not for commercial use. 

## Authors

* **Teddy Rowan**
