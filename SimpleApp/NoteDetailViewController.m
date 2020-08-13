//
//  NoteDetailViewController.m
//  SimpleApp
//
//  Created by IOS1 on 2/4/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import "NoteDetailViewController.h"
#import "AppDelegate.h"
#import "importListViewController.h"
#import "RecordListViewController.h"
#import "HtmlTextDescription.h"
#import <BFRImageViewer/BFRImageViewController.h>
#import <AppAuth/AppAuth.h>
#import <GTMAppAuth/GTMAppAuth.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import <GoogleAPIClientForREST/GoogleAPIClientForREST-umbrella.h>
#import <GTMSessionFetcher/GTMSessionFetcher.h>

@interface NoteDetailViewController ()<UIAlertViewDelegate , UITextFieldDelegate , UITextViewDelegate , UIImagePickerControllerDelegate , UINavigationControllerDelegate>
{
    NSMutableDictionary *recordDetail;
    NSInteger currentIndex;
    NSMutableArray *recordArray;
    UIBarButtonItem *rightBarBtn;
    UIBarButtonItem *homeBarBtn;
    UIBarButtonItem *btnSave;
    
    UIImagePickerController *imagePicker;
    
    GTLRDriveService *driveService;
    NSString *mimiType;
    NSData *data;
    NSURL *imageUrl;
    NSString *folderID;
    NSString *folderName;
    NSString *defaultFolderName;
    NSString *forSharedId;
    NSString *shareLink;
    BOOL *loginStatus;
    NSData *dataImage;

}


@property (weak, nonatomic) IBOutlet GIDSignInButton *signinbtn;

@property (strong, nonatomic) IBOutlet UIView *categoryView;
@property (strong, nonatomic) IBOutlet UIView *recordView;

@property (strong, nonatomic) IBOutlet UIView *noteView;
@property (strong, nonatomic) IBOutlet UILabel *categoryName;
@property (strong, nonatomic) IBOutlet UILabel *recordTitle;
@property (strong, nonatomic) IBOutlet UITextView *note;
@property (strong, nonatomic) IBOutlet UIButton *nextBtn;
@property (strong, nonatomic) IBOutlet UIButton *previousBtn;
@end

@implementation NoteDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_signinbtn setHidden:YES];
    // self.btnSave.hidden = YES;
    // Do any additional setup after loading the view.
    currentIndex=self.selectedIndex;
    defaultFolderName = @"SimpleApp";

    driveService = [[GTLRDriveService alloc] init];

    
    
//    if(GIDSignIn.sharedInstance.hasAuthInKeychain)
//    {
//        //loggedIn
//        NSLog(@"%@",  @"logged in");
//
//    } else {
//
//        NSLog(@"%@",  @"logged out");
//        //[[GIDSignIn sharedInstance] signInSilently];
//
//        [GIDSignIn sharedInstance].delegate = self;
//        [GIDSignIn sharedInstance].uiDelegate = self;
//        [GIDSignIn sharedInstance] .scopes = [NSArray arrayWithObjects:kGTLRAuthScopeDriveFile,kGTLRAuthScopeDrive, nil ];
//        [[GIDSignIn sharedInstance] signInSilently];
//    }
//
//
//    NSLog(@"%@",GIDSignIn.sharedInstance.currentUser.userID );
//    driveService.authorizer = GIDSignIn.sharedInstance.currentUser.authentication.fetcherAuthorizer;
    
    
    
    UISwipeGestureRecognizer *swipeLeft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRecognizerLeft)];
    swipeLeft.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRecognizerRight)];
    swipeRight.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    
