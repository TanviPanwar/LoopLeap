//
//  DBListViewController.h
//  SimpleApp
//
//  Created by IOS3 on 25/10/18.
//  Copyright © 2018 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBListViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableViw;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

@end

NS_ASSUME_NONNULL_END
