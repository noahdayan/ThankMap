//
//  TMThirdViewController.h
//  ThankMap
//
//  Created by Noah Dayan on 9/1/14.
//  Copyright (c) 2014 Noah Dayan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface TMThirdViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberThanks;
@property (weak, nonatomic) IBOutlet UILabel *numberFollowing;
@property (weak, nonatomic) IBOutlet UILabel *numberFollowers;

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) NSString *friendID;

- (IBAction)logoutButtonTouchHandler:(id)sender;

@end
