//
//  SettingViewController.m
//  SimpleApp
//
//  Created by IOS1 on 2/15/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import "SettingViewController.h"
#import "AppDelegate.h"
#import <MessageUI/MessageUI.h>
#import "userList.h"
#import "ShareDBViewController.h"
#import "importListViewController.h"
#import "ViewController.h"
#import "SelectDatabaseVC.h"
#import "CategoryViewTableViewController.h"
#import "UserInfoViewController.h"
#import "CreateDBController.h"
#import "DBListViewController.h"
#import "PublicDBViewController.h"
#import "LicenseViewController.h"
#import "CreateNewDBViewController.h"
#import "ImportFromViewController.h"
#import "ShareLocationViewController.h"
#import "ShowTeamMapViewController.h"
#import "Singleton.h"

@interface SettingViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate , MFMailComposeViewControllerDelegate , MFMessageComposeViewControllerDelegate , UIDocumentPickerDelegate , UIDocumentMenuDelegate>
{
    NSMutableArray *categoryArr;
    NSArray *sectionArr;
    NSArray *rowArr;
    NSMutableArray *statusArr;
    NSMutableArray *recordArr;
    NSMutableDictionary *shareDBArr;
    NSMutableDictionary *importDBDict;
    AppDelegate *appDelegate;
    bool showOptions;
    UITextField *newDbfield ,  *txtfieldDbId;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    shareDBArr=[[NSMutableDictionary alloc]init];
    importDBDict=[[NSMutableDictionary alloc]init];;
    categoryArr=[[NSMutableArray alloc]init];
    recordArr=[[NSMutableArray alloc]init];
    statusArr = [[NSMutableArray alloc] init];
    

    sectionArr = @[@"My DB Management" , @"Contacts" , @"Account Settings" , @"Options"];
    rowArr = @[@[@"Import Your DB" ,@"Share DB Info", @"Select Database", @"Share DB" ,@"Reset DB" ,@"Create New DB" , @"Delete Database", @"Import From Google Drvie"]  , @[@"Import" , @"Invite Contacts"] , @[@"Change Password" , @"Set Passcode" , @"License"],@[@"Category View" , @"Logout"]];
    
    //, @"Allow Location Sharing", @"Show Map"
    
    for (int i = 0; i <sectionArr.count; i++) {
        [statusArr addObject:@"0"];
    }
    self.tableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
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

#pragma mark - UITableViewDelegate
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return sectionArr.count;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView * view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    
    UIButton *emailBtn = [[UIButton alloc] initWithFrame:CGRectMake(65, 0, self.view.frame.size.width - 60, 30)];
    [emailBtn setTitle:@"Email" forState:UIControlStateNormal];
    [emailBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    emailBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    emailBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [emailBtn addTarget:self action:@selector(email_Action) forControlEvents:UIControlEventTouchUpInside];
    UIButton *smsBtn = [[UIButton alloc] initWithFrame:CGRectMake(65, 30, self.view.frame.size.width - 60, 30)];
    [smsBtn setTitle:@"SMS" forState:UIControlStateNormal];
    [smsBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    smsBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    smsBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [smsBtn addTarget:self action:@selector(SMSAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:emailBtn];
    [view addSubview:smsBtn];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    view.backgroundColor=[UIColor whiteColor];
//    if(section>0)
//    {
//        UIImageView *img=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 3)];
//       // img.backgroundColor=[UIColor colorWithRed:(103/255.0f) green:(187/255.0f) blue:(223/255.0f) alpha:1.0f];
//        img.backgroundColor=[UIColor colorWithRed:(101/255.0f) green:(102/255.0f) blue:(103/255.0f) alpha:1.0f];
//        [view addSubview:img];
//    }
    UILabel *title=[[UILabel alloc]initWithFrame:CGRectMake(25, 10, self.view.frame.size.width-40, 30)];
    title.textColor=[UIColor colorWithRed:(101/255.0f) green:(102/255.0f) blue:(103/255.0f) alpha:1.0f];
    title.font=[UIFont boldSystemFontOfSize:16];
    title.text = [sectionArr objectAtIndex:section];
    UIButton *arrowImg = [UIButton buttonWithType:UIButtonTypeSystem];
    arrowImg.frame = CGRectMake(0, 10,30, 30);
    arrowImg.contentMode = UIViewContentModeScaleAspectFit;
    [arrowImg setTintColor:[UIColor colorWithRed:20/255.0f green:123/255.0f blue:255/255.0f alpha:1.0]];
    [arrowImg setImage:[UIImage imageNamed:@"expandArrow"] forState:UIControlStateNormal];
    [view addSubview:arrowImg];
    
    UIView *tapViw = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    tapViw.tag = section;
    [tapViw setUserInteractionEnabled:true];
    UITapGestureRecognizer *tapgesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesturehandler:)];
    tapgesture.numberOfTapsRequired = 1;
    [tapViw addGestureRecognizer:tapgesture];
    
    
//    switch(section){
//        case 0:
//            title.text=@"My DB Management";
//            break;
//        case 1:
//            title.text=@"Import Contacts";
//            break;
//        case 2:
//            title.text=@"Invite Contacts";
//            break;
//        case 3:
//            title.text=@"Passcode Setting";
//            break;
//        case 4:
//            title.text=@"Account Management";
//            break;
//    }
//
  
   
    [view addSubview:title];
    [view addSubview:tapViw];
    
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
     return 40;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (section == 1) {
    if (showOptions) {
        return 60;
    }
    else {
        return 0;
    }
    }
    else {
        return  0;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSString *status = [statusArr objectAtIndex:section];
    if ([status isEqualToString:@"1"]) {
    NSArray *arr = [rowArr objectAtIndex:section];
    return  arr.count;
    }
    else {
        return 0;
    }
    
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[self.tableView dequeueReusableCellWithIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    NSArray *arr = [rowArr objectAtIndex:indexPath.section];
    cell.textLabel.text= [NSString stringWithFormat:@"      %@", [arr objectAtIndex:indexPath.row]];
    
    return cell;
    
    
}
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    if(section==0){
//        return 9;
//    }
//
//    else if(section==1){
//        return 1;
//    }
//    else if(section==2){
//        return 2;
//    }
//    else if(section==3)
//    {
//        return 1;
//    }
//    else if(section==4)
//    {
//      return 2;
//    }
//    return 2;
//
//}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    UITableViewCell *cell=[self.tableView dequeueReusableCellWithIdentifier:@"cellIdentifier" forIndexPath:indexPath];
//    if(indexPath.section==0){
//        switch(indexPath.row)
//        {
//            case 0:
//                cell.textLabel.text=@"Import Your DB";
//                break;
//            case 1:
//                cell.textLabel.text=@"Shared DB info";
//                break;
//            case 2:
//                cell.textLabel.text=@"Select Database";
//                break;
//            case 3:
//                cell.textLabel.text=@"Share DB";
//                break;
//            case 4:
//                cell.textLabel.text=@"Reset DB";
//                break;
//            case 5:
//                cell.textLabel.text=@"Create New DB";
//                break;
//            case 6:
//                cell.textLabel.text=@"Delete Database";
//                break;
//            case 7:
//                cell.textLabel.text= @"Category View";
//                  break;
//            case 8:
//                cell.textLabel.text= @"Info";
//
//                break;
//        }
//    }else if(indexPath.section==1) {
//        switch(indexPath.row){
//            case 0:
//                cell.textLabel.text=@"Contacts";
//                break;
//
//        }
//
//    }
//    else if(indexPath.section==2) {
//        switch(indexPath.row){
//            case 0:
//                cell.textLabel.text=@"By Email";
//                break;
//            case 1:
//                cell.textLabel.text=@"By SMS";
//                break;
//
//        }
//
//    }
//    else if(indexPath.section==3)
//    {
//        switch(indexPath.row){
//            case 0:
//                cell.textLabel.text=@"Set Passcode";
//                break;
//
//        }
//    }
//
//
//      else if(indexPath.section==4) {
//        switch(indexPath.row){
//            case 0:
//                cell.textLabel.text=@"Change Password";
//                break;
//            case 1:
//                cell.textLabel.text=@"Logout";
//                break;
//
//        }
//
//    }
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//
//    return cell;
//}
//

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if(indexPath.section==0){
        switch(indexPath.row){
            case 0:
                [self importDB];
                break;
            case 1:

            {


                UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @""
                                                                                          message: @"Do you want to import DB List?"
                                                                                   preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                            {


                                                [self importDBList];

                                            }]];

                [alertController addAction:[UIAlertAction
                                            actionWithTitle:@"No"
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                //Handle no, thanks button

                                                importListViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"importListViewController"];
                                                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];

                                                [self.navigationController pushViewController:vc animated:true];
                                            }]];

                [self presentViewController:alertController animated:YES completion:nil];







            }
                break;


