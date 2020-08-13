//
//  SelectDatabaseVC.h
//  SimpleApp
//
//  Created by IOS3 on 15/06/18.
//  Copyright © 2018 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectDatabaseVC : UIViewController <UITableViewDelegate , UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *databaseTable;
@property(retain , nonatomic) NSString *screenType;
@end
