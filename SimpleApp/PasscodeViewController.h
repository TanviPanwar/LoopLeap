//
//  PasscodeViewController.h
//  SimpleApp
//
//  Created by IOS4 on 23/03/17.
//  Copyright © 2017 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PasscodeViewController : UIViewController
@property (strong, nonatomic) IBOutlet UISwitch *passcodeSwitchOutlet;
 
- (IBAction)passcodeSwitchAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *btnChangePassOutlet;
- (IBAction)btnChangePassAction:(id)sender;


@end