            case 2: {
                SelectDatabaseVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectDatabaseVC"];
                 vc.screenType = @"Select";
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
                [self.navigationController pushViewController:vc animated:true];
                break;

            }
                
            case 3:
            {

                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"dbId"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"dbName"];
                ShareDBViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ShareDBViewController"];
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
                [self.navigationController pushViewController:vc animated:true];
            }
//                [self shareDB];
                break;
            case 4:{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"This will ERASE your database. You should SAVE it first with the SHARE OPTION" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Erase", nil];
                [alertView show];
            }
                break;
            case 5:{
                
                CreateNewDBViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateNewDBViewController"];
                [self.navigationController pushViewController:vc animated:true];
                
                
//                UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Create New DB"
//                                                                                          message: @"Please enter database name"
//                                                                                   preferredStyle:UIAlertControllerStyleAlert];
//
//                [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
//                    textField.placeholder = @"Enter new datebase name";
//                    textField.textColor = [UIColor blackColor];
//                    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
//                    //        textField.borderStyle = UITextBorderStyleRoundedRect;
//                }];
//
//                [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
//                                            {
//                                                NSArray * textfields = alertController.textFields;
//                                                newDbfield = textfields[0];
//
//                                                NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
//                                                if ([[newDbfield.text stringByTrimmingCharactersInSet: set] length] == 0)
//                                                {
//
//                                                }else {
//                                                    NSString *dbName = newDbfield.text;
//                                                    dbName = [dbName stringByReplacingOccurrencesOfString:@"\"" withString:@"~#~"];
//                                                    dbName = [dbName stringByReplacingOccurrencesOfString:@"\'" withString:@"~!~"];
//
//                                                     [self createDBAPi:dbName];
//                                                }
//
//
//                                               // txtfieldDbId = textfields[1];
//
//
//
////                                                NSArray * licenceType = [[NSArray alloc]init];
////                                                licenceType = [[DBManager getSharedInstance] recordExistOrNot:[NSString stringWithFormat:@"SELECT license_type FROM users WHERE userid=\"%@\"", [AppDelegate getOwnerId]]];
////
////                                                if ([[licenceType objectAtIndex:0] intValue] == 1)
////                                                {
////                                                    [self findDBBy_licensetype1];
////                                                }
//
//
//                                            }]];
//
//
//                [alertController addAction:[UIAlertAction
//                                            actionWithTitle:@"Cancel"
//                                            style:UIAlertActionStyleDefault
//                                            handler:^(UIAlertAction * action) {
//                                                //Handle no, thanks button
//                                            }]];
//
//
//                [self presentViewController:alertController animated:true completion:nil];
            }
                break;

            case 6: {

                SelectDatabaseVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectDatabaseVC"];
                vc.screenType = @"Delete";
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
                [self.navigationController pushViewController:vc animated:true];
                break;

            }
                
            case 7:{
                
                ImportFromViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ImportFromViewController"];
                [self.navigationController pushViewController:vc animated:true];
                
            }
             
                break;
                
                
                
                
//            case 8:{
//
//                ShareLocationViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ShareLocationViewController"];
//                [self.navigationController pushViewController:vc animated:true];
//
//            }
//
//                break;
//
//            case 9:{
//
//                ShowTeamMapViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ShowTeamMapViewController"];
//                [self.navigationController pushViewController:vc animated:true];
//
//            }
//
//                break;
                
                
                
                
                
