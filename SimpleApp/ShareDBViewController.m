//
//  ShareDBViewController.m
//  SimpleApp
//
//  Created by IOS3 on 07/03/17.
//  Copyright © 2017 MAC. All rights reserved.
//

#import "ShareDBViewController.h"
#import "ShareDBTableViewCell.h"
#import "AppDelegate.h"
#import "AddUserViewController.h"
@interface ShareDBViewController () <UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource>
{
    NSMutableArray *dbArray;
//      NSMutableArray *categoryArr;
      NSMutableArray *userArray ;
      NSString *strdbId;
}
@property (weak, nonatomic) IBOutlet UITableView *usersTblView;
@property (weak, nonatomic) IBOutlet UITextField *categoryTxtFld;
@property (weak, nonatomic) IBOutlet UIView *pickerContainerView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;


@end

@implementation ShareDBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   _categoryTxtFld.rightViewMode=UITextFieldViewModeAlways;
  /*  UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(9, 15, 12, 9)];
    [btn setBackgroundImage:[UIImage imageNamed:@"arrow"] forState:UIControlStateNormal];
    UIView *viw = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 30, 39)];
    [viw addSubview:btn];
    [btn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    _categoryTxtFld.rightView=viw;*/
    
    self.title = @"Share Database";
    // Do any additional setup after loading the view.
    dbArray = [[NSMutableArray alloc] init];
   // [self getCategoryList];
    [_usersTblView setTableFooterView:[[UIView alloc] init]];
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hidePickerView)];
    tap.numberOfTapsRequired=1;
    [self.view addGestureRecognizer:tap];

    
    [self.view addSubview:_pickerContainerView];
}

-(void)viewWillAppear:(BOOL)animated
{
   strdbId = [[NSUserDefaults standardUserDefaults] valueForKey:@"dbId"];
   NSString *strdbName = [[NSUserDefaults standardUserDefaults] valueForKey:@"dbName"];
    
    
    [self getDBListFromDatabase];
    if (strdbId.length == 0 && strdbName.length == 0)
    {
         self.categoryTxtFld.text=@"";
    }
    else
    {
        self.categoryTxtFld.text=strdbName;
        [self getShareDbListUsersFromLocal];
    }
    
}

