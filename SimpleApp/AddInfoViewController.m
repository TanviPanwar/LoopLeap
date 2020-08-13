//
//  AddItemViewController.m
//  SimpleApp
//
//  Created by IOS1 on 1/27/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import "AddInfoViewController.h"
#import "AppDelegate.h"
#import "HtmlTextDescription.h"
#import <GoogleSignIn/GoogleSignIn.h>
#import <GoogleAPIClientForREST/GoogleAPIClientForREST-umbrella.h>
#import <GTMSessionFetcher/GTMSessionFetcher.h>

#import <AppAuth/AppAuth.h>
#import <GTMAppAuth/GTMAppAuth.h>
//#import "AppDelegate.h"


@interface AddInfoViewController ()<UITextFieldDelegate,UITextViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource , UIImagePickerControllerDelegate, UINavigationControllerDelegate , UIActionSheetDelegate >
{
    
    NSInteger selectedTag;
    NSString *tableName;
    UITextField *activeTextField;
    NSString *db_name;
    NSString *db_ID;
    NSString * owner_ID ,*notes_str;
    NSMutableArray *categoryArr;
    GTLRDriveService *driveService;
    NSString *mimiType;
    NSData *data;
    NSURL *imageUrl;
    NSString *folderID;
    NSString *folderName;
    NSString *defaultFolderName;
    NSString *forSharedId;
    NSString *shareLink;
    NSData *dataImage;

   
    AppDelegate *appDelegate;
    UIImagePickerController *imagePicker;
}

@property (strong, nonatomic) IBOutlet UITextView *notes;
@property(nonatomic, nullable) GTMAppAuthFetcherAuthorization *authorization;

@property (weak, nonatomic) IBOutlet GIDSignInButton *signinbtn;


//@property (strong, nonatomic) IBOutlet RichTextEditor *notes;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIView *pickerView;
@property (strong, nonatomic) IBOutlet UITextField *selectedCategory;
@property (strong, nonatomic) IBOutlet UITextField *categoryNew;
@property (strong, nonatomic) IBOutlet UITextField *record_title;
//@property (strong, nonatomic) IBOutlet UITextView *notes;
@property (strong, nonatomic) IBOutlet UIButton *saveBtn;
@property (strong, nonatomic) IBOutlet UIPickerView *picker;
@property (strong, nonatomic) IBOutlet UILabel *orLbl;


@end

@implementation AddInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    defaultFolderName = @"SimpleApp";
    [_signinbtn setHidden:YES];
    
    NSString *str =  [[NSUserDefaults standardUserDefaults]valueForKey:@"SelectedCategory"];
    if (str.length != 0) {
        str = [str stringByReplacingOccurrencesOfString:@"~#~" withString:@"\""];
        str = [str stringByReplacingOccurrencesOfString:@"~!~" withString:@"\'"];
        self.selectedCategory.text = str;
    }
    driveService = [[GTLRDriveService alloc] init];
    //[GIDSignIn sharedInstance].delegate = self;
    
  //  [GIDSignIn sharedInstance].uiDelegate = self;
    //[GIDSignIn.sharedInstance scopes:kGTLRAuthScopeDriveFile];