//                case 7: {
//
//                    CategoryViewTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CategoryViewTableViewController"];
//
//                    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
//                    [self.navigationController pushViewController:vc animated:false];
//                    break;
//                }
//            case 8: {
//
//                UserInfoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"UserInfoViewController"];
//
//                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
//                [self.navigationController pushViewController:vc animated:false];
//                break;
//            }
        }
    }
    else if (indexPath.section==1)
    {
        switch(indexPath.row)
        {
            case 0:
            {
                userList *userlist = [self.storyboard instantiateViewControllerWithIdentifier:@"userList"];
                [self.navigationController pushViewController:userlist animated:true];

            }

                break;
                
            case 1:
            {
                if (showOptions) {
                    showOptions = false;
                }
                else {
                    showOptions = true;
                }
                [self.tableView reloadData];
                   break;
            }
                
            
            }
                
        }
  
//    else if (indexPath.section==2)
//    {
//        switch(indexPath.row)
//        {
//            case 0:
//            {
//                [self email_Action];
//            }
//
//                break;
//            case 1:
//            {
//                [self SMSAction];
//            }
//                break;
//        }
//    }
    else if (indexPath.section==2)
    {
        switch(indexPath.row)
        {
                
            case 0:
            {
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
                [self performSegueWithIdentifier:@"ChangePasswordSegue" sender:self];
           
            }
                
                break;
            case 1:
            {
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
                [self performSegueWithIdentifier:@"passcode" sender:self];
            }

                break;
                
                
            case 2:
            {
                LicenseViewController *license = [self.storyboard instantiateViewControllerWithIdentifier:@"LicenseViewController"];
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
                [self.navigationController pushViewController:license animated:true];
                
              
            }
            break;
        }
    }



    else if (indexPath.section==3)
    {
        switch(indexPath.row)
        {
            case 0:
            {
                CategoryViewTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CategoryViewTableViewController"];
                
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
                [self.navigationController pushViewController:vc animated:false];
                break;

            }

                break;
            case 1:
                
                //[self logOutAction];
                [self logoutApi];
                
                break;

        }

    }

}

