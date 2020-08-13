//
//  NoteDetailViewController.h
//  SimpleApp
//
//  Created by IOS1 on 2/4/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotesObject.h"
#import <GoogleSignIn/GoogleSignIn.h>
#import <GoogleAPIClientForREST/GoogleAPIClientForREST-umbrella.h>
#import <GTMSessionFetcher/GTMSessionFetcher.h>

@interface NoteDetailViewController : UIViewController<UITextViewDelegate,UITextFieldDelegate, GIDSignInDelegate , GIDSignInUIDelegate>{
    
     NSData *imageData ;
}
@property (weak, nonatomic) IBOutlet UIButton *editImgBtn;

@property(nonatomic,assign)NSInteger selectedIndex;
@property(nonatomic,assign)NSInteger isFrom;
@property(nonatomic,strong)NSMutableArray *recordArr;
@property (strong, nonatomic) IBOutlet UIImageView *imgView;
@property(nonatomic ,assign) NotesObject * notObj;
@property (strong, nonatomic) IBOutlet UITextField *textTille;
@property (strong, nonatomic) IBOutlet UITextView *desTextView;
@property (weak, nonatomic) IBOutlet UIImageView *imgeViewDescription;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textViewHeight;
@property(nonatomic,strong)NSString *navTittle;
//@property (strong, nonatomic) IBOutlet UIButton *btnSave;
- (IBAction)btnSaveClick:(id)sender;

@end
