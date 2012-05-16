//
//  ViewController.h
//  GeoAlarm
//
//  Created by Johan Månsson on 2012-01-18.
//  Copyright (c) 2012 KANMalmo AB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"

@interface ViewController : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>
{
	NSArray * favorites;
	NSMutableArray * filteredListContent;
	Location * selectedLocation;
	NSInteger selectedRadius;
	AppDelegate * delegate;
}

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *progressSymbol;
@property (strong, nonatomic) IBOutlet UITableView *favoritesTableView;
@property (strong, nonatomic) IBOutlet UIButton *mapDestinationButton;

@property (strong, nonatomic) NSArray * favorites;
//@property (strong, nonatomic) NSMutableArray * filteredListContent;

//- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope;
- (void)createNotificationMessage:(NSString *) notificationString;

@end