#pragma mark - API
-(void)createDBAPi : (NSString*)DBName {
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setObject:[AppDelegate getOwnerId] forKey:@"userid"];
    [dict setObject:DBName forKey:@"new_db"];
    [dict setObject:@"Personal" forKey:@"db_type"];
    [dict setObject:kCreateNewDB forKey:kDefault];
  
    NSLog(@"dict =%@",dict);

    
    [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:HostUrl parameters:dict success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        [AppDelegate hideHUDForView:self.view animated:YES];
        NSLog(@"Success: %@\n ***** %@", operation.responseString, responseObject);
        id status= [responseObject valueForKey:@"status"];
        if([status isKindOfClass:[NSString class]]){
            if([status isEqualToString:@"Success"])
            {
              NSDictionary* result= [responseObject valueForKey:@"result"];
                if([result isKindOfClass:[NSDictionary class]])
                {
                    NSLog(@"Here");
                    NSString *dbID = [result valueForKey:@"DatabaseId"];
                    NSString *DBName = [result valueForKey:@"DBName"];
                    NSString *OwnerID = [result valueForKey:@"Owner_Userid"];
                    NSString *Catalog = [result valueForKey:@"Catalog"];
                    NSString *LastModifieddate = [result valueForKey:@"LastModified"] ;
                    NSString *storageType = @"Local" ;

                    NSString *admin = [result valueForKey:@"Admin"]  ;
                    NSString *locationStatus = [result valueForKey:@"Location_Status"];
                    NSString *Latitude = [result valueForKey:@"Latitude"] ;
                    NSString *Longitude = [result valueForKey:@"Longitude"] ;
                   
                   [self createNewDBFromJsonResponse:dbID withdbName:DBName withownerID:OwnerID withcatalog:Catalog withlastModifiedDate:LastModifieddate withStorageType:storageType admin:admin locationStatus:locationStatus lattitude:Latitude longitude:Longitude];
                }
                
                
            }
            else
            {
                id reason= [responseObject valueForKey:@"reason"];
                if([reason isKindOfClass:[NSString class]])
                {
                    NSLog(@"Here");
                    
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

-(void)createNewDBFromJsonResponse : (NSString*)dbID withdbName :(NSString*)dbName withownerID  :(NSString*)ownerID withcatalog : (NSString*)catalog withlastModifiedDate :(NSString*)lastModifiedDate withStorageType : (NSString*)storageType admin:(NSString*)admin locationStatus:(NSString*)locationStatus  lattitude:(NSString*)lattitude  longitude:(NSString*)longitude {
    
    BOOL success = NO;
    NSString *alertString = @"Data Insertion failed";
    
        
    success = [[DBManager getSharedInstance] createNewDataBase_dataBaseId:dbID dbName:dbName ownerUser_Id:ownerID cataLog:catalog lastModified:lastModifiedDate dbType:@"Personal" storageType:storageType admin:admin locationStatus:locationStatus lattitude:lattitude longitude:longitude];
        if (success == YES)
        {
            
            [AppDelegate showAlertViewWithTitle:@"Message" Message:@"Your DB Created Successfully."];
        }
    
    
    if (success == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: alertString message:nil  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
}
#pragma mark - Gesture Handler

-(void)tapGesturehandler:(UITapGestureRecognizer*)gesture {
    UIView *view = [gesture view];
     NSString *str = [statusArr objectAtIndex:view.tag];
    if ([str isEqualToString:@"0"]) {
        
        [statusArr replaceObjectAtIndex:view.tag withObject:@"1"];
    }
    else {
        if (view.tag == 1) {
        showOptions = false;
        }
        [statusArr replaceObjectAtIndex:view.tag withObject:@"0"];
    }
    [_tableView reloadData];
    
}

#pragma mark - Email Action
-(void)email_Action {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:@"SimpleApp/Notification"];
        [mc setMessageBody:@"SimpleApp/Notification" isHTML:NO];
        [mc setToRecipients:[NSArray arrayWithObjects:@"", nil]];
        [self presentViewController:mc animated:true completion:nil];
    }
    else
    {
        [AppDelegate showAlertViewWithTitle:nil Message:@"This device cannot send email"];
        NSLog(@"This device cannot send email");
    }
    
    

}
// delegate function callback
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    // switchng the result
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail send canceled.");
            /*
             Execute your code for canceled event here ...
             */
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved.");
            /*
             Execute your code for email saved event here ...
             */
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent.");
            /*
             Execute your code for email sent event here ...
             */
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail send error: %@.", [error localizedDescription]);
            /*
             Execute your code for email send failed event here ...
             */
            break;
        default:
            break;
    }
    // hide the modal view controller
    [self dismissViewControllerAnimated:true completion:nil];
}

-(void)findDBBy_licensetype1
{
    int data = [[DBManager getSharedInstance] dbEmptyOrNot:[NSString stringWithFormat:@"SELECT COUNT(*) FROM MyDatabase where Owner_Userid =\"%@\"", [AppDelegate getOwnerId]]];
    if (data == 3 || data > 3)
    {
         [AppDelegate showAlertViewWithTitle:@"Message" Message:@"You Can't Create DB Anymore."];
    }
    else
    {
        NSLog(@"%d", data);
        [self saveDataInMyDataBase];
    }
    
}



-(void)saveDataInMyDataBase
{
    BOOL success = NO;
    NSString *alertString = @"Data Insertion failed";
    if (newDbfield.text.length>0)
    {
        
        NSDate *date = [[NSDate alloc] init];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd-MM-YYYY HH:mm:ss"];
        NSString *dateString = [dateFormatter stringFromDate:date];
        
        NSLog(@"The Date: %@", dateString);
        
//        success = [[DBManager getSharedInstance] createNewDataBase_dataBaseId:txtfieldDbId.text dbName:newDbfield.text ownerUser_Id:[AppDelegate getOwnerId] cataLog:@"" lastModified:dateString];
//        if (success == YES)
//        {
//
//        [AppDelegate showAlertViewWithTitle:@"Message" Message:@"Your DB Created Sucessfully."];
//        }
        
    }
    else
    {
        alertString = @"Enter all fields";
    }
    if (success == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: alertString message:nil  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }

}

#pragma mark - SMS Action

-(void)SMSAction {
    
    if([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init]; // Create message VC
        messageController.messageComposeDelegate = self; // Set delegate to current instance
        
        NSMutableArray *recipients = [[NSMutableArray alloc] init]; // Create an array to hold the recipients
        [recipients addObject:@""]; // Append example phone number to array
        messageController.recipients = recipients; // Set the recipients of the message to the created array
        
        messageController.body = @"SimpleApp/Notification"; // Set initial text to example message
        
        dispatch_async(dispatch_get_main_queue(), ^{ // Present VC when possible
            [self presentViewController:messageController animated:YES completion:NULL];
        });
    }
    else
    {
        [AppDelegate showAlertViewWithTitle:nil Message:@"This device cannot send message"];
        NSLog(@"This device cannot send message");
    }
    
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Logout Action

- (IBAction)aboutAction:(id)sender {
    
                    UserInfoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"UserInfoViewController"];
    
                    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
                    [self.navigationController pushViewController:vc animated:false];
}


-(void)logOutAction
{
    [[Singleton singleton].globalArray removeAllObjects];
    
    if ([Singleton singleton].timer != nil) {
    
    [[Singleton singleton].timer invalidate];
    [Singleton singleton].timer = nil;
        
    }
    
    [[GIDSignIn sharedInstance] signOut];
    
    if(GIDSignIn.sharedInstance.hasAuthInKeychain)
            {
                //loggedIn
                NSLog(@"%@",  @"logged in");
//                 [_signinbtn setHidden:YES];
//                NSLog(@"%@",GIDSignIn.sharedInstance.currentUser.userID );
//                driveService.authorizer = GIDSignIn.sharedInstance.currentUser.authentication.fetcherAuthorizer;
        
            } else {
        
                 NSLog(@"%@",  @"logged Out");
        }

    //[[GIDSignIn sharedInstance] disconnect];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"dbId"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"dbName"];
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"CurrentDbID"];
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"CurrentDbName"];
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"CurrentStorageType"];
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"CurrentAdminType"];
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"CurrentLocationType"];

    
    [self deletedatafromTableLogout];
    [AppDelegate setLoggedIn:@"0"];