// [[GIDSignIn sharedInstance] signInSilently];
    
    
//    if(GIDSignIn.sharedInstance.hasAuthInKeychain)
//    {
//        //loggedIn
//        NSLog(@"%@",  @"logged in");
//         [_signinbtn setHidden:YES];
//        NSLog(@"%@",GIDSignIn.sharedInstance.currentUser.userID );
//        driveService.authorizer = GIDSignIn.sharedInstance.currentUser.authentication.fetcherAuthorizer;
//
//    } else {
//
//          NSLog(@"%@",  @"logged out");
//
//        NSLog(@"%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentStorageType"]);
//        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentStorageType"] isEqualToString:@"Google Drive"] ) {
//
//            NSString *loginStatus;
//            loginStatus = [[NSUserDefaults standardUserDefaults] valueForKey:@"loginStatus"];
//
//            if([loginStatus  isEqual: @"login"]) {
//
//                [_signinbtn setHidden:YES];
//
//            }
//
//            else {
//
//               [_signinbtn setHidden:FALSE];
//
//            }
//
//            [GIDSignIn sharedInstance].delegate = self;
//            [GIDSignIn sharedInstance].uiDelegate = self;
//            [GIDSignIn sharedInstance] .scopes = [NSArray arrayWithObjects:kGTLRAuthScopeDriveFile,kGTLRAuthScopeDrive, nil ];
//            [[GIDSignIn sharedInstance] signInSilently];
//
//        }
//
//        else {
//
//            [_signinbtn setHidden:YES];
//        }
//
//    }
 

    // Do any additional setup after loading the view.
    self.title = self.Database;
   
    _notes.delegate = self;
   
    appDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    tableName=RecordTable;
   
    self.selectedCategory.tag=1;
    self.categoryNew.tag=2;
    self.record_title.tag=3;
    [self fetchCategoriesUsingDB:self.DatabaseID];
   
//    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hidePickerAndKeyboard)];
//    tap.numberOfTapsRequired=1;
//    [self.view addGestureRecognizer:tap];
    
   
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideButton:)
                                                 name:@"HideGoogleSignIn" object:nil];
}