//    id thePresenter = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
//    
//    // and test its class
//    if ([thePresenter isKindOfClass:[importListViewController class]]) {
//        
//        NSString * userID =   [[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID];
//        NSArray * data = [[NSArray alloc] init];
//        NSString *query = [NSString stringWithFormat:@"SELECT COUNT(*)  FROM SharedDatabases WHERE  UserId =%lld and DatabaseId = %lld and Admin = 1",[userID longLongValue],self.notObj.DatabaseID];
//        data = [[DBManager getSharedInstance] recordExistOrNot:query];
//        
//        if ([[data objectAtIndex:0] intValue] == 0)
//        {
//            [_editImgBtn setHidden:true];
//            
//        }
//        
//        else {
//            homeBarBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"home"] style:UIBarButtonItemStyleDone target:self action:@selector(homeBtnAction)];
//            btnSave = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(btnSaveClick:)];
//            self.navigationItem.rightBarButtonItems = @[homeBarBtn];
//            [_editImgBtn setHidden:false];
//
//            
//        }
//        
//        // do this
//    } else {
//        // do that
//
//       homeBarBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"home"] style:UIBarButtonItemStyleDone target:self action:@selector(homeBtnAction)];
//        btnSave = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(btnSaveClick:)];
//        self.navigationItem.rightBarButtonItems = @[homeBarBtn];
//
//    }
    recordArray = [[NSMutableArray alloc] init];
    recordArray = self.recordArr;
    if (currentIndex == 0)
    {
        self.previousBtn.enabled = NO;
    }
    if (currentIndex == recordArray.count-1)
    {
        self.nextBtn.enabled = NO;
    }
    NotesObject *notes = recordArray[currentIndex];
    
    [[NSUserDefaults standardUserDefaults]setValue:notes.Note forKey:@"HTMLTEXT"];
    self.textTille.text= notes.Title;
     self.imgeViewDescription.image = [UIImage imageWithData:notes.imageData];
    if (notes.imageData.length == 0) {
        [_editImgBtn setTitle:@"Add Image" forState:UIControlStateNormal];
    }
    
        
        _imgeViewDescription.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
       
        [_imgeViewDescription addGestureRecognizer:tap];
    
    // Add an observer that will respond to loginComplete
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideButton:)
                                                 name:@"HideGoogleSignIn" object:nil];
    
    
    
    
    id thePresenter = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    
    // and test its class
    if ([thePresenter isKindOfClass:[importListViewController class]]) {
        
        NSString * userID =   [[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID];
        NSArray * data = [[NSArray alloc] init];
        NSString *query = [NSString stringWithFormat:@"SELECT COUNT(*)  FROM SharedDatabases WHERE  UserId =%lld and DatabaseId = %lld and Admin = 1",[userID longLongValue],notes.DatabaseID];
        data = [[DBManager getSharedInstance] recordExistOrNot:query];
        
        self.navigationItem.title = notes.Title;
        
        if ([[data objectAtIndex:0] intValue] == 0)
        {
            [_editImgBtn setHidden:true];
            _textTille.userInteractionEnabled = NO;
            [_textTille resignFirstResponder];
            _desTextView.editable = NO;
            [_desTextView resignFirstResponder];
            
        }
        
        else {
            homeBarBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"home"] style:UIBarButtonItemStyleDone target:self action:@selector(homeBtnAction)];
            btnSave = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(btnSaveClick:)];
            self.navigationItem.rightBarButtonItems = @[homeBarBtn];
            [_editImgBtn setHidden:false];
            _textTille.userInteractionEnabled = YES;
            _desTextView.editable = YES;
          
            
        }
        
        // do this
    } else {
        // do that
        
        homeBarBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"home"] style:UIBarButtonItemStyleDone target:self action:@selector(homeBtnAction)];
        btnSave = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(btnSaveClick:)];
        self.navigationItem.rightBarButtonItems = @[homeBarBtn];
        
    }
   
}
-(void)viewWillAppear:(BOOL)animated
{
    _desTextView.userInteractionEnabled = YES;
    [self setDetail];
    
}

- (void)hideButton:(NSNotification *)note {
    NSLog(@"Received Notification - Someone seems to have logged in");
    NSLog(@"%@", note.object);
    GIDGoogleUser *user =  note.object;
    [_signinbtn setHidden:YES];
    
    
}


