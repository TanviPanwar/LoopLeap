//
//  ImportFromViewController.m
//  SimpleApp
//
//  Created by iOS6 on 09/10/19.
//  Copyright © 2019 MAC. All rights reserved.
//

#import "ImportFromViewController.h"
#import <AppAuth/AppAuth.h>
#import <GTMAppAuth/GTMAppAuth.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import <GoogleAPIClientForREST/GoogleAPIClientForREST-umbrella.h>
#import <GTMSessionFetcher/GTMSessionFetcher.h>
#import "AppDelegate.h"
#import "GTMSessionFetcher/GTMSessionFetcherService.h"
#import "GoogleNotesObject.h"
#import "PreviewViewController.h"

int globalCount = 0;

@interface ImportFromViewController ()<UIPickerViewDataSource, UIPickerViewDelegate> {
    
    GTLRDriveService *driveService;
    NSString *folderID;
    NSMutableArray *dbArray;
    NSArray *structureArray;
    NSArray *delimetersArray;
    NSArray *duplicateOptionsArray;
    NSMutableArray *filesDataArray;
    NSString *fileName;
    NSString *fileID;
    NSMutableArray *filesNameArray;
    NSMutableString *notes;
    NSString *title;
    NSString *category;
    NSString *delimeter;
    int *textFieldValue;
    GoogleNotesObject *googleNoteObj;
    NSMutableArray *googleNotesArray;
    NSString *databaseID;
    
    NSMutableArray *filesImportedNameArray;
    NSMutableArray *filesImportedIDArray;
    NSMutableArray *driveFiles;
    NSMutableArray *notesArray;
    NSMutableArray *categoryArray;
    
    NSString *totalCount;
    NSString *addCount;
    NSString *updateCount;
    NSString *skipCount;
    NSString *errorCount;
    NSString *totalUpdateCount;



    
    
    

}

@property(weak, nonatomic) IBOutlet GIDSignInButton *signInButton;
@property (weak, nonatomic) IBOutlet UIView *selectDatabaseView;
@property (weak, nonatomic) IBOutlet UIView *selectPathView;
@property (weak, nonatomic) IBOutlet UIView *selectStructureView;
@property (weak, nonatomic) IBOutlet UIView *selectDelimeters;
@property (weak, nonatomic) IBOutlet UITextField *selectDatabaseTextField;
@property (weak, nonatomic) IBOutlet UITextField *selectPathTextField;
@property (weak, nonatomic) IBOutlet UITextField *selectStructureTextField;
@property (weak, nonatomic) IBOutlet UITextField *selectDelimetersTextField;
@property (weak, nonatomic) IBOutlet UITextField *userDefinedDelimeterTextField;
@property (weak, nonatomic) IBOutlet UITextField *duplicateTextField;

@property (weak, nonatomic) IBOutlet UIView  *pickerInputView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelToolBarBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneToolBarBtn;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIView *duplicateView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *duplicateTopConstraint;

@property (weak, nonatomic) IBOutlet UIButton *importFolderBtn;

@property (weak, nonatomic) IBOutlet UIButton *previewFilesBtn;

@end

@implementation ImportFromViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    driveService = [[GTLRDriveService alloc] init];
    [GIDSignIn sharedInstance].delegate = self;
    [GIDSignIn sharedInstance].uiDelegate = self;
    [GIDSignIn sharedInstance] .scopes = [NSArray arrayWithObjects:kGTLRAuthScopeDriveFile,kGTLRAuthScopeDrive, nil ];
    // [[GIDSignIn sharedInstance] signInSilently];
    GIDGoogleUser *user;
    NSLog(@"%@", user.grantedScopes);
    notes = [[NSMutableString alloc] init];
    googleNoteObj  = [[GoogleNotesObject alloc] init];
    googleNotesArray  = [[NSMutableArray alloc] init];
    structureArray = [[NSArray alloc] init];
    delimetersArray = [[NSArray alloc] init];
    duplicateOptionsArray = [[NSArray alloc] init];
    filesDataArray =  [[NSMutableArray alloc] init];
    filesNameArray =  [[NSMutableArray alloc] init];
    filesImportedNameArray =  [[NSMutableArray alloc] init];
    filesImportedIDArray =  [[NSMutableArray alloc] init];
    notesArray =  [[NSMutableArray alloc] init];
    categoryArray =  [[NSMutableArray alloc] init];
    driveFiles = [[NSMutableArray alloc] init];

    structureArray = @[@"First Row By Title", @"First Row By Category"];
    delimetersArray = @[@",", @":", @"|", @"V", @"User Specified Delimeters"];
    duplicateOptionsArray = @[@"Add", @"Update", @"Skip"];


    _selectDatabaseTextField.tintColor = UIColor.clearColor;
    _selectStructureTextField.tintColor = UIColor.clearColor;
    _selectDelimetersTextField.tintColor = UIColor.clearColor;

    
    [self showPicker];
    [self getMyDBListFromSqlite];
    
    // Add an observer that will respond to loginComplete
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideButton:)
                                                 name:@"HideGoogleSignIn" object:nil];

    
}