-(void)getShareDBListUsers1 {
    
    userArray = [[NSMutableArray alloc] init];
    [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
    NSInteger row= [self.pickerView selectedRowInComponent:0];
    
    // NSString *registerUrl=[NSString stringWithFormat:@"%@",HostUrl];
    NSMutableDictionary *userDetail = [[NSMutableDictionary alloc]init];
    [userDetail setValue:kGetShareDBlist forKey:kDefault];
    [userDetail setValue:strdbId forKey:kDbID];
    [userDetail setValue:[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID] forKey:kLoogedInUserID];
    NSLog(@"UsetDetail Dict%@", userDetail);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:HostUrl parameters:userDetail success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
     
        NSLog(@"Success: %@\n ***** %@", operation.responseString, responseObject);
        id status= [responseObject valueForKey:@"status"];
        if([status isKindOfClass:[NSString class]]){
            [AppDelegate hideHUDForView:self.view animated:YES];
            if([status isEqualToString:@"success"]) {
                
                NSMutableArray *tableData = [[NSMutableArray alloc] init];
                tableData =  [AppDelegate getContacts];
                
                NSMutableArray  *resultArray = [responseObject valueForKey:@"MyDatabase"];
                for (int i=0; i < tableData.count; i++) {
                    
                    for (int j=0; j < resultArray.count; j++) {
                        
                        if ([[[resultArray objectAtIndex:j] valueForKey:@"phone_number"] isEqualToString:[[tableData objectAtIndex:i] valueForKey:@"phoneno"]]) {
                            
                            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                            [dict setValue:[[resultArray objectAtIndex:j] valueForKey:@"Admin"] forKey:@"Admin"];
                            [dict setValue:[[resultArray objectAtIndex:j]valueForKey:@"phone_number"] forKey:@"phone_number"];
                            [dict setValue:[[resultArray objectAtIndex:j]valueForKey:@"userid"] forKey:@"userid"];
                            [dict setValue:[[tableData objectAtIndex:i] valueForKey:@"Fname"] forKey:@"first_name"];
                            [dict setValue:[[tableData objectAtIndex:i] valueForKey:@"Lname"] forKey:@"last_name"];
                            [userArray addObject:dict];
                        }
                        
                        
                    }
                    
                    
                }
                
                [[NSUserDefaults standardUserDefaults] setObject:userArray forKey:@"DBArray"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [_usersTblView reloadData];
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
-(void)buttonAction:(UIButton *)sender
{
    NSLog(@"dadkjk");
    
    if (dbArray.count > 0){
    [self showPickerView];
    }
}


-(void)showPickerView {
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    self.pickerContainerView.frame = CGRectMake(0, self.view.frame.size.height-self.pickerContainerView.frame.size.height, self.pickerContainerView.frame.size.width, self.pickerContainerView.frame.size.height);
    [UIView commitAnimations];
}

-(void)hidePickerView {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    self.pickerContainerView.frame = CGRectMake(0, self.view.frame.size.height, self.pickerContainerView.frame.size.width, self.pickerContainerView.frame.size.height);
    [UIView commitAnimations];
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (dbArray.count > 0) {
       [self showPickerView];
    }
    return NO;
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection: (NSInteger)section
{
    return [userArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"shareCell";
    
     ShareDBTableViewCell*cell = (ShareDBTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSString *lastName;
    if (([[[userArray objectAtIndex:indexPath.row] valueForKey:@"last_name"]  isEqual: @""]) || ([[userArray objectAtIndex:indexPath.row] valueForKey:@"last_name"] == NULL))
    {
        
        lastName = @"";
        
    } else {
        
        lastName = [[userArray objectAtIndex:indexPath.row] valueForKey:@"last_name"];

        
    }
     cell.nameLbl.text = [NSString stringWithFormat:@"%@ %@",[[userArray objectAtIndex:indexPath.row] valueForKey:@"first_name"],lastName];
    NSString *adminFlag = [[userArray objectAtIndex:indexPath.row] valueForKey:@"Admin"];
    if ([adminFlag isEqualToString:@"0"]) {
        [cell.adminBtn setBackgroundImage:[UIImage imageNamed:@"unchecked.png"] forState:UIControlStateNormal];
        
    }
    else if ([adminFlag isEqualToString:@""]) {
         [cell.adminBtn setBackgroundImage:[UIImage imageNamed:@"unchecked.png"] forState:UIControlStateNormal];
    }
    else {
          [cell.adminBtn setBackgroundImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateNormal];
    }
     return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // determine the selected data from the IndexPath.row
    
    
}
#pragma mark- UIPickerViewDelegate
#pragma mark-
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return dbArray.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    MyDataBaseObject *obj = [dbArray objectAtIndex:row];
    return obj.DBName;
}
#pragma mark- IBAction Methods

- (IBAction)done:(id)sender {
    [self hidePickerView];
    NSInteger row= [self.pickerView selectedRowInComponent:0];
    MyDataBaseObject *obj = [dbArray objectAtIndex:row];
    self.categoryTxtFld.text=obj.DBName;
    
    if (obj.Admin == 1){
        
        _addUserBtn.hidden = NO;
         [self getShareDbListUsersFromLocal];
        
    } else {
        
        _addUserBtn.hidden = YES;
        [userArray removeAllObjects];
        [_usersTblView reloadData];

        [AppDelegate showAlertViewWithTitle:@"" Message:@"You have no admin access to share this database"];
    }
    
   
}
- (IBAction)addUser_action:(id)sender {
    if (_categoryTxtFld.text.length > 0) {
        NSInteger row= [self.pickerView selectedRowInComponent:0];
        AddUserViewController *addUser = [self.storyboard instantiateViewControllerWithIdentifier:@"AddUserViewController"];
        MyDataBaseObject *obj = [dbArray objectAtIndex:row];
        addUser.dbID = [NSString stringWithFormat:@"%lld", obj.Databaseid ];
        addUser.dbName = obj.DBName;
        [[NSUserDefaults standardUserDefaults] setValue:addUser.dbID forKey:@"dbId"];
        [[NSUserDefaults standardUserDefaults] setValue:addUser.dbName forKey:@"dbName"];
        
        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
        [self.navigationController pushViewController:addUser animated:true];
        
    } else {
        
          [AppDelegate showAlertViewWithTitle:@"Alert! " Message:[NSString stringWithFormat:@" Please select Database"]];
    }
    
   
}

- (IBAction)admin_Action:(UIButton *)sender {
    
//    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:sender.tag inSection:0];
//    ShareDBTableViewCell*cell = [_usersTblView cellForRowAtIndexPath:indexPath];
//    if ([[cell.adminBtn backgroundImageForState:UIControlStateNormal] isEqual:[UIImage imageNamed:@"unchecked.png"]]) {
//        
//        [cell.adminBtn setBackgroundImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateNormal];
//    }
//    else {
//        [cell.adminBtn setBackgroundImage:[UIImage imageNamed:@"unchecked.png"] forState:UIControlStateNormal];
//    }
   
}
- (IBAction)prev_Action:(id)sender {
    if (userArray.count > 0) {
        
        if (userArray.count > 6) {
            
        }
    }
    
}
- (IBAction)next_Action:(id)sender {
    
    if (userArray.count > 6) {
        
        
    }
    
}

#pragma mark- Webservices
//-(void)getCategoryList {
//    
//    [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
//    // NSString *registerUrl=[NSString stringWithFormat:@"%@",HostUrl];
//    NSMutableDictionary *userDetail = [[NSMutableDictionary alloc]init];
//    [userDetail setValue:kGetCategories forKey:kDefault];
//    [userDetail setValue:[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID] forKey:kLoogedInUserID];
//    NSLog(@"UsetDetail Dict%@", userDetail);
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    [manager POST:HostUrl parameters:userDetail success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
//        
//        [AppDelegate hideHUDForView:self.view animated:YES];
//        NSLog(@"Success: %@\n ***** %@", operation.responseString, responseObject);
//        id status= [responseObject valueForKey:@"status"];
//        if([status isKindOfClass:[NSString class]]){
//            if([status isEqualToString:@"success"]) {
//                categoryArr = [[NSMutableArray alloc] init];
//                categoryArr = [responseObject valueForKey:@"MyDatabase"];
//                [_pickerView reloadAllComponents];
//                
//                //                     [self save];
//            }
//            
//            else{
//                 [AppDelegate hideHUDForView:self.view animated:YES];
//                
//                //                    [AppDelegate showAlertViewWithTitle:@"Sorry!" Message:@"Email already exists"];
//            }
//        }
//    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
//        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
//        
//      [AppDelegate hideHUDForView:self.view animated:YES];
//        //if(dict)
//        [AppDelegate showAlertViewWithTitle:@"Network error" Message:@"Please Check your internet connection"];
//    }];
//    
//    
//    
//    
//}


-(void)getDBListFromDatabase {
    dbArray = [[NSMutableArray alloc] init];
    NSString *ownerID = [[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID];
    
    
    /* For Owner Database*/
//    dbArray = [[DBManager getSharedInstance]getDataFromMyDataBase:ownerID];
    
      /* For All Database*/
     dbArray = [[DBManager getSharedInstance]getAllDataFromMyDataBase];

    
}

-(void)getShareDbListUsersFromLocal {
    userArray = [[NSMutableArray alloc] init];
    NSInteger row= [self.pickerView selectedRowInComponent:0];
    MyDataBaseObject *obj = [dbArray objectAtIndex:row];
    NSMutableArray *tableData = [[NSMutableArray alloc] init];
    tableData =  [AppDelegate getContacts];
    NSMutableArray  *resultArray =  [[DBManager getSharedInstance]getShareUserList: obj.Databaseid];
    NSLog(@"%@",resultArray);
    
    for (int i=0; i < tableData.count; i++) {
        
        for (int j=0; j < resultArray.count; j++) {
            
            UserObject  *userOBJ =  [resultArray objectAtIndex:j];
            
            if (userOBJ.PhoneNo ==  [[[tableData objectAtIndex:i] valueForKey:@"phoneno"] longLongValue]) {
                
                NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                
                [dict setValue:[NSString stringWithFormat:@"%lld",userOBJ.adminFlag] forKey:@"Admin"];
                [dict setValue:[NSString stringWithFormat:@"%lld",userOBJ.PhoneNo] forKey:@"phone_number"];
                [dict setValue:[NSString stringWithFormat:@"%lld",userOBJ.UserID] forKey:@"userid"];
                [dict setValue:userOBJ.FirstName forKey:@"first_name"];
                [dict setValue:userOBJ.LastName  forKey:@"last_name"];
                [userArray addObject:dict];
            }
            
                    }
        
        
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:userArray forKey:@"DBArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [_usersTblView reloadData];


}
-(void)getShareDBListUsers {
    
    userArray = [[NSMutableArray alloc] init];
    [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
    NSInteger row= [self.pickerView selectedRowInComponent:0];
    MyDataBaseObject *obj = [dbArray objectAtIndex:row];
    // NSString *registerUrl=[NSString stringWithFormat:@"%@",HostUrl];
    NSMutableDictionary *userDetail = [[NSMutableDictionary alloc]init];
    [userDetail setValue:kGetShareDBlist forKey:kDefault];
    [userDetail setValue:[ NSString stringWithFormat:@"%lld", obj.Databaseid ] forKey:kDbID];
    [userDetail setValue:[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID] forKey:kLoogedInUserID];
    NSLog(@"UsetDetail Dict%@", userDetail);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:HostUrl parameters:userDetail success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        [AppDelegate hideHUDForView:self.view animated:YES];
        NSLog(@"Success: %@\n ***** %@", operation.responseString, responseObject);
        id status= [responseObject valueForKey:@"status"];
        if([status isKindOfClass:[NSString class]]){
            if([status isEqualToString:@"success"]) {
                
                NSMutableArray *tableData = [[NSMutableArray alloc] init];
                tableData =  [AppDelegate getContacts];
                
                 NSMutableArray  *resultArray = [responseObject valueForKey:@"MyDatabase"];
                for (int i=0; i < tableData.count; i++) {
                    
                    for (int j=0; j < resultArray.count; j++) {
                        
                        if ([[[resultArray objectAtIndex:j] valueForKey:@"phone_number"] isEqualToString:[[tableData objectAtIndex:i] valueForKey:@"phoneno"]]) {
                            
                            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                            
                            [dict setValue:[[resultArray objectAtIndex:j] valueForKey:@"Admin"] forKey:@"Admin"];
                            [dict setValue:[[resultArray objectAtIndex:j]valueForKey:@"phone_number"] forKey:@"phone_number"];
                            [dict setValue:[[resultArray objectAtIndex:j]valueForKey:@"userid"] forKey:@"userid"];
                            [dict setValue:[[tableData objectAtIndex:i] valueForKey:@"Fname"] forKey:@"first_name"];
                            [dict setValue:[[tableData objectAtIndex:i] valueForKey:@"Lname"] forKey:@"last_name"];
                            
                            [userArray addObject:dict];
                        }
                        
                        
                    }

                    
                }
                
                [[NSUserDefaults standardUserDefaults] setObject:userArray forKey:@"DBArray"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [_usersTblView reloadData];
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

- (IBAction)btnArrowAction:(id)sender {
    if (dbArray.count > 0){
    [self showPickerView];
    }
}
@end
