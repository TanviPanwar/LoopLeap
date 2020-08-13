//
//  ShareDBObject.h
//  SimpleApp
//
//  Created by IOS3 on 05/04/17.
//  Copyright © 2017 MAC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShareDBObject : NSObject
@property (nonatomic, assign) long long DatabaseID;
@property (nonatomic, assign) long long UserID;
@property (nonatomic, assign) long long Admin;
@property (nonatomic, strong) NSString *DBName;
@property (nonatomic, strong) NSString *DBType;
@property (nonatomic, strong) NSString *DBID;
@property (nonatomic, strong) NSString *Location_Status;






@end