- (NSManagedObjectContext *)managedObjectContext {
    
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

-(void)swipeRecognizerRight
{
    if(currentIndex>0)
    {
      
        id thePresenter = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
        
        // and test its class
        if ([thePresenter isKindOfClass:[importListViewController class]]) {
             NotesObject *notes = recordArray[currentIndex - 1];
            NSString * userID =   [[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID];
            NSArray * data = [[NSArray alloc] init];
            NSString *query = [NSString stringWithFormat:@"SELECT COUNT(*)  FROM SharedDatabases WHERE  UserId =%lld and DatabaseId = %lld and Admin = 1",[userID longLongValue],notes.DatabaseID];
            data = [[DBManager getSharedInstance] recordExistOrNot:query];
            
            self.navigationItem.title = notes.Title;
            
            if ([[data objectAtIndex:0] intValue] == 0)
            {
                [_editImgBtn setHidden:true];
                _textTille.userInteractionEnabled = NO;
                [_textTille resignFirstResponder];
                _desTextView.editable = NO;
                [_desTextView resignFirstResponder];
                currentIndex--;
                self.previousBtn.enabled = YES;
                self.nextBtn.enabled = YES;
                [self setDetailNextPrev];
                if (currentIndex == 0)
                {
                    self.previousBtn.enabled = NO;
                }
                
            }
            
            else {
                homeBarBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"home"] style:UIBarButtonItemStyleDone target:self action:@selector(homeBtnAction)];
                btnSave = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(btnSaveClick:)];
                self.navigationItem.rightBarButtonItems = @[homeBarBtn];
                [_editImgBtn setHidden:false];
                _textTille.userInteractionEnabled = YES;
                _desTextView.editable = YES;
              
                currentIndex--;
                self.previousBtn.enabled = YES;
                self.nextBtn.enabled = YES;
                [self setDetailNextPrev];
                if (currentIndex == 0)
                {
                    self.previousBtn.enabled = NO;
                }
                
                
            }
            
            // do this
        } else {
            // do that
            
//            homeBarBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"home"] style:UIBarButtonItemStyleDone target:self action:@selector(homeBtnAction)];
//            btnSave = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(btnSaveClick:)];
//            self.navigationItem.rightBarButtonItems = @[homeBarBtn];
            currentIndex--;
            self.previousBtn.enabled = YES;
            self.nextBtn.enabled = YES;
            [self setDetailNextPrev];
            if (currentIndex == 0)
            {
                self.previousBtn.enabled = NO;
            }
            
        }
//
//        currentIndex--;
//        self.previousBtn.enabled = YES;
//        self.nextBtn.enabled = YES;
//        [self setDetailNextPrev];
//        if (currentIndex == 0)
//        {
//            self.previousBtn.enabled = NO;
//        }
    }
    else
    {
        self.previousBtn.enabled = NO;
    }
    NotesObject *notes = recordArray[currentIndex];
    [[NSUserDefaults standardUserDefaults]setValue:notes.Note forKey:@"HTMLTEXT"];
}

-(void)swipeRecognizerLeft
{
    if(currentIndex<recordArray.count-1)
    {
        id thePresenter = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
        
        // and test its class
        if ([thePresenter isKindOfClass:[importListViewController class]]) {
             NotesObject *notes = recordArray[currentIndex + 1];
            NSString * userID =   [[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID];
            NSArray * data = [[NSArray alloc] init];
            NSString *query = [NSString stringWithFormat:@"SELECT COUNT(*)  FROM SharedDatabases WHERE  UserId =%lld and DatabaseId = %lld and Admin = 1",[userID longLongValue],notes.DatabaseID];
            data = [[DBManager getSharedInstance] recordExistOrNot:query];
            
            self.navigationItem.title = notes.Title;
            
            if ([[data objectAtIndex:0] intValue] == 0)
            {
                [_editImgBtn setHidden:true];
                _textTille.userInteractionEnabled = NO;
                [_textTille resignFirstResponder];
                _desTextView.editable = NO;
                [_desTextView resignFirstResponder];
                currentIndex++;
                self.previousBtn.enabled = YES;
                self.nextBtn.enabled = YES;
                [self setDetailNextPrev];
                if (currentIndex == recordArray.count-1)
                {
                    self.nextBtn.enabled = NO;
                }
                
            }
            
            else {
                homeBarBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"home"] style:UIBarButtonItemStyleDone target:self action:@selector(homeBtnAction)];
                btnSave = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(btnSaveClick:)];
                self.navigationItem.rightBarButtonItems = @[homeBarBtn];
                [_editImgBtn setHidden:false];
                _textTille.userInteractionEnabled = YES;
                _desTextView.editable = YES;
                
                currentIndex++;
                self.previousBtn.enabled = YES;
                self.nextBtn.enabled = YES;
                [self setDetailNextPrev];
                if (currentIndex == recordArray.count-1)
                {
                    self.nextBtn.enabled = NO;
                }
                
                
            }
            
            // do this
        } else {
            // do that
            
//            homeBarBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"home"] style:UIBarButtonItemStyleDone target:self action:@selector(homeBtnAction)];
//            btnSave = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(btnSaveClick:)];
//            self.navigationItem.rightBarButtonItems = @[homeBarBtn];
            currentIndex++;
            self.previousBtn.enabled = YES;
            self.nextBtn.enabled = YES;
            [self setDetailNextPrev];
            if (currentIndex == recordArray.count-1)
            {
                self.nextBtn.enabled = NO;
            }
            
        }
    
