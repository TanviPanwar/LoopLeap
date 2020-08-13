//
//  CreateNewDBViewController.m
//  SimpleApp
//
//  Created by iOS6 on 04/07/19.
//  Copyright © 2019 MAC. All rights reserved.
//

#import "CreateNewDBViewController.h"
#import "AppDelegate.h"
#import <GoogleSignIn/GoogleSignIn.h>
#import <GoogleAPIClientForREST/GoogleAPIClientForREST-umbrella.h>
#import <GTMSessionFetcher/GTMSessionFetcher.h>


@interface CreateNewDBViewController () {
    NSArray *locationArray;
    UITextField *newDbfield ,  *txtfieldDbId;
    GTLRDriveService *driveService;
    NSString *folderID;
    NSString *folderName;


}
@end

@implementation CreateNewDBViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // [self.navigationController.navigationBar setHidden:YES];
    locationArray = [[NSArray alloc] init];
    
    locationArray = @[@"Google Drive", @"Local Storage"];
    
    _databaseView.layer.borderWidth = 1;
    _databaseView.layer.cornerRadius = 4;
    _databaseView.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor clearColor]);
    _databaseView.clipsToBounds = YES;
    
    _storageView.layer.borderWidth = 1;
    _storageView.layer.cornerRadius = 4;
    _storageView.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor clearColor]);
    _storageView.clipsToBounds = YES;
    driveService = [[GTLRDriveService alloc] init];
    
    self.navigationItem.title = @"Create New DB";
    UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc]
                                initWithTitle:@"Save"
                                style:UIBarButtonItemStyleBordered
                                target:self
                                action:@selector(saveTapped:)];
    self.navigationItem.rightBarButtonItem = saveBtn;
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc]
                                  initWithTitle:@"Cancel"
                                  style:UIBarButtonItemStyleBordered
                                  target:self
                                  action:@selector(cancelTapped:)];
    self.navigationItem.leftBarButtonItem = cancelBtn;
    
    [self showPicker];
    
    
    // Add an observer that will respond to loginComplete
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideButton:)
                                                 name:@"HideGoogleSignIn" object:nil];


    [_signInButton setHidden:YES];

    
}

- (void)hideButton:(NSNotification *)note {
    NSLog(@"Received Notification - Someone seems to have logged in");
    NSLog(@"%@", note.object);
    GIDGoogleUser *user =  note.object;
    [_signInButton setHidden:YES];
}

- (IBAction)saveTapped:(id)sender
{
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    if ([[_databaseTextField.text stringByTrimmingCharactersInSet: set] length] == 0 || [[_storageLocationTextField.text stringByTrimmingCharactersInSet: set] length] == 0 )
    {
        
       if ([[_databaseTextField.text stringByTrimmingCharactersInSet: set] length] == 0) {
        
         [AppDelegate showAlertViewWithTitle:@"" Message:@"Please enter database name."];
            
        }
         
         else if ([[_storageLocationTextField.text stringByTrimmingCharactersInSet: set] length] == 0) {
             
               [AppDelegate showAlertViewWithTitle:@"" Message:@"Please select storage type."];
             
         }
        
    }
    else {
        NSString *dbName = _databaseTextField.text;
        dbName = [dbName stringByReplacingOccurrencesOfString:@"\"" withString:@"~#~"];
        dbName = [dbName stringByReplacingOccurrencesOfString:@"\'" withString:@"~!~"];
        
        NSString *storageLocationName = _storageLocationTextField.text;
        storageLocationName = [storageLocationName stringByReplacingOccurrencesOfString:@"\"" withString:@"~#~"];
        storageLocationName = [storageLocationName stringByReplacingOccurrencesOfString:@"\'" withString:@"~!~"];
        
        [self createDBAPi:dbName StorageLocationName:storageLocationName];
    }
    
}


- (IBAction)cancelTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}





/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


#pragma mark - Picker Method

- (void)showPicker {
    
    
    [_storageLocationTextField setInputView: _inputView];
    _storageLocationTextField.inputAccessoryView = nil;
    
}

#pragma mark - TextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField == _databaseTextField) {
        
        [self showPicker];
        
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return  true;
}

#pragma mark - IB Actions

//- (IBAction)cancelBtnAction:(id)sender {
//
//   [self.navigationController popToRootViewControllerAnimated:YES];
//
//
//}
//
//- (IBAction)saveBtnAction:(id)sender {
//
//
//
//    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
//    if ([[_databaseTextField.text stringByTrimmingCharactersInSet: set] length] == 0 || [[_storageLocationTextField.text stringByTrimmingCharactersInSet: set] length] == 0 )
//    {
//
//    }
//    else {
//        NSString *dbName = _databaseTextField.text;
//        dbName = [dbName stringByReplacingOccurrencesOfString:@"\"" withString:@"~#~"];
//        dbName = [dbName stringByReplacingOccurrencesOfString:@"\'" withString:@"~!~"];
//
//        NSString *storageLocationName = _storageLocationTextField.text;
//        storageLocationName = [storageLocationName stringByReplacingOccurrencesOfString:@"\"" withString:@"~#~"];
//        storageLocationName = [storageLocationName stringByReplacingOccurrencesOfString:@"\'" withString:@"~!~"];
//
//        [self createDBAPi:dbName StorageLocationName:storageLocationName];
//    }
//
//
//}

