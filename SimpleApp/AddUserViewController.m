//
//  AddUserViewController.m
//  SimpleApp
//
//  Created by IOS3 on 08/03/17.
//  Copyright © 2017 MAC. All rights reserved.
//

#import "AddUserViewController.h"
#import "AddUserCell.h"
#import "AppDelegate.h"

@interface AddUserViewController ()<UIPickerViewDelegate, UIPickerViewDataSource , UITableViewDelegate,UITableViewDataSource, UITextFieldDelegate>
{
    NSMutableArray *categoryArr;
    NSMutableArray *tableData;
    NSMutableArray *arrSelected;
    NSMutableArray *userArray;
    NSMutableArray *shareArrList;
    BOOL locationStatus;
    int locationFlag;
    
}
@property (weak, nonatomic) IBOutlet UITextField *categoryTxtFld;
@property (weak, nonatomic) IBOutlet UITableView *tablViw;
@property (weak, nonatomic) IBOutlet UIView *pickerContainerView;
@property (weak, nonatomic) IBOutlet UIPickerView *categoryPicker;

@end

@implementation AddUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
    [self checkContacts];
    
    
    self.title = @"Add User";
    categoryArr = [[NSMutableArray alloc] init];
    locationFlag = 0;
  
   
    // Do any additional setup after loading the view.
}

-(void)setUI {
   
    
    [_tablViw setTableFooterView:[[UIView alloc] init]];
//    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hidePickerView)];
//    tap.numberOfTapsRequired=1;
//    [self.view addGestureRecognizer:tap];
    
    _categoryTxtFld.userInteractionEnabled = false;
    
//    _categoryTxtFld.rightViewMode=UITextFieldViewModeAlways;
//    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(9, 15, 12, 9)];
//    [btn setBackgroundImage:[UIImage imageNamed:@"arrow"] forState:UIControlStateNormal];
//    UIView *viw = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 30, 39)];
//    [viw addSubview:btn];
//    //    [btn addTarget:self action:@selector() forControlEvents:UIControlEventTouchUpInside]
//    _categoryTxtFld.rightView=viw;
    _categoryTxtFld.text = self.dbName;


}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
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
} */


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection: (NSInteger)section
{
    return userArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"userCell";
    
    AddUserCell*cell = (AddUserCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.nameLbl.text = [NSString stringWithFormat:@"%@ %@",[[userArray objectAtIndex:indexPath.row] valueForKey:@"first_name"] ,[[userArray objectAtIndex:indexPath.row] valueForKey:@"last_name"]];
    
    NSString *adminFlag = [[userArray objectAtIndex:indexPath.row] valueForKey:@"Admin"];
    if ([adminFlag isEqualToString:@"1"]) {
        
        [cell.adminBtn setBackgroundImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateNormal];
    }
    else {
        [cell.adminBtn setBackgroundImage:[UIImage imageNamed:@"unchecked.png"] forState:UIControlStateNormal];
    }
    NSString *shareFlag = [[userArray objectAtIndex:indexPath.row] valueForKey:@"Share"];
    if ([shareFlag isEqualToString:@"1"]) {
        
        [cell.shareBtn setBackgroundImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateNormal];
    }
    else {
        [cell.shareBtn setBackgroundImage:[UIImage imageNamed:@"unchecked.png"] forState:UIControlStateNormal];
    }
    
    cell.adminBtn.tag = indexPath.row;
    cell.shareBtn.tag = indexPath.row;
    
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
    return categoryArr.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [categoryArr[row] valueForKey:@"DBName"];
}
- (IBAction)admin_Action:(UIButton *)sender {
    
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:sender.tag inSection:0];
        AddUserCell*cell = [_tablViw cellForRowAtIndexPath:indexPath];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        dict = [userArray objectAtIndex:sender.tag];
    
        if ([[cell.adminBtn backgroundImageForState:UIControlStateNormal] isEqual:[UIImage imageNamed:@"unchecked.png"]]) {
           
            [dict setValue:@"1" forKey:@"Admin"];
            [cell.adminBtn setBackgroundImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateNormal];
        }
        else {
              [dict setValue:@"0" forKey:@"Admin"];
            [cell.adminBtn setBackgroundImage:[UIImage imageNamed:@"unchecked.png"] forState:UIControlStateNormal];
        }
      [userArray replaceObjectAtIndex:sender.tag withObject:dict];
    
    
}
- (IBAction)share_Action:(UIButton *)sender {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:sender.tag inSection:0];
    AddUserCell*cell = [_tablViw cellForRowAtIndexPath:indexPath];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict = [userArray objectAtIndex:sender.tag];
    if ([[cell.shareBtn backgroundImageForState:UIControlStateNormal] isEqual:[UIImage imageNamed:@"unchecked.png"]]) {
        [dict setValue:@"1" forKey:@"Share"];
        [cell.shareBtn setBackgroundImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateNormal];
    }
    else {
        [dict setValue:@"0" forKey:@"Share"];
        [cell.shareBtn setBackgroundImage:[UIImage imageNamed:@"unchecked.png"] forState:UIControlStateNormal];
    }
     [userArray replaceObjectAtIndex:sender.tag withObject:dict];
    [self.tablViw reloadData];

}