//
//
//        currentIndex++;
//        self.previousBtn.enabled = YES;
//        self.nextBtn.enabled = YES;
//        [self setDetailNextPrev];
//        if (currentIndex == recordArray.count-1)
//        {
//            self.nextBtn.enabled = NO;
//        }
    }
    else
    {
        self.nextBtn.enabled = NO;
    }
    
    NotesObject *notes = recordArray[currentIndex];
    [[NSUserDefaults standardUserDefaults]setValue:notes.Note forKey:@"HTMLTEXT"];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGFloat)heightForText:(NSString*)text font:(UIFont*)font {
    if (text.length == 0) {
        return 30;
    }
    NSStringDrawingContext *ctx = [NSStringDrawingContext new];
    CGSize labelSize = CGSizeMake(self.view.frame.size.width- 35, 999);
    CGRect textRect = [text boundingRectWithSize:labelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:ctx];
    //NSLog(@"height: %f", textRect.size.height);
    if(textRect.size.height<20)
        return 20;
    return textRect.size.height;
}

-(void)setDetail
{
    if(recordArray.count==1){
        self.previousBtn.hidden=YES;
        self.nextBtn.hidden=YES;
    }
    

     NSString *htmlDes =  [[NSUserDefaults standardUserDefaults]valueForKey:@"HTMLTEXT"];
    NSAttributedString *attributedString = [[NSAttributedString alloc]
                                            initWithData: [htmlDes dataUsingEncoding:NSUnicodeStringEncoding]
                                            options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                                            documentAttributes: nil
                                            error: nil
                                            ];
    self.desTextView.attributedText=attributedString;
    self.title = self.navTittle;
  
    self.textViewHeight.constant = [self heightForText:self.desTextView.text font:[UIFont fontWithName:@"Helvetica" size:15.0]];
    if (self.textViewHeight.constant < 30) {
        self.textViewHeight.constant = 30;
    }
    else {
          self.textViewHeight.constant = self.textViewHeight.constant + 15;
    }
    self.desTextView.frame = CGRectMake( self.desTextView.frame.origin.x,  self.desTextView.frame.origin.y,  self.desTextView.frame.size.width, self.textViewHeight.constant);
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)previous:(id)sender {
    [self swipeRecognizerRight];
    
}

- (IBAction)next:(id)sender {
    [self swipeRecognizerLeft];
}


-(void)deleteTitleAPI {
    
    NotesObject *obj = recordArray[currentIndex];
    [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
    //        NSString *registerUrl=[NSString stringWithFormat:@"%@",HostUrl];
    NSMutableDictionary *userDetail = [[NSMutableDictionary alloc]init];
    [userDetail setValue:kDeleteNotes forKey:kDefault];
    [userDetail setValue:[NSString stringWithFormat:@"%lld",obj.DatabaseID] forKey:@"db_id"];
     [userDetail setValue:[NSString stringWithFormat:@"%lld",obj.NotesID]  forKey:@"notes_id"];
    [userDetail setValue:[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID] forKey:kDeleteUserID];
    
    NSLog(@"UsetDetail Dict%@", userDetail);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:HostUrl parameters:userDetail success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        [AppDelegate hideHUDForView:self.view animated:YES];
        NSLog(@"Success: %@\n ***** %@", operation.responseString, responseObject);
        id status= [responseObject valueForKey:@"status"];
        if([status isKindOfClass:[NSString class]]){
            if([status isEqualToString:@"Success"]) {
                [self deleteNotesFromSqlite];
                
                [self.navigationController popViewControllerAnimated:true];
                
            }
            else{
                
            }
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        
        [AppDelegate hideHUDForView:self.view animated:YES];
        //if(dict)
        [AppDelegate showAlertViewWithTitle:@"Network Error" Message:@"Please Check Your Internet Connection."];
    }];

    
}



