//
//  TMFirstViewController.m
//  ThankMap
//
//  Created by Noah Dayan on 9/1/14.
//  Copyright (c) 2014 Noah Dayan. All rights reserved.
//

#import "TMFirstViewController.h"
#import "TMReviewViewController.h"
#import "TMQueryHelper.h"
#import <Parse/Parse.h>

@interface TMFirstViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate>

@property (strong, nonatomic) TMQueryHelper *queryHelper;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray *annotations;
@property (strong, nonatomic) CLGeocoder *geocoder;

@end

@implementation TMFirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.mapView.delegate = self;
    self.searchBar.delegate = self;
    self.locationManager.delegate = self;
    
    self.queryHelper = [[TMQueryHelper alloc] init];
    self.geocoder = [[CLGeocoder alloc] init];
    self.locationManager = [[CLLocationManager alloc] init];
    
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 1000, 1000);
    [self.mapView setRegion:viewRegion animated:YES];
    //[self.mapView setCenterCoordinate:userLocation.coordinate animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"Search: %@", searchBar.text);
    [self performSearch:searchBar.text];
    
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)performSearch:(NSString *)term
{
    if(self.annotations)
    {
        [self.mapView removeAnnotations:self.annotations];
    }
    self.annotations = [[NSMutableArray alloc] init];
    
    CLLocationCoordinate2D location = self.mapView.userLocation.coordinate;
    
    NSString *latitude = [[NSNumber numberWithDouble:location.latitude] stringValue];
    NSString *longitude = [[NSNumber numberWithDouble:location.longitude] stringValue];
    
    [self.queryHelper queryTopBusinessInfoForTerm:term latitude:latitude longitude:longitude completionHandler:^(NSDictionary *topBusinessJSON, NSError *error) {
        
        if (error) {
            NSLog(@"An error happened during the request: %@", error);
        } else if (topBusinessJSON) {
            NSLog(@"Top business info: \n %@", topBusinessJSON);
            
            [self addPin:topBusinessJSON];
            
        } else {
            NSLog(@"No business was found");
        }
    }];
}

- (void)addPin:(NSDictionary *)dict
{
    NSDictionary *location = [dict objectForKey:@"location"];
    NSDictionary *coordinate = [location objectForKey:@"coordinate"];
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.title = [dict objectForKey:@"name"];
    
    if(coordinate)
    {
        annotation.coordinate = CLLocationCoordinate2DMake([[coordinate objectForKey:@"latitude"] doubleValue], [[coordinate objectForKey:@"longitude"] doubleValue]);
        
        [self.mapView addAnnotation:annotation];
        [self.annotations addObject:annotation];
    }
    else
    {
        NSString *address = [NSString stringWithFormat:@"%@, %@, %@, %@, %@", [[location objectForKey:@"address"] objectAtIndex:0], [location objectForKey:@"city"], [location objectForKey:@"state_code"], [location objectForKey:@"postal_code"], [location objectForKey:@"country_code"]];
        
        [self.geocoder geocodeAddressString:address
                          completionHandler:^(NSArray* placemarks, NSError* error){
                              if (placemarks && placemarks.count > 0) {
                                  CLPlacemark *topResult = [placemarks objectAtIndex:0];
                                  MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:topResult];
                                  
                                  annotation.coordinate = placemark.coordinate;
                                  
                                  [self.mapView addAnnotation:annotation];
                                  [self.annotations addObject:annotation];
                              }
                          }
         ];
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"Place"];
    [query whereKey:@"name" equalTo:[dict objectForKey:@"name"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if([objects count] != 0)
        {
            PFQuery *innerQuery = [PFQuery queryWithClassName:@"Review"];
            [innerQuery whereKey:@"place" equalTo:[objects firstObject]];
            [innerQuery whereKey:@"user" equalTo:[PFUser currentUser]];
            [innerQuery findObjectsInBackgroundWithBlock:^(NSArray *innerObjects, NSError *error) {
                if([innerObjects count] != 0)
                {
                    switch ((int)[[innerObjects firstObject][@"rating"] integerValue]) {
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
                }
            }];
        }
    }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"PinAnnotationView"];
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"PinAnnotationView"];
            pinView.canShowCallout = YES;
            pinView.animatesDrop = YES;
            
            // Add a detail disclosure button to the callout.
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            pinView.rightCalloutAccessoryView = rightButton;
            
        } else {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    id<MKAnnotation> annotation = [view annotation];
    if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        [self performSegueWithIdentifier:@"ReviewSegue" sender:view];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(MKAnnotationView *)sender
{
    if([[segue identifier] isEqualToString:@"ReviewSegue"])
    {
        [[segue destinationViewController] loadReview:sender.annotation];
    }
}

@end