- (void)hideButton:(NSNotification *)note {
    NSLog(@"Received Notification - Someone seems to have logged in");
    NSLog(@"%@", note.object);
    GIDGoogleUser *user =  note.object;
    [_signinbtn setHidden:YES];

  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    _notes.userInteractionEnabled = YES;
    NSString *htmlDes =  [[NSUserDefaults standardUserDefaults]valueForKey:@"HTMLTEXT"];
    NSString *simpleDes =  [[NSUserDefaults standardUserDefaults]valueForKey:@"SIMPLETEXT"];
   
    NSLog(@"%@",htmlDes);
    if (simpleDes.length == 0) {
        _notes.textColor = [UIColor lightGrayColor];
        [_notes setText:@"Description"];
    }
    else{
        NSAttributedString *attributedString = [[NSAttributedString alloc]
                                                initWithData: [htmlDes dataUsingEncoding:NSUnicodeStringEncoding]
                                                options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                                                documentAttributes: nil
                                                error: nil
                                                ];
        _notes.attributedText = attributedString;
        
      
        
        //_notes.textColor = [UIColor blackColor];
    }
      self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(SaveRecord)];
    
    
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
-(void)hidePickerAndKeyboard
{
    [self hidePickerView];
    [self hideKeyboard];
}
-(void)hideKeyboard
{
    [self.notes resignFirstResponder];
    [activeTextField resignFirstResponder];
}
-(void)SaveRecord {
    [self hideKeyboard];
    [self hidePickerView];
    NSString *record,*notes;
    // category_name=[category_name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    record=[self.record_title.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    notes = self.notes.text;
    //    notes=[self.notes.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    // notes = self.notes.htmlString;
    if( self.selectedCategory.text.length == 0 && self.categoryNew.text.length == 0)
    {
        [AppDelegate showAlertViewWithTitle:nil Message:@"Please Fill Category."];
    }
    else if(!record.length){
        [AppDelegate showAlertViewWithTitle:nil Message:@"Please Fill Title."];
    }else if(!notes.length || [notes isEqualToString:@"Description"]){
        [AppDelegate showAlertViewWithTitle:nil Message:@"Please Fill Description."];
    }
    
    else{
        
        NSLog(@"%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentStorageType"]);
        if  (_imageView.image != nil && [[[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentStorageType"] isEqualToString:@"Google Drive"]) {
            
            
       [self searchFolder];
        //[self uploadFileURL:imageUrl mimeType:mimiType];
            
        }

        else {
        
           [self addNewCategory];
            
        }
        
    }
}

- (IBAction)save:(id)sender {
   
    
    
    
}
-(IBAction)AddActionSheet
{
    //    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"Add Photo From" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo",@"Gallery",@"Remove Photo", nil];
    //
    //    popupQuery.actionSheetStyle = UIActionSheetStyleDefault;
    //
    //    [popupQuery showInView:self.view];
    

}
                                                                                                                

- (IBAction)browse_Action:(id)sender {
    [self.view endEditing:true];
    
    
    
    if(GIDSignIn.sharedInstance.hasAuthInKeychain)
    {
        //loggedIn
        NSLog(@"%@",  @"logged in");
        [_signinbtn setHidden:YES];
        NSLog(@"%@",GIDSignIn.sharedInstance.currentUser.userID );
        driveService.authorizer = GIDSignIn.sharedInstance.currentUser.authentication.fetcherAuthorizer;
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Add Photo From"
                                                                                 message:@""
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"Take Photo"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction *action) {
                                                                    [self performSelector:@selector(camera)];
                                                                    
                                                                }];
        UIAlertAction *galleryAction = [UIAlertAction actionWithTitle:@"Gallery"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                                  [self performSelector:@selector(photoGallery)];
                                                                  
                                                              }];
        UIAlertAction *removePhotoAction = [UIAlertAction actionWithTitle:@"Remove Photo"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action) {
                                                                      _imageView.image = nil;
                                                                      
                                                                  }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        
        [alertController addAction:takePhotoAction];
        [alertController addAction:galleryAction];
        [alertController addAction:removePhotoAction];
        [alertController addAction:cancelAction];
        
        
        [self presentViewController:alertController animated:YES completion:nil];
        [self setModalPresentationStyle:UIModalPresentationPopover];
        [alertController.popoverPresentationController setSourceView:sender];
        
    }
    
    else {
        
        NSLog(@"%@",  @"logged out");
        
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentStorageType"] isEqualToString:@"Google Drive"] ) {
            
            
//            NSString *loginStatus;
//            loginStatus = [[NSUserDefaults standardUserDefaults] valueForKey:@"loginStatus"];
//
//            if([loginStatus  isEqual: @"login"]) {
//
//                [_signinbtn setHidden:YES];
//
//            }
//
//            else {
            
                [_signinbtn setHidden:FALSE];
                [AppDelegate showAlertViewWithTitle:@" " Message:@"Please SignIn your Google Account to upload your files to Google Drive"];
           // }
            
            
            
            [GIDSignIn sharedInstance].delegate = self;
            [GIDSignIn sharedInstance].uiDelegate = self;
            [GIDSignIn sharedInstance] .scopes = [NSArray arrayWithObjects:kGTLRAuthScopeDriveFile,kGTLRAuthScopeDrive, nil ];
          //  [[GIDSignIn sharedInstance] signInSilently];
            
            
//            if(GIDSignIn.sharedInstance.hasAuthInKeychain) {
//
//                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Add Photo From"
//                                                                                         message:@""
//                                                                                  preferredStyle:UIAlertControllerStyleActionSheet];
//
//                UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"Take Photo"
//                                                                          style:UIAlertActionStyleDefault
//                                                                        handler:^(UIAlertAction *action) {
//                                                                            [self performSelector:@selector(camera)];
//
//                                                                        }];
//                UIAlertAction *galleryAction = [UIAlertAction actionWithTitle:@"Gallery"
//                                                                        style:UIAlertActionStyleDefault
//                                                                      handler:^(UIAlertAction *action) {
//                                                                          [self performSelector:@selector(photoGallery)];
//
//                                                                      }];
//                UIAlertAction *removePhotoAction = [UIAlertAction actionWithTitle:@"Remove Photo"
//                                                                            style:UIAlertActionStyleDefault
//                                                                          handler:^(UIAlertAction *action) {
//                                                                              _imageView.image = nil;
//
//                                                                          }];
//                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
//                                                                       style:UIAlertActionStyleCancel
//                                                                     handler:nil];
//
//                [alertController addAction:takePhotoAction];
//                [alertController addAction:galleryAction];
//                [alertController addAction:removePhotoAction];
//                [alertController addAction:cancelAction];
//
//
//                [self presentViewController:alertController animated:YES completion:nil];
//                [self setModalPresentationStyle:UIModalPresentationPopover];
//                [alertController.popoverPresentationController setSourceView:sender];
//
//            }
            
        }
        
        else {
            
            [_signinbtn setHidden:YES];
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Add Photo From"
                                                                                     message:@""
                                                                              preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"Take Photo"
                                                                      style:UIAlertActionStyleDefault
                                                                    handler:^(UIAlertAction *action) {
                                                                        [self performSelector:@selector(camera)];
                                                                        
                                                                    }];
            UIAlertAction *galleryAction = [UIAlertAction actionWithTitle:@"Gallery"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action) {
                                                                      [self performSelector:@selector(photoGallery)];
                                                                      
                                                                  }];
            UIAlertAction *removePhotoAction = [UIAlertAction actionWithTitle:@"Remove Photo"
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction *action) {
                                                                          _imageView.image = nil;
                                                                          
                                                                      }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:nil];
            
            [alertController addAction:takePhotoAction];
            [alertController addAction:galleryAction];
            [alertController addAction:removePhotoAction];
            [alertController addAction:cancelAction];
            
            
            [self presentViewController:alertController animated:YES completion:nil];
            [self setModalPresentationStyle:UIModalPresentationPopover];
            [alertController.popoverPresentationController setSourceView:sender];
            
        }
        
    }
    

}