-(void)deleteNotesFromSqlite{
     NotesObject *obj = recordArray[currentIndex];
    [[DBManager getSharedInstance]deleteNotes:[NSString stringWithFormat:@"%lld",obj.NotesID] forUserID:[NSString stringWithFormat:@"%lld",obj.DatabaseID]];
    
    
}
-(void)updateNotesFromSqlite :(NotesObject*)noteObjc{
   // NotesObject *obj = recordArray[currentIndex];
    
   // NSString *notes = self.desTextView.text;
     NSString *notes =  [[NSUserDefaults standardUserDefaults]valueForKey:@"HTMLTEXT"];
    NSString *tittle = self.textTille.text;
    
    notes = [notes stringByReplacingOccurrencesOfString:@"\"" withString:@"~#~"];
    notes = [notes stringByReplacingOccurrencesOfString:@"\'" withString:@"~!~"];
    
    tittle = [tittle stringByReplacingOccurrencesOfString:@"\"" withString:@"~#~"];
    tittle = [tittle stringByReplacingOccurrencesOfString:@"\'" withString:@"~!~"];

   // [[DBManager getSharedInstance] updateNotes:[NSString stringWithFormat:@"%lld",obj.NotesID]  forUserID:[NSString stringWithFormat:@"%lld",obj.DatabaseID] notes:notes title:tittle];
   
    
   [[DBManager getSharedInstance] updateNotes:[NSString stringWithFormat:@"%lld",noteObjc.NotesID]  forUserID:[NSString stringWithFormat:@"%lld",noteObjc.DatabaseID] notes:notes title:tittle withImage:noteObjc.imageData withFileUpload:noteObjc.FileUpload];
    
  // [[DBManager getSharedInstance] importNotesFromServer:noteObjc];
   
}

-(void)homeBtnAction {
    NSArray *array = self.navigationController.viewControllers;
    
    for (UIViewController *controller in array) {
        if ([controller isKindOfClass:[RecordListViewController class]]) {
            [self.navigationController popToViewController:controller animated:true];
        }
    }
    
}
-(void)editRecord {
    if ([rightBarBtn.title isEqualToString:@"Save"]) {
        self.textViewHeight.constant = [self heightForText:self.desTextView.text font:[UIFont fontWithName:@"Helvetica" size:15.0]];
        if (self.textViewHeight.constant < 30) {
            self.textViewHeight.constant = 30;
        }
        else {
            self.textViewHeight.constant = self.textViewHeight.constant + 15;
        }
        self.desTextView.frame = CGRectMake( self.desTextView.frame.origin.x,  self.desTextView.frame.origin.y,  self.desTextView.frame.size.width, self.textViewHeight.constant);
        [self updateNote];
    }
    
}
- (IBAction)editImageAction:(id)sender {
    
    
    
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
                                                                      _imgeViewDescription.image = nil;
                                                                      [_editImgBtn setTitle:@"Add Image" forState:UIControlStateNormal];
                                                                      
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
        
        
        
        
        
    } else {
        
        NSLog(@"%@",  @"logged out");
       
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentStorageType"] isEqualToString:@"Google Drive"] ) {
            
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
//                                                                              _imgeViewDescription.image = nil;
//                                                                              [_editImgBtn setTitle:@"Add Image" forState:UIControlStateNormal];
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
//
//
//
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
                                                                          _imgeViewDescription.image = nil;
                                                                          [_editImgBtn setTitle:@"Add Image" forState:UIControlStateNormal];
                                                                          
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
    
     [_editImgBtn setTitle:@"Edit Image" forState:UIControlStateNormal];
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    _imgeViewDescription.image = chosenImage;
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
    
    self.navigationItem.rightBarButtonItems = @[homeBarBtn,btnSave];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}