- (void)showPicker {
    
    _selectDatabaseTextField.inputView = _pickerInputView;
    _selectDatabaseTextField.inputAccessoryView = nil;
    _selectStructureTextField.inputView = _pickerInputView;
    _selectStructureTextField.inputAccessoryView = nil;
    _selectDelimetersTextField.inputView = _pickerInputView;
    _selectDelimetersTextField.inputAccessoryView = nil;
    _duplicateTextField.inputView = _pickerInputView;
    _duplicateTextField.inputAccessoryView = nil;
    
    
}

- (void)hideButton:(NSNotification *)note {
    NSLog(@"Received Notification - Someone seems to have logged in");
    NSLog(@"%@", note.object);
    GIDGoogleUser *user =  note.object;
  
    [_signInButton setHidden:YES];
}

#pragma mark - TextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField == _selectDatabaseTextField) {
        
        
        
        textField.tag = 1;
        textFieldValue = textField.tag;
        
        if (dbArray.count > 0) {
            
            [self showPicker];
            [_pickerView reloadAllComponents];
            
        } else {
            
            [_selectDatabaseTextField resignFirstResponder];
            _selectDatabaseTextField.inputView = nil;
            _selectDatabaseTextField.inputAccessoryView = nil;
            [AppDelegate showAlertViewWithTitle:@" " Message:[NSString stringWithFormat:@" No Database found to import folder"]];
            
        }
        
    } else if (textField == _selectStructureTextField) {
        
        textField.tag = 2;
        textFieldValue = textField.tag;
        [self showPicker];
        [_pickerView reloadAllComponents];
        
    } else if (textField == _selectDelimetersTextField) {
        
        textField.tag = 3;
        textFieldValue = textField.tag;
        [self showPicker];
        [_pickerView reloadAllComponents];
        
    } else if (textField == _duplicateTextField) {
        
        textField.tag = 4;
        textFieldValue = textField.tag;
        [self showPicker];
        [_pickerView reloadAllComponents];
        
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return  true;
}


#pragma mark- IB Actions

- (IBAction)gettFoldersBtnAction:(id)sender {
    

    
    if (([_selectDatabaseTextField.text isEqual:@""])){
        
        [AppDelegate showAlertViewWithTitle:@"Alert!" Message:@"Please select database."];
        
    } else if (([_selectPathTextField.text isEqual:@""])){
          
          [AppDelegate showAlertViewWithTitle:@"Alert!" Message:@"Please enter path of your google drive."];
        
    } else if (([_selectStructureTextField.text isEqual:@""])){
          
          [AppDelegate showAlertViewWithTitle:@"Alert!" Message:@"Please select structure."];
        
    } else if (([_selectDelimetersTextField.text isEqual:@""])){
          
          [AppDelegate showAlertViewWithTitle:@"Alert!" Message:@"Please select delimeter."];
        
    } else if (([_duplicateTextField.text isEqual:@""])){
          
          [AppDelegate showAlertViewWithTitle:@"Alert!" Message:@"Please select duplicate handling."];
        
    } else {
    
        [self searchFolder];
        
    }
   
}

- (IBAction)previewFilesBtnAction:(id)sender {
    
    PreviewViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PreviewViewController"];
    vc.notesArray = notesArray;
    vc.categoryArray = categoryArray;
    vc.totalCount = totalCount;
    vc.addCount = addCount;
    vc.updateCount = updateCount;
    vc.skipCount = skipCount;
    vc.errorCount = errorCount;
    vc.totalUpdateCount =  totalUpdateCount;

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
    [self.navigationController pushViewController:vc animated:true];
    
    
}



