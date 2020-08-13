//
//  CreateDBController.h
//  SimpleApp
//
//  Created by IOS3 on 24/10/18.
//  Copyright © 2018 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyDataBaseObject.h"
NS_ASSUME_NONNULL_BEGIN

@interface CreateDBController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *dbTxtFld;
@property (weak, nonatomic) IBOutlet UIButton *personalBtn;
@property (weak, nonatomic) IBOutlet UIButton *publicBtn;
@property(retain , nonatomic) NSString *screenType;
@property(retain , nonatomic) MyDataBaseObject *dbObj;
@end

NS_ASSUME_NONNULL_END