- (IBAction)arrowBtnAction:(id)sender {
    if(categoryArr.count) {
        selectedTag = 1;
        [_picker reloadAllComponents];
        [self showPickerView];
    }
}


#pragma mark UIAction Sheet Delegate Methods
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    
    if (buttonIndex == 0) {
        
        [self performSelector:@selector(camera)];
        
        
    } else if (buttonIndex == 1) {
        
        [self performSelector:@selector(photoGallery)];
        
    }
    else
    {
        _imageView.image = nil;
    }
}


-(void)photoGallery
{
    [self selectPhotos];
}

- (void)selectPhotos

{   [self dismissViewControllerAnimated:false completion:nil];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = (id)self;
    [self presentViewController:picker animated:YES completion:nil];
    
    
}

-(void)camera
{
    [self dismissViewControllerAnimated:false completion:nil];
    imagePicker = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        // Set source to the camera
        imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
        
        imagePicker.allowsEditing = NO;
        
        // Delegate is self
        imagePicker.delegate = (id)self;
        
        // Show image picker
        
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    }
    else {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"No Camera Device Found" message:nil delegate:self
                                            cancelButtonTitle:@"Ok" otherButtonTitles:nil ];
        [alert show];
        
    }
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    _imageView.image = chosenImage;
    
    dataImage = UIImageJPEGRepresentation(chosenImage, 0.5);
    
    
    imageUrl = info[UIImagePickerControllerImageURL];
    
    if ([imageUrl.absoluteString hasSuffix:@"jpg"]) {
        
        mimiType = @"jpg";
        
    }
    
   else  if ([imageUrl.absoluteString hasSuffix:@"png"]) {
        
        mimiType = @"png";
        
    }
    
   else  if ([imageUrl.absoluteString hasSuffix:@"jpeg"]) {
       
       mimiType = @"jpeg";
       
   }
    
   else  if ([imageUrl.absoluteString hasSuffix:@"gif"]) {
       
       mimiType = @"gif";
       
   }
   
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}


-(void)showPickerView {
    [self hideKeyboard];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    self.pickerView.frame = CGRectMake(0, self.view.frame.size.height-self.pickerView.frame.size.height, self.pickerView.frame.size.width, self.pickerView.frame.size.height);
    [UIView commitAnimations];
}

