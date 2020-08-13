//
//  HtmlTextDescription.h
//  SimpleApp
//
//  Created by IOS4 on 27/12/17.
//  Copyright © 2017 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSSRichTextEditor.h"
#import "ZSSTextView.h"
#import "RichTextEditor.h"
//@interface HtmlTextDescription :ZSSRichTextEditor
//@property(nonatomic , strong) NSString * filledText;
//@property(nonatomic , strong) NSString * viewCheck;
//
//@end
@interface HtmlTextDescription :UIViewController
@property (weak, nonatomic) IBOutlet RichTextEditor *textViw;


@property(nonatomic , strong) NSString * filledText;
@property(nonatomic , strong) NSString * viewCheck;

@end
