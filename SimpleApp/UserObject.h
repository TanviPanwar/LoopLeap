//
//  UserObject.h
//  SimpleApp
//
//  Created by IOS3 on 05/04/17.
//  Copyright © 2017 MAC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserObject : NSObject
@property (nonatomic, assign) long long PhoneNo;
@property (nonatomic, assign) long long UserID;
@property (nonatomic, assign) long long adminFlag;
@property (nonatomic, strong) NSString * FirstName;
@property (nonatomic, strong) NSString * LastName;

@end