- (IBAction)cancelBtnAction:(id)sender {
    
    [self.view endEditing:true];
    
}

- (IBAction)doneBtnAction:(id)sender {
    
    
    NSInteger row = [self.pickerView selectedRowInComponent:0];
    
    if (textFieldValue == 1) {
        
        MyDataBaseObject *DbObj =  [dbArray objectAtIndex:row];
        self.selectDatabaseTextField.text =  DbObj.DBName;
        databaseID = [NSString stringWithFormat:@"%lld", DbObj.Databaseid];
        if (DbObj.Admin == 0){
           
          _importFolderBtn.hidden = YES;
          [self.view endEditing:true];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
               
                [AppDelegate showAlertViewWithTitle:@"" Message:@"You have no admin access to this database to import folder"];
            });
            
          
            
        } else {
            
            _importFolderBtn.hidden = NO;
             [self.view endEditing:true];
        }
        
    } else if (textFieldValue == 2) {
        
        self.selectStructureTextField.text =  structureArray[row];
        [self.view endEditing:true];
        
    }  else if (textFieldValue == 4) {
        
        self.duplicateTextField.text =  duplicateOptionsArray[row];
        [self.view endEditing:true];

        
    } else {
        
        if ([delimetersArray[row]  isEqual: @"User Specified Delimeters"]) {
            
            [_userDefinedDelimeterTextField setHidden:false];
            _duplicateTopConstraint.constant = 80;
            
            

          
            
        } else {
            
            _selectDelimetersTextField.tintColor = UIColor.clearColor;
            [_userDefinedDelimeterTextField setHidden:true];
            _duplicateTopConstraint.constant = 15;

        



        }
        self.selectDelimetersTextField.text =  delimetersArray[row];
        [self.view endEditing:true];
    }
    
   // [self.view endEditing:true];

}


#pragma mark- Custom Methods

-(void)getMyDBListFromSqlite {
    
    dbArray = [[NSMutableArray alloc] init];
    NSString *ownerID = [[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID];
    
    /* For Owner Database*/
//    dbArray = [[DBManager getSharedInstance]getDataFromMyDataBase:ownerID];
    
    
    /* For All Database*/
    dbArray = [[DBManager getSharedInstance]getAllDataFromMyDataBase];
    
    [self.pickerView reloadAllComponents];
    
    if (dbArray.count == 0) {
     [AppDelegate showAlertViewWithTitle:@" " Message:[NSString stringWithFormat:@" No Database found to import folder"]];
        
    } else {
        
        
    }
}


    #pragma mark - PickerView Delegates

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (textFieldValue == 1) {
    return dbArray.count;
        
    } else if (textFieldValue == 2)  {
        
          return structureArray.count;
        
    } else  if (textFieldValue == 3)  {
  
        return delimetersArray.count;
        
    } else {
        
        return duplicateOptionsArray.count;
    }
    
    
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (textFieldValue == 1) {
        MyDataBaseObject *obj = dbArray[row];
        // _storageTypeLabel .text = obj.StorageType;
        
        return obj.DBName;
        
    } else if (textFieldValue == 2) {
        
        return structureArray[row];
        
    } else if (textFieldValue == 3) {
        
        return delimetersArray[row];
        
    } else {
        
        return duplicateOptionsArray[row];
        
    }
}

#pragma mark- API Methods

