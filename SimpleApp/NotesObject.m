//
//  NotesObject.m
//  SimpleApp
//
//  Created by IOS2 on 4/4/17.
//  Copyright © 2017 MAC. All rights reserved.
//

#import "NotesObject.h"

@implementation NotesObject
-(instancetype)init {
    self = [super init];
    if (self) {
        self.DatabaseID = 0;
        self.UserID = 0;
        self.CategoryID = 0;
        self.NotesID = 0 ;
        self.expandStatus = 0 ;
        self.Title = @"" ;
        self.Note = @"" ;
        self.FileUpload = @"";
        self.imageData = [[NSData alloc] init];
    }
    return self;
}

@end
