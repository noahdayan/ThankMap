//
//  TMThirdViewController.m
//  ThankMap
//
//  Created by Noah Dayan on 9/1/14.
//  Copyright (c) 2014 Noah Dayan. All rights reserved.
//

#import "TMThirdViewController.h"
#import "TMFollowViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface TMThirdViewController () <MKMapViewDelegate>

@property (nonatomic, strong) PFObject *friendObject;

@property (nonatomic, weak) NSString *followKey;
@property (nonatomic, weak) NSString *oppositeKey;
@property (nonatomic, weak) NSString *viewTitle;

@end

@implementation TMThirdViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mapView.delegate = self;
    
    self.profilePic.layer.cornerRadius = (self.profilePic.frame.size.width / 2);
    self.profilePic.clipsToBounds = YES;
    
    UITapGestureRecognizer *followersGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(followersTap:)];
    [self.numberFollowers addGestureRecognizer:followersGesture];
    
    UITapGestureRecognizer *followingGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(followingTap:)];
    [self.numberFollowing addGestureRecognizer:followingGesture];
    
    if(!self.friendID)
    {
        [self loadData];
        [self loadPins];
    }
    else
    {
        PFQuery *query = [PFUser query];
        [query getObjectInBackgroundWithId:self.friendID block:^(PFObject *object, NSError *error) {
            
            _friendObject = object;
            
            [self accommodateFriendView];
            [self loadFriend];
            [self loadPins];
            
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logoutButtonTouchHandler:(id)sender
{
    // Logout user, this automatically clears the cache
    [PFUser logOut];
    
    NSLog(@"User logged out!");
    
    // Return to login view controller
    [self presentLoginViewControllerAnimated:YES];
}

- (void)presentLoginViewControllerAnimated:(BOOL)animated
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UIViewController *controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"login"];
    [self presentViewController:controller animated:animated completion:nil];
}

- (void)loadData
{
    // If the user is already logged in, display any previously cached values before we get the latest from Facebook.
    if ([PFUser currentUser]) {
        [self updateProfileData];
    }
    
    // Send request to Facebook
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // handle response
        if (!error) {
            // Parse the data received
            NSDictionary *userData = (NSDictionary *)result;
            
            NSString *facebookID = userData[@"id"];
            
            NSMutableDictionary *userProfile = [NSMutableDictionary dictionaryWithCapacity:5];
            
            if (facebookID) {
                userProfile[@"facebookId"] = facebookID;
            }
            
            NSString *name = userData[@"name"];
            if (name) {
                userProfile[@"name"] = name;
            }
            
            NSString *email = userData[@"email"];
            if (email) {
                userProfile[@"email"] = email;
            }
            
            NSString *gender = userData[@"gender"];
            if (gender) {
                userProfile[@"gender"] = gender;
            }
            
            userProfile[@"pictureURL"] = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID];
            
            [[PFUser currentUser] setObject:userProfile forKey:@"profile"];
            [[PFUser currentUser] saveInBackground];
            
            [self updateProfileData];
        } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                    isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
            [self logoutButtonTouchHandler:nil];
        } else {
            NSLog(@"Some other error: %@", error);
        }
    }];
}

// Set received values if they are not nil and reload the table
- (void)updateProfileData
{
    PFQuery *query = [PFQuery queryWithClassName:@"UserData"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        NSString *thanksCount = [NSString stringWithFormat:@"%d", (int)[object[@"thanks"] integerValue]];
        if (thanksCount) {
            self.numberThanks.text = thanksCount;
        }
        
        NSString *followersCount = [NSString stringWithFormat:@"%d", (int)[object[@"followers"] integerValue]];
        if (followersCount) {
            self.numberFollowers.text = followersCount;
        }
        
        NSString *followingCount = [NSString stringWithFormat:@"%d", (int)[object[@"following"] integerValue]];
        if (followingCount) {
            self.numberFollowing.text = followingCount;
        }
        
    }];
    
    // Set the name in the header view label
    NSString *name = [PFUser currentUser][@"profile"][@"name"];
    if (name) {
        self.nameLabel.text = name;
    }
    
    NSString *userProfilePhotoURLString = [PFUser currentUser][@"profile"][@"pictureURL"];
    // Download the user's facebook profile picture
    if (userProfilePhotoURLString) {
        NSURL *pictureURL = [NSURL URLWithString:userProfilePhotoURLString];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
        
        [NSURLConnection sendAsynchronousRequest:urlRequest
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   if (connectionError == nil && data != nil) {
                                       self.profilePic.image = [UIImage imageWithData:data];
                                       
                                   } else {
                                       NSLog(@"Failed to load profile photo.");
                                   }
                               }];
    }
}

- (void)loadFriend
{
    PFQuery *query = [PFQuery queryWithClassName:@"UserData"];
    [query whereKey:@"user" equalTo:_friendObject];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        NSString *thanksCount = [NSString stringWithFormat:@"%d", (int)[object[@"thanks"] integerValue]];
        if (thanksCount) {
            self.numberThanks.text = thanksCount;
        }
        
        NSString *followersCount = [NSString stringWithFormat:@"%d", (int)[object[@"followers"] integerValue]];
        if (followersCount) {
            self.numberFollowers.text = followersCount;
        }
        
        NSString *followingCount = [NSString stringWithFormat:@"%d", (int)[object[@"following"] integerValue]];
        if (followingCount) {
            self.numberFollowing.text = followingCount;
        }
        
    }];
    
    // Set the name in the header view label
    NSString *name = _friendObject[@"profile"][@"name"];
    if (name) {
        self.nameLabel.text = name;
    }
    
    NSString *userProfilePhotoURLString = _friendObject[@"profile"][@"pictureURL"];
    // Download the user's facebook profile picture
    if (userProfilePhotoURLString) {
        NSURL *pictureURL = [NSURL URLWithString:userProfilePhotoURLString];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
        
        [NSURLConnection sendAsynchronousRequest:urlRequest
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   if (connectionError == nil && data != nil) {
                                       self.profilePic.image = [UIImage imageWithData:data];
                                       
                                   } else {
                                       NSLog(@"Failed to load profile photo.");
                                   }
                               }];
    }
}

