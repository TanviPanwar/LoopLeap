//
//  AppDelegate.m
//  SimpleApp
//
//  Created by IOS1 on 1/25/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import <AddressBook/ABAddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "RecordListViewController.h"
#import "JKLLockScreenViewController.h"
#import <GoogleSignIn/GoogleSignIn.h>
#import <GoogleAPIClientForREST/GoogleAPIClientForREST-umbrella.h>
#import <AppAuth/AppAuth.h>
#import <GTMAppAuth/GTMAppAuth.h>
#import <GoogleMaps/GoogleMaps.h>
#import "Singleton.h"

#define ROOTVIEW [[[UIApplication sharedApplication] keyWindow] rootViewController]
@interface AppDelegate ()< JKLLockScreenViewControllerDataSource, JKLLockScreenViewControllerDelegate, GIDSignInDelegate> {
    
   NSMutableArray *sharedLocationArray;

}
@property (nonatomic, strong) NSString * enteredPincode;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
  
    
   // [DBManager getSharedInstance];
   //[AppDelegate getContactAuthorizationFromUser];
  // [AppDelegate getContacts];
    
    sharedLocationArray = [[NSMutableArray alloc] init];

    [GMSServices provideAPIKey:@"AIzaSyA7RNjmVhKx7j5IJDa1iIaY1XsNnNdJHzk"];
    
    GIDSignIn.sharedInstance.clientID = @"711978537769-upbltfk92h8uj8a2qj6dphl5bpc4rq7j.apps.googleusercontent.com";
    
    [GIDSignIn sharedInstance].delegate = self;
    
    if (GIDSignIn.sharedInstance.hasAuthInKeychain) {
        
        NSLog(@"%@", @"logged in");
        /* Code to show your tab bar controller */
    } else {
        /* code to show your login VC */
        
       NSLog(@"%@", @"logged out");
              
        // [[GIDSignIn sharedInstance] signInSilently];
    }
   
    
    if([AppDelegate isLoggedIn]&&[AppDelegate getUserEmail])
    {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        RecordListViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:@"RecordListViewController"];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:ivc];
        self.window.rootViewController = nav;
       //  [ROOTVIEW presentViewController:ivc animated:YES completion:^{}];
        
    }
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    
    if ([Singleton singleton].globalArray.count> 0){
        
      [[Singleton singleton].timer invalidate];
        
    }
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if ([[[NSUserDefaults standardUserDefaults]  valueForKey:@"switch"] isEqualToString:@"On"])
    {
        self.enteredPincode = [[NSUserDefaults standardUserDefaults] valueForKey:@"pin"];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        JKLLockScreenViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"JKLLockScreenViewController"];
        [viewController setLockScreenMode:0];    // enum { LockScreenModeNormal, LockScreenModeNew, LockScreenModeChange }
        [viewController setDelegate:self];
        [viewController setDataSource:self];
        [viewController setTintColor:[UIColor redColor]];
        
        //  [self presentViewController:viewController animated:YES completion:NULL];
        
        [ROOTVIEW presentViewController:viewController animated:YES completion:^{}];
    }
    

    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateLocationOnBackground" object:self];

    
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self activeStatusAPI];
    
    }

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<NSString *, id> *)options {
    
    return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                      annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:sourceApplication
                                      annotation:annotation];
}

- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    // Perform any operations on signed in user here.
    NSString *userId = user.userID;                  // For client-side use only!
    NSString *idToken = user.authentication.idToken; // Safe to send to the server
    NSString *fullName = user.profile.name;
    NSString *givenName = user.profile.givenName;
    NSString *familyName = user.profile.familyName;
    NSString *email = user.profile.email;
    
    
    
    
    NSLog(@"%@userId and token", userId, idToken);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:
     @"HideGoogleSignIn" object:nil userInfo:nil];
    
    // ...
}

- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    // Perform any operations when the user disconnects from app here.
    // ...
}



-(void)activeStatusAPI {
    if([AppDelegate isLoggedIn]&&[AppDelegate getUserEmail]) {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@"1" forKey:@"user_status"];
    [params setObject:[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID] forKey:@"user_id"];
    [params setObject:kActiveStatus forKey:kDefault];
    NSString *registerUrl=[NSString stringWithFormat:@"%@",HostUrl];
    NSLog(@"Detail Dict%@", params);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:registerUrl parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
       
        NSLog(@"Success: %@\n ***** %@", operation.responseString, responseObject);
        id status= [responseObject valueForKey:@"status"];
        if([status isKindOfClass:[NSString class]]){
            if([status isEqualToString:@"success"]){
            }
            else{
              
            }
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        
       
    }];
}
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "Visions.SimpleApp" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SimpleApp" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SimpleApp.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

+(void)showAlertViewWithTitle:(NSString*)title Message:(NSString*)message {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];

}


