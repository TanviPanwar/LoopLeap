//
//  CreateDBController.m
//  SimpleApp
//
//  Created by IOS3 on 24/10/18.
//  Copyright © 2018 MAC. All rights reserved.
//

#import "CreateDBController.h"
#import "AppDelegate.h"

@interface CreateDBController ()<UITextFieldDelegate>
{
    NSString * selectedBtnTag;
}
@end

@implementation CreateDBController
@synthesize dbObj;
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
    if ([_screenType isEqualToString:@"Edit"]) {
        
        [self.dbTxtFld setUserInteractionEnabled:false];
        self.title = dbObj.DBName;
        self.dbTxtFld.text = dbObj.DBName;
        if ([dbObj.DBType isEqualToString:@"Public"]) {
            [_personalBtn setImage:[UIImage imageNamed:@"radio"] forState:UIControlStateNormal];
            [_publicBtn setImage:[UIImage imageNamed:@"radioFilled"] forState:UIControlStateNormal];
            selectedBtnTag = @"Public";
        }
        else {
            [_personalBtn setImage:[UIImage imageNamed:@"radioFilled"] forState:UIControlStateNormal];
            [_publicBtn setImage:[UIImage imageNamed:@"radio"] forState:UIControlStateNormal];
            selectedBtnTag = @"Personal";
        }
        
    }
    else {
        
        [self.dbTxtFld setUserInteractionEnabled:true];
        self.title = @"Create New DB";
        [_personalBtn setImage:[UIImage imageNamed:@"radio"] forState:UIControlStateNormal];
        [_publicBtn setImage:[UIImage imageNamed:@"radio"] forState:UIControlStateNormal];
    }
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveAction)];
    
    self.navigationItem.leftBarButtonItem = cancel;
    self.navigationItem.rightBarButtonItem = save;
    
    // Do any additional setup after loading the view.
}

#pragma mark -
#pragma mark - TextField Delegate Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return true;
}


#pragma mark -
#pragma mark - IBAction Methods

-(void)saveAction {
    
    if ( [_screenType isEqualToString:@"Create"]) {
        NSString *dbName = [_dbTxtFld.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if ([dbName isEqualToString:@""] || dbName == nil) {
            
            [AppDelegate showAlertViewWithTitle:@"Alert" Message:@"Please enter database name"];
        }
        else if ([selectedBtnTag isEqualToString:@""] || selectedBtnTag == nil) {
            [AppDelegate showAlertViewWithTitle:@"Alert" Message:@"Please select database type"];
        }
        else {
            [self createDBAPi:dbName type:selectedBtnTag];
        }
    }
    
    else {
        [self updateDBTypeAPI];
        
    }
}
-(void)cancelAction {
    [self dismissViewControllerAnimated:true completion:nil];
}
- (IBAction)personalbtnAction:(id)sender {
    [self.view endEditing:true];
    [_personalBtn setImage:[UIImage imageNamed:@"radioFilled"] forState:UIControlStateNormal];
    [_publicBtn setImage:[UIImage imageNamed:@"radio"] forState:UIControlStateNormal];
    selectedBtnTag = @"Personal";
}

- (IBAction)publicBtnAction:(id)sender {
    [self.view endEditing:true];
    [_personalBtn setImage:[UIImage imageNamed:@"radio"] forState:UIControlStateNormal];
    [_publicBtn setImage:[UIImage imageNamed:@"radioFilled"] forState:UIControlStateNormal];
    selectedBtnTag = @"Public";
}


#pragma mark -
#pragma mark - Webservice Methods
-(void)createDBAPi : (NSString*)DBName  type:(NSString *)DBType {
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setObject:[AppDelegate getOwnerId] forKey:@"userid"];
    [dict setObject:DBName forKey:@"new_db"];
    [dict setObject:selectedBtnTag forKey:@"db_type"];
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
                    NSString *dbType = [result valueForKey:@"DBType"] ;
                    NSString *storageType = @"Local";
                    
                    NSString *admin = [result valueForKey:@"Admin"]  ;
                    NSString *locationStatus = [result valueForKey:@"Location_Status"];
                    NSString *Latitude = [result valueForKey:@"Latitude"] ;
                    NSString *Longitude = [result valueForKey:@"Longitude"] ;
                    
                    

                    [self createNewDBFromJsonResponse:dbID withdbName:DBName withownerID:OwnerID withcatalog:Catalog withlastModifiedDate:LastModifieddate dbtype:dbType withStorageType:storageType admin:admin locationStatus:locationStatus lattitude:Latitude longitude:Longitude];
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

-(void)updateDBTypeAPI {
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setObject:[AppDelegate getOwnerId] forKey:@"userid"];
    [dict setObject: [NSString stringWithFormat:@"%lld",dbObj.Databaseid] forKey:@"db_id"];
    [dict setObject:selectedBtnTag forKey:@"db_type"];
    [dict setObject:kUpdateDBType forKey:kDefault];
    
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
               
                    [self updateDBTypeOnLocalDatabase];
                
                
                
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
#pragma mark -
#pragma mark - SQLite Methods
-(void)createNewDBFromJsonResponse : (NSString*)dbID withdbName :(NSString*)dbName withownerID  :(NSString*)ownerID withcatalog : (NSString*)catalog withlastModifiedDate :(NSString*)lastModifiedDate dbtype:(NSString *)dbType withStorageType :(NSString*)storageType admin:(NSString*)admin locationStatus:(NSString*)locationStatus  lattitude:(NSString*)lattitude  longitude:(NSString*)longitude {
    
    BOOL success = NO;
    NSString *alertString = @"Data Insertion failed";
    
    
    success = [[DBManager getSharedInstance] createNewDataBase_dataBaseId:dbID dbName:dbName ownerUser_Id:ownerID cataLog:catalog lastModified:lastModifiedDate dbType:dbType storageType:storageType admin:admin locationStatus:locationStatus lattitude:lattitude longitude:longitude];
    if (success == YES)
    {
        [self dismissViewControllerAnimated:true completion:^{
            [AppDelegate showAlertViewWithTitle:@"Message" Message:@"Your DB Created Successfully."];
        }];
        
    }
    
    
    if (success == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: alertString message:nil  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
}

-(void)updateDBTypeOnLocalDatabase  {
    
    BOOL success = NO;
    NSString *alertString = @"Data Insertion failed";
    
    
    success = [[DBManager getSharedInstance] updateDbType:selectedBtnTag withDbID:[NSString stringWithFormat:@"%lld", dbObj.Databaseid]];
    if (success == YES)
    {
        [self dismissViewControllerAnimated:true completion:^{
            [AppDelegate showAlertViewWithTitle:@"Message" Message:@"Your DB updated Successfully."];
        }];
        
    }
    
    
    if (success == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: alertString message:nil  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
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