- (IBAction)cancelTooolBarBtnAction:(id)sender {
    
    [self.view endEditing:YES];
    
}

- (IBAction)DoneToolBarBtnAction:(id)sender {
    
    NSInteger *row = [self.storageLocationPickerView selectedRowInComponent:0];
    
    _storageLocationTextField.text = [locationArray objectAtIndex:row];
    
    
    if ([(_storageLocationTextField.text)  isEqual: @"Google Drive"]) {

        if(GIDSignIn.sharedInstance.hasAuthInKeychain)
        {
            //loggedIn
            [_signInButton setHidden:YES];
            NSLog(@"%@",GIDSignIn.sharedInstance.currentUser.userID );
            driveService.authorizer = GIDSignIn.sharedInstance.currentUser.authentication.fetcherAuthorizer;
        }
        else
        {
            //not loggedIn
            
//            NSString *loginStatus;
//            loginStatus = [[NSUserDefaults standardUserDefaults] valueForKey:@"loginStatus"];
//
//            if([loginStatus  isEqual: @"login"]) {
//
//                [_signInButton setHidden:YES];
//
//            }
//
//            else {
            
                [_signInButton setHidden:FALSE];
                
           // }
            
            [GIDSignIn sharedInstance].delegate = self;
            [GIDSignIn sharedInstance].uiDelegate = self;
            [GIDSignIn sharedInstance] .scopes = [NSArray arrayWithObjects:kGTLRAuthScopeDriveFile,kGTLRAuthScopeDrive, nil ];
           // [[GIDSignIn sharedInstance] signInSilently];
            GIDGoogleUser *user;
            NSLog(@"%@", user.grantedScopes);

   
        }
   
    }
    
    else {
        
         [_signInButton setHidden:YES];
        
    }
    
    
    [self.view endEditing:true];
    
}

#pragma mark - Picker Delegates

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return locationArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return [locationArray objectAtIndex:row];
}

#pragma mark - API

-(void)createDBAPi : (NSString*)DBName StorageLocationName:(NSString*)StorageLocationName {
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setObject:[AppDelegate getOwnerId] forKey:@"userid"];
    [dict setObject:DBName forKey:@"new_db"];
    [dict setObject:StorageLocationName forKey:@"storage_type"];
    [dict setObject:@"Personal" forKey:@"db_type"];
    [dict setObject:kCreateNewDB forKey:kDefault];
    [dict setObject:[NSString stringWithFormat:@"%d",1] forKey:@"admin"];
    [dict setObject:[NSString stringWithFormat:@"%d",0] forKey:@"location_status"];
    [dict setObject:@"" forKey:@"latitiude"];
    [dict setObject:@"" forKey:@"longitude"];
    
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
                    NSString *Catalog = @"Catalog";
                    NSString *LastModifieddate = [result valueForKey:@"LastModified"] ;
                    NSString *storageType = [result valueForKey:@"Storage_Type"] ;
                    
                    NSString *admin = [result valueForKey:@"Admin"]  ;
                    NSString *locationStatus = [result valueForKey:@"Location_Status"];
                    NSString *Latitude = [result valueForKey:@"Latitude"] ;
                    NSString *Longitude = [result valueForKey:@"Longitude"] ;
                    
                    [self createNewDBFromJsonResponse:dbID withdbName:DBName withownerID:OwnerID withcatalog:Catalog withlastModifiedDate:LastModifieddate storageType:storageType admin:admin locationStatus:locationStatus lattitude:Latitude longitude:Longitude];
                    
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

