//
//  GoogleNotesObject.m
//  SimpleApp
//
//  Created by iOS6 on 16/10/19.
//  Copyright © 2019 MAC. All rights reserved.
//

#import "GoogleNotesObject.h"

@implementation GoogleNotesObject

-(instancetype)init {
    self = [super init];
    if (self) {
        self.GoogleTitle = @"" ;
        self.GoogleCategory = @"" ;
        self.GoogleNotes = @"";
        
    }
    return self;
}

@end
