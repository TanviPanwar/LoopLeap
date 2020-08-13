//
//  NotesObject.h
//  SimpleApp
//
//  Created by IOS2 on 4/4/17.
//  Copyright © 2017 MAC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotesObject : NSObject
@property (nonatomic, assign) long long NotesID;
@property (nonatomic, assign) long long UserID;
@property (nonatomic, assign) long long expandStatus;
@property (nonatomic, strong) NSString * Title;
@property (nonatomic, strong) NSString * Note;
@property (nonatomic, strong) NSString * categoryName;
@property (nonatomic, strong) NSString * FileUpload;
@property (nonatomic, strong) NSData * imageData;
@property (nonatomic, assign) long long DatabaseID;
@property (nonatomic, assign) long long CategoryID;
@end
