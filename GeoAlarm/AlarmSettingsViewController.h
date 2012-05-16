//
//  AlarmSettingsViewController.h
//  GeoAlarm
//
//  Created by Johan Månsson on 2012-02-01.
//  Copyright (c) 2012 KANMalmo AB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"
#import "AppDelegate.h"
#import "AlarmPickerViewController.h"

@protocol AlarmSettingsDelegate <NSObject>

-(void)updateAlarmSettings:(NSInteger)selectedRadius;

@end

@interface AlarmSettingsViewController : UIViewController <UITableViewDelegate, SaveAlarmDelegate>
{
	id<AlarmSettingsDelegate> alarmSettingsDelegate;
	AppDelegate * delegate;
	Location * loc;
	NSInteger selectedRadius;
}

@property (strong, nonatomic) Location * loc;
@property (strong, nonatomic) id<AlarmSettingsDelegate> alarmSettingsDelegate;
@property (nonatomic) int lastQuestionStep;
@property (nonatomic) int stepValue;

@property (assign, nonatomic) NSInteger selectedRadius;
@property (strong, nonatomic) IBOutlet UITableView *settingsTableView;
@property (strong, nonatomic) IBOutlet UILabel *radiusLabel;
@property (strong, nonatomic) IBOutlet UISlider *radiusSlider;

- (IBAction)radiusSelectorChange:(id)sender;

-(void)saveLocationWithAlarmName:(NSString *)alarmName;

@end
