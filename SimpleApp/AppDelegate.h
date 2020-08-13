//
//  AppDelegate.h
//  SimpleApp
//
//  Created by IOS1 on 1/25/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "MBProgressHUD.h"
#import "Constant.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"
#import "JKLLockScreenViewController.h"
#import "DBManager.h"
#import <AppAuth/AppAuth.h>
#import <GTMAppAuth/GTMAppAuth.h>

#define UserTable @"User"
#define CategoryTable @"MyCategory"
#define RecordTable @"Record"

#define FromCategory 21
#define FromRecord   22
#define FromNote     23

@interface AppDelegate : UIResponder <UIApplicationDelegate, JKLLockScreenViewControllerDataSource, JKLLockScreenViewControllerDelegate>


@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property(nonatomic, nullable)
id<OIDAuthorizationFlowSession> currentAuthorizationFlow;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


+(void)showAlertViewWithTitle:(NSString*)title Message:(NSString*)message;
+ (BOOL) validateEmail: (NSString *) emailAddress;
+ (BOOL) validatePhone: (NSString *) phone;
+(void)setUserEmailAndName:(NSString *)userEmail userName:(NSString *)userName password:(NSString*)password;
+(void)setUserPassword:(NSString*)password;
+(void)setRememberUserName:(NSString*)str;
+(void)setLoggedIn:(NSString*)str;

+(void)showPopUpAlertViewWithTitle:(NSString*)title Message:(NSString*)message placeHolder:(NSString*)placeHolder dbName:(NSString*)dbName;
+(void)setOwnerId:(NSString*)str;



+(NSString *)getOwnerId;
+(NSString *)getRememberUserName;
+(NSString *)getUserName;
+(NSString*)getUserEmail;
+(NSString*)getUserPassword;
 
+(BOOL )isLoggedIn;


+ (MBProgressHUD *)showHUDAddedTo:(UIView *)view animated:(BOOL)animated withLabel:(NSString *)labelText detailsLabel:(NSString *)detailsText;
+ (BOOL)hideHUDForView:(UIView *)view animated:(BOOL)animated;

-(BOOL)searchRecord:(NSString*)record_title category:(NSString*)category;
-(NSString*)searchCategory:(NSString*)category;


+(NSMutableArray *)getContactAuthorizationFromUser;
+(NSMutableArray *)getContacts;
@end

