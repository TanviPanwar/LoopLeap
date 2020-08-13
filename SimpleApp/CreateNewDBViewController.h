//
//  CreateNewDBViewController.h
//  SimpleApp
//
//  Created by iOS6 on 04/07/19.
//  Copyright © 2019 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleSignIn/GoogleSignIn.h>


NS_ASSUME_NONNULL_BEGIN

@interface CreateNewDBViewController : UIViewController<UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, GIDSignInUIDelegate, GIDSignInDelegate>

@property (weak, nonatomic) IBOutlet UIView *databaseView;
@property (weak, nonatomic) IBOutlet UIView *storageView;
@property (strong, nonatomic) IBOutlet UITextField *databaseTextField;
@property (weak, nonatomic) IBOutlet UITextField *storageLocationTextField;
@property (strong, nonatomic) IBOutlet UIView *inputView;
@property (weak, nonatomic) IBOutlet UIPickerView *storageLocationPickerView;

@property(weak, nonatomic) IBOutlet GIDSignInButton *signInButton;


- (IBAction)cancelBtnAction:(id)sender;
- (IBAction)saveBtnAction:(id)sender;
- (IBAction)cancelTooolBarBtnAction:(id)sender;
- (IBAction)DoneToolBarBtnAction:(id)sender;


@end

NS_ASSUME_NONNULL_END

