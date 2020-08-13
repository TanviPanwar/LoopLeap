//
//  DbObject.h
//  SimpleApp
//
//  Created by IOS2 on 6/12/17.
//  Copyright © 2017 MAC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DbObject : NSObject
@property (nonatomic, assign) long long DatabaseID;
@property (nonatomic, strong) NSString * DBName;
@property (nonatomic, strong) NSString * StorageType;
@property (nonatomic, assign) long long Admin;
@property (nonatomic, assign) long long LcationStatus;


@end
