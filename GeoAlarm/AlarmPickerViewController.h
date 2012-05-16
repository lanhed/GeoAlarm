//
//  AlarmPickerViewController.h
//  GeoAlarm
//
//  Created by Johan Månsson on 2012-02-01.
//  Copyright (c) 2012 KANMalmo AB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol SaveAlarmDelegate <NSObject>

-(void) saveLocationWithAlarmName:(NSString *)alarmName;

@end

@interface AlarmPickerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate>
{
	id<SaveAlarmDelegate> saveSoundDelegate;
	NSArray * sounds;
	NSString * currentAlarmName;
	AVAudioPlayer * soundPlayer;
}

@property (strong, nonatomic) id<SaveAlarmDelegate> saveSoundDelegate;
@property (strong, nonatomic) NSArray * sounds;
@property (strong, nonatomic) NSString * currentAlarmName;
- (IBAction)saveSound:(id)sender;
@end