-(void)checkContacts {
    
    
    tableData = [[NSMutableArray alloc] init];
    tableData =  [AppDelegate getContacts];
    [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
    NSMutableDictionary   *newUserDetail = [[NSMutableDictionary  alloc] init];
    [newUserDetail removeAllObjects];
    [newUserDetail setObject:tableData forKey:@"contacts"];
    NSError *error;
    NSData *postdata = [NSJSONSerialization dataWithJSONObject:newUserDetail options:0 error:&error];
    NSString *responseString = [[NSString alloc] initWithData:postdata encoding:NSUTF8StringEncoding];
    [NSString stringWithFormat:@"%@",HostUrl];
    NSMutableDictionary *dict  = [[NSMutableDictionary alloc] init];
    [dict setValue:kImportContacts forKey:kDefault];
    [dict setValue:responseString forKey:kPhoneBook];
    NSLog(@"JSONSTRING  %@", responseString);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:HostUrl parameters:dict success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        [AppDelegate hideHUDForView:self.view animated:YES];
        NSLog(@"Success: %@\n ***** %@", operation.responseString, responseObject);
        id status= [responseObject valueForKey:@"status"];
        if([status isKindOfClass:[NSString class]]){
            if([status isEqualToString:@"success"]){
                NSLog(@"%@",[responseObject valueForKey:@"result"]);
                [tableData removeAllObjects];
                
                NSMutableArray *contactArray = [[NSMutableArray alloc] init];
                NSMutableArray *array = [[NSMutableArray alloc] init];
                contactArray = [responseObject valueForKey:@"result"];
                for (int i=0; i < contactArray.count; i++) {
                    if ([[[contactArray objectAtIndex:i] valueForKey:@"Status"] isEqualToString:@"1"]) {
                        [array addObject:[contactArray objectAtIndex:i]];
                    }
                    
                }
//                array = [responseObject valueForKey:@"result"];
                
                NSString *query = [NSString stringWithFormat:@"DELETE  from users where userid !=  \"%lld\" ",[[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID] longLongValue]];
                [[DBManager getSharedInstance] executeQuery:query];
                for (int i=0; i < array.count; i++) {
                    
                    NSMutableDictionary *contactDict = [[NSMutableDictionary alloc] init];
                    [contactDict setValue:[[array objectAtIndex:i] valueForKey:@"Fname"] forKey:@"Fname"];
                    [contactDict setValue:[[array objectAtIndex:i] valueForKey:@"Lname"] forKey:@"Lname"];
                    [contactDict setValue:[[array objectAtIndex:i] valueForKey:@"userid"] forKey:@"userid"];
                    [contactDict setValue:[[array objectAtIndex:i] valueForKey:@"Status"] forKey:@"Status"];
                    [contactDict setValue:[[array objectAtIndex:i] valueForKey:@"phoneno"] forKey:@"phoneno"];
                    
                    UserObject *usrObj = [[UserObject alloc] init];
                    usrObj.UserID =  [[[array objectAtIndex:i] valueForKey:@"userid"] longLongValue];
                    usrObj.PhoneNo = [[[array objectAtIndex:i] valueForKey:@"phoneno"] longLongValue];
                    usrObj.FirstName = [[array objectAtIndex:i] valueForKey:@"Fname"] ;
                    usrObj.LastName = [[array objectAtIndex:i] valueForKey:@"Lname"] ;
                    [[DBManager getSharedInstance] importUsersFromServer:usrObj];
                    
                    [tableData addObject:contactDict];
                    
                }
                
                
                arrSelected = [[NSMutableArray alloc] init];
                for (int i = 0; i <tableData.count; i++) {
                    if ([[[tableData objectAtIndex:i] valueForKey:@"Status"] isEqualToString:@"1"]) {
                        [arrSelected addObject:[NSNumber numberWithBool:YES]];
                        
                    }
                    else {
                        [arrSelected addObject:[NSNumber numberWithBool:NO]];
                    }
                    
                }
            
                   [self getSharedUsersList];
            }
            else{
                
            }
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        [AppDelegate hideHUDForView:self.view animated:YES];
        
        //if(dict)
        //        [AppDelegate showAlertViewWithTitle:@"Network error" Message:@"Please Check your internet connection."];
    }];
    
}