//    [self.navigationController popToRootViewControllerAnimated:YES];
    
    for (UIViewController *controller in self.navigationController.viewControllers)
    {
        if ([controller isKindOfClass:[ViewController class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
            
            break;
        }
    }
    
    [AppDelegate showAlertViewWithTitle:@"" Message:@"Logout Successfully."];
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    [self.navigationController pushViewController:vc animated:YES];
    

}


-(void)deletedatafromTableLogout {
    
    NSString *query = [NSString stringWithFormat:@"DELETE  from MyDatabase"];
    [[DBManager getSharedInstance]executeQuery:query];
    
    NSString *licenses = [NSString stringWithFormat:@"DELETE  from licenses"];
    [[DBManager getSharedInstance]executeQuery:licenses];
    NSString *SharedDatabases = [NSString stringWithFormat:@"DELETE  from SharedDatabases"];
    [[DBManager getSharedInstance]executeQuery:SharedDatabases];
    NSString *users = [NSString stringWithFormat:@"DELETE  from users"];
    [[DBManager getSharedInstance]executeQuery:users];
    NSString *user_categories = [NSString stringWithFormat:@"DELETE  from user_categories"];
    [[DBManager getSharedInstance]executeQuery:user_categories];
    NSString *user_notes = [NSString stringWithFormat:@"DELETE  from user_notes"];
    [[DBManager getSharedInstance]executeQuery:user_notes];
   
}


-(void)shareDB{
    [shareDBArr removeAllObjects];
    [self fetchCategory];
//    for(int i=0;i<categoryArr.count;i++){
//        NSMutableArray *categoryList=[[NSMutableArray alloc]init];
//        NSMutableArray *arr=[self fetchRecord:[categoryArr[i] valueForKey:@"category_name"]];
//        for(int j=0;j<arr.count;j++){
//            NSDictionary *note=[NSDictionary dictionaryWithObject:[arr[j] valueForKey:@"note"] forKey:@"note"];
//            NSArray *title=@[ note] ;
//            [categoryList addObject:title];
//        }
//        
//        [shareDBArr addObject:categoryList];
//    }
    
//    for(int i=0;i<categoryArr.count;i++){
//        NSMutableDictionary *categoryList=[[NSMutableDictionary alloc]init];
//        NSMutableArray *arr=[self fetchRecord:[categoryArr[i] valueForKey:@"category_name"]];
//        for(int j=0;j<arr.count;j++){
//            NSDictionary *note=[NSDictionary dictionaryWithObject:[arr[j] valueForKey:@"note"] forKey:@"note"];
//            //NSDictionary *title=[NSDictionary dictionaryWithObject:note forKey:[arr[j] valueForKey:@"record_title"]] ;
//            [categoryList setObject:note forKey:[arr[j] valueForKey:@"record_title"]];
//        }
//        [shareDBArr setObject:categoryList forKey:[categoryArr[i] valueForKey:@"category_name"]];
//        //[shareDBArr addObject:categoryList];
//    }


    NSMutableArray *categoryArray=[[NSMutableArray alloc]init];
    for(int i=0;i<categoryArr.count;i++){
        NSMutableArray *categoryList=[[NSMutableArray alloc]init];
        NSMutableArray *arr=[self fetchRecord:[categoryArr[i] valueForKey:@"category_name"]];
        for(int j=0;j<arr.count;j++){
            NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
            [dict setObject:[arr[j] valueForKey:@"note"] forKey:@"note"];
            [dict setObject:[arr[j] valueForKey:@"record_title"] forKey:@"title"];
            [categoryList addObject: dict];
        }
        
        NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
        [dict setObject:[categoryArr[i] valueForKey:@"category_name"] forKey:@"category"];
        [dict setObject:categoryList forKey:@"data"];
        [categoryArray addObject: dict];
         //[shareDBArr addObject:categoryList];
    }
    if(categoryArray.count==0){
        [AppDelegate showAlertViewWithTitle:@"Sorry!" Message:@"You Have No DB To Share."];
        return;
    }
   
    [shareDBArr setObject:categoryArray forKey:@"catalog"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:shareDBArr options:kNilOptions error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setObject:[AppDelegate getUserEmail] forKey:@"username"];
    [dict setObject:[AppDelegate getUserPassword] forKey:@"password"];
    [dict setObject:kShareDB forKey:kDefault];
    [dict setObject:jsonString forKey:@"catalog"];
    NSLog(@"dict =%@",dict);
    [self hitApi:dict];
}
-(void)importDB{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setObject:kImportDB forKey:kDefault];
    [dict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID] forKey:@"user_id"];
    
    NSLog(@"dict =%@",dict);
    [self hitApi:dict];
    
  //  NSData *data=[NSJSONSerialization en ]
}

-(void)hitApi:(NSMutableDictionary*)dict
{
    [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
    NSString *hostUrl=[NSString stringWithFormat:@"%@",HostUrl];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:hostUrl parameters:dict success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        [AppDelegate hideHUDForView:self.view animated:YES];
        NSLog(@"Success: %@\n ***** %@", operation.responseString, responseObject);
        id status= [responseObject valueForKey:@"status"];
        if([status isKindOfClass:[NSString class]]){
            if([status isEqualToString:@"Success"]){
                id jsonString  =   [responseObject valueForKey:@"result"];
                NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *dictResult = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
               
               
                
                NSArray *myDataBaseArray = [dictResult  valueForKey:@"MyDatabase"];
                NSArray *categoryArray = [dictResult  valueForKey:@"user_categories"];
                NSArray *NotesArray = [dictResult  valueForKey:@"all_notes"];
                NSArray *getShareDBData = [dictResult  valueForKey:@"getShareDBData"];
                NSArray *getShareDBDataUsers = [dictResult  valueForKey:@"getShareDBUsers"];
                
                [self ImportMydatabaseFromServerResponse:myDataBaseArray];
                [self ImportCategoryFromServerResponse:categoryArray];
                [self ImportNotesFromServerResponse:NotesArray];
                [self ImportDatabaseShareDBFromServerResponse:getShareDBData];
                [self shareDBUsers:getShareDBDataUsers];
               
               [AppDelegate showAlertViewWithTitle:@"" Message:@"Your DB Imported Successfully."];
            }
                
            else{
                [AppDelegate hideHUDForView:self.view animated:YES];
                [AppDelegate showAlertViewWithTitle:@"Sorry!" Message:@"Try Again."];
            }
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        
        [AppDelegate hideHUDForView:self.view animated:YES];
        //if(dict)
         [AppDelegate showAlertViewWithTitle:@"Network Error" Message:@"Please Check Your Internet Connection."];
    }];
    
}

-(void)shareDBUsers : (NSArray*)array {
    
    NSString *query = [NSString stringWithFormat:@"DELETE  from users where userid !=  \"%lld\" ",[[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID] longLongValue]];
    [[DBManager getSharedInstance]executeQuery:query];
    
    for(int i = 0;i<[array count];i++) {
        
        UserObject *usrObj = [[UserObject alloc] init];
        usrObj.UserID =  [[[array objectAtIndex:i] valueForKey:@"userid"] longLongValue];
        usrObj.PhoneNo = [[[array objectAtIndex:i] valueForKey:@"phone_number"] longLongValue];
        usrObj.FirstName = [[array objectAtIndex:i] valueForKey:@"first_name"] ;
        usrObj.LastName = [[array objectAtIndex:i] valueForKey:@"last_name"] ;
        [[DBManager getSharedInstance] importUsersFromServer:usrObj];
    }
}

-(void)ImportDatabaseShareDBFromServerResponse : (NSArray*)shareArrList {
  
    
    NSString *query = [NSString stringWithFormat:@"delete  from SharedDatabases where DatabaseId IN (select DatabaseId from MyDatabase where Owner_Userid = %d)",[[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID] intValue]];
    [[DBManager getSharedInstance]executeQuery:query];
    
    for(int i = 0;i<[shareArrList count];i++) {
        
        ShareDBObject *dbObj = [[ShareDBObject alloc] init];
        dbObj.DatabaseID = [[[shareArrList objectAtIndex:i] valueForKey:@"DatabaseId"] longLongValue];
        dbObj.Admin = [[[shareArrList objectAtIndex:i] valueForKey:@"Admin"] longLongValue];
        dbObj.UserID = [[[shareArrList objectAtIndex:i] valueForKey:@"UserId"] longLongValue];
        [[DBManager getSharedInstance] importShareDBUsersFromServer:dbObj];
    }
}

