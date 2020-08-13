//
//  RegisterViewController.m
//  H2GO
//
//  Created by MAC on 11/20/15.
//  Copyright © 2015 MAC. All rights reserved.
//

#import "RegisterViewController.h"
#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>


@interface RegisterViewController ()<UITextFieldDelegate, CLLocationManagerDelegate>
{
    UITextField *activeTextfield;
    NSMutableDictionary *userDetail;
    NSString * userName, *firstName, *lastName, *userId, *phNo, *licencType, *dateCreate, *catalog, *email_validation_key, *password;
    
}
@property (strong, nonatomic) IBOutlet UITextField *userName;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) IBOutlet UITextField *emailId;
@property (strong, nonatomic) IBOutlet UITextField *confirmPassword;
@property (strong, nonatomic) IBOutlet UITextField *phoneNumber;
@property (strong, nonatomic) CLLocationManager *locationManager;


@end

@implementation RegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    userDetail=[[NSMutableDictionary alloc]init];
    // Do any additional setup after loading the view.
    
    [_btnFind addTarget:self action:@selector(findbyEmail) forControlEvents:UIControlEventTouchUpInside];
    [_btnSave addTarget:self action:@selector(saveInSqlite) forControlEvents:UIControlEventTouchUpInside];
    
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

//  /Users/ios4/Library/Developer/CoreSimulator/Devices/510737AE-47EA-4416-8A8B-C6B9116C1C7D/data/Containers/Data/Application/D6A3E350-C60A-4D50-ADA2-E3DEA035E082/Documents/SimpleApp.db


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



