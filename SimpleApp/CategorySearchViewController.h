//
//  CategorySearchViewController.h
//  SimpleApp
//
//  Created by IOS2 on 6/12/17.
//  Copyright © 2017 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryObject.h"

@interface CategorySearchViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>{
     NSInteger currentIndex;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray* searchCategoryArr;


@end
