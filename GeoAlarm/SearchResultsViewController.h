//
//  SearchResultsViewController.h
//  GeoAlarm
//
//  Created by Johan Månsson on 2012-01-20.
//  Copyright (c) 2012 KANMalmo AB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"

@interface SearchResultsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIApplicationDelegate>
{
	NSArray * searchResult;
	Location * selectedLocation;
	NSInteger selectedRadius;
}

@property (strong, nonatomic) NSArray * searchResult;
@property (nonatomic) NSInteger selectedRadius;
@end
