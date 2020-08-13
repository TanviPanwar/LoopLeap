//
//  ChangePswdViewController.m
//  SimpleApp
//
//  Created by IOS1 on 3/2/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import "ChangePswdViewController.h"
#import "AppDelegate.h"

@interface ChangePswdViewController (){
    UITextField *activeTextfield;
    NSMutableDictionary *userDetail;
    
}
//@property (strong, nonatomic) IBOutlet UITextField *emailId;

@property (strong, nonatomic) IBOutlet UITextField *oldPassword;

@property (strong, nonatomic) IBOutlet UITextField *password_new;
@property (strong, nonatomic) IBOutlet UITextField *confirm_pswd;
@end

@implementation ChangePswdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    userDetail=[[NSMutableDictionary alloc]init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}
#pragma mark- UITextFieldDelegate
#pragma mark-


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeTextfield=textField;
    
//    if(self.view.frame.size.height<500 &&( textField == _confirmPassword || textField == _password))
//    {
//        CGRect frame=self.view.frame;
//        frame.origin.y =-100;
//        [self.view setFrame:frame];
//    }
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    activeTextfield=textField;
//    CGRect frame=self.view.frame;
//    frame.origin.y =0;
//    [self.view setFrame:frame];
}

- (IBAction)changePassword:(id)sender {

    NSString *pswd_new=[_password_new.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if(pswd_new.length )
    {
       /* if(![AppDelegate validateEmail: _emailId.text])
        {
            [AppDelegate showAlertViewWithTitle:@"Oops!" Message:@"Invalid Email Id"];
            
        }
        else */
        
        if(![_confirm_pswd.text isEqualToString:_password_new.text])
        {
            [AppDelegate showAlertViewWithTitle:nil Message:@"Password Mismatch."];
            _confirm_pswd.text=@"";
            _password_new.text=@"";
            
        }else
        {
            [userDetail removeAllObjects];
            [userDetail setObject:[AppDelegate getUserEmail] forKey:@"username"];
            [userDetail setObject:@"" forKey:@"password"];
            [userDetail setObject:_password_new.text forKey:@"newpassword"];
            [userDetail setObject:_confirm_pswd.text forKey:@"newpassword1"];
            [userDetail setObject:kChangePswd forKey:kDefault];
            
            [self hitApi];
        }
        
    }
    else
        [AppDelegate showAlertViewWithTitle:nil Message:@"Please Fill All Required Fields."];

}

#pragma mark- HitApi
#pragma mark

-(void)hitApi
{
    [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
    NSString *registerUrl=[NSString stringWithFormat:@"%@",HostUrl];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:registerUrl parameters:userDetail success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
    [AppDelegate hideHUDForView:self.view animated:YES];
    NSLog(@"Success: %@\n ***** %@", operation.responseString, responseObject);
    id status= [responseObject valueForKey:@"status"];
        if([status isKindOfClass:[NSString class]]){
            if([status isEqualToString:@"success"]){
                [self updatePassword];
                [AppDelegate showAlertViewWithTitle:@"Your Password Changed Successfully." Message:nil];
                [self.navigationController popViewControllerAnimated:YES];
            }
            else{
                 id reason= [responseObject valueForKey:@"reason"];
                 if([reason isKindOfClass:[NSString class]]){
                     [AppDelegate showAlertViewWithTitle:@"Sorry!" Message:@"Invalid Password."];
                }
               
            }
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        
        [AppDelegate hideHUDForView:self.view animated:YES];
        //if(dict)
        [AppDelegate showAlertViewWithTitle:@"Network Error" Message:@"Please Check Your Internet Connection."];
    }];
    
}

-(void)updatePassword
{
    NSString *pswd_new=[_password_new.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [[DBManager getSharedInstance]UpdatePassword:pswd_new forUserID:[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID]];
    
}



@end
