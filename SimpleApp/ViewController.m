//
//  ViewController.m
//  H2GO
//
//  Created by MAC on 11/20/15.
//  Copyright © 2015 MAC. All rights reserved.
//

#import "ViewController.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import <AddressBook/ABAddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <CoreLocation/CoreLocation.h>


@interface ViewController ()<UITextFieldDelegate, CLLocationManagerDelegate>{
    BOOL isRememberUserName;
    NSMutableDictionary *userDetail;
    UITextField *emailfield;
    NSString * userNam, *firstName, *lastName, *userId, *phNo, *licencType, *dateCreate, *catalog, *email_validation_key, *passwd;
}
@property (strong, nonatomic) IBOutlet UITextField *userName;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) NSMutableArray *userList;
@property (strong, nonatomic) IBOutlet UIButton *rememberUserNameBtn;
@property (strong, nonatomic) CLLocationManager *locationManager;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    
    userDetail=[[NSMutableDictionary alloc]init];
    isRememberUserName=NO;
    self.navigationController.navigationBarHidden=YES;
    // Do any additional setup after loading the view, typically from a nib.
     self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
    
    self.rememberUserNameBtn.layer.borderWidth=3;
    self.rememberUserNameBtn.layer.borderColor=[UIColor blackColor].CGColor;
    
    self.btnLogin.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.btnLogin.layer.borderWidth = 2.0;
    self.btnLogin.layer.cornerRadius = 8.0;
    
    self.btnSignUp.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.btnSignUp.layer.borderWidth = 2.0;
    self.btnSignUp.layer.cornerRadius = 8.0;
    
    _userName.layer.cornerRadius = 8.0;
    _userName.layer.borderWidth = 1.0;

    _password.layer.cornerRadius = 8.0;
    _password.layer.borderWidth = 1.0;
    
    if( _locationManager == nil ) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
         [_locationManager requestWhenInUseAuthorization];
        _locationManager.allowsBackgroundLocationUpdates = NO;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        [_locationManager startUpdatingLocation];
    }
    
    [self checkLocationAccess];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
     [DBManager getSharedInstance];
     [self getContactAuthorizationFromUser];
     [self getContacts];
}
-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden=YES;
//    if([AppDelegate getRememberUserName] && [AppDelegate getUserEmail]&&[[AppDelegate getRememberUserName] intValue]){
//        self.userName.text=[AppDelegate getUserEmail];
//        [self.rememberUserNameBtn setImage:[UIImage imageNamed:@"tick2"] forState:UIControlStateNormal];
//    }
    
    if([AppDelegate getRememberUserName] && [AppDelegate getUserEmail]&&([[AppDelegate getRememberUserName] intValue] == 1)){
        self.userName.text=[AppDelegate getUserEmail];
        self.password.text = [AppDelegate getUserPassword];
        [self.rememberUserNameBtn setImage:[UIImage imageNamed:@"tick2"] forState:UIControlStateNormal];
    }
    else
    {
        self.userName.text=@"";
        self.password.text= @"";
        [self.rememberUserNameBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    }
    
    
    
}
-(void)viewDidDisappear:(BOOL)animated{
    self.userName.text=@"";
    self.password.text=@"";
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)checkLocationAccess {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    switch (status) {
            
            // custom methods after each case
            
        case kCLAuthorizationStatusDenied:
            //            [self allowLocationAccess]; // custom method
            break;
        case kCLAuthorizationStatusRestricted:
            // [self allowLocationAccess]; // custom method
            break;
        case kCLAuthorizationStatusNotDetermined:
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            break;
    }
    
}



- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}
//#pragma mark- Navigation
//#pragma mark-
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if([segue.identifier isEqualToString:@"AddItemSegue"])
//    {
//        CategoryListViewController *obj=segue.destinationViewController;
//        obj.isFromCategory=YES;
//    }
//}


#pragma mark- UITextFieldDelegate
#pragma mark-
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if(self.view.frame.size.height<500 && textField==self.password){
        CGRect frame=self.view.frame;
        frame.origin.y=-60;
        [self.view setFrame:frame];

    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    CGRect frame=self.view.frame;
    frame.origin.y=0;
    [self.view setFrame:frame];
}