-(void)ImportMydatabaseFromServerResponse : (NSArray*)myDataBaseArray {
    
       /* Delete my database for logged in user */
    
//    NSString *query = [NSString stringWithFormat:@"DELETE  from MyDatabase WHERE Owner_Userid = %d",[[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID] intValue]];
    
    
    NSString *query = [NSString stringWithFormat:@"DELETE  from MyDatabase"];

   [[DBManager getSharedInstance]executeQuery:query];
    
    
   
    
    for (int i =0 ; i < myDataBaseArray.count; i++) {
        MyDataBaseObject * myDbObj =  [[MyDataBaseObject alloc]init];
        myDbObj.Databaseid =  [[[myDataBaseArray objectAtIndex:i]valueForKey:@"DatabaseId"] longLongValue];
        myDbObj.DBName =  [[myDataBaseArray objectAtIndex:i] valueForKey:@"DBName"];
        myDbObj.Owner_Userid =  [[[myDataBaseArray objectAtIndex:i]valueForKey:@"Owner_Userid"] longLongValue];
        
        myDbObj.DBType =  [[myDataBaseArray objectAtIndex:i] valueForKey:@"DBType"];
        myDbObj.Admin =  [[[myDataBaseArray objectAtIndex:i]valueForKey:@"Admin"] longLongValue];
        myDbObj.LocationStatus =  [[[myDataBaseArray objectAtIndex:i]valueForKey:@"Location_Status"] longLongValue];
        myDbObj.StorageType =  [[myDataBaseArray objectAtIndex:i] valueForKey:@"Storage_Type"];
        myDbObj.Latitude = [[myDataBaseArray objectAtIndex:i] valueForKey:@"Latitude"];
        myDbObj.Longitude = [[myDataBaseArray objectAtIndex:i] valueForKey:@"Longitude"];


        
        
        myDbObj.Catelog = @"";
        myDbObj.LastModified =  [[myDataBaseArray objectAtIndex:i] valueForKey:@"LastModified"];
        
        [[DBManager getSharedInstance] importDBFromServer:myDbObj];
        
    }
}

-(void)ImportCategoryFromServerResponse : (NSArray*)categoryArray {
    
    NSString *query = [NSString stringWithFormat:@"DELETE  from user_Categories WHERE userid = %d",[[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID] intValue]];
    [[DBManager getSharedInstance]executeQuery:query];
    
    for (int i =0 ; i < categoryArray.count; i++) {
        CategoryObject * catObj =  [[CategoryObject alloc]init];
        catObj.UserID =  [[[categoryArray objectAtIndex:i]valueForKey:@"userid"] longLongValue];
        catObj.DatabaseID =  [[[categoryArray objectAtIndex:i]valueForKey:@"DatabaseId"] longLongValue];
        catObj.CategoryID =  [[[categoryArray objectAtIndex:i]valueForKey:@"category_id"] longLongValue];
        catObj.CategoryName =  [[categoryArray objectAtIndex:i] valueForKey:@"category_name"];
      
        
        [[DBManager getSharedInstance] importCategoriesFromServer:catObj];
        
    }
}
-(void)ImportNotesFromServerResponse : (NSArray*)notesArray {
    
    NSString *query = [NSString stringWithFormat:@"DELETE  from user_notes WHERE userid = %d",[[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID] intValue]];
     [[DBManager getSharedInstance]executeQuery:query];
    
    for (int i =0 ; i < notesArray.count; i++) {
        NotesObject * noteObj =  [[NotesObject alloc]init];
        noteObj.NotesID =  [[[notesArray objectAtIndex:i]valueForKey:@"Notes_id"] longLongValue];
        noteObj.UserID =  [[[notesArray objectAtIndex:i]valueForKey:@"userid"] longLongValue];
        noteObj.DatabaseID =  [[[notesArray objectAtIndex:i]valueForKey:@"DatabaseId"] longLongValue];
        noteObj.CategoryID =  [[[notesArray objectAtIndex:i]valueForKey:@"category_id"] longLongValue];
        noteObj.Title =  [[notesArray objectAtIndex:i] valueForKey:@"title"];
        noteObj.Note =  [[notesArray objectAtIndex:i] valueForKey:@"note"];
       // noteObj.FileUpload =  [[notesArray objectAtIndex:i] valueForKey:@"File_upload"];
        
        if ([[[notesArray objectAtIndex:i] valueForKey:@"File_upload"] isKindOfClass:[NSNull class]] || [[[notesArray objectAtIndex:i] valueForKey:@"File_upload"] isEqualToString:@""]){
            noteObj.FileUpload  = @"";
        }
        
        else {
            
            noteObj.FileUpload = [[notesArray objectAtIndex:i] valueForKey:@"File_upload"];
            
        }

        [[DBManager getSharedInstance] importNotesFromServer:noteObj];
        
    }
}



#pragma mark- NSManagedObjectContext
#pragma mark-

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}
-(NSMutableArray *)fetchRecord:(NSString*)categoryName
{
      // Fetch the devices from persistent data store
    NSMutableArray *recordList=[[NSMutableArray alloc]init];
   // NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:RecordTable];
    NSSortDescriptor *sdSortDate = [NSSortDescriptor sortDescriptorWithKey:@"record_time" ascending:NO];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"email_id == %@ && category_name == %@",[AppDelegate getUserEmail],categoryName];
    fetchRequest.sortDescriptors=@[sdSortDate];
    recordList = [[[self managedObjectContext] executeFetchRequest:fetchRequest error:nil] mutableCopy];
    return recordList;
}

