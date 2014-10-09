//
//  TMLoginViewController.h
//  ThankMap
//
//  Created by Noah Dayan on 9/16/14.
//  Copyright (c) 2014 Noah Dayan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TMLoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)loginButtonTouchHandler:(id)sender;

@end
