//
//  TMReviewViewController.h
//  ThankMap
//
//  Created by Noah Dayan on 9/29/14.
//  Copyright (c) 2014 Noah Dayan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface TMReviewViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *ratingButtons;

- (void)loadReview:(id<MKAnnotation>)annotation;

@end
