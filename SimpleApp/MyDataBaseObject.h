//
//  MyDataBaseObject.h
//  SimpleApp
//
//  Created by IOS2 on 4/4/17.
//  Copyright © 2017 MAC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyDataBaseObject : NSObject

@property (nonatomic, assign) long long Databaseid;
@property (nonatomic, assign) long long Owner_Userid;
@property (nonatomic, strong) NSString * DBName;
@property (nonatomic, strong) NSString * Catelog;
@property (nonatomic, strong) NSString * LastModified;
@property (nonatomic, strong) NSString * DBType;
@property (nonatomic, strong) NSString * StorageType;
@property (nonatomic, assign) long long Admin;
@property (nonatomic, assign) long long LocationStatus;
@property (nonatomic, strong) NSString * Latitude;
@property (nonatomic, strong) NSString * Longitude;

@end