-(void)saveInSqlite
{
    BOOL success = NO;
    NSString *alertString = @"Data Insertion failed";
    if (_emailId.text.length>0 &&_userName.text.length>0 &&
        _lastName.text.length>0 &&_password.text.length>0 &&_phoneNumber.text.length>0)
    {
        
        
        success =  [[DBManager getSharedInstance]checkExistence:userId];
        if (success == YES)
        {
            [AppDelegate setUserEmailAndName:self.emailId.text userName:[userDetail valueForKey:@"firstname"] password:[userDetail valueForKey:@"password"]];
            [AppDelegate setLoggedIn:@"1"];
            [AppDelegate setRememberUserName:@"1"];
            [self performSegueWithIdentifier:@"RecordListSegue" sender:self];
        }
        else
        {
            
            success = [[DBManager getSharedInstance] saveData_UserName:userName userid:userId firstName:firstName lastName:lastName phone_number:phNo license_type:licencType date_created:dateCreate catalog:@"" email_validation_key:email_validation_key password:password];
            
            if (success == YES)
            {
                [AppDelegate setUserEmailAndName:self.emailId.text userName:[userDetail valueForKey:@"firstname"] password:[userDetail valueForKey:@"password"]];
                [AppDelegate setLoggedIn:@"1"];
                [AppDelegate setRememberUserName:@"1"];
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

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden=YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

#pragma mark- UITextFieldDelegate
#pragma mark-


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeTextfield=textField;
    
    if(self.view.frame.size.height<500 &&( textField == _confirmPassword || textField == _password))
    {
        CGRect frame=self.view.frame;
        frame.origin.y =-100;
        [self.view setFrame:frame];
    }
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    activeTextfield=textField;
    CGRect frame=self.view.frame;
    frame.origin.y =0;
    [self.view setFrame:frame];
}




#pragma mark- IBAction
#pragma mark-

- (IBAction)registerAction:(id)sender
{

    NSString *userName=[_userName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *email=[_emailId.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *lastname=[_lastName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if(userName.length && _password.text.length&& _confirmPassword.text.length&& email.length &&lastname.length)
    {
        if(![AppDelegate validateEmail: _emailId.text])
        {
            [AppDelegate showAlertViewWithTitle:@"Oops!" Message:@"Your  Email Id Is Invalid."];
            
        }
        else if(![AppDelegate validatePhone: _phoneNumber.text])
        {
            [AppDelegate showAlertViewWithTitle:nil Message:@"Please Fill Valid Phone Number."];
            _phoneNumber.text = @"";
            
        }
       else if(![_confirmPassword.text isEqualToString:_password.text])
       {
           [AppDelegate showAlertViewWithTitle:nil Message:@"Password Mismatch."];
           _confirmPassword.text=@"";
           _password.text=@"";
           
       }
       else
       {
           NSString *userName=[_userName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
           NSString *lastName=[_lastName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
           
//         NSInteger randomNumber = arc4random() % 99;
           NSInteger randomNumber = 1;
           [userDetail removeAllObjects];
           [userDetail setObject:userName forKey:@"firstname"];
           [userDetail setObject:lastName forKey:@"lastname"];
           [userDetail setObject:_emailId.text forKey:@"username"];
           [userDetail setObject:_password.text forKey:@"password"];
           [userDetail setObject:_phoneNumber.text forKey:@"phone_number"];
           [userDetail setObject:kRegister forKey:kDefault];
           [userDetail setObject:[NSString stringWithFormat:@"%ld",(long)randomNumber] forKey:@"licensetype"];
           
           //[self save];
           [self registerApi];
       
       }

    }
    else
     [AppDelegate showAlertViewWithTitle:nil Message:@"Please Fill All Required Fields."];
    
}
- (IBAction)signInAction:(id)sender {
    [activeTextfield resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)save
{
    [activeTextfield resignFirstResponder];
    NSManagedObjectContext *context = [self managedObjectContext];
    
    // Create a new managed object
    NSManagedObject *userTable = [NSEntityDescription insertNewObjectForEntityForName:UserTable inManagedObjectContext:context];
    [userTable setValue:[userDetail valueForKey:@"firstname"]forKey:@"firstname"];
    [userTable setValue:[userDetail valueForKey:@"lastname"] forKey:@"lastname"];
    [userTable setValue:[userDetail valueForKey:@"username"] forKey:@"emailId"];
    [userTable setValue:[userDetail valueForKey:@"password"] forKey:@"password"];
    [userTable setValue:[userDetail valueForKey:@"licensetype"] forKey:@"licensetype"];
    [userTable setValue:[userDetail valueForKey:@"phone_number"] forKey:@"phone_number"];
    
   // [NSPersistentStoreCoordinator managedObjectIDForURIRepresentation:userTable];

    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }else{
//        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
        [AppDelegate setUserEmailAndName:self.emailId.text userName:[userDetail valueForKey:@"firstname"] password:[userDetail valueForKey:@"password"]];
        [AppDelegate setLoggedIn:@"1"];
        [AppDelegate setRememberUserName:@"1"];
        
        [self performSegueWithIdentifier:@"RecordListSegue" sender:self];
        
       // [self performSegueWithIdentifier:@"loginSimpleApp" sender:self];
        
        //[AppDelegate showAlertViewWithTitle:nil Message:@"Registered Successfully"];
        //[self performSegueWithIdentifier:@"LoginSegue" sender:self];
    }
    
}

//-(void)searchEmail
//{
//    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
//    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:UserTable];
//    request.predicate = [NSPredicate predicateWithFormat:@"emailId == %@",_emailId.text];
//    NSArray *results = [managedObjectContext executeFetchRequest:request error:nil];
//    if(results.count)
//    {
//        NSLog(@"Email id already exists");
//        [AppDelegate showAlertViewWithTitle:@"Sorry!" Message:@"Email id already exists"];
//    }else{
//        NSLog(@"New Email id");
//        [self save];
//    }
//}

//-(void)searchUserName
//{
//    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
//    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:UserTable];
//    request.predicate = [NSPredicate predicateWithFormat:@"username == %@",_userName.text];
//    NSArray *results = [managedObjectContext executeFetchRequest:request error:nil];
//    if(results.count)
//    {
//        NSLog(@"Username already exists");
//        [AppDelegate showAlertViewWithTitle:@"Sorry!" Message:@"Username already exists"];
//    }else{
//        NSLog(@"New Username");
//        [self searchEmail];
//    }
//}
#pragma mark- HitApi
#pragma mark

-(void)registerApi
{
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
     
     [[NSUserDefaults standardUserDefaults] setValue:[[responseObject valueForKey:@"result"] valueForKey:@"userid"] forKey:kLoogedInUserID];
//     [[NSUserDefaults standardUserDefaults] setValue:userName forKey:@"UserEmail"];
//     [[NSUserDefaults standardUserDefaults] setValue:password forKey:@"password"];
     [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@ %@",[[responseObject valueForKey:@"result"] valueForKey:@"first_name"],[[responseObject valueForKey:@"result"] valueForKey:@"last_name"]]  forKey:@"UserName"];
     [[NSUserDefaults standardUserDefaults] setValue:[[responseObject valueForKey:@"result"] valueForKey:@"first_name"]  forKey:@"first_name"];
     [[NSUserDefaults standardUserDefaults] setValue:[[responseObject valueForKey:@"result"] valueForKey:@"last_name"]  forKey:@"last_name"];
     [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@ %@",[[responseObject valueForKey:@"result"] valueForKey:@"first_name"],[[responseObject valueForKey:@"result"] valueForKey:@"last_name"]]  forKey:@"UserName"];
     [[NSUserDefaults standardUserDefaults] setValue:[[responseObject valueForKey:@"result"] valueForKey:@"phone_number"] forKey:@"phoneNo"];
     
     
   
 
     catalog = [[responseObject valueForKey:@"result"] valueForKey:@"catalog"];
     dateCreate = [[responseObject valueForKey:@"result"] valueForKey:@"date_created"];
     email_validation_key = [[responseObject valueForKey:@"result"] valueForKey:@"email_validation_key"];
     firstName = [[responseObject valueForKey:@"result"] valueForKey:@"first_name"];
     lastName = [[responseObject valueForKey:@"result"] valueForKey:@"last_name"];
     licencType = [[responseObject valueForKey:@"result"] valueForKey:@"license_type"];
    [[NSUserDefaults standardUserDefaults] setValue: licencType forKey:@"license_type"];
     password = _password.text;
     phNo = [[responseObject valueForKey:@"result"] valueForKey:@"phone_number"];
      [[NSUserDefaults standardUserDefaults] setValue: phNo forKey:@"phoneNo"];
     userId = [[responseObject valueForKey:@"result"] valueForKey:@"userid"];
     userName = [[responseObject valueForKey:@"result"] valueForKey:@"username"];
     [AppDelegate setOwnerId:[[responseObject valueForKey:@"result"] valueForKey:@"userid"]];
   //  [self save];
       [[NSUserDefaults standardUserDefaults] synchronize];
     [self saveInSqlite];
 
 
     
     
    /* Login {
     clientip = "122.160.233.187";
     reason = "User has been logged in suceessfully";
     result =     {
     0 = "Amit@visions.net.in";
     1 = 118;
     2 = amit;
     3 = Singh;
     4 = 7895463258;
     5 = 1;
     6 = "2017-03-15 22:42:45";
     7 = "<null>";
     8 = 310315224245000000;
     9 = e1b35aPTONfXM;
     catalog = "<null>";
     "date_created" = "2017-03-15 22:42:45";
     "email_validation_key" = 310315224245000000;
     "first_name" = amit;
     "last_name" = Singh;
     "license_type" = 1;
     password = e1b35aPTONfXM;
     "phone_number" = 7895463258;
     userid = 118;
     username = "Amit@visions.net.in";
     };
     status = success;
     }   */

     
     
     }
     
     
         else{
            [AppDelegate hideHUDForView:self.view animated:YES];
           [AppDelegate showAlertViewWithTitle:@"Sorry!" Message:@"This Email ID  Already Exists."];
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
