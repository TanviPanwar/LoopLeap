//
//  HtmlTextDescription.m
//  SimpleApp
//
//  Created by IOS4 on 27/12/17.
//  Copyright © 2017 MAC. All rights reserved.
//

#import "HtmlTextDescription.h"
#import "ZSSDemoPickerViewController.h"


@interface HtmlTextDescription ()

@end

@implementation HtmlTextDescription

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Description";
     self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(canClicked)];
   
//    NSString *customCSS = @"";
    NSLog(@"%@",self.filledText);
    
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[self.filledText dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    
    
    
    [_textViw setAttributedText:attrStr];
    
    
//    [self setCSS:self.filledText];
//
//    self.alwaysShowToolbar = NO;
//    self.receiveEditorDidChangeEvents = NO;
//    if ([self.filledText isEqualToString:@"Description"] || [self.filledText isEqualToString:@""]) {
//         [self setPlaceholder:@"Description"];
//    }else{
//        self.formatHTML = NO;
//        [self setHTML:self.filledText];
//    }
    
    // Export HTML
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(exportHTML)];
    
    // HTML Content to set in the editor
   // NSString *html = @"<div class='test'></div><!-- This is an HTML comment -->"
   // "<p>This is a test of the <strong>ZSSRichTextEditor</strong> by <a title=\"Zed Said\" href=\"http://www.zedsaid.com\">Zed Said Studio</a></p>";
    
    // Set the base URL if you would like to use relative links, such as to images.
   // self.baseURL = [NSURL URLWithString:@"http://www.zedsaid.com"];
//    self.shouldShowKeyboard = YES;
    // Set the HTML contents of the editor
   
    
 //
    
}


//- (void)showInsertURLAlternatePicker {
//
//    [self dismissAlertView];
//
//    ZSSDemoPickerViewController *picker = [[ZSSDemoPickerViewController alloc] init];
//    picker.demoView = self;
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:picker];
//    nav.navigationBar.translucent = NO;
//    [self presentViewController:nav animated:YES completion:nil];
//
//}
//
//
//- (void)showInsertImageAlternatePicker {
//
//    [self dismissAlertView];
//
//    ZSSDemoPickerViewController *picker = [[ZSSDemoPickerViewController alloc] init];
//    picker.demoView = self;
//    picker.isInsertImagePicker = YES;
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:picker];
//    nav.navigationBar.translucent = NO;
//    [self presentViewController:nav animated:YES completion:nil];
//
//}
//
//
- (void)exportHTML {
    NSLog(@"%@", _textViw.htmlString);
    [[NSUserDefaults standardUserDefaults]setValue:_textViw.htmlString forKey:@"HTMLTEXT"];
    [[NSUserDefaults standardUserDefaults]setValue:_textViw.htmlString forKey:@"SIMPLETEXT"];
    [self.navigationController popViewControllerAnimated:YES];

}
//
//- (void)editorDidChangeWithText:(NSString *)text andHTML:(NSString *)html {
//
//    NSLog(@"Text Has Changed: %@", text);
//
//    NSLog(@"HTML Has Changed: %@", html);
//
//}
//
//- (void)hashtagRecognizedWithWord:(NSString *)word {
//
//    NSLog(@"Hashtag has been recognized: %@", word);
//
//}
//
//- (void)mentionRecognizedWithWord:(NSString *)word {
//
//    NSLog(@"Mention has been recognized: %@", word);
//
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)canClicked{
    if([self.viewCheck isEqualToString:@"Notes"]){
        
    }else{
    [[NSUserDefaults standardUserDefaults]setValue:@"" forKey:@"HTMLTEXT"];
    [[NSUserDefaults standardUserDefaults]setValue:@"" forKey:@"SIMPLETEXT"];
    }
    [self.navigationController popViewControllerAnimated:YES];
}


@end
