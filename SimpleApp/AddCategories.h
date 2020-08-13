//
//  AddCategories.h
//  SimpleApp
//
//  Created by IOS2 on 4/3/17.
//  Copyright © 2017 MAC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddCategories : NSObject

@property (nonatomic, assign) long long Databaseid;
@property (nonatomic, assign) long long Owner_Userid;
@property (nonatomic, strong) NSString * DBName;
@property (nonatomic, strong) NSString * Catelog;
@property (nonatomic, strong) NSDate * LastModified;

@end
