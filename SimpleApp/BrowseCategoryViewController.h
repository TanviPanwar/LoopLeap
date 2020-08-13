//
//  BrowseCategoryViewController.h
//  SimpleApp
//
//  Created by IOS2 on 6/5/17.
//  Copyright © 2017 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BrowseCategoryViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>{
    
}
@property(nonatomic,strong)NSString *catTittle;
@property(nonatomic,strong)NSString *catId;
@property(nonatomic,strong)NSString *DBId;
@property(nonatomic,strong)NSString *AdminStatus;
@property bool isPublic;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tittleHeight;

@end
