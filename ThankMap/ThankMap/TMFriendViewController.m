//
//  TMFriendViewController.m
//  ThankMap
//
//  Created by Noah Dayan on 10/8/14.
//  Copyright (c) 2014 Noah Dayan. All rights reserved.
//

#import "TMFriendViewController.h"
#import "TMThirdViewController.h"

@interface TMFriendViewController ()

@end

@implementation TMFriendViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // This table displays items in the User class
        self.parseClassName = @"User";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PFQuery *)queryForTable
{
    PFQuery *query = [PFUser query];
    PFUser *user = [PFUser currentUser];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query whereKey:@"objectId" notEqualTo:user.objectId];
    
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *cellIdentifier = @"Cell";
    
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier];
    }
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:10];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:20];
    UILabel *actionLabel = (UILabel *)[cell viewWithTag:30];
    
    imageView.layer.cornerRadius = (imageView.frame.size.width / 2);
    imageView.clipsToBounds = YES;
    
    // Configure the cell to show user
    nameLabel.text = object[@"profile"][@"name"];
    actionLabel.text = object[@"profile"][@"email"];
    
    NSString *userProfilePhotoURLString = object[@"profile"][@"pictureURL"];
    // Download the user's facebook profile picture
    if (userProfilePhotoURLString) {
        NSURL *pictureURL = [NSURL URLWithString:userProfilePhotoURLString];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
        
        [NSURLConnection sendAsynchronousRequest:urlRequest
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   if (connectionError == nil && data != nil) {
                                       imageView.image = [UIImage imageWithData:data];
                                       
                                   } else {
                                       NSLog(@"Failed to load profile photo.");
                                   }
                               }];
    }
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender
{
    if([[segue identifier] isEqualToString:@"ProfileSegue"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        [[segue destinationViewController] setFriendID:[self objectAtIndexPath:indexPath].objectId];
    }
}

@end