-(void)addNewCategory  {
     //:(GoogleNotesObject *)obj
   // [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
    NSMutableDictionary *userDetail = [[NSMutableDictionary alloc] init];
    [userDetail setValue:databaseID forKey:kCategory];
 
    [userDetail setValue:kAddBulkCategory forKey:kDefault];
    
    [userDetail setValue:[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID] forKey:kLoogedInUserID];
    NSString *duplicateHandle = _duplicateTextField.text;
    [userDetail setValue:duplicateHandle forKey:@"data_action"];
    
    NSMutableArray *filesArray;
     filesArray = [[NSMutableArray alloc] init];
    NSError *error;

    if (googleNotesArray.count > 0) {
 
    for (int i=0; i<=googleNotesArray.count-1; i++) {
        
        NSMutableDictionary *dict;
        dict = [[NSMutableDictionary alloc] init];
        
        GoogleNotesObject *obj = [googleNotesArray objectAtIndex:i];
        
        [dict setValue:obj.GoogleTitle forKey:@"title"];
        [dict setValue:obj.GoogleCategory forKey:@"new_category"];
        [dict setValue:obj.GoogleNotes forKey:@"description"];

        [filesArray addObject:dict];

    }
    NSLog(@"%@", filesArray);
    
    NSString *createJSON = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:filesArray
                                                                                   options:NSJSONWritingPrettyPrinted
                                                                                     error:&error] encoding:NSUTF8StringEncoding];
    [userDetail setValue:createJSON forKey:kNewCategoryArray];
        
    } else {
        
        NSString *createJSON = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:filesArray
                                                                                          options:NSJSONWritingPrettyPrinted
                                                                                            error:&error] encoding:NSUTF8StringEncoding];
        [userDetail setValue:createJSON forKey:kNewCategoryArray];

        
    }
    

    NSString *createJSONStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:filesNameArray
                                                                                          options:NSJSONWritingPrettyPrinted
                                                                                            error:&error] encoding:NSUTF8StringEncoding];
    
    [userDetail setValue:createJSONStr forKey:kerrorFilesArray];

    
    
    NSLog(@"UsetDetail Dict%@", userDetail);
    //    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:HostUrl]];
   
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
   
        //[userDetail setValue:@"" forKey:@"drive_path"];
    
    AFHTTPRequestOperation *op = [manager POST:HostUrl parameters:userDetail constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        
        //do not put image inside parameters dictionary as I did, but append it!
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [AppDelegate hideHUDForView:self.view animated:YES];
        NSError *error;
        NSLog(@"Success: %@***** ", operation.responseString);
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject
                                                             options:NSJSONReadingMutableContainers
                                                               error:&error];
        NSLog(@"JSON ==%@", json);
        id status= [json valueForKey:@"status"];
        if([status isKindOfClass:[NSString class]]){
            if([status isEqualToString:@"Success"]) {
                
                totalCount = [json valueForKey:@"totalcount"];
                addCount = [json valueForKey:@"InsertCount"];
                updateCount = [json valueForKey:@"updateCount"];
                skipCount = [json valueForKey:@"Skipcount"];
                errorCount = [json valueForKey:@"error_files"];
                totalUpdateCount = [json valueForKey:@"TotalUpdate"];
                
                NSMutableArray *dictResult = [json  valueForKey:@"result"];
                if (dictResult.count > 0) {
                    for (int i=0; i<dictResult.count; i++)
                    {
                        NSDictionary *dictObj = [dictResult objectAtIndex:i];
                        
                        if ([[dictObj valueForKey:@"notes_info"] isKindOfClass:[NSDictionary class]]) {
                            NSDictionary *noteDict = [dictObj valueForKey:@"notes_info"];
                            NotesObject *noteObj = [[NotesObject alloc] init];
                            noteObj.DatabaseID = [[noteDict valueForKey:@"DatabaseId"] longLongValue];
                            noteObj.NotesID = [[noteDict valueForKey:@"Notes_id"] longLongValue];
                            noteObj.CategoryID = [[noteDict valueForKey:@"category_id"] longLongValue];
                            noteObj.Note = [noteDict valueForKey:@"note"];
                            noteObj.Title = [noteDict valueForKey:@"title"];
                            noteObj.UserID = [[noteDict valueForKey:@"userid"] longLongValue];
                            
                            if ([[noteDict valueForKey:@"File_upload"] isKindOfClass:[NSNull class]] || [[noteDict valueForKey:@"File_upload"] isEqualToString:@""] ){
                                noteObj.FileUpload  = @"";
                            }
                            
                            else {
                                
                                noteObj.FileUpload = [noteDict valueForKey:@"File_upload"];
                                
                            }
                            
                            noteObj.imageData = nil;
                            
                            //*********************
                            //**********************
                            [[DBManager getSharedInstance] importNotesFromServer:noteObj];
                            [notesArray addObject: noteObj.Title];
                        }
                        
                        if ([[dictObj valueForKey:@"cat_info"] isKindOfClass:[NSDictionary class]]) {
                            NSDictionary *catDict = [dictObj valueForKey:@"cat_info"];
                            CategoryObject *catObj = [[CategoryObject alloc] init];
                            catObj.DatabaseID = [[catDict valueForKey:@"DatabaseId"] longLongValue];
                            catObj.CategoryName = [catDict valueForKey:@"category_name"];
                            catObj.CategoryID = [[catDict valueForKey:@"category_id"] longLongValue];
                            catObj.UserID = [[catDict valueForKey:@"userid"] longLongValue];
                            ;
                            [[DBManager getSharedInstance] importCategoriesFromServer:catObj];
                            [categoryArray addObject:catObj.CategoryName];
                            
                        }
                        
                    }
                    
                    //                _previewFilesBtn.hidden = false;
                    //                [AppDelegate showAlertViewWithTitle:@"" Message:@"Notes added successfully"];
                    //[self.navigationController popViewControllerAnimated:YES];
                    
                }
                
                NSMutableArray *updatedNotes = [json  valueForKey:@"updatedata"];
                if (updatedNotes.count > 0) {
                    for (int i=0; i<updatedNotes.count; i++)
                    {
                        NSDictionary *updateObj = [updatedNotes objectAtIndex:i];
                        
                        if ([[updateObj valueForKey:@"notes_info"] isKindOfClass:[NSDictionary class]]) {
                            NSDictionary *noteDict = [updateObj valueForKey:@"notes_info"];
                            NotesObject *noteObj = [[NotesObject alloc] init];
                            noteObj.DatabaseID = [[noteDict valueForKey:@"DatabaseId"] longLongValue];
                            noteObj.NotesID = [[noteDict valueForKey:@"Notes_id"] longLongValue];
                            noteObj.CategoryID = [[noteDict valueForKey:@"category_id"] longLongValue];
                            noteObj.Note = [noteDict valueForKey:@"note"];
                            noteObj.Title = [noteDict valueForKey:@"title"];
                            noteObj.UserID = [[noteDict valueForKey:@"userid"] longLongValue];
                            
                            if ([[noteDict valueForKey:@"File_upload"] isKindOfClass:[NSNull class]] || [[noteDict valueForKey:@"File_upload"] isEqualToString:@""] ){
                                noteObj.FileUpload  = @"";
                            }
                            
                            else {
                                
                                noteObj.FileUpload = [noteDict valueForKey:@"File_upload"];
                                
                            }
                            
                            noteObj.imageData = nil;
                            
                            //*********************
                            //**********************
                            
                        
                              NSString *notes =  noteObj.Note;
                              NSString *tittle = noteObj.Title;
                               
                               notes = [notes stringByReplacingOccurrencesOfString:@"\"" withString:@"~#~"];
                               notes = [notes stringByReplacingOccurrencesOfString:@"\'" withString:@"~!~"];
                               
                               tittle = [tittle stringByReplacingOccurrencesOfString:@"\"" withString:@"~#~"];
                               tittle = [tittle stringByReplacingOccurrencesOfString:@"\'" withString:@"~!~"];

                              // [[DBManager getSharedInstance] updateNotes:[NSString stringWithFormat:@"%lld",obj.NotesID]  forUserID:[NSString stringWithFormat:@"%lld",obj.DatabaseID] notes:notes title:tittle];
                              
                               
                              [[DBManager getSharedInstance] updateNotes:[NSString stringWithFormat:@"%lld",noteObj.NotesID]  forUserID:[NSString stringWithFormat:@"%lld",noteObj.DatabaseID] notes:notes title:tittle withImage:noteObj.imageData withFileUpload:noteObj.FileUpload];
                            
                          //  if (![notesArray containsObject:noteObj.Title]){
                                
                                 [notesArray addObject: noteObj.Title];
                         //   }
                        }
                        
                        if ([[updateObj valueForKey:@"cat_info"] isKindOfClass:[NSDictionary class]]) {
                            NSDictionary *catDict = [updateObj valueForKey:@"cat_info"];
                            CategoryObject *catObj = [[CategoryObject alloc] init];
                            catObj.DatabaseID = [[catDict valueForKey:@"DatabaseId"] longLongValue];
                            catObj.CategoryName = [catDict valueForKey:@"category_name"];
                            catObj.CategoryID = [[catDict valueForKey:@"category_id"] longLongValue];
                            catObj.UserID = [[catDict valueForKey:@"userid"] longLongValue];
                            
                          //  if (![categoryArray containsObject:catObj.CategoryName]){
                                
                                [categoryArray addObject:catObj.CategoryName];
                           // }
   
                        }
                        
                    }
                    
                    //                _previewFilesBtn.hidden = false;
                    //                [AppDelegate showAlertViewWithTitle:@"" Message:@"Notes added successfully"];
                    //[self.navigationController popViewControllerAnimated:YES];
                    
                }
                
                _previewFilesBtn.hidden = false;
                _selectDatabaseTextField.text = @"";
                _selectPathTextField.text = @"";
                _selectStructureTextField.text = @"";
                _selectDelimetersTextField.text = @"";
                _userDefinedDelimeterTextField.text = @"";
                _selectDelimetersTextField.text = @"";
                _duplicateTextField.text  = @"";
                
                [AppDelegate showAlertViewWithTitle:@"" Message:@"Notes added successfully"];
            }
            
            else{
                [AppDelegate showAlertViewWithTitle:@"Network Error" Message:@"Please Check Your Internet Connection."];
                
            }
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppDelegate hideHUDForView:self.view animated:YES];
        [AppDelegate showAlertViewWithTitle:@"Network Error" Message:@"Please Check Your Internet Connection."];
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
    }];
    [op start];
    
    
    
}



