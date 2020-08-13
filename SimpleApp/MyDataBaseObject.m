//
//  MyDataBaseObject.m
//  SimpleApp
//
//  Created by IOS2 on 4/4/17.
//  Copyright © 2017 MAC. All rights reserved.
//

#import "MyDataBaseObject.h"

@implementation MyDataBaseObject

-(instancetype)init {
    self = [super init];
    if (self) {
        self.Databaseid = 0;
        self.Owner_Userid = 0;
        self.DBName = @"";
        self.LastModified = @"" ;
        self.DBType = @"";
    }
    return self;
}

@end
