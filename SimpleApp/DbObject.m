//
//  DbObject.m
//  SimpleApp
//
//  Created by IOS2 on 6/12/17.
//  Copyright © 2017 MAC. All rights reserved.
//

#import "DbObject.h"

@implementation DbObject
-(instancetype)init {
    self = [super init];
    if (self) {
        self.DatabaseID = 0;
        self.DBName = @"";
    }
    return self;
}
@end
