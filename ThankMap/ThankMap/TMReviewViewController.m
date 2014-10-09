//
//  TMReviewViewController.m
//  ThankMap
//
//  Created by Noah Dayan on 9/29/14.
//  Copyright (c) 2014 Noah Dayan. All rights reserved.
//

#import "TMReviewViewController.h"

#import <Parse/Parse.h>

@interface TMReviewViewController ()

@property (nonatomic, strong) PFObject *reviewObject;

@end

@implementation TMReviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        
        _reviewObject[@"rating"] = [NSNumber numberWithInteger:self.ratingButtons.selectedSegmentIndex];
        [_reviewObject saveInBackground];
    }
    [super viewWillDisappear:animated];
}

- (void)loadReview:(id<MKAnnotation>)annotation
{
    CLLocationCoordinate2D coordinate = [annotation coordinate];
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Place"];
    [query whereKey:@"name" equalTo:[annotation title]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(error)
        {
            PFObject *place = [PFObject objectWithClassName:@"Place"];
            place[@"name"] = [annotation title];
            place[@"location"] = point;
            [place saveInBackground];
            
            NSLog(@"Place created");
            
            PFObject *review = [PFObject objectWithClassName:@"Review"];
            review[@"user"] = [PFUser currentUser];
            review[@"place"] = place;
            review[@"rating"] = @-1;
            [review saveInBackground];
            
            NSLog(@"Review created");
            
            _reviewObject = review;
        }
        else
        {
            NSLog(@"Place found");
            
            PFQuery *nextQuery = [PFQuery queryWithClassName:@"Review"];
            [nextQuery whereKey:@"user" equalTo:[PFUser currentUser]];
            [nextQuery whereKey:@"place" equalTo:object];
            [nextQuery getFirstObjectInBackgroundWithBlock:^(PFObject *nextObject, NSError *error) {
                if(error)
                {
                    PFObject *review = [PFObject objectWithClassName:@"Review"];
                    review[@"user"] = [PFUser currentUser];
                    review[@"place"] = object;
                    review[@"rating"] = @-1;
                    [review saveInBackground];
                    
                    NSLog(@"Review created");
                    
                    _reviewObject = review;
                }
                else
                {
                    NSLog(@"Review found");
                    
                    _reviewObject = nextObject;
                    
                    switch ((int)[nextObject[@"rating"] integerValue]) {
                        case 0:
                            [self.ratingButtons setSelectedSegmentIndex:0];
                            break;
                            
                        case 1:
                            [self.ratingButtons setSelectedSegmentIndex:1];
                            break;
                            
                        case 2:
                            [self.ratingButtons setSelectedSegmentIndex:2];
                            break;
                            
                        case 3:
                            [self.ratingButtons setSelectedSegmentIndex:3];
                            break;
                            
                        default:
                            NSLog(@"No rating");
                            break;
                    }
                }
            }];
        }
    }];
}

@end
