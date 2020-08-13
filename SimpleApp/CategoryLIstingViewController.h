//
//  CategoryLIstingViewController.h
//  SimpleApp
//
//  Created by IOS2 on 6/28/17.
//  Copyright © 2017 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryObject.h"
#import "NotesObject.h"

@interface CategoryLIstingViewController :  UIViewController <UITableViewDelegate,UITableViewDataSource,UISearchDisplayDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray* searchCategoryArr;
@property (strong ,nonatomic)NSString* dbID;

@property (strong ,nonatomic)NotesObject *selectedObj;
@property (nonatomic, assign) long long selectedNoteID;
@property (nonatomic, assign) long long cateID;
- (IBAction)btnCancel:(id)sender;

@end
