//
//  TMFollowViewController.h
//  ThankMap
//
//  Created by Noah Dayan on 10/7/14.
//  Copyright (c) 2014 Noah Dayan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface TMFollowViewController : PFQueryTableViewController

@property (weak, nonatomic) NSString *queryKey;
@property (weak, nonatomic) NSString *reverseKey;
@property (weak, nonatomic) PFObject *friendKey;

@end
