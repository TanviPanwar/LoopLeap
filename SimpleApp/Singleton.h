//
//  Singleton.h
//  SimpleApp
//
//  Created by iOS6 on 31/10/19.
//  Copyright © 2019 MAC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Singleton : NSObject
@property (nonatomic, retain) NSMutableArray * globalArray;
@property BOOL globalCount;
@property NSTimer *timer;

+(Singleton*)singleton;
@end

NS_ASSUME_NONNULL_END