-(void)saveUserListFromServer:(NSDictionary *)dict {
    
    
    
}

- (IBAction)locationSharingBtnAction:(id)sender {
    
    if (locationStatus == false) {
        
        [_locationSharingBtn setBackgroundImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateNormal];
        locationStatus = true;
        locationFlag = 1;
        
    } else if (locationStatus == true) {
        
        [_locationSharingBtn setBackgroundImage:[UIImage imageNamed:@"unchecked.png"] forState:UIControlStateNormal];
         locationStatus = false;
        locationFlag = 0;
    }
    
}


- (IBAction)shareDatabase_Action:(id)sender {
    NSMutableDictionary   *newUserDetail = [[NSMutableDictionary  alloc] init];
    [newUserDetail removeAllObjects];
    shareArrList = [[NSMutableArray alloc] init];
    
    for(int i = 0;i<[userArray count];i++) {
        NSMutableDictionary *dict =[[NSMutableDictionary alloc] init];
        if ([[[userArray objectAtIndex:i] valueForKey:@"Share"] isEqualToString:@"1"]) {
            [dict setValue:[[userArray objectAtIndex:i] valueForKey:@"Admin"] forKey:@"admin"];
            [dict setValue:[[userArray objectAtIndex:i] valueForKey:@"userid"] forKey:@"userid"];
            [shareArrList addObject:dict];
            
        }
        
    }
     [newUserDetail setObject:shareArrList forKey:@"contacts"];
    
    NSError *error;
    NSData *postdata = [NSJSONSerialization dataWithJSONObject:newUserDetail options:0 error:&error];
    NSString *responseString = [[NSString alloc] initWithData:postdata encoding:NSUTF8StringEncoding];
    [NSString stringWithFormat:@"%@",HostUrl];
    NSMutableDictionary *paramDict  = [[NSMutableDictionary alloc] init];
    [paramDict setValue:kAddShareDb forKey:kDefault];
    [paramDict setValue:responseString forKey:kSharedb_json];
    [paramDict setValue:self.dbID forKey:kDbID];
    [paramDict setValue:[NSString stringWithFormat:@"%d",locationFlag] forKey:@"Location_Status"];
    NSLog(@"JSONSTRING  %@", responseString);

    [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:@"" detailsLabel:@""];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:HostUrl parameters:paramDict success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        [AppDelegate hideHUDForView:self.view animated:YES];
        NSLog(@"Success: %@\n ***** %@", operation.responseString, responseObject);
        id status= [responseObject valueForKey:@"status"];
        if([status isKindOfClass:[NSString class]]){
            if([status isEqualToString:@"successfully"])
            {
                NSString *query = [NSString stringWithFormat:@"DELETE  from SharedDatabases where DatabaseId = \"%lld\" ", [self.dbID longLongValue]];
                [[DBManager getSharedInstance] executeQuery:query];
                for(int i = 0;i<[shareArrList count];i++) {
                    
                    ShareDBObject *dbObj = [[ShareDBObject alloc] init];
                    dbObj.DatabaseID = [self.dbID longLongValue];
                    dbObj.Admin = [[[shareArrList objectAtIndex:i] valueForKey:@"admin"] longLongValue];
                    dbObj.UserID = [[[shareArrList objectAtIndex:i] valueForKey:@"userid"] longLongValue];
                    dbObj.Location_Status = [NSString stringWithFormat:@"%d", locationFlag];
                    [[DBManager getSharedInstance] importShareDBUsersFromServer:dbObj];
    
                    [[DBManager getSharedInstance]UpdateLocationStatus:dbObj.Location_Status forDBID:[NSString stringWithFormat:@"%lld", dbObj.DatabaseID]];
                    
                    
                }
        
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateLocationOnSharing" object:self];
                      
                  

                
                [self.navigationController popViewControllerAnimated:YES];
                
            }
            else{
                
            }
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        
        
        //if(dict)
        //        [AppDelegate showAlertViewWithTitle:@"Network error" Message:@"Please Check your internet connection."];
    }];

    
    
}

