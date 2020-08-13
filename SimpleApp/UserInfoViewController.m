//
//  UserInfoViewController.m
//  SimpleApp
//
//  Created by IOS1 on 2/15/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import "UserInfoViewController.h"
#import "AppDelegate.h"

@interface UserInfoViewController ()
@property (weak, nonatomic) IBOutlet UITextField *txtUserName;
@property (weak, nonatomic) IBOutlet UITextField *txtEmailId;
@property (weak, nonatomic) IBOutlet UITextField *txtPhoneNo;
@property (weak, nonatomic) IBOutlet UITextField *liceneType;
@property (weak, nonatomic) IBOutlet UILabel *databaseNameLbl;

@end

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self searchUserDetail];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)searchUserDetail
{
    
    
    _txtEmailId.text = [AppDelegate getUserEmail];
    _txtUserName.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"first_name"];
    _txtPhoneNo.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"phoneNo"];
    _liceneType.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"license_type"];
    _databaseNameLbl.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentDbName"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
