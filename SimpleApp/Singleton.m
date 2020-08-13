//
//  Singleton.m
//  SimpleApp
//
//  Created by iOS6 on 31/10/19.
//  Copyright © 2019 MAC. All rights reserved.
//

#import "Singleton.h"

@implementation Singleton
@synthesize globalArray, globalCount, timer;
+(Singleton *)singleton {
    static dispatch_once_t pred;
    static Singleton *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[Singleton alloc] init];
        shared.globalArray = [[NSMutableArray alloc]init];
    });
    return shared;
}
@end
