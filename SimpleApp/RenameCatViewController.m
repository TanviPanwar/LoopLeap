 //
//  RenameCatViewController.m
//  SimpleApp
//
//  Created by IOS2 on 7/26/17.
//  Copyright © 2017 MAC. All rights reserved.
//

#import "RenameCatViewController.h"
#import "DBManager.h"
#import "RecordListViewController.h"
#import "AFHTTPSessionManager.h"
#import "AppDelegate.h"

@interface RenameCatViewController ()

@end

@implementation RenameCatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.txtCatName.text = self.catName;
    self.title = self.catName;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back.png"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];//[[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    // Do any additional setup after loading the view.
}

-(void)backAction{
    NSArray *array = self.navigationController.viewControllers;
    
    for (UIViewController *controller in array) {
        if ([controller isKindOfClass:[RecordListViewController class]]) {
            [self.navigationController popToViewController:controller animated:true];
        }
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
   return  [textField resignFirstResponder];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnSaveClick:(id)sender {
    
    if (self.txtCatName.text.length != 0) {
        [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
        
        NSString *categoryName =  self.txtCatName.text;
        categoryName = [categoryName stringByReplacingOccurrencesOfString:@"\""  withString:@"~#~"];
        categoryName = [categoryName stringByReplacingOccurrencesOfString:@"\'" withString:@"~!~"];
        
        NSMutableDictionary *userDetail = [[NSMutableDictionary alloc]init];
        [userDetail setValue:rename_category forKey:kDefault];
        [userDetail setValue:self.CategoryID forKey:@"category_id"];
        [userDetail setValue:self.DatabaseID forKey:@"database_id"];
        [userDetail setValue:categoryName forKey:@"category_name"];
        [userDetail setValue:[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID] forKey:kLoogedInUserID];
        
        
        NSLog(@"UsetDetail Dict%@", userDetail);


        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:HostUrl parameters:userDetail success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            
            
            NSLog(@"Success: %@\n ***** %@", operation.responseString, responseObject);
            id status= [responseObject valueForKey:@"status"];
            if([status isKindOfClass:[NSString class]]){
                [AppDelegate hideHUDForView:self.view animated:YES];
                if([status isEqualToString:@"Success"]) {
                    
                    
                     [self reNameCatInSqlite:categoryName];
                    NSArray *array = self.navigationController.viewControllers;
                    
                    for (UIViewController *controller in array) {
                        if ([controller isKindOfClass:[RecordListViewController class]]) {
                            [self.navigationController popToViewController:controller animated:true];
                            [[NSUserDefaults standardUserDefaults]setValue:@""forKey:@"SelectedCategory"];
                        }
                    }
                }
                else if([status isEqualToString:@"Failed"])  {
                    [AppDelegate hideHUDForView:self.view animated:YES];
                    
                    id status= [responseObject valueForKey:@"reason"];
                  
                    [AppDelegate showAlertViewWithTitle:@"Error" Message:status];
                }
                
                else{
                    [AppDelegate hideHUDForView:self.view animated:YES];
                    //                    [AppDelegate showAlertViewWithTitle:@"Sorry!" Message:@"Email already exists"];
                }
            }
        } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
            NSLog(@"Error: %@ ***** %@", operation.responseString, error);
            
            [AppDelegate hideHUDForView:self.view animated:YES];
            //if(dict)
            [AppDelegate showAlertViewWithTitle:@"Network Error" Message:@"Please Check Your Internet Connection."];
        }];

       }
    else{
        
    }
}


-(void)reNameCatInSqlite:(NSString*)catName{
    
    [[DBManager getSharedInstance]renameCategory:self.CategoryID withDbID:self.DatabaseID withNewName:catName];
    
    
}


@end