- (void)accommodateFriendView
{
    if(![_friendObject.objectId isEqualToString:[PFUser currentUser].objectId])
    {
        PFQuery *query = [PFQuery queryWithClassName:@"Follow"];
        [query whereKey:@"from" equalTo:[PFUser currentUser]];
        [query whereKey:@"to" equalTo:_friendObject];
        [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
            
            if(count == 0)
            {
                UIBarButtonItem *followButton = [[UIBarButtonItem alloc] initWithTitle:@"Follow" style:UIBarButtonItemStylePlain target:self action:@selector(followUser:)];
                self.navigationItem.rightBarButtonItem = followButton;
            }
            else
            {
                UIBarButtonItem *unfollowButton = [[UIBarButtonItem alloc] initWithTitle:@"Unfollow" style:UIBarButtonItemStylePlain target:self action:@selector(unfollowUser:)];
                self.navigationItem.rightBarButtonItem = unfollowButton;
            }
            
        }];
    }
}

- (void)followUser:(id)sender
{
    if(_friendObject)
    {
        // create an entry in the Follow table
        PFObject *follow = [PFObject objectWithClassName:@"Follow"];
        [follow setObject:[PFUser currentUser]  forKey:@"from"];
        [follow setObject:_friendObject forKey:@"to"];
        [follow setObject:[NSDate date] forKey:@"date"];
        [follow saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            PFQuery *query = [PFQuery queryWithClassName:@"UserData"];
            [query whereKey:@"user" equalTo:[PFUser currentUser]];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                
                [object incrementKey:@"following"];
                [object saveInBackground];
                
            }];
            
            PFQuery *nextQuery = [PFQuery queryWithClassName:@"UserData"];
            [nextQuery whereKey:@"user" equalTo:_friendObject];
            [nextQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                
                [object incrementKey:@"followers"];
                [object saveInBackground];
                
            }];
            
            [self accommodateFriendView];
        }];
    }
}

- (void)unfollowUser:(id)sender
{
    if(_friendObject)
    {
        PFQuery *query = [PFQuery queryWithClassName:@"Follow"];
        [query whereKey:@"from" equalTo:[PFUser currentUser]];
        [query whereKey:@"to" equalTo:_friendObject];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            
            [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                PFQuery *query = [PFQuery queryWithClassName:@"UserData"];
                [query whereKey:@"user" equalTo:[PFUser currentUser]];
                [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    
                    [object incrementKey:@"following" byAmount:@-1];
                    [object saveInBackground];
                    
                }];
                
                PFQuery *nextQuery = [PFQuery queryWithClassName:@"UserData"];
                [nextQuery whereKey:@"user" equalTo:_friendObject];
                [nextQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    
                    [object incrementKey:@"followers" byAmount:@-1];
                    [object saveInBackground];
                    
                }];
                
                [self accommodateFriendView];
            }];
            
        }];
    }
}

- (void)followersTap:(id)sender
{
    _followKey = @"to";
    _oppositeKey = @"from";
    _viewTitle = @"Followers";
    [self performSegueWithIdentifier:@"FollowSegue" sender:sender];
}

- (void)followingTap:(id)sender
{
    _followKey = @"from";
    _oppositeKey = @"to";
    _viewTitle = @"Following";
    [self performSegueWithIdentifier:@"FollowSegue" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITapGestureRecognizer *)sender
{
    if([[segue identifier] isEqualToString:@"FollowSegue"])
    {
        if(self.friendID)
        {
            [[segue destinationViewController] setFriendKey:_friendObject];
        }
        [[segue destinationViewController] setTitle:_viewTitle];
        [[segue destinationViewController] setQueryKey:_followKey];
        [[segue destinationViewController] setReverseKey:_oppositeKey];
    }
}

- (void)loadPins
{
    PFQuery *query = [PFQuery queryWithClassName:@"Review"];
    
    if(self.friendID)
    {
        [query whereKey:@"user" equalTo:_friendObject];
    }
    else
    {
        [query whereKey:@"user" equalTo:[PFUser currentUser]];
    }
    
    [query includeKey:@"place"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        for(PFObject *object in objects)
        {
            PFObject *place = object[@"place"];
            PFGeoPoint *location = place[@"location"];
            
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            annotation.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
            annotation.title = place[@"name"];
            switch ((int)[object[@"rating"] integerValue]) {
                case 0:
                    annotation.subtitle = @"User Rating: Bad";
                    break;
                    
                case 1:
                    annotation.subtitle = @"User Rating: OK";
                    break;
                    
                case 2:
                    annotation.subtitle = @"User Rating: Good";
                    break;
                    
                case 3:
                    annotation.subtitle = @"User Rating: Great";
                    break;
                    
                default:
                    annotation.subtitle = @"No User Rating";
                    break;
            }
            [self.mapView addAnnotation:annotation];
        }
        
    }];
}

@end