#pragma mark- Upload to Google Drive
#pragma mark-


-(void) searchFolder {
    
    [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];

    GTLRDriveQuery_FilesList *query = [GTLRDriveQuery_FilesList query];
    query.pageSize = 1;
    NSString *folderName =  [self.selectPathTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //self.selectPathTextField.text;
    query.q = [NSString stringWithFormat:@"'root' IN parents and name = '%@' and trashed = false", folderName];
    
    //[NSString stringWithFormat:@"fullText contains '%@' and trashed = false", folderName];
    //[NSString stringWithFormat:@"'root' IN parents and name = '%@' and trashed = false", folderName];
    //[NSString stringWithFormat:@"name contains '%@'", folderName];
    
    [driveService executeQuery:query completionHandler:^(GTLRServiceTicket *ticket,
                                                         GTLRDrive_FileList *file,
                                                         NSError *error) {
        if (error == nil) {
            NSLog(@"File ID %@", file.files.firstObject.identifier);
            
            if ([file.files.firstObject.identifier length] > 0) {
                
                folderID = file.files.firstObject.identifier;
                [self searchFolders:folderID];
                
            }
            
            else {
                
                [AppDelegate hideHUDForView:self.view animated:YES];
                 [AppDelegate showAlertViewWithTitle:@" " Message:[NSString stringWithFormat:@" Google Drive Folder Not Found!"]];
                
            }
            
            
        } else {
            NSLog(@"An error occurred: %@", error);
            [AppDelegate hideHUDForView:self.view animated:YES];
            [AppDelegate showAlertViewWithTitle:@" " Message:[NSString stringWithFormat:@"%@", error.localizedDescription]];
        }
    }];
}

-(void) searchFolders:(NSString *)fileId {
    
     GTLRDriveQuery_FilesList *query = [GTLRDriveQuery_FilesList query];
    query.q = [NSString stringWithFormat:@"'%@' IN parents", fileId];
    // root is for root folder replace it with folder identifier in case to fetch any specific folder
    [driveService executeQuery:query completionHandler:^(GTLRServiceTicket *ticket,
                                                         GTLRDrive_FileList *files,
                                                         NSError *error) {
        if (error == nil)
        {
           
            driveFiles = [files valueForKey: @"files"];
            // Now you have all files of root folder
            NSLog(@"File is %@", driveFiles);
            NSLog(@"%lu", (unsigned long)driveFiles.count);

            
            if ((driveFiles.count > 0) && (driveFiles != nil)) {
            
            for (int i = 0; i<=driveFiles.count-1; i++) {
                GTLRDrive_File * file = [driveFiles objectAtIndex:i];
                fileID = file.identifier;
                fileName = file.name;
                NSString *mimeType = file.mimeType;
                if ([mimeType hasPrefix:@"text"]) {
                    [filesImportedNameArray addObject:fileName];
                    [filesImportedIDArray addObject:fileID];

                // [self getFiles:fileID fileName:fileName];
                } else {
                    
                     globalCount = globalCount + 1;
                     [filesNameArray addObject:fileName];
                }
            }
                
                if (filesImportedIDArray.count > 0) {
                    for (int i = 0; i<=filesImportedIDArray.count-1; i++) {
                        
                        [self getFiles:[filesImportedIDArray objectAtIndex:i] fileName:[filesImportedNameArray objectAtIndex:i]];
                        
                    }
                
                } else  {
                    
                    
                    //if (globalCount == driveFiles.count) {
                        
                        [self addNewCategory];
                    
                    // }
                    
   
                }
               
            
                
            } else {
                
                 [AppDelegate hideHUDForView:self.view animated:YES];
                 [AppDelegate showAlertViewWithTitle:@"" Message:@"Files Not Found"];
                
            }
       }
        else
        {
            NSLog(@"An error occurred: %@", error);
            [AppDelegate hideHUDForView:self.view animated:YES];
        }
    }];
}

-(void) getContent {
 
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"myList" ofType:@"text/rtf"];
    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];
    
    if (error)
        NSLog(@"Error reading file: %@", error.localizedDescription);
    
    // maybe for debugging...
    NSLog(@"contents: %@", fileContents);
    
    NSArray *listArray = [fileContents componentsSeparatedByString:@"\n"];
    NSLog(@"items = %d", [listArray count]);
}


