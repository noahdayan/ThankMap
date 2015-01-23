//
//  TMFollowViewController.m
//  ThankMap
//
//  Created by Noah Dayan on 10/7/14.
//  Copyright (c) 2014 Noah Dayan. All rights reserved.
//

#import "TMFollowViewController.h"
#import "TMThirdViewController.h"

@interface TMFollowViewController ()

@end

@implementation TMFollowViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // This table displays items in the Follow class
        self.parseClassName = @"Follow";
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
    PFQuery *query = [PFQuery queryWithClassName:@"Follow"];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    if(_friendKey)
    {
        [query whereKey:self.queryKey equalTo:_friendKey];
    }
    else
    {
        [query whereKey:self.queryKey equalTo:[PFUser currentUser]];
    }
    
    [query includeKey:self.reverseKey];
    
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)result
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
    
    PFObject *object = result[self.reverseKey];
    
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
        PFObject *object = [self objectAtIndexPath:indexPath][self.reverseKey];
        [[segue destinationViewController] setFriendID:object.objectId];
    }
}

@end
