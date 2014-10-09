//
//  TMSecondViewController.h
//  ThankMap
//
//  Created by Noah Dayan on 9/1/14.
//  Copyright (c) 2014 Noah Dayan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface TMSecondViewController : PFQueryTableViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *feedButtons;

- (IBAction)feedChange:(id)sender;

@end