+ (BOOL) validatePhone: (NSString *) phone
{
    
   NSString *phoneRegex = @"[0-9]{10}";
   NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
   return[test evaluateWithObject:phone];
}

+ (BOOL) validateEmail: (NSString *) emailAddress {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return[emailTest evaluateWithObject:emailAddress];
}

+(void)setUserEmailAndName:(NSString *)userEmail userName:(NSString *)userName password:(NSString*)password
{
    [[NSUserDefaults standardUserDefaults]setObject:userEmail forKey:@"UserEmail"];
    [[NSUserDefaults standardUserDefaults]setObject:userName forKey:@"UserName"];
     [[NSUserDefaults standardUserDefaults]setObject:password forKey:@"password"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+(void)setRememberUserName:(NSString*)str{
    [[NSUserDefaults standardUserDefaults]setObject:str forKey:@"RememberUserName"];
    [[NSUserDefaults standardUserDefaults]synchronize];

}
+(void)setOwnerId:(NSString*)str{
    [[NSUserDefaults standardUserDefaults]setObject:str forKey:@"ownerId"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
}

+(void)setUserPassword:(NSString *)password{
    [[NSUserDefaults standardUserDefaults]setObject:password forKey:@"password"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
}

+(void)setLoggedIn:(NSString*)str{
    [[NSUserDefaults standardUserDefaults]setObject:str forKey:@"isLoggedIn"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
}

+(NSString *)getRememberUserName{
    return [[NSUserDefaults standardUserDefaults]valueForKey:@"RememberUserName"];
}
+(NSString *)getOwnerId{
    return [[NSUserDefaults standardUserDefaults]valueForKey:@"ownerId"];
}

+(NSString *)getUserEmail{
    NSString *userEmail=[[NSUserDefaults standardUserDefaults]valueForKey:@"UserEmail"];
    return userEmail;
}
+(NSString *)getUserPassword{
    return [[NSUserDefaults standardUserDefaults]valueForKey:@"password"];
}

+(NSString *)getUserName{
    NSString *userEmail=[[NSUserDefaults standardUserDefaults]valueForKey:@"UserName"];
    return userEmail;
}
+(BOOL )isLoggedIn{
    return [[[NSUserDefaults standardUserDefaults]valueForKey:@"isLoggedIn"] boolValue];
}

+ (MBProgressHUD *)showHUDAddedTo:(UIView *)view animated:(BOOL)animated withLabel:(NSString *)labelText detailsLabel:(NSString *)detailsText
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    [hud setDimBackground:YES];
    [view addSubview:hud];
    [hud show:animated];
    [hud setLabelText:labelText];
    [hud setDetailsLabelText:detailsText];
    
    return hud;
}

+ (BOOL)hideHUDForView:(UIView *)view animated:(BOOL)animated
{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
    if (hud != nil)
    {
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:animated];
        return YES;
    }
    return NO;
}

-(BOOL)searchRecord:(NSString*)record_title category:(NSString*)category
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RecordTable];
    
    request.predicate = [NSPredicate predicateWithFormat:@"record_title == %@ && category_name == %@  && email_id == %@ ",record_title,category,[AppDelegate getUserEmail]];
    NSArray *results = [managedObjectContext executeFetchRequest:request error:nil];
    if(results.count)
    {
        return YES;
    }
    return NO;
}

-(NSString*)searchCategory:(NSString*)category
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:CategoryTable];
    
    request.predicate = [NSPredicate predicateWithFormat:@"category_name == %@  && email_id == %@ ",category,[AppDelegate getUserEmail]];
    NSArray *results = [managedObjectContext executeFetchRequest:request error:nil];
    if(results.count)
    {
        return [results[0] valueForKey:@"category_name"];
    }
    return @"";
}



+(NSMutableArray *)getContactAuthorizationFromUser{
    
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


+(NSMutableArray *)getContacts{
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

+(AppDelegate* )appdelegate
{
    
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
}

#pragma mark -
#pragma mark YMDLockScreenViewControllerDelegate
- (void)unlockWasCancelledLockScreenViewController:(JKLLockScreenViewController *)lockScreenViewController {
    
    NSLog(@"LockScreenViewController dismiss because of cancel");
}

- (void)unlockWasSuccessfulLockScreenViewController:(JKLLockScreenViewController *)lockScreenViewController pincode:(NSString *)pincode {
    self.enteredPincode = pincode;
    
    
}

#pragma mark -
#pragma mark YMDLockScreenViewControllerDataSource
- (BOOL)lockScreenViewController:(JKLLockScreenViewController *)lockScreenViewController pincode:(NSString *)pincode {
    
#ifdef DEBUG
    NSLog(@"Entered Pincode : %@", self.enteredPincode);
#endif
    
    return [self.enteredPincode isEqualToString:pincode];
}




@end