- (void) getFiles:(NSString *)file fileName:(NSString *)fileName {
    GTLRQuery *query = [GTLRDriveQuery_FilesGet queryForMediaWithFileId:file];
  // queryTicket can be used to track the status of the request.
    
    [driveService executeQuery:query completionHandler:^(GTLRServiceTicket *ticket, GTLRDataObject *file,
                            NSError *error) {
        if (error == nil) {
            
            if ([file.contentType  isEqual: @"text/plain"]) {
                
                NSString *string = [[NSString alloc] initWithData:file.data encoding:NSUTF8StringEncoding];
                NSLog(@"%@", string);
                
                [self getLines:string fileName:fileName];
                
            } else if ([file.contentType  isEqual: @"text/rtf"]) {
                
                NSString *string = [[NSString alloc] initWithData:file.data encoding:NSUTF8StringEncoding];
                NSLog(@"%@", string);
                
                NSAttributedString *attributedStringWithRtf = [[NSAttributedString alloc]   initWithData:file.data  options:@{NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType} documentAttributes:nil error:nil];
                NSLog(@"%@", attributedStringWithRtf);
                
                NSLog(@"%@",attributedStringWithRtf.string);
                NSString *str = attributedStringWithRtf.string;
                NSLog(@"%@",str);
                //                [filesDataArray addObject:str];
                //                 NSLog(@"%@", filesDataArray);
                //                for (int i = 0; i<=filesDataArray.count-1; i++) {
                //                    NSString * file = [filesDataArray objectAtIndex:i];
                //                [self getLines:file fileName:fileName];
                //
                [self getLines:str fileName:fileName];
            } else {
 
                NSString *string = [[NSString alloc] initWithData:file.data encoding:NSUTF8StringEncoding];
                NSLog(@"%@", string);
                
                NSAttributedString *attributedStringWithRtf = [[NSAttributedString alloc]   initWithData:file.data  options:@{NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType} documentAttributes:nil error:nil];
                NSLog(@"%@", attributedStringWithRtf);
                
                NSLog(@"%@",attributedStringWithRtf.string);
                NSString *str = attributedStringWithRtf.string;
                NSLog(@"%@",str);

                [self getLines:str fileName:fileName];
                
                
                
                
                
                //                globalCount = globalCount + 1;
                //                [filesNameArray addObject:fileName];
                //
                //                if (globalCount == driveFiles.count) {
                //
                //                    [self addNewCategory];
                //                    globalCount = 0;
                //
                //                }
                
                
                
            }
            // }
            
            
        } else {
                NSLog(@"An error occurred: %@", error);
                [AppDelegate hideHUDForView:self.view animated:YES];
            }
        }];
}


