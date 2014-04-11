//
//  TopFlickrPlacesTVC.m
//  TopPlaces
//
//  Created by David Wieringa on 4/10/14.
//  Copyright (c) 2014 Userwise Solutions. All rights reserved.
//

#import "TopFlickrPlacesTVC.h"
#import "FlickrFetcher.h"

@interface TopFlickrPlacesTVC ()

@end

@implementation TopFlickrPlacesTVC

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
    [self fetchPlaces];
}

- (void)fetchPlaces
{
    NSURL *url = [FlickrFetcher URLforTopPlaces];
    NSData *jsonResult = [NSData dataWithContentsOfURL:url];
    NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResult
                                                                        options:0
                                                                          error:NULL];
    NSLog(@"Flickr results = %@", propertyListResults);
    
    NSArray *places = [propertyListResults valueForKeyPath:FLICKR_RESULTS_PLACES];
    
    NSMutableArray *countries = [[NSMutableArray alloc] init];
    NSMutableDictionary *placesByCountry = [[NSMutableDictionary alloc] init];
    for (NSDictionary *placeX in places) {
        NSMutableDictionary *place = [placeX mutableCopy];
        NSArray *locationParts = [[place valueForKeyPath:FLICKR_PLACE_NAME] componentsSeparatedByString:@","];
        NSString *country = locationParts[locationParts.count-1];
        NSString *middlePart = @"";
        if (locationParts.count == 3) {
            middlePart = locationParts[1];
        }
        place[@"title"] = locationParts[0];
        place[@"subtitle"] = middlePart;
        NSMutableArray *placesInCountry = [placesByCountry objectForKey:country];
        if (placesInCountry == nil) {
            [countries addObject:country];
            placesInCountry = [[NSMutableArray alloc] init];
        }
        [placesInCountry addObject:place];
        placesByCountry[country] = placesInCountry;
    }
    self.countries = [countries sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

    //sort places within countries
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"title"  ascending:YES];
    for (NSString *country in countries) {
        //placesByCountry[country] = [ sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        NSArray *places = placesByCountry[country];
        placesByCountry[country] = [places sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
        //recent = [stories copy];
    }
    self.placesByCountry = placesByCountry;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