-(void)hidePickerView {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    self.pickerView.frame = CGRectMake(0, self.view.frame.size.height, self.pickerView.frame.size.width , self.pickerView.frame.size.height);
    [UIView commitAnimations];
}

#pragma mark- UITextFieldDelegate
#pragma mark-


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    selectedTag = textField.tag;
   
    
    if(textField.tag==1)
    {
        if (categoryArr.count > 0) {
            [_picker reloadAllComponents];
            [self showPickerView];
        }
        return NO;
    }
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    activeTextField=textField;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if(textField.tag==2 )
    {
        if (textField.text.length > 0) {
            //            category_name=textField.text;
            self.selectedCategory.text=@"";
        }
        
    }
}

#pragma mark- UITextViewDelegate
#pragma mark-
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.view endEditing:YES];
    NSString *htmlDes =  [[NSUserDefaults standardUserDefaults]valueForKey:@"HTMLTEXT"];
    HtmlTextDescription *VC =  [self.storyboard instantiateViewControllerWithIdentifier:@"HtmlTextDescription"];
    textView.userInteractionEnabled = NO;
    VC.filledText = htmlDes;
   // [self presentViewController:VC animated:YES completion:nil];
    
    [self.navigationController pushViewController:VC animated:NO];
//    if([textView.textColor isEqual:[UIColor lightGrayColor]]){
//        textView.textColor = [UIColor blackColor];
//        textView.text = @"";
//    }
//    CGRect frame=self.view.frame;
//    frame.origin.y=-120;
//    [self.view setFrame:frame];
}



-(void)textViewDidEndEditing:(UITextView *)textView
{
//    if([textView.text isEqual:@""]){
//        textView.textColor = [UIColor lightGrayColor];
//        [textView setText:@"Description"];
//    }
//    CGRect frame=self.view.frame;
//    frame.origin.y=0;
//    [self.view setFrame:frame];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if([textView.textColor isEqual:[UIColor lightGrayColor]]){
        textView.textColor = [UIColor blackColor];
        textView.text = @"";
    }
    
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    //    if(_notes.text.length == 0){
    //        _notes.textColor = [UIColor lightGrayColor];
    //        _notes.text = @"Description";
    //        [_notes resignFirstResponder];
    //    }
}
- (IBAction)done{
    [self hidePickerView];
    NSInteger row= [self.picker selectedRowInComponent:0];
    CategoryObject *catObj =  [categoryArr objectAtIndex:row];
    self.selectedCategory.text = catObj.CategoryName;
    //self.CategoryID  = [NSString stringWithFormat:@"%lld", catObj.CategoryID];
    self.categoryNew.text = @"";
}

#pragma mark- UIPickerViewDelegate
#pragma mark-
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return categoryArr.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
        CategoryObject *obj = categoryArr[row];
        return obj.CategoryName;
}