-(NSString *)convertHTML:(NSString *)html {
    
    NSScanner *myScanner;
    NSString *text = nil;
    myScanner = [NSScanner scannerWithString:html];
    
    while ([myScanner isAtEnd] == NO) {
        
        [myScanner scanUpToString:@"<" intoString:NULL] ;
        
        [myScanner scanUpToString:@">" intoString:&text] ;
        
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
    }
    //
    html = [html stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return html;
}

-(void)getLines: (NSString *)content fileName:(NSString *)fileName {
    // split into lines
    globalCount = globalCount + 1;
    if( _userDefinedDelimeterTextField.isHidden == true ) {
        delimeter = _selectDelimetersTextField.text;
        
    } else {
        delimeter = _userDefinedDelimeterTextField.text;
        
    }
    NSArray* lines = [content componentsSeparatedByString:@"\n"];
    
    if ((lines.count > 2) && (lines != nil)) {
        
        // return the first
        
        if ([_selectStructureTextField.text isEqual: @"First Row By Title"]) {
            
            title =  lines[0];
            category =  lines[1];
            
        } else if ([_selectStructureTextField.text isEqual: @"First Row By Category" ]) {
            
            category =  lines[0];
            title =  lines[1];
            
        }
        
        NSMutableString *note = [[NSMutableString alloc] init];
        
        for (int i = 2; i<=lines.count-1; i++) {
            NSString * str = [lines objectAtIndex:i];
            [note appendString:str];
            [note appendString: @"\n"];
        }
        
        
        NSArray *categoryLines;
        
        
        if (([category rangeOfString:delimeter].location != NSNotFound) && [_selectStructureTextField.text isEqual: @"First Row By Category" ]) {
            
            
            categoryLines =  [category componentsSeparatedByString:delimeter];
            
            for (int i = 0; i<categoryLines.count; i++) {
                
                GoogleNotesObject *objc = [[GoogleNotesObject alloc] init];
                objc.GoogleTitle = title;
                objc.GoogleCategory = categoryLines[i];
                objc.GoogleNotes = note;
                
                [googleNotesArray addObject:objc];
                //NSLog(@"%@", googleNoteObj);
               
                
                
            }
            
             NSLog(@"%@", googleNotesArray);
             NSLog(@"*******%d",globalCount);
            
            
        } else if ([_selectStructureTextField.text isEqual: @"First Row By Title" ]) {
        
        GoogleNotesObject *objc = [[GoogleNotesObject alloc] init];
        objc.GoogleTitle = title;
        objc.GoogleCategory = category;
        objc.GoogleNotes = note;
        
        [googleNotesArray addObject:objc];
        //NSLog(@"%@", googleNoteObj);
        NSLog(@"%@", googleNotesArray);
       
        
        } else {
            
            [filesNameArray addObject:fileName];
            NSLog(@"%@", filesNameArray);
        }
     
        
    } else {
        
        [filesNameArray addObject:fileName];
        NSLog(@"%@", filesNameArray);
        
    }
    // NSLog(@"%@", globalCount);
    
    NSLog(@"*******%d",globalCount);
    if (globalCount == driveFiles.count) {
        
        [self addNewCategory];
        globalCount = 0;
        
    }
    
}


-(BOOL)doesString:(NSString *)string containCharacter:(char)character
{
    return [string rangeOfString:[NSString stringWithFormat:@"%c",character]].location != NSNotFound;
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
        NSString *accessToken = user.authentication.accessToken; //Use this
        NSLog(@"%@userId and token", userId, accessToken);
        [[NSUserDefaults standardUserDefaults]setValue:accessToken forKey:@"googleAccessToken"];
        [[NSNotificationCenter defaultCenter] postNotificationName:
         @"HideGoogleSignIn" object:user userInfo:nil];

        NSLog(@"%@", user.grantedScopes);
        driveService.authorizer = user.authentication.fetcherAuthorizer;
        [GIDSignIn sharedInstance] .scopes = [NSArray arrayWithObjects:kGTLRAuthScopeDriveFile,kGTLRAuthScopeDrive, nil ];
        NSLog(@"%@", user.grantedScopes);


        [[NSUserDefaults standardUserDefaults] synchronize];


    }
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