-(void)tapGesture : (UITapGestureRecognizer *)gesture{
    NSLog(@"Gesture Tag %li",gesture.view.tag);
    if (_imgeViewDescription.image != nil) {
      
    BFRImageViewController *imageVC = [[BFRImageViewController alloc] initWithImageSource:@[_imgeViewDescription.image]];
    [[NSUserDefaults standardUserDefaults]setValue:@"noReload" forKey:@"Reload"];
    [self presentViewController:imageVC animated:YES completion:nil];
    }
}
//-(void)deleteRecord{
//    
//    UIAlertView *alert;
//    if(!alert)
//    {
//        alert = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure want to delete this note?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
//    }
//    [alert show];
//   
//}
#pragma mark- UITextfield Delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField {
     self.navigationItem.rightBarButtonItems = @[homeBarBtn,btnSave];
   //  self.btnSave.hidden = NO;
    //rightBarBtn=[[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(editRecord)];
    
   // self.navigationItem.rightBarButtonItems = @[rightBarBtn,homeBarBtn];

   
}
-(void)textViewDidBeginEditing:(UITextView *)textView {
        [self.view endEditing:YES];
    if (textView == _desTextView){
        _desTextView.userInteractionEnabled = NO;
        NSString *htmlDes =  [[NSUserDefaults standardUserDefaults]valueForKey:@"HTMLTEXT"];
        HtmlTextDescription *VC =  [self.storyboard instantiateViewControllerWithIdentifier:@"HtmlTextDescription"];
        VC.filledText = htmlDes;
        VC.viewCheck = @"Notes";
        [self.navigationController pushViewController:VC animated:NO];
    }
    self.navigationItem.rightBarButtonItems = @[homeBarBtn,btnSave];
  //  self.btnSave.hidden = NO;
//rightBarBtn=[[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(editRecord)];
     //self.navigationItem.rightBarButtonItems = @[rightBarBtn,homeBarBtn];
    
}

#pragma mark- UIAlertViewDelegate
#pragma mark-

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==1){
        [self deleteTitleAPI];
    }
}

-(BOOL)textView:(UITextView *)_textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    [self adjustFrames];
    return YES;
}


-(void) adjustFrames
{
    CGRect textFrame = self.desTextView.frame;
    textFrame.size.height = self.desTextView.contentSize.height;
    self.desTextView.frame = textFrame;
}

