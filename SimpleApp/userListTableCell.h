//
//  userListTableCell.h
//  SimpleApp
//
//  Created by IOS4 on 03/03/17.
//  Copyright © 2017 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface userListTableCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lastName;
@property (strong, nonatomic) IBOutlet UILabel *firstName;
@property (strong, nonatomic) IBOutlet UILabel *contactNo;
@property (strong, nonatomic) IBOutlet UIButton *btnAddUser;

@end