-(void)fetchCategory
{
    // Fetch the devices from persistent data store
   // NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:CategoryTable];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"email_id == %@ ",[AppDelegate getUserEmail]];
    categoryArr = [[[self managedObjectContext] executeFetchRequest:fetchRequest error:nil]mutableCopy];
    
}
- (void)clearCoreData {
    
    if(categoryArr.count==0)
       [self fetchCategory];
    
    if(categoryArr.count){
        for(int i=0;i<categoryArr.count;i++){
            NSManagedObject *categoryObject=categoryArr[0];
            NSMutableArray *recordList=[self fetchRecord:[categoryArr[i] valueForKey:@"category_name"]];
            
            //To delete memo detail record
            for(NSManagedObject *record in recordList){
                [[self managedObjectContext] deleteObject:record];
                 [[self managedObjectContext] save:nil];
                
            }
            
            //To delete category detail
            [[self managedObjectContext] deleteObject:categoryObject];
            [[self managedObjectContext] save:nil];
            
        }

       
    }else{
        [AppDelegate showAlertViewWithTitle:@"Sorry!" Message:@"No Records Found To Delete."];
    }
    
    
}

#pragma mark- UIAlertViewDelegate
#pragma mark-

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        [self clearCoreData];
      
    }
}
-(void)convertJsonToDictionary:(NSString*)catalogStr{
    BOOL isImportedData=YES;
    const char *c = [catalogStr cStringUsingEncoding:NSISOLatin1StringEncoding];
    NSString *newString = [[NSString alloc]initWithCString:c encoding:NSUTF8StringEncoding];
    NSData *data = [newString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSLog(@"%@",json);
    NSArray *categoryList=[json valueForKey:@"catalog"];
    for(NSDictionary *dict in categoryList){
        NSString *categoryName=[dict valueForKey:@"category"];
        if([self saveCategory:categoryName]){
            NSArray *data=[dict valueForKey:@"data"];
            for(NSDictionary *record in data){
                NSString *note=[record valueForKey:@"note"];
                NSString *title=[record valueForKey:@"title"];
                if(![self saveRecord:title category_name:categoryName note:note]){
                    isImportedData=NO;
                      break;
                }
            }
            if(!isImportedData)
                break;

        }else{
            isImportedData=NO;
            break;
        }
    
    }
    if(!isImportedData){
        [AppDelegate showAlertViewWithTitle:@"Sorry!" Message:@"Unable To Import Whole DB."];
    }

}
-(BOOL)saveCategory:(NSString*)categoryName
{
    
    if(![[appDelegate searchCategory:categoryName] length]){
        NSManagedObjectContext *context = [self managedObjectContext];
        NSManagedObject *entity = [NSEntityDescription insertNewObjectForEntityForName:CategoryTable inManagedObjectContext:context];
        [entity setValue:categoryName forKey:@"category_name"];
        [entity setValue:[AppDelegate getUserEmail] forKey:@"email_id"];
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            return NO;
        }
        return YES;

    }else{
        //Already saved
        return YES;
    }
}

-(BOOL)saveRecord:(NSString*)record_title category_name:(NSString*)category_name  note:(NSString*)note
{
    if(![appDelegate searchRecord:record_title category:category_name]){
        NSDate *today=[NSDate date];
        // Create a new managed object
        NSManagedObjectContext *context = [self managedObjectContext];
        NSManagedObject *entity = [NSEntityDescription insertNewObjectForEntityForName:RecordTable inManagedObjectContext:context];
        [entity setValue:category_name forKey:@"category_name"];
        [entity setValue:[AppDelegate getUserEmail] forKey:@"email_id"];
        [entity setValue:record_title forKey:@"record_title"];
        [entity setValue:note forKey:@"note"];
        [entity setValue:today forKey:@"record_time"];
        
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            return NO;
        }else{
            return YES;
        }

    }else{
        //Record Already added
        return YES;
    }
  
}



-(void)importDBList
{
    [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
    // NSString *registerUrl=[NSString stringWithFormat:@"%@",HostUrl];
    NSMutableDictionary *userDetail = [[NSMutableDictionary alloc]init];
    [userDetail setValue:kImportList forKey:kDefault];
   [userDetail setValue:[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID] forKey:@"user_id"];
    // [userDetail setValue:@"813" forKey:@"user_id"];
    // [userDetail setValue:@"27" forKey:kLoogedInUserID];
    
    NSLog(@"UsetDetail Dict%@", userDetail);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:HostUrl parameters:userDetail success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        [AppDelegate hideHUDForView:self.view animated:YES];
        NSLog(@"Success: %@\n ***** %@", operation.responseString, responseObject);
        id status= [responseObject valueForKey:@"status"];
        if([status isKindOfClass:[NSString class]]){
            if([status isEqualToString:@"Success"]) {
                id jsonString  =   [responseObject valueForKey:@"result"];
                NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *dictResult = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
                
                
                NSArray *shareDataBaseArray = [dictResult  valueForKey:@"ShareDB"];
                NSArray *myDataBaseArray = [dictResult  valueForKey:@"MyDatabase"];
                NSArray *categoryArray = [dictResult  valueForKey:@"user_categories"];
                NSArray *NotesArray = [dictResult  valueForKey:@"all_notes"];
                
                [self deleteImportList:[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID]];
                
                [self ImportDatabaseListMydatabaseFromServerResponse:myDataBaseArray];
                [self ImportListDatabseCategoryFromServerResponse:categoryArray];
                [self ImportListDatabaseNotesFromServerResponse:NotesArray];
                [self ImportListDatabaseShareDBFromServerResponse:shareDataBaseArray];
                
                importListViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"importListViewController"];
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
                
                [self.navigationController pushViewController:vc animated:true];
            }else
            {
               
            }
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        
        [AppDelegate hideHUDForView:self.view animated:YES];
        //if(dict)
         [AppDelegate showAlertViewWithTitle:@"Network Error" Message:@"Please Check Your Internet Connection."];
    }];
    
}

