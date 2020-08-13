//
//  userList.h
//  SimpleApp
//
//  Created by IOS4 on 03/03/17.
//  Copyright © 2017 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/ABAddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
@interface userList : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableViewUserList;
@property (nonatomic, strong) NSMutableArray *tableData;


- (IBAction)btnaddManually:(id)sender;
- (IBAction)btnSave:(id)sender;
- (IBAction)btnImportContact:(id)sender;

@end
