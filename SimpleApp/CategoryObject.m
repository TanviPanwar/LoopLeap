//
//  CategoryObject.m
//  SimpleApp
//
//  Created by IOS2 on 4/4/17.
//  Copyright © 2017 MAC. All rights reserved.
//

#import "CategoryObject.h"

@implementation CategoryObject
-(instancetype)init {
    self = [super init];
    if (self) {
        self.DatabaseID = 0;
        self.UserID = 0;
        self.CategoryName = @"";
        self.CategoryID = 0 ;
        
    }
    return self;
}
@end