-(void)addNewCategory{
    [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
    NSMutableDictionary *userDetail = [[NSMutableDictionary alloc]init];
    [userDetail setValue:self.DatabaseID forKey:kCategory];
    if (_categoryNew.text.length == 0){
        self.selectedCategory.text = [self.selectedCategory.text stringByReplacingOccurrencesOfString:@"\"" withString:@"~#~"];
        self.selectedCategory.text = [self.selectedCategory.text stringByReplacingOccurrencesOfString:@"\'" withString:@"~!~"];
        [userDetail setValue:self.selectedCategory.text forKey:kNewCategory];
        [[NSUserDefaults standardUserDefaults]setValue:self.selectedCategory.text forKey:@"SelectedCategory"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }else {
        NSString *strCateName = _categoryNew.text;
        strCateName = [strCateName stringByReplacingOccurrencesOfString:@"\"" withString:@"~#~"];
        strCateName = [strCateName stringByReplacingOccurrencesOfString:@"\'" withString:@"~!~"];
        [[NSUserDefaults standardUserDefaults]setValue:strCateName forKey:@"SelectedCategory"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        [userDetail setValue:strCateName  forKey:kNewCategory];
    }
    
    [userDetail setValue:kAddCategory forKey:kDefault];
    
    [userDetail setValue:[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID] forKey:kLoogedInUserID];
    
    
    //noteObj.Note =  [noteObj.Note stringByReplacingOccurrencesOfString:@"\"" withString:@"~#~"];
    NSString *strTittleName = _record_title.text;
    strTittleName = [strTittleName stringByReplacingOccurrencesOfString:@"\"" withString:@"~#~"];
    strTittleName = [strTittleName stringByReplacingOccurrencesOfString:@"\'" withString:@"~!~"];
    
    NSString *htmlDes =  [[NSUserDefaults standardUserDefaults]valueForKey:@"HTMLTEXT"];
    //NSString *simpleDes =  [[NSUserDefaults standardUserDefaults]valueForKey:@"SIMPLETEXT"];
    
   
        
    
   
    
    NSString *strNote = htmlDes;
    strNote = [strNote stringByReplacingOccurrencesOfString:@"\"" withString:@"~#~"];
    strNote = [strNote stringByReplacingOccurrencesOfString:@"\'" withString:@"~!~"];
   
    [userDetail setValue:strTittleName forKey:kTitle];
    [userDetail setValue:strNote forKey:kDescription];
    
    NSLog(@"UsetDetail Dict%@", userDetail);
    //    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
   
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:HostUrl]];
    
    if (_imageView.image != nil) {
        imageData = UIImageJPEGRepresentation(_imageView.image, 0.5);
    }
    
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    //_imageView.image != nil &&
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentStorageType"] isEqualToString:@"Google Drive"] ) {
        
        
        if (_imageView.image == nil) {
            
            shareLink = @"";
        }
        NSLog(@"%@", shareLink);
        [userDetail setValue:shareLink forKey:@"drive_path"];
        
    }
    
    AFHTTPRequestOperation *op = [manager POST:HostUrl parameters:userDetail constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
       
         NSLog(@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentStorageType"]);
      if (_imageView.image != nil && [[[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentStorageType"] isEqualToString:@"Local Storage"] ) {
            
            [formData appendPartWithFileData:imageData name:@"fileupload" fileName:@"photo.jpg" mimeType:@"image/jpeg"];
            
        }
        
        else if (_imageView.image != nil && [[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentStorageType"] == nil ) {
            
            [formData appendPartWithFileData:imageData name:@"fileupload" fileName:@"photo.jpg" mimeType:@"image/jpeg"];
            
        }
        
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
                
                NSDictionary *dictResult = [json  valueForKey:@"result"];
                if ([[dictResult valueForKey:@"notes_info"] isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *noteDict = [dictResult valueForKey:@"notes_info"];
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
                    
                    //******* Change ********
                    //**********************
                    //noteObj.FileUpload = @"";
                   // NSString *strData = [[NSString alloc] initWithData:imageData encoding:NSUTF8StringEncoding];
                 
                   // NSString* strData = [[NSString alloc] initWithData:imageData encoding:NSUTF8StringEncoding];
                    
                    
                    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentStorageType"] isEqualToString:@"Google Drive"] ) {
                        
                        noteObj.imageData = nil;
                        
                    }
                    
                    else {
                        
                        noteObj.FileUpload  = @"";
                        if (_imageView.image != nil  && [[[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentStorageType"] isEqualToString:@"Local Storage"] ) {
                            noteObj.imageData = imageData;
                        }
                        else if (_imageView.image != nil  && [[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentStorageType"] == nil ) {
                            noteObj.imageData = imageData;
                        }
                        else{
                            noteObj.imageData = nil;
                        }
                        
                    }
                    //*********************
                    //**********************
                    [[DBManager getSharedInstance] importNotesFromServer:noteObj];
                }
                
                if ([[dictResult valueForKey:@"cat_info"] isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *catDict = [dictResult valueForKey:@"cat_info"];
                    CategoryObject *catObj = [[CategoryObject alloc] init];
                    catObj.DatabaseID = [[catDict valueForKey:@"DatabaseId"] longLongValue];
                    catObj.CategoryName = [catDict valueForKey:@"category_name"];
                    catObj.CategoryID = [[catDict valueForKey:@"category_id"] longLongValue];
                    catObj.UserID = [[catDict valueForKey:@"userid"] longLongValue];
                    ;
                    [[DBManager getSharedInstance] importCategoriesFromServer:catObj];
                }
                
                
                if (_imageView.image != nil && [[[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentStorageType"] isEqualToString:@"Local Storage"] ) {
                    
                     [AppDelegate showAlertViewWithTitle:@"" Message:@"File uploaded successfully"];
                }
                
                else if (_imageView.image == nil && [[[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentStorageType"] isEqualToString:@"Local Storage"] ) {
                    
                    [AppDelegate showAlertViewWithTitle:@"" Message:@"Notes added successfully"];
                    
                }
                
                else if (_imageView.image == nil && [[[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentStorageType"] isEqualToString:@"Google Drive"] ) {
                    
                    [AppDelegate showAlertViewWithTitle:@"" Message:@"Notes added successfully"];
                    
                }
                
                [self.navigationController popViewControllerAnimated:YES];
                
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

-(void)fetchCategoriesUsingDB : (NSString*)DbId{
    categoryArr =  [[NSMutableArray alloc]init];
    categoryArr =  [[DBManager getSharedInstance]getDataFromUserCategories:DbId];
    
    
}

#pragma mark- Upload to Google Drive
#pragma mark-

-(void) searchFolder {
    
    [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
    // GTLRDriveQuery_FilesCreate *query;
    GTLRDriveQuery_FilesList *query = [GTLRDriveQuery_FilesList query];
    query.pageSize = 1;
    query.q = [NSString stringWithFormat:@"name contains '%@'", defaultFolderName];
    [driveService executeQuery:query completionHandler:^(GTLRServiceTicket *ticket,
                                                         GTLRDrive_FileList *file,
                                                         NSError *error) {
        if (error == nil) {
            NSLog(@"File ID %@", file.files.firstObject.identifier);
            
            if ([file.files.firstObject.identifier length] > 0) {
                
                folderID = file.files.firstObject.identifier;
                [self uploadFileURL:dataImage mimeType:mimiType];
                
            }
            
            else {
               
                [self createAFolder];

            }
            
            
        } else {
            NSLog(@"An error occurred: %@", error);
             [AppDelegate hideHUDForView:self.view animated:YES];
             [AppDelegate showAlertViewWithTitle:@" " Message:[NSString stringWithFormat:@"%@", error.localizedDescription]];
        }
    }];
}

- (void)createAFolder {
    
    GTLRDrive_File *metadata = [GTLRDrive_File object];
    metadata.name = defaultFolderName;
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
             if ([file.identifier length] > 0) {
            folderID = file.identifier;
            [self uploadFileURL:dataImage mimeType:mimiType];
             }
            
             else {
                 
                 [AppDelegate hideHUDForView:self.view animated:YES];
                  [AppDelegate showAlertViewWithTitle:@" " Message:@"Folder ID is not created"];
             }
            
        } else {
            NSLog(@"An error occurred: %@", error);
            [AppDelegate hideHUDForView:self.view animated:YES];
             [AppDelegate showAlertViewWithTitle:@" " Message:[NSString stringWithFormat:@"%@", error.localizedDescription]];
        }
    }];
    
}

- (void)uploadFileURL:(NSData *)fileToUploaData mimeType: (NSString*)mimeType {
    
    
   // NSString *fileStr = fileToUploadURL.absoluteString;
    
   // NSData *fileData =   [NSData dataWithContentsOfURL:[NSURL URLWithString:fileStr]];
    
    NSLog(@"%@", dataImage);
    
    GTLRDrive_File *metadata = [GTLRDrive_File object];
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    // NSTimeInterval is defined as double
    NSNumber *timeStampObj = [NSNumber numberWithInt: timeStamp];
    metadata.name =  [NSString stringWithFormat:@"photo%@.jpg", timeStampObj];
    metadata.parents = [NSArray arrayWithObject:folderID];
    
    
    GTLRUploadParameters *uploadParameters = [GTLRUploadParameters uploadParametersWithData:fileToUploaData
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
            if ([file.identifier length] > 0) {
                
                 forSharedId = file.identifier;
                [self getSharedLink];
            }
            
            else {
                
                [AppDelegate hideHUDForView:self.view animated:YES];
                [AppDelegate showAlertViewWithTitle:@" " Message:@"File ID is not created"];
   
            }
        } else {
            NSLog(@"An error occurred: %@", error);
            [AppDelegate hideHUDForView:self.view animated:YES];
             [AppDelegate showAlertViewWithTitle:@" " Message:[NSString stringWithFormat:@"%@", error.localizedDescription]];
        }
    }];
    
    
}

-(void) getSharedLink {
  
    GTLRDrive_Permission *userPermssions = [GTLRDrive_Permission object];
    userPermssions.type = @"anyone";
    userPermssions.role = @"reader";
    
    GTLRDriveQuery_PermissionsCreate *query = [GTLRDriveQuery_PermissionsCreate queryWithObject:userPermssions fileId:forSharedId];
    query.fields = @"id";
    [driveService executeQuery:query completionHandler:^(GTLRServiceTicket *ticket, GTLRDrive_File *file, NSError *error) {
        if (error == nil) {

             NSLog(@"File ID %@", file.identifier);
            
    shareLink = [NSString stringWithFormat:@"https://drive.google.com/uc?export=view&id=%@",forSharedId];
          //  https://drive.google.com/uc?export=view&id=1p_EqLftJHEJufkZVJIg_c97Wf1lZEd_r
            // https://drive.google.com/open?id=
            NSLog(@"%@", shareLink);
             NSLog(@"%@", forSharedId);
           // [self downloadLink];
            [self addNewCategory];
             [AppDelegate hideHUDForView:self.view animated:YES];
             [AppDelegate showAlertViewWithTitle:@" " Message:@"File uploaded successfully to Google Drive"];
        }

        else{

            NSLog(@"An error occurred: %@", error);
             [AppDelegate hideHUDForView:self.view animated:YES];
             [AppDelegate showAlertViewWithTitle:@" " Message:[NSString stringWithFormat:@"%@", error.localizedDescription]];

        }
    }];

}

-(void) downloadLink {
    
    GTLRDriveQuery_FilesGet *query = [GTLRDriveQuery_FilesGet queryForMediaWithFileId:forSharedId];
    [driveService executeQuery:query completionHandler:^(GTLRServiceTicket *ticket , GTLRDataObject *obj, NSError *error) {
        
        
        if (error == nil) {
            
            NSLog(@"%@", obj.data);
  
        }
        
        else{
            
            NSLog(@"An error occurred: %@", error);
            [AppDelegate hideHUDForView:self.view animated:YES];
            [AppDelegate showAlertViewWithTitle:@" " Message:[NSString stringWithFormat:@"%@", error.localizedDescription]];
            
        }
        
    }];
   
    
//    let query = GTLRDriveQuery_FilesGet.queryForMedia(withFileId: fileID)
//    service.executeQuery(query) { (ticket, file, error) in
//        onCompleted((file as? GTLRDataObject)?.data, error)
//    }
}




#pragma mark - GoogleSignIn delegates
-(void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    if (error) {
        //TODO: handle error
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
         @"HideGoogleSignIn" object:nil userInfo:nil];
        //TODO: do your stuff
        
        
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
        
       // [[NSUserDefaults standardUserDefaults]setValue:@"login" forKey:@"loginStatus"];
        [AppDelegate showAlertViewWithTitle:@" " Message:@"Google sign in successfully"];
            
       // }
        
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

@end