#pragma mark- IBAction
#pragma mark-

- (IBAction)loginBtnAction:(id)sender {
    
   //[self authenicateButtonTapped:sender];
    [_userName resignFirstResponder];
    [_password resignFirstResponder];
    
    if(_userName.text.length && _password.text.length)
//         [self search];
        
           [self loginApi];
    else
        [AppDelegate showAlertViewWithTitle:nil Message:@"Invalid Email Id Or Password."];
}
- (IBAction)resetPassword_Action:(id)sender
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Reset Passsword"
                                                                              message: @"Please Enter Email id."
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"email";
        textField.textColor = [UIColor blackColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
//        textField.borderStyle = UITextBorderStyleRoundedRect;
    }];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
    {
        NSArray * textfields = alertController.textFields;
        emailfield = textfields[0];
        NSLog(@"%@",emailfield.text);
        [self hitResetApi];
        
    }]];
    
    [alertController addAction:[UIAlertAction
                               actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   //Handle no, thanks button
                               }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
-(void)hitResetApi
{
    
    NSString *userName=[emailfield.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (userName.length == 0 || ![AppDelegate validateEmail: userName])
    {
        [AppDelegate showAlertViewWithTitle:@"Message" Message:@"Invalid Email Id."];
        
    }
    else {
        
    [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
    [userDetail removeAllObjects];
    [userDetail setObject:userName forKey:@"username"];
    [userDetail setObject:@"reset_password" forKey:@"action"];
    NSString *registerUrl = @"http://app.infopalm.com/appupdate.php";
  
     [NSString stringWithFormat:@"%@",HostUrl];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:registerUrl parameters:userDetail success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        [AppDelegate hideHUDForView:self.view animated:YES];
        NSLog(@"Success: %@\n ***** %@", operation.responseString, responseObject);
        id status= [responseObject valueForKey:@"status"];
        if([status isKindOfClass:[NSString class]]){
            if([status isEqualToString:@"success"])
            {
               // [self updatePassword];
                [AppDelegate showAlertViewWithTitle:@"Reset Password Has Been Sent On Your Email Id." Message:nil];
                
            }
            else
            {
                id reason= [responseObject valueForKey:@"reason"];
                if([reason isKindOfClass:[NSString class]])
                {
                    [AppDelegate showAlertViewWithTitle:@"Sorry!" Message:@"Invalid Email Id."];
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
}


-(void)search
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:UserTable];
    request.predicate = [NSPredicate predicateWithFormat:@"password == %@ && emailId == %@", _password.text,_userName.text];
   // request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES]];
    NSArray *results = [managedObjectContext executeFetchRequest:request error:nil];
    if(results.count)
    {
        NSManagedObject *managedObject=results[0];
      //  NSManagedObjectID *moID = [managedObject objectID];
        NSURL *uri = [[managedObject objectID] URIRepresentation];
        NSData *uriData = [NSKeyedArchiver archivedDataWithRootObject:uri];
        NSLog(@"%@",uriData);
        NSString *email=[results[0] valueForKey:@"emailId"];
        NSString *firstname=[results[0] valueForKey:@"firstname"];
        NSString *pwd=[results[0] valueForKey:@"password"];
        if(email.length){
            [AppDelegate setUserEmailAndName:email userName:firstname password:pwd];
            [AppDelegate setLoggedIn:@"1"];
            [self performSegueWithIdentifier:@"RecordListSegue" sender:self];
            NSLog(@"Login successfully");
        }
       
    }else{
        [AppDelegate showAlertViewWithTitle:nil Message:@"Invalid Email Id Or Password."];
        NSLog(@"Invalid Email id");
    }
}

-(void)loginApi
{
    
    NSString *userName=[_userName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password=[_password.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    //         NSInteger randomNumber = arc4random() % 99;
    
    [userDetail removeAllObjects];

    [userDetail setObject:userName forKey:@"username"];
    [userDetail setObject:password forKey:@"password"];
    [userDetail setObject:kLogin forKey:kDefault];
    
    [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
    NSString *registerUrl=[NSString stringWithFormat:@"%@",HostUrl];
    NSLog(@"UsetDetail Dict%@", userDetail);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:registerUrl parameters:userDetail success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        [AppDelegate hideHUDForView:self.view animated:YES];
        NSLog(@"Success: %@\n ***** %@", operation.responseString, responseObject);
        id status= [responseObject valueForKey:@"status"];
        if([status isKindOfClass:[NSString class]]){
            if([status isEqualToString:@"success"]){
                [AppDelegate hideHUDForView:self.view animated:YES];
                [[NSUserDefaults standardUserDefaults] setValue:[[responseObject valueForKey:@"result"] valueForKey:@"userid"] forKey:kLoogedInUserID];
                [[NSUserDefaults standardUserDefaults] setValue:userName forKey:@"UserEmail"];
                [[NSUserDefaults standardUserDefaults] setValue:password forKey:@"password"];
                [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@ %@",[[responseObject valueForKey:@"result"] valueForKey:@"first_name"],[[responseObject valueForKey:@"result"] valueForKey:@"last_name"]]  forKey:@"UserName"];
                [[NSUserDefaults standardUserDefaults] setValue:[[responseObject valueForKey:@"result"] valueForKey:@"first_name"]  forKey:@"first_name"];
                 [[NSUserDefaults standardUserDefaults] setValue:[[responseObject valueForKey:@"result"] valueForKey:@"last_name"]  forKey:@"last_name"];
                [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@ %@",[[responseObject valueForKey:@"result"] valueForKey:@"first_name"],[[responseObject valueForKey:@"result"] valueForKey:@"last_name"]]  forKey:@"UserName"];
                [[NSUserDefaults standardUserDefaults] setValue:[[responseObject valueForKey:@"result"] valueForKey:@"phone_number"] forKey:@"phoneNo"];
                [AppDelegate setOwnerId:[[responseObject valueForKey:@"result"] valueForKey:@"userid"]];
                [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"FirstTimeLogin"];
                
                [[NSUserDefaults standardUserDefaults] synchronize];
              //  [self save];
               
                catalog = [[responseObject valueForKey:@"result"] valueForKey:@"catalog"];
                dateCreate = [[responseObject valueForKey:@"result"] valueForKey:@"date_created"];
                email_validation_key = [[responseObject valueForKey:@"result"] valueForKey:@"email_validation_key"];
                firstName = [[responseObject valueForKey:@"result"] valueForKey:@"first_name"];
                lastName = [[responseObject valueForKey:@"result"] valueForKey:@"last_name"];
                licencType = [[responseObject valueForKey:@"result"] valueForKey:@"license_type"];
                passwd = self.password.text;
                phNo = [[responseObject valueForKey:@"result"] valueForKey:@"phone_number"];
                userId = [[responseObject valueForKey:@"result"] valueForKey:@"userid"];
                userNam = [[responseObject valueForKey:@"result"] valueForKey:@"username"];
                
                
                [self saveInSqlite];
                
                
                
                
                
           /*     {
                    clientip = "122.160.233.187";
                    reason = "User has been logged in suceessfully";
                    result =     {
                        0 = "ankukand@visions.net.in";
                        1 = 731;
                        2 = ankukand;
                        3 = kashyap;
                        4 = 7837523243;
                        5 = 1;
                        6 = "2017-03-29 06:19:07";
                        7 = "<null>";
                        8 = Verified;
                        9 = "20hHKoTBW6cD.";
                        catalog = "<null>";
                        "date_created" = "2017-03-29 06:19:07";
                        "email_validation_key" = Verified;
                        "first_name" = ankukand;
                        "last_name" = kashyap;
                        "license_type" = 1;
                        password = "20hHKoTBW6cD.";
                        "phone_number" = 7837523243;
                        userid = 731;
                        username = "ankukand@visions.net.in";
                    };
                    status = success;
                }*/
                
                
                
                
            }
                
            else{
                [AppDelegate hideHUDForView:self.view animated:YES];
                [AppDelegate showAlertViewWithTitle:@"Sorry!" Message:@"Invalid Email Id Or Password."];
            }
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        
        [AppDelegate hideHUDForView:self.view animated:YES];
        //if(dict)
         [AppDelegate showAlertViewWithTitle:@"Network Error" Message:@"Please Check Your Internet Connection."];
    }];
    
}

-(void)saveInSqlite
{
    BOOL success = NO;
    NSString *alertString = @"Data Insertion failed";
    if (_userName.text.length>0 &_password.text.length>0)
    {
        
      success =  [[DBManager getSharedInstance]checkExistence:userId];
        if (success == YES)
        {
            [AppDelegate setUserEmailAndName:self.userName.text userName:[userDetail valueForKey:@"firstname"] password:[userDetail valueForKey:@"password"]];
            
            [AppDelegate setLoggedIn:@"1"];
            
            [self performSegueWithIdentifier:@"RecordListSegue" sender:self];
        }
        else
        {
        
        success = [[DBManager getSharedInstance] saveData_UserName:userNam userid:userId firstName:firstName lastName:lastName phone_number:phNo license_type:licencType date_created:dateCreate catalog:@"" email_validation_key:email_validation_key password:_password.text];
        
        if (success == YES)
        {
          
        
        [AppDelegate setUserEmailAndName:self.userName.text userName:[userDetail valueForKey:@"firstname"] password:[userDetail valueForKey:@"password"]];
        
        [AppDelegate setLoggedIn:@"1"];
        
        [self performSegueWithIdentifier:@"RecordListSegue" sender:self];
        }
        }
        
    }
    else
    {
        alertString = @"Enter all fields";
    }
    if (success == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:
                              alertString message:nil  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}


/*
-(void)save
{
   
    NSManagedObjectContext *context = [self managedObjectContext];
    
    // Create a new managed object
    NSManagedObject *userTable = [NSEntityDescription insertNewObjectForEntityForName:UserTable inManagedObjectContext:context];
    [userTable setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"first_name"] forKey:@"firstname"];
    [userTable setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"last_name"] forKey:@"lastname"];
    [userTable setValue:[AppDelegate getUserEmail]  forKey:@"emailId"];
    [userTable setValue:[AppDelegate getUserPassword] forKey:@"password"];
    [userTable setValue:[userDetail valueForKey:@"licensetype"] forKey:@"licensetype"];
    [userTable setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"phoneNo"] forKey:@"phone_number"];
    // [NSPersistentStoreCoordinator managedObjectIDForURIRepresentation:userTable];
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }else{
        //        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
//        [AppDelegate setUserEmailAndName:self.emailId.text userName:[userDetail valueForKey:@"firstname"] password:[userDetail valueForKey:@"password"]];
        [AppDelegate setLoggedIn:@"1"];
        
        [self performSegueWithIdentifier:@"RecordListSegue" sender:self];
        
        //[AppDelegate showAlertViewWithTitle:nil Message:@"Registered Successfully"];
        //[self performSegueWithIdentifier:@"LoginSegue" sender:self];
    }
    
}
 */

- (IBAction)rememberUserNameAction:(id)sender {
    
    if(isRememberUserName == NO && [[AppDelegate getRememberUserName] intValue] == 0)
    {
        [self.rememberUserNameBtn setImage:[UIImage imageNamed:@"tick2"] forState:UIControlStateNormal];
        
         isRememberUserName=YES;
         [AppDelegate setRememberUserName:@"1"];
        
    }
    else
    {
         [self.rememberUserNameBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            isRememberUserName=NO;
         [AppDelegate setRememberUserName:@"0"];
    }
    
}

- (void)authenicateButtonTapped:(id)sender {
    LAContext *context = [[LAContext alloc] init];
    
    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                localizedReason:@"Are you the device owner?"
                          reply:^(BOOL success, NSError *error) {
                              
                              if (error) {
                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                  message:@"There was a problem verifying your identity."
                                                                                 delegate:nil
                                                                        cancelButtonTitle:@"Ok"
                                                                        otherButtonTitles:nil];
                                  [alert show];
                                  return;
                              }
                              
                              if (success) {
                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                                                  message:@"You are the device owner!"
                                                                                 delegate:nil
                                                                        cancelButtonTitle:@"Ok"
                                                                        otherButtonTitles:nil];
                                  [alert show];
                                  
                              } else {
                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                  message:@"You are not the device owner."
                                                                                 delegate:nil
                                                                        cancelButtonTitle:@"Ok"
                                                                        otherButtonTitles:nil];
                                  [alert show];
                              }
                              
                          }];
        
    } else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Your device cannot authenticate using TouchID."
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
}

-(NSMutableArray *)getContactAuthorizationFromUser{
    
    NSMutableArray *finalContactList = [[NSMutableArray alloc] init];
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                // First time access has been granted, add the contact
                [finalContactList addObject:[self getContacts]];
            } else {
                // User denied access
                // Display an alert telling user the contact could not be added
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access, add the contact
        finalContactList = [self getContacts];
    }
    else {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
    }
    return finalContactList;
    
}


-(NSMutableArray *)getContacts
{
    
    NSMutableArray *newContactArray = [[NSMutableArray alloc]init];
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    NSArray *arrayOfAllPeople1 = (__bridge NSArray *) ABAddressBookCopyArrayOfAllPeople(addressBook);
    NSUInteger peopleCounter = 0;
    for (peopleCounter = 0;peopleCounter < [arrayOfAllPeople1 count]; peopleCounter++)
    {   NSMutableDictionary * contantDic = [[NSMutableDictionary alloc] init];
        ABRecordRef thisPerson = (__bridge ABRecordRef) [arrayOfAllPeople1 objectAtIndex:peopleCounter];
        NSString *name = (__bridge NSString *) ABRecordCopyCompositeName(thisPerson);
        NSString * firstName, *lastName;
        firstName = (__bridge NSString *)(ABRecordCopyValue(thisPerson, kABPersonFirstNameProperty));
        lastName  = (__bridge NSString *)(ABRecordCopyValue(thisPerson, kABPersonLastNameProperty));
        
        ABMultiValueRef number = ABRecordCopyValue(thisPerson, kABPersonPhoneProperty);
        for (NSUInteger emailCounter = 0; emailCounter < ABMultiValueGetCount(number); emailCounter++)
        {
            
            NSString *email = (__bridge NSString *)ABMultiValueCopyValueAtIndex(number, emailCounter);
            if ([email length]!=0)
            {
                NSString* removed0=[email stringByReplacingOccurrencesOfString:@"."withString:@""];
                NSString* removed1=[removed0 stringByReplacingOccurrencesOfString:@"-"withString:@""];
                NSString* removed2=[removed1 stringByReplacingOccurrencesOfString:@")"withString:@""];
                NSString* removed3=[removed2 stringByReplacingOccurrencesOfString:@" "withString:@""];
                NSString* removed4=[removed3 stringByReplacingOccurrencesOfString:@"("withString:@""];
                NSString* removed5=[removed4 stringByReplacingOccurrencesOfString:@"+"withString:@""];
                
                if ([firstName length]==0)
                {
                    [contantDic setValue:@"" forKey:@"Fname"];
                }
                else
                {
                    [contantDic setValue:firstName forKey:@"Fname"];
                }
                
                if ([lastName length]==0)
                {
                    [contantDic setValue:@"" forKey:@"Lname"];
                }
                else
                {
                    [contantDic setValue:lastName forKey:@"Lname"];
                }
                
                
                [contantDic setValue:removed5 forKey:@"phoneno"];
                
                // [contantDic setValue:@"NO" forKey:@"isselected"];
                //                NSData *contactImageData = (__bridge NSData *)ABPersonCopyImageDataWithFormat(thisPerson, kABPersonImageFormatThumbnail);
                //                if (contactImageData!=nil)
                //                {
                //                    [contantDic setObject:contactImageData forKey:@"image"];
                //                }else{
                //                    [contantDic setObject:@"" forKey:@"image"];
                //                }
                
            }
            
        }
        if ([contantDic valueForKey:@"phoneno"] != nil ) {
            
            [newContactArray addObject:contantDic];
        }
        NSLog(@"%@",newContactArray);
        
    }
    
    
    
    return newContactArray;
    
}

@end
