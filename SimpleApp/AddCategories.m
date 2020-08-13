//
//  AddCategories.m
//  SimpleApp
//
//  Created by IOS2 on 4/3/17.
//  Copyright © 2017 MAC. All rights reserved.
//

#import "AddCategories.h"

@implementation AddCategories
-(instancetype)init {
    self = [super init];
    if (self) {
        self.Databaseid = 0;
        self.Owner_Userid = 0;
        self.DBName = @"";
        self.LastModified = 0;
        
    }
    return self;
}

@end