-(void)createNewDBFromJsonResponse : (NSString*)dbID withdbName :(NSString*)dbName withownerID  :(NSString*)ownerID withcatalog : (NSString*)catalog withlastModifiedDate :(NSString*)lastModifiedDate storageType:(NSString*)storageType admin:(NSString*)admin locationStatus:(NSString*)locationStatus  lattitude:(NSString*)lattitude  longitude:(NSString*)longitude
{
    
    BOOL success = NO;
    NSString *alertString = @"Data Insertion failed";
    
    
    success = [[DBManager getSharedInstance] createNewDataBase_dataBaseId:dbID dbName:dbName ownerUser_Id:ownerID cataLog:catalog lastModified:lastModifiedDate dbType:@"Personal" storageType:storageType admin:admin locationStatus:locationStatus lattitude:lattitude longitude:longitude];
    if (success == YES)
    {
        
        [AppDelegate showAlertViewWithTitle:@"Message" Message:@"Your DB Created Successfully."];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    
    if (success == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: alertString message:nil  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
}

#pragma mark - GoogleSignIn delegates
-(void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    if (error) {
        //TODO: handle error
        // [AppDelegate showAlertViewWithTitle:@" " Message:[NSString stringWithFormat:@"%@", error.localizedDescription]];
    } else {
        NSString *userId   = user.userID;
        NSString *fullName = user.profile.name;
        NSString *email    = user.profile.email;
        NSURL *imageURL    = [user.profile imageURLWithDimension:1024];
        NSString *accessToken = user.authentication.accessToken; //Use this access token in Google+ API calls.
//        NSArray *currentScopes = [GIDSignIn sharedInstance].scopes;
//        [GIDSignIn sharedInstance].scopes = [currentScopes arrayByAddingObject:kGTLRAuthScopeDriveFile];
        NSLog(@"%@userId and token", userId, accessToken);
        [[NSUserDefaults standardUserDefaults]setValue:accessToken forKey:@"googleAccessToken"];
        [[NSNotificationCenter defaultCenter] postNotificationName:
         @"HideGoogleSignIn" object:user userInfo:nil];
       
        NSLog(@"%@", user.grantedScopes);
        driveService.authorizer = user.authentication.fetcherAuthorizer;
       [GIDSignIn sharedInstance] .scopes = [NSArray arrayWithObjects:kGTLRAuthScopeDriveFile,kGTLRAuthScopeDrive, nil ];
        NSLog(@"%@", user.grantedScopes);
        
//        NSString *loginStatus;
//        loginStatus = [[NSUserDefaults standardUserDefaults] valueForKey:@"loginStatus"];
//
//        if([loginStatus  isEqual: @"login"]) {
//
//
//        }
//
//        else {
//
//            [[NSUserDefaults standardUserDefaults]setValue:@"login" forKey:@"loginStatus"];
        
            [AppDelegate showAlertViewWithTitle:@" " Message:@"Google sign in successfully"];
            
       // }
        
        [[NSUserDefaults standardUserDefaults] synchronize];

       
    }
}


- (void)uploadFileURL:(NSURL *)fileToUploadURL mimeType: (NSString*)mimeType {
    
    
    UIImage * img = [UIImage imageNamed:@"database"];
    
    NSData *fileData =   UIImagePNGRepresentation(img);

    
    GTLRDrive_File *metadata = [GTLRDrive_File object];
    metadata.name = @"photo.jpg";
    metadata.parents =  [NSArray arrayWithObject:folderID];
    
    GTLRUploadParameters *uploadParameters = [GTLRUploadParameters uploadParametersWithData:fileData
                                                                                   MIMEType:@"image/jpeg"];
    uploadParameters.shouldUploadWithSingleRequest = TRUE;
    GTLRDriveQuery_FilesCreate *query = [GTLRDriveQuery_FilesCreate queryWithObject:metadata
                                                                   uploadParameters:uploadParameters];
    query.fields = @"id";
    [driveService executeQuery:query completionHandler:^(GTLRServiceTicket *ticket,
                                                         GTLRDrive_File *file,
                                                         NSError *error) {
        if (error == nil) {
            NSLog(@"File ID %@", file.identifier);
        } else {
            NSLog(@"An error occurred: %@", error);
        }
    }];
    
}

- (void)createAFolder {
 
    GTLRDrive_File *metadata = [GTLRDrive_File object];
    metadata.name = @"SimpleApp";
    folderName = metadata.name;
    metadata.mimeType = @"application/vnd.google-apps.folder";
    GTLRDriveQuery_FilesCreate *query = [GTLRDriveQuery_FilesCreate queryWithObject:metadata
                                                                   uploadParameters:nil];
    query.fields = @"id";
    [driveService executeQuery:query completionHandler:^(GTLRServiceTicket *ticket,
                                                         GTLRDrive_File *file,
                                                         NSError *error) {
        if (error == nil) {
            NSLog(@"File ID %@", file.identifier);
            folderID = file.identifier;
             [self uploadFileURL:[NSURL URLWithString:@""] mimeType:@""];
            
            
        } else {
            NSLog(@"An error occurred: %@", error);
        }
    }];
    
}

-(void) searchFolder {
    
   
   // GTLRDriveQuery_FilesCreate *query;
    GTLRDriveQuery_FilesList *query;
    query.pageSize = 1;
    query.q = [NSString stringWithFormat:@"name contains %@",folderName];
    [driveService executeQuery:query completionHandler:^(GTLRServiceTicket *ticket,
                                                         GTLRDrive_File *file,
                                                         NSError *error) {
        if (error == nil) {
            NSLog(@"File ID %@", file.identifier);
            if ([file.identifier isKindOfClass:[NSNull null]] || [file.identifier isEqualToString:@""]) {
                
                [self createAFolder];
                
            }
            
            else {
                [self uploadFileURL:[NSURL URLWithString:@""] mimeType:@""];
                
            }
            

        } else {
            NSLog(@"An error occurred: %@", error);
        }
    }];
    
    
//    let query = GTLRDriveQuery_FilesList.query()
//    query.pageSize = 1
//    query.q = "name contains '\(fileName)'"
//
//    service.executeQuery(query) { (ticket, results, error) in
//        onCompleted((results as? GTLRDrive_FileList)?.files?.first?.identifier, error)
//    }
    
}



-(void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error {
    // Perform any operations when the user disconnects from app here.
}

-(void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}

// Dismiss the "Sign in with Google" view
-(void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
