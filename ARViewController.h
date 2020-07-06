//
//  ARViewController.h
//  ARKit_with_ObjC
//
//  Created by Raju on 8/30/17.
//  Copyright © 2017 rajubd49. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import "GridDemoView.h"
#import <CoreLocation/CoreLocation.h>

@interface ARViewController : UIViewController
{
    UIView *infoLayer;
    UILabel *rollLabel, *pitchLabel, *yawLabel;         // plane coordinate scheme
    UILabel *thetaLabel, *phiLabel, *tiltLabel;         // spherical coordinate scheme
    UILabel *angleResultLabel, *distanceResultLabel;
    
    double directionOffsetRad;                          // offset for theta to make theta(North) = 0
    UIImageView *compassView;
    
    UIImageView *cnModel;                               // let's us change the photo for different angles
    int currentImage;                                   // the current image, so that we don't waste resources resetting the same image
}

@property (nonatomic, strong) UIView *infoLayer;
@property (nonatomic, strong) UILabel *rollLabel, *pitchLabel, *yawLabel, *angleResultLabel, *distanceResultLabel, *thetaLabel, *phiLabel, *tiltLabel;
@property (nonatomic, strong) UIImageView *compassView, *cnModel;
@property (nonatomic) int currentImage;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) double directionOffsetRad;



@property (nonatomic, retain) NSMutableArray<SCNNode *> *sceneNode;
@property (nonatomic, copy) NSString *sceneName;
@property (nonatomic, assign) CGFloat currentYAngle;

@property (strong, nonatomic) IBOutlet ARSCNView *sceneView;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;
@property (weak, nonatomic) IBOutlet UIButton *addNodeButton;
@property (weak, nonatomic) IBOutlet UIButton *snapshotButton;

@end
