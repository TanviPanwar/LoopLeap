//
//  CategoriesViewController.h
//  SimpleApp
//
//  Created by IOS3 on 26/10/18.
//  Copyright © 2018 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyDataBaseObject.h"
NS_ASSUME_NONNULL_BEGIN

@interface CategoriesViewController : UIViewController
@property (strong ,nonatomic)MyDataBaseObject* dbObj;
@end

NS_ASSUME_NONNULL_END