-(void)updateNote {
    
    NotesObject *obj = recordArray[currentIndex];
    [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
  
    NSMutableDictionary *userDetail = [[NSMutableDictionary alloc]init];
    [userDetail setValue:kEditNotes forKey:kDefault];
    [userDetail setValue:[NSNumber numberWithLong:obj.DatabaseID] forKey:@"db_id"];
    [userDetail setValue:[NSNumber numberWithLong:obj.NotesID] forKey:@"notes_id"];
    
  //  NSString *notes = self.desTextView.text;
    NSString *tittle = self.textTille.text;
    NSString *notes =  [[NSUserDefaults standardUserDefaults]valueForKey:@"HTMLTEXT"];
    notes = [notes stringByReplacingOccurrencesOfString:@"\"" withString:@"~#~"];
    notes = [notes stringByReplacingOccurrencesOfString:@"\'" withString:@"~!~"];
    
    tittle = [tittle stringByReplacingOccurrencesOfString:@"\"" withString:@"~#~"];
    tittle = [tittle stringByReplacingOccurrencesOfString:@"\'" withString:@"~!~"];

    
    [userDetail setValue:tittle forKey:@"title"];
    [userDetail setValue:notes forKey:@"notes"];
    
    NSLog(@"UsetDetail Dict%@", userDetail);
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentStorageType"] isEqualToString:@"Google Drive"] ) {
        
        
        
        [userDetail setValue:obj.FileUpload forKey:@"drive_path"];
        
    }
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:HostUrl]];
    
    if (_imgeViewDescription.image != nil) {
        imageData = UIImageJPEGRepresentation(_imgeViewDescription.image, 0.5);
    }
    
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    
    AFHTTPRequestOperation *op = [manager POST:HostUrl parameters:userDetail constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        NSLog(@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentStorageType"]);
        
        if (_imgeViewDescription.image != nil && [[[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentStorageType"] isEqualToString:@"Local Storage"] ) {
            [formData appendPartWithFileData:imageData name:@"fileupload" fileName:@"photo.jpg" mimeType:@"image/jpeg"];
        }
        
        else if (_imgeViewDescription.image != nil && [[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentStorageType"] == nil ) {
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

                    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentStorageType"] isEqualToString:@"Google Drive"] ) {
                        
                        noteObj.imageData = nil;
                        
                    }
                    
                    else {
                        
                        noteObj.FileUpload  = @"";
                        if (_imgeViewDescription.image != nil && [[[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentStorageType"] isEqualToString:@"Local Storage"] ) {
                            noteObj.imageData = imageData;
                        }
                        else if (_imgeViewDescription.image != nil && [[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentStorageType"] == nil ) {
                            noteObj.imageData = imageData;
                        }
                        
                        else {
                            noteObj.imageData = nil;
                        }
                        
                    }
                    
                    [self updateNotesFromSqlite:noteObj];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                
                
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
    
    
    
    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    [manager POST:HostUrl parameters:userDetail success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
//
//
//        NSLog(@"Success: %@\n ***** %@", operation.responseString, responseObject);
//        id status= [responseObject valueForKey:@"status"];
//        if([status isKindOfClass:[NSString class]]){
//            [AppDelegate hideHUDForView:self.view animated:YES];
//            if([status isEqualToString:@"Success"]) {
//
//                 [self updateNotesFromSqlite];
//                [self.navigationController popViewControllerAnimated:YES];
//            }
//
//            else{
//                [AppDelegate hideHUDForView:self.view animated:YES];
//
//            }
//        }
//    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
//        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
//
//        [AppDelegate hideHUDForView:self.view animated:YES];
//        //if(dict)
//        [AppDelegate showAlertViewWithTitle:@"Network Error" Message:@"Please Check Your Internet Connection."];
//    }];
//
    
    
    
}




- (IBAction)btnSaveClick:(id)sender {
    
   
    
    NSString *notes = self.desTextView.text;
    NSString *tittle = self.textTille.text;
    // category_name=[category_name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    notes=[notes stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    tittle=[tittle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(!tittle.length){
       // [AppDelegate showAlertViewWithTitle:nil Message:@"Please Fill Title."];
    }else if(!notes.length ){
       // [AppDelegate showAlertViewWithTitle:nil Message:@"Please Fill Description."];
    }else {
        //_imgeViewDescription.image != nil &&
        if  (_imgeViewDescription.image != nil && [[[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentStorageType"] isEqualToString:@"Google Drive"]) {
            
            [self searchFolder];
            
        }
        else {
            
            [self updateNote];
        }
    }
}


-(void)setDetailNextPrev
{
    if(recordArray.count==1){
        self.previousBtn.hidden=YES;
        self.nextBtn.hidden=YES;
    }
    
    NotesObject *notes = recordArray[currentIndex];
    self.textTille.text= notes.Title;
    self.imgeViewDescription.image = [UIImage imageWithData:notes.imageData];
    NSString *htmlDes = notes.Note;
    NSAttributedString *attributedString = [[NSAttributedString alloc]
                                            initWithData: [htmlDes dataUsingEncoding:NSUnicodeStringEncoding]
                                            options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
                                            documentAttributes: nil
                                            error: nil
                                            ];
    self.desTextView.attributedText=attributedString;
    self.title = self.navTittle;
    
    self.textViewHeight.constant = [self heightForText:self.desTextView.text font:[UIFont fontWithName:@"Helvetica" size:15.0]];
    if (self.textViewHeight.constant < 30) {
        self.textViewHeight.constant = 30;
    }
    else {
        self.textViewHeight.constant = self.textViewHeight.constant + 15;
    }
    self.desTextView.frame = CGRectMake( self.desTextView.frame.origin.x,  self.desTextView.frame.origin.y,  self.desTextView.frame.size.width, self.textViewHeight.constant);
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

- (void)uploadFileURL:(NSData *)fileToUploadData mimeType: (NSString*)mimeType {
    
    
    //NSString *fileStr = fileToUploadURL.absoluteString;
    
   // NSData *fileData =   [NSData dataWithContentsOfURL:[NSURL URLWithString:fileStr]];
    
    
    GTLRDrive_File *metadata = [GTLRDrive_File object];
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    // NSTimeInterval is defined as double
    NSNumber *timeStampObj = [NSNumber numberWithInt: timeStamp];
    metadata.name =  [NSString stringWithFormat:@"photo%@.jpg", timeStampObj];
    metadata.parents = [NSArray arrayWithObject:folderID];
    
    
    GTLRUploadParameters *uploadParameters = [GTLRUploadParameters uploadParametersWithData:fileToUploadData
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
             NotesObject *obj = recordArray[currentIndex];
            obj.FileUpload = shareLink;
            [recordArray replaceObjectAtIndex:currentIndex withObject:obj];
            NSLog(@"%@", forSharedId);
            // [self downloadLink];
            [self updateNote];
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