-(void)getSharedUsersList {
    
    userArray =[[NSMutableArray alloc] init];
    NSArray *dbArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"DBArray"];
    NSLog(@"DBArray +++%@",dbArray);
    
    for(int i = 0;i<[tableData count];i++)
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        NSString *share = @"0";
        NSString *Admin=  @"0";
        if ([dbArray count] > 0) {
            for(int j= 0;j<[dbArray count];j++)
            {
                
                
                if ([[arrSelected objectAtIndex:i] boolValue] == YES) {
                    
                    
                    if([[[tableData objectAtIndex:i] valueForKey:@"phoneno"] isEqualToString:[[dbArray objectAtIndex:j] valueForKey:@"phone_number"]])
                    {
                        share = @"1";
                        Admin = [[dbArray objectAtIndex:j] valueForKey:@"Admin"];
                        
                    }
                    
                }
   
            }

        }
        else {
            
             Admin = @"0";
             share = @"0";
        }
        
        [dict setValue:Admin forKey:@"Admin"];
        [dict setValue:share forKey:@"Share"];
      
        [dict setValue:[[tableData objectAtIndex:i] valueForKey:@"phoneno"] forKey:@"phone_number"];
        [dict setValue:[[tableData objectAtIndex:i] valueForKey:@"Fname"] forKey:@"first_name"];
        [dict setValue:[[tableData objectAtIndex:i] valueForKey:@"Lname"] forKey:@"last_name"];
        [dict setValue:[[tableData objectAtIndex:i] valueForKey:@"userid"] forKey:@"userid"];
        [userArray addObject:dict];

    }
    [_tablViw reloadData];
  
    
    NSLog(@"Users Array **** %@", userArray);
    
}

- (IBAction)done_Action:(id)sender {
  //  [self hidePickerView];
    NSInteger row= [self.categoryPicker selectedRowInComponent:0];
    self.categoryTxtFld.text=[categoryArr[row] valueForKey:@"DBName"];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnShowSelectedOnly:(id)sender {
   
    long j = userArray.count;
    NSMutableArray *arrSelUsers = [[NSMutableArray alloc]init];
    for (int i = 0; i < j; i++)
    {
        
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict = [userArray objectAtIndex:i];
    if ([[dict valueForKey:@"Share"] isEqualToString:@"1"])
    {
        [arrSelUsers addObject:dict];
    }
    else
    {
        
    }
   
    }
    userArray = arrSelUsers;
    [self.tablViw reloadData];
}

- (IBAction)btnShowAll:(id)sender {
    [self checkContacts];
}
@end
