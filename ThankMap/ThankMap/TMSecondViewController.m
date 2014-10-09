//
//  TMSecondViewController.m
//  ThankMap
//
//  Created by Noah Dayan on 9/1/14.
//  Copyright (c) 2014 Noah Dayan. All rights reserved.
//

#import "TMSecondViewController.h"
#import "TMThirdViewController.h"

@interface TMSecondViewController ()

@end

@implementation TMSecondViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // This table displays items in the Review class
        self.parseClassName = @"Review";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PFQuery *)queryForTable
{
    PFQuery *query;
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    if(self.feedButtons.selectedSegmentIndex == 0)
    {
        query = [PFQuery queryWithClassName:@"Review"];
        
        PFQuery *innerQuery = [PFQuery queryWithClassName:@"Follow"];
        [innerQuery whereKey:@"from" equalTo:[PFUser currentUser]];
        
        [query whereKey:@"user" matchesKey:@"to" inQuery:innerQuery];
        [query includeKey:@"place"];
        [query includeKey:@"user"];
        
        [query orderByDescending:@"createdAt"];
    }
    else if(self.feedButtons.selectedSegmentIndex == 1)
    {
        query = [PFQuery queryWithClassName:@"Follow"];
        
        [query whereKey:@"to" equalTo:[PFUser currentUser]];
        [query includeKey:@"from"];
    }
    
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
    
    cell.imageView.layer.cornerRadius = (cell.imageView.frame.size.width / 2);
    cell.imageView.clipsToBounds = YES;
    
    PFObject *user;
    
    if(self.feedButtons.selectedSegmentIndex == 0)
    {
        user = object[@"user"];
        
        PFObject *place = object[@"place"];
        
        switch ((int)[object[@"rating"] integerValue]) {
            case 0:
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ Rating: Bad", place[@"name"]];
                break;
                
            case 1:
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ Rating: OK", place[@"name"]];
                break;
                
            case 2:
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ Rating: Good", place[@"name"]];
                break;
                
            case 3:
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ Rating: Great", place[@"name"]];
                break;
                
            default:
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ Rating: None", place[@"name"]];
                break;
        }
    }
    else if(self.feedButtons.selectedSegmentIndex == 1)
    {
        user = object[@"from"];
        
        cell.detailTextLabel.text = @"follows you now!";
    }
    
    // Configure the cell to show user
    cell.textLabel.text = user[@"profile"][@"name"];
    
    NSString *userProfilePhotoURLString = user[@"profile"][@"pictureURL"];
    // Download the user's facebook profile picture
    if (userProfilePhotoURLString) {
        NSURL *pictureURL = [NSURL URLWithString:userProfilePhotoURLString];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
        
        [NSURLConnection sendAsynchronousRequest:urlRequest
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   if (connectionError == nil && data != nil) {
                                       cell.imageView.image = [UIImage imageWithData:data];
                                       
                                   } else {
                                       NSLog(@"Failed to load profile photo.");
                                   }
                               }];
    }
    
    return cell;
}

- (IBAction)feedChange:(id)sender
{
    [self loadObjects];
}

@end
