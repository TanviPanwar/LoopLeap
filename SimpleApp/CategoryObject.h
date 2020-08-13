//
//  CategoryObject.h
//  SimpleApp
//
//  Created by IOS2 on 4/4/17.
//  Copyright © 2017 MAC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CategoryObject : NSObject
@property (nonatomic, assign) long long UserID;
@property (nonatomic, assign) long long DatabaseID;
@property (nonatomic, strong) NSString * CategoryName;
@property (nonatomic, assign) long long CategoryID;

@end
