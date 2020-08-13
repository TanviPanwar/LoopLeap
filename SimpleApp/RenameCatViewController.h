//
//  RenameCatViewController.h
//  SimpleApp
//
//  Created by IOS2 on 7/26/17.
//  Copyright © 2017 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RenameCatViewController : UIViewController<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *txtCatName;
- (IBAction)btnSaveClick:(id)sender;
@property(nonatomic,strong)NSString *catName;

@property (nonatomic, strong) NSString* DatabaseID;
@property (nonatomic,  strong) NSString* CategoryID;
@end
