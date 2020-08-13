//
//  RegisterViewController.h
//  H2GO
//
//  Created by MAC on 11/20/15.
//  Copyright © 2015 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBManager.h"
@interface RegisterViewController : UIViewController


@property (strong, nonatomic) IBOutlet UITextField *lastName;
@property (strong, nonatomic) IBOutlet UIButton *btnFind;
@property (strong, nonatomic) IBOutlet UIButton *btnSave;

@end