-(void)deleteImportList :(NSString*)userUid {
    
    NSString *myDatabaseQuery = [NSString stringWithFormat:@"SELECT DatabaseId FROM SharedDatabases WHERE UserId = \"%lld\"",[userUid longLongValue]];

   
    [[DBManager getSharedInstance] IdFromSource:myDatabaseQuery];
    
    NSString *shareDBquery = [NSString stringWithFormat:@"DELETE FROM SharedDatabases WHERE UserId = \"%lld\"",[userUid longLongValue]];
    
    [[DBManager getSharedInstance]executeQuery:shareDBquery];
    
    //    NSString *userCategoriesquery = [NSString stringWithFormat:@"DELETE FROM user_categories WHERE DatabaseId IN (SELECT DatabaseId FROM SharedDatabases WHERE UserId = \"%lld\")",[userUid longLongValue]];
//    [[DBManager getSharedInstance]executeQuery:userCategoriesquery];
//    NSString *notesQuery = [NSString stringWithFormat:@"DELETE FROM user_notes WHERE DatabaseId IN (SELECT DatabaseId FROM SharedDatabases WHERE UserId = \"%lld\")",[userUid longLongValue]];
//    [[DBManager getSharedInstance]executeQuery:notesQuery];
//
//    NSString *shareDBquery = [NSString stringWithFormat:@"DELETE FROM SharedDatabases WHERE UserId = \"%lld\"",[userUid longLongValue]];
//    [[DBManager getSharedInstance]executeQuery:shareDBquery];
}




-(void)ImportDatabaseListMydatabaseFromServerResponse : (NSArray*)myDataBaseArray {
    for (int i =0 ; i < myDataBaseArray.count; i++) {
        MyDataBaseObject * myDbObj =  [[MyDataBaseObject alloc]init];
        myDbObj.Databaseid =  [[[myDataBaseArray objectAtIndex:i]valueForKey:@"DatabaseId"] longLongValue];
        myDbObj.DBName =  [[myDataBaseArray objectAtIndex:i] valueForKey:@"DBName"];
        myDbObj.Owner_Userid =  [[[myDataBaseArray objectAtIndex:i]valueForKey:@"Owner_Userid"] longLongValue];
        myDbObj.Catelog = @"";
        myDbObj.LastModified =  [[myDataBaseArray objectAtIndex:i] valueForKey:@"LastModified"];
        [[DBManager getSharedInstance] importDBFromServer:myDbObj];
    }
}

-(void)ImportListDatabseCategoryFromServerResponse : (NSArray*)categoryArray {
    for (int i =0 ; i < categoryArray.count; i++) {
        CategoryObject * catObj =  [[CategoryObject alloc]init];
        catObj.UserID =  [[[categoryArray objectAtIndex:i]valueForKey:@"userid"] longLongValue];
        catObj.DatabaseID =  [[[categoryArray objectAtIndex:i]valueForKey:@"DatabaseId"] longLongValue];
        catObj.CategoryID =  [[[categoryArray objectAtIndex:i]valueForKey:@"category_id"] longLongValue];
        catObj.CategoryName =  [[categoryArray objectAtIndex:i] valueForKey:@"category_name"];
        [[DBManager getSharedInstance] importCategoriesFromServer:catObj];
    }
}
-(void)ImportListDatabaseNotesFromServerResponse : (NSArray*)notesArray {
     for (int i =0 ; i < notesArray.count; i++) {
        NotesObject * noteObj =  [[NotesObject alloc]init];
        noteObj.NotesID =  [[[notesArray objectAtIndex:i]valueForKey:@"Notes_id"] longLongValue];
        noteObj.UserID =  [[[notesArray objectAtIndex:i]valueForKey:@"userid"] longLongValue];
        noteObj.DatabaseID =  [[[notesArray objectAtIndex:i]valueForKey:@"DatabaseId"] longLongValue];
        noteObj.CategoryID =  [[[notesArray objectAtIndex:i]valueForKey:@"category_id"] longLongValue];
        noteObj.Title =  [[notesArray objectAtIndex:i] valueForKey:@"title"];
        noteObj.Note =  [[notesArray objectAtIndex:i] valueForKey:@"note"];
      //  noteObj.FileUpload =  [[notesArray objectAtIndex:i] valueForKey:@"File_upload"];
         
         
         if ([[[notesArray objectAtIndex:i] valueForKey:@"File_upload"] isKindOfClass:[NSNull class]] || [[[notesArray objectAtIndex:i] valueForKey:@"File_upload"] isEqualToString:@""]){
             noteObj.FileUpload  = @"";
         }
         
         else {
             noteObj.FileUpload = [[notesArray objectAtIndex:i] valueForKey:@"File_upload"];
         }
         
         
        [[DBManager getSharedInstance] importNotesFromServer:noteObj];
    }
}

-(void)ImportListDatabaseShareDBFromServerResponse : (NSArray*)shareArrList {
    
for(int i = 0;i<[shareArrList count];i++) {
    ShareDBObject *dbObj = [[ShareDBObject alloc] init];
    dbObj.DatabaseID = [[[shareArrList objectAtIndex:i] valueForKey:@"DatabaseId"] longLongValue];
    dbObj.Admin = [[[shareArrList objectAtIndex:i] valueForKey:@"Admin"] longLongValue];
    dbObj.UserID = [[[shareArrList objectAtIndex:i] valueForKey:@"UserId"] longLongValue];
    [[DBManager getSharedInstance] importShareDBUsersFromServer:dbObj];
}
}


-(void)logoutApi
{
    [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
    // NSString *registerUrl=[NSString stringWithFormat:@"%@",HostUrl];
    NSMutableDictionary *userDetail = [[NSMutableDictionary alloc]init];
    [userDetail setValue:kLogout forKey:kDefault];
   [userDetail setValue:[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID] forKey:@"userid"];

    
    NSLog(@"UsetDetail Dict%@", userDetail);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:HostUrl parameters:userDetail success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        [AppDelegate hideHUDForView:self.view animated:YES];
        NSLog(@"Success: %@\n ***** %@", operation.responseString, responseObject);
        id status= [responseObject valueForKey:@"status"];
        if([status isKindOfClass:[NSString class]]){
            if([status isEqualToString:@"success"]) {
                
                [self logOutAction];
                
                
                
            } else {
                
                [AppDelegate showAlertViewWithTitle:@"" Message:@"Server Error."];
               
            }
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        
        [AppDelegate hideHUDForView:self.view animated:YES];
        //if(dict)
         [AppDelegate showAlertViewWithTitle:@"Network Error" Message:@"Please Check Your Internet Connection."];
    }];
    
}


@end
