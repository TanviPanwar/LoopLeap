//
//  AddUserViewController.h
//  SimpleApp
//
//  Created by IOS3 on 08/03/17.
//  Copyright © 2017 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserObject.h"
#import "ShareDBObject.h"
@interface AddUserViewController : UIViewController
@property (nonatomic,retain)NSString *dbID;
@property (nonatomic,retain)NSString *dbName;
@property (weak, nonatomic) IBOutlet UIButton *locationSharingBtn;

- (IBAction)btnShowSelectedOnly:(id)sender;
- (IBAction)btnShowAll:(id)sender;

@end
