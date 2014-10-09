//
//  TMLoginViewController.m
//  ThankMap
//
//  Created by Noah Dayan on 9/16/14.
//  Copyright (c) 2014 Noah Dayan. All rights reserved.
//

#import "TMLoginViewController.h"

#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface TMLoginViewController ()

@end

@implementation TMLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Check if user is cached and linked to Facebook, if so, bypass login
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self presentMainViewControllerAnimated:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButtonTouchHandler:(id)sender
{
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:@[@"public_profile", @"email", @"user_friends"] block:^(PFUser *user, NSError *error) {
        
        [self.activityIndicator stopAnimating];
        
        if (!user) {
            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
        } else {
            if (user.isNew) {
                NSLog(@"User with facebook signed up and logged in!");
                
                PFObject *userData = [PFObject objectWithClassName:@"UserData"];
                userData[@"user"] = user;
                userData[@"thanks"] = @0;
                userData[@"followers"] = @0;
                userData[@"following"] = @0;
                [userData saveInBackground];
                
            } else {
                NSLog(@"User with facebook logged in!");
            }
            [self presentMainViewControllerAnimated:YES];
        }
    }];
    
    [self.activityIndicator startAnimating];
}

- (void)presentMainViewControllerAnimated:(BOOL)animated
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UIViewController *controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"main"];
    [self presentViewController:controller animated:animated completion:nil];
}

@end
