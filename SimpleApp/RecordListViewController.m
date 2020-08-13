//
//  RecordListViewController.m
//  SimpleApp
//
//  Created by IOS1 on 1/27/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import "RecordListViewController.h"
#import "NoteDetailViewController.h"
#import "AppDelegate.h"
#import "SearchTableViewCell.h"
#include "SearchObject.h"
#import "CategoryListViewController.h"
#import "JKLLockScreenViewController.h"
#import "SettingViewController.h"
#import "BrowseCategoryViewController.h"
#import "CategorySearchViewController.h"
#import "AddInfoViewController.h"
#import "RenameCatViewController.h"
#import "CollectionTableViewCell.h"
#import "CategoryCollectionViewCell.h"
#import <CoreLocation/CoreLocation.h>
#import "Singleton.h"
#import "ShowTeamMapViewController.h"



#define ROOTVIEW [[[UIApplication sharedApplication] keyWindow] rootViewController]
@interface RecordListViewController ()
< JKLLockScreenViewControllerDataSource, JKLLockScreenViewControllerDelegate , UITableViewDelegate , UITableViewDataSource , UICollectionViewDataSource , UICollectionViewDelegate, CLLocationManagerDelegate>

{
    NSMutableArray *recordArr,*categoryArr, *categoryListArray,*dbArray;
    BOOL isSearchActive;
    NSMutableArray *searchResultArr;
    NSInteger selectedIndex;
    NSArray *searchRecorArr;
    NSArray *searchNoteArr;
    NSArray *searchCategoryArr;
    NSString *selectedDBID;
    NSString *selectedDB;
    NSString *AdminStatus;
    NSInteger currentIndex;
    NSString *selectedStorageType;
    NSMutableArray * sharedLocationArray;
    float latitude ;
    float longitude ;
    long long Admin;
    long long LocationStatus;
 
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSString * enteredPincode;
@property (strong, nonatomic) CLLocationManager *locationManager;


@end

@implementation RecordListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    sharedLocationArray = [[NSMutableArray alloc] init];
    
    [self sharedDbApi];
    
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
    
    
    [self.refreshButton setEnabled:YES];
   
    
                NSArray *defaultDbArray = [[DBManager getSharedInstance]getDefaultDBData];
    
                NSString *dbID =   [[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentDbID"];
                NSString *dbName =   [[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentDbName"];
                NSString *storageType =   [[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentStorageType"];
    
                NSString *adminType =   [[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentAdminType"];
    
                NSString *locationStatusType =   [[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentLocationType"];
      
    
    
                if ([dbID isEqualToString:@""] || [dbID isEqual:nil]|| [dbID isKindOfClass:[NSNull class]]) {
                    if (defaultDbArray.count > 0) {
                        DbObject *dbObject = [defaultDbArray objectAtIndex:0];
                        self.title =  dbObject.DBName;
                        selectedDB =  dbObject.DBName;
                        selectedStorageType = dbObject.StorageType;
                        AdminStatus =  [NSString stringWithFormat:@"%lld",dbObject.Admin];
                        Admin = dbObject.Admin;
                        LocationStatus = dbObject.LcationStatus;
                        

                        selectedDBID =  [NSString stringWithFormat:@"%lld",dbObject.DatabaseID];
                        [[NSUserDefaults standardUserDefaults] setValue:selectedDBID forKey:@"CurrentDbID"];
                        [[NSUserDefaults standardUserDefaults] setValue:selectedDB forKey:@"CurrentDbName"];
                        [[NSUserDefaults standardUserDefaults] setValue:selectedStorageType forKey:@"CurrentStorageType"];
                        [_databaseTxt setText:[NSString stringWithFormat:@"Current Database: %@",selectedDB]];
                        
                        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%lld",Admin] forKey:@"CurrentAdminType"];
                        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%lld",LocationStatus] forKey:@"CurrentLocationType"];
                        
                        
                        
                        if ((Admin == 0) && (LocationStatus == 0)) {
                            
                           _addRecordBtn.hidden = YES;
                            _showMapBtn.hidden = YES;
                            
                        } else  if ((Admin == 1) && (LocationStatus == 1)) {
                            
                           _addRecordBtn.hidden = NO;
                            _showMapBtn.hidden = NO;
                        }
                        
                        else if ((Admin == 1) && (LocationStatus == 0)) {
                            
                        _addRecordBtn.hidden = NO;
                        _showMapBtn.hidden = YES;
                            
                        } else  if ((Admin == 0) && (LocationStatus == 1)) {
                            
                           _addRecordBtn.hidden = YES;
                            _showMapBtn.hidden = NO;
                        }
                        
                        
                        
                        
                        
               
                        
                        [_picker selectRow:0 inComponent:0 animated:YES];
                    }
                }
                
                else {
                    
                    selectedDB = dbName;
                    self.title = dbName;
                    selectedDBID = dbID;
                    AdminStatus =  adminType;
                    [_databaseTxt setText:[NSString stringWithFormat:@"Current Database: %@",selectedDB]];
                    _storageTypeLabel.text = storageType;
                    
                    
                    
                    if (([adminType  isEqual: @"0"]) && ([locationStatusType  isEqual: @"0"])) {
                        
                      _addRecordBtn.hidden = YES;
                        _showMapBtn.hidden = YES;
                        
                    } else  if (([adminType  isEqual: @"1"]) && ([locationStatusType  isEqual: @"1"])) {
                        
                       _addRecordBtn.hidden = NO;
                        _showMapBtn.hidden = NO;
                    }
                    
                  else if (([adminType  isEqual: @"1"]) && ([locationStatusType  isEqual: @"0"])) {
                        
                       _addRecordBtn.hidden = NO;
                        _showMapBtn.hidden = YES;
                        
                    } else  if (([adminType  isEqual: @"0"]) && ([locationStatusType  isEqual: @"1"])) {
                        
                        _addRecordBtn.hidden = YES;
                        _showMapBtn.hidden = NO;
                    }
                                    
                    
                }
                
                
                
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
                    
                    [self presentViewController:viewController animated:YES completion:^{}];
                }
                
                
                
                
                // Do any additional setup after loading the view.
                self.tableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
                recordArr=[[NSMutableArray alloc]init];
                categoryListArray=[[NSMutableArray alloc]init];
                
                categoryArr=[[NSMutableArray alloc]init];
                searchResultArr=[[NSMutableArray alloc]init];
                searchNoteArr=[[NSArray alloc]init];
                isSearchActive=NO;
                
                
    
                [[NSNotificationCenter  defaultCenter] addObserver:self selector:@selector(refreshDatabase) name:@"RefreshDatabase" object:nil];
    
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdateInForeground:) name:@"UpdateLocationOnBackground" object:nil];
    
             [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdateOnSharing:) name:@"UpdateLocationOnSharing" object:nil];
    

    
//    [Singleton singleton].timer =  [NSTimer scheduledTimerWithTimeInterval: 60
//                                                            target: self
//                                                          selector:@selector(onTick:)
//                                                          userInfo: nil repeats:YES];
//
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if([[NSUserDefaults standardUserDefaults]boolForKey:@"FirstTimeLogin"]) {
        [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"GridView"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self refereshDataAfterLogin:^(BOOL something) {
            if (something) {
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshDatabase" object:self];
                  [self getMyDBListFromSqlite];
            }
        }];
        }
     if ([[NSUserDefaults standardUserDefaults]boolForKey:@"GridView"]) {
         isGridView = true;
     }else{
         isGridView = false;
     }
    [self.tableView reloadData];
    
    
}
    

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
   
}
-(void)refreshDatabase {
    NSString *dbID =  [[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentDbID"];
    NSString *dbName =   [[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentDbName"];
    NSString *storageType =   [[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentStorageType"];
    NSString *adminType =   [[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentAdminType"];
    NSString *locationStatusType =   [[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentLocationType"];

    self.title = dbName;
    selectedDB  = dbName;
    selectedStorageType = storageType;
    [categoryListArray removeAllObjects];
    categoryListArray =  [[DBManager getSharedInstance] getcategoryListOfSelectedDB:dbID];
    selectedDBID = dbID;
    _databaseTxt.text = [NSString stringWithFormat:@"Current Database: %@",selectedDB];
    AdminStatus =  adminType;

    
    if (([adminType  isEqual: @"0"]) && ([locationStatusType  isEqual: @"0"])) {
        
        _addRecordBtn.hidden = YES;
        _showMapBtn.hidden = YES;
        
    } else  if (([adminType  isEqual: @"1"]) && ([locationStatusType  isEqual: @"1"])) {
        
       _addRecordBtn.hidden = NO;
        _showMapBtn.hidden = NO;
    }
    
    else if (([adminType  isEqual: @"1"]) && ([locationStatusType  isEqual: @"0"])) {
        
       _addRecordBtn.hidden = NO;
       _showMapBtn.hidden = YES;
        
    } else  if (([adminType  isEqual: @"0"]) && ([locationStatusType  isEqual: @"1"])) {
        
        _addRecordBtn.hidden = YES;
        _showMapBtn.hidden = NO;
    }

    
    [self.tableView reloadData];
    
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    latitude = manager.location.coordinate.latitude;
    longitude = manager.location.coordinate.longitude;
  
}


-(void)onTick:(NSTimer *)timer {
    //do smth
    NSLog(@"%@", @"60 seconds" );
    
    [Singleton singleton].globalCount = true;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
//if ((sharedLocationArray.count > 0) && (sharedLocationArray != nil)) {
            
            [self locationBackgroundUpdate];
            
        //}
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            //stop your HUD here
            //This is run on the main thread
            
            
        });
    });
    
    
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


-(void)locationBackgroundUpdate{
    
    // [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
    NSMutableDictionary *userDetail = [[NSMutableDictionary alloc] init];
    
    [userDetail setValue:kGetGeneral_Location_Update forKey:kDefault];
    
    // kLocationUpdateCrown
    [userDetail setValue:[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID] forKey:@"userid"];
    
    NSError *error;
    
    NSString *createJSONStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[Singleton singleton].globalArray
                                                                                             options:NSJSONWritingPrettyPrinted
                                                                                               error:&error] encoding:NSUTF8StringEncoding];
    
    [userDetail setValue:createJSONStr forKey:@"dbids"];
    [userDetail setValue:[NSString stringWithFormat:@"%f", latitude] forKey:@"lat"];
    
    [userDetail setValue:[NSString stringWithFormat:@"%f", longitude] forKey:@"long"];
    [userDetail setValue:@"1" forKey:@"bool"];
    

    NSLog(@"UsetDetail Dict%@", userDetail);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:HostUrl parameters:userDetail success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        [AppDelegate hideHUDForView:self.view animated:YES];
        NSLog(@"Success: %@\n ***** %@", operation.responseString, responseObject);
        id status= [responseObject valueForKey:@"status"];
        if([status isKindOfClass:[NSString class]]){
            if([status isEqualToString:@"success"]) {
                
                
                
            } else
            {
                
            }
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        
        [AppDelegate hideHUDForView:self.view animated:YES];
        //if(dict)
        //        [AppDelegate showAlertViewWithTitle:@"Network Error" Message:@"Please Check Your Internet Connection."];
    }];
    
}


- (void)locationUpdateInForeground:(NSNotification *)notification {
 
    
    if ([Singleton singleton].globalArray.count> 0) {
          
         [Singleton singleton].globalCount = true;

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      
                    [self locationBackgroundUpdate];
                    
          
            });
        
      [Singleton singleton].timer =  [NSTimer scheduledTimerWithTimeInterval: 60
                                         target: self
                                       selector:@selector(onTick:)
                                       userInfo: nil repeats:YES];
        
    }
    
}

- (void)locationUpdateOnSharing:(NSNotification *)notification {
    
    [self sharedDbApi];
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


-(void)getMyDBListFromSqlite {
    
    dbArray = [[NSMutableArray alloc] init];
    NSString *ownerID = [[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID];
    
   // dbArray = [[DBManager getSharedInstance]getDataFromMyDataBase:ownerID];
    dbArray = [[DBManager getSharedInstance]getAllDataFromMyDataBase];
    
    if ((dbArray.count > 0) && ([[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentDbName"] == nil)) {
        MyDataBaseObject *obj = [dbArray objectAtIndex:0];
        selectedDB = obj.DBName;
         [_databaseTxt setText:[NSString stringWithFormat:@"Current Database: %@",selectedDB]];
        self.title =  obj.DBName;
        selectedDB =  obj.DBName;
        selectedStorageType = obj.StorageType;
       _storageTypeLabel.text = selectedStorageType;
        
        AdminStatus =  [NSString stringWithFormat:@"%lld",obj.Admin];
        Admin = obj.Admin;
        LocationStatus = obj.LocationStatus;
        
        selectedDBID =  [NSString stringWithFormat:@"%lld",obj.Databaseid];
        [[NSUserDefaults standardUserDefaults] setValue:selectedDBID forKey:@"CurrentDbID"];
        [[NSUserDefaults standardUserDefaults] setValue:selectedDB forKey:@"CurrentDbName"];
        [[NSUserDefaults standardUserDefaults] setValue:selectedStorageType forKey:@"CurrentStorageType"];
        
        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%lld",Admin] forKey:@"CurrentAdminType"];
        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%lld",LocationStatus] forKey:@"CurrentLocationType"];
        
        if ((Admin == 0) && (LocationStatus == 0)) {
            
           _addRecordBtn.hidden = YES;
            _showMapBtn.hidden = YES;
            
        } else  if ((Admin == 1) && (LocationStatus == 1)) {
            
           _addRecordBtn.hidden = NO;
            _showMapBtn.hidden = NO;
        }
        
        else if ((Admin == 1) && (LocationStatus == 0)) {
            
        _addRecordBtn.hidden = NO;
        _showMapBtn.hidden = YES;
            
        } else  if ((Admin == 0) && (LocationStatus == 1)) {
            
           _addRecordBtn.hidden = YES;
            _showMapBtn.hidden = NO;
        }
        
        
    
    } else if(dbArray.count > 0)  {
        
        NSString *dbID =   [[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentDbID"];
        NSString *locationStatusType =   [[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentLocationType"];
        
        NSArray *objcArray = [[NSMutableArray alloc]init];
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(SELF.Databaseid = %lld)", [dbID longLongValue]];
        
        objcArray = [dbArray filteredArrayUsingPredicate:predicate];
        NSLog(@"HERE %@",objcArray);
        
        if(objcArray.count > 0) {
        
        MyDataBaseObject *obj1 = [objcArray objectAtIndex:0];
        
        AdminStatus =  [NSString stringWithFormat:@"%lld",obj1.Admin];
        Admin = obj1.Admin;
        LocationStatus = obj1.LocationStatus;
        
            if ((dbArray.count > 0) && !([locationStatusType isEqualToString:[NSString stringWithFormat:@"%lld",obj1.LocationStatus]])) {
                
                if ((Admin == 0) && (LocationStatus == 0)) {
                    
                    _addRecordBtn.hidden = YES;
                    _showMapBtn.hidden = YES;
                    
                } else  if ((Admin == 1) && (LocationStatus == 1)) {
                    
                    _addRecordBtn.hidden = NO;
                    _showMapBtn.hidden = NO;
                }
                
                else if ((Admin == 1) && (LocationStatus == 0)) {
                    
                    _addRecordBtn.hidden = NO;
                    _showMapBtn.hidden = YES;
                    
                } else  if ((Admin == 0) && (LocationStatus == 1)) {
                    
                    _addRecordBtn.hidden = YES;
                    _showMapBtn.hidden = NO;
                }
  
                [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%lld",Admin] forKey:@"CurrentAdminType"];
                [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%lld",LocationStatus] forKey:@"CurrentLocationType"];
                
            }
        }
    
    }
  
    [self.picker reloadAllComponents];
}

-(void)viewWillAppear:(BOOL)animated {
    [categoryArr removeAllObjects ];
    [categoryListArray removeAllObjects];
    [recordArr removeAllObjects];
    [self getMyDBListFromSqlite];
    
    if (![selectedDBID isEqualToString:@""] ) {
    long long ID = selectedDBID.longLongValue;
    MyDataBaseObject *obj = [[MyDataBaseObject alloc] init];
    obj.Databaseid = ID;
    obj.DBName = selectedDB;
    NSPredicate *exists = [NSPredicate predicateWithFormat:
                           @"SELF.Databaseid == %lld", ID];
    NSUInteger index = [dbArray indexOfObjectPassingTest:
                        ^(id obj, NSUInteger idx, BOOL *stop) {
                            return [exists evaluateWithObject:obj];
                        }];
   
    if (index != NSNotFound) {
    [_picker selectRow:index inComponent:0 animated:NO];
    }
    }
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBarHidden=NO;
    self.navigationItem.hidesBackButton=YES;
    
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID]);
    
    recordArr  = [[DBManager getSharedInstance] getNotesDataFromUserNotes:selectedDBID];
    categoryListArray =  [[DBManager getSharedInstance] getcategoryListOfSelectedDB : selectedDBID];
    for (int i = 0; i < recordArr.count; i++) {
        NotesObject *notes =  [recordArr objectAtIndex:i];
        NSMutableDictionary * dict  = [[NSMutableDictionary alloc] init];
        [dict setValue:notes.Title forKey:@"title"];
        [dict setValue:notes.Note forKey:@"Note"];
        [dict setValue:notes.categoryName forKey:@"category_name"];
        
        [categoryArr addObject:dict];
    }
    [_tableView reloadData];
    
//    [self fetchRecord];
//    [self fetchCategory];
    //[self getCategoryList];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self cancelSearchBr];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
-(void)fetchRecord
{
    // Fetch the devices from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:RecordTable];
    NSSortDescriptor *sdSortDate = [NSSortDescriptor sortDescriptorWithKey:@"record_time" ascending:NO];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"email_id == %@ ",[AppDelegate getUserEmail]];
    fetchRequest.sortDescriptors=@[sdSortDate];
    // fetchRequest.predicate = [NSPredicate predicateWithFormat:@"email_id == %@",[AppDelegate getUserEmail]];
    recordArr = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    [self.tableView reloadData];
    
}




#pragma mark- Navigation
#pragma mark-
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];

    if([segue.identifier isEqualToString:@"MemoDetail"])
    {
        NoteDetailViewController *obj=segue.destinationViewController;
        obj.selectedIndex=selectedIndex;
        if(isSearchActive)
        {
            switch(selectedIndex)
            {
                case 0:
                {
                    obj.recordArr=[NSMutableArray arrayWithArray:searchRecorArr];
                    obj.selectedIndex=0;
                }
                    break;
                    
                case 1:
                {
                    obj.recordArr=[NSMutableArray arrayWithArray:searchNoteArr];
                    obj.selectedIndex=0;
                }
                    break;
                    
                case 2:
                {
                    obj.recordArr=[NSMutableArray arrayWithArray:searchCategoryArr];
                    obj.selectedIndex=0;
                }
                    
                    break;

                   
            }
            
        }else{
            
            obj.recordArr=recordArr;
//            obj.notObj = [recordArr objectAtIndex:selectedIndex];
        }
       

    }else if([segue.identifier isEqualToString:@"CategorySegue"])
    {
        CategoryListViewController *obj=segue.destinationViewController;
        obj.categoryArr=[NSMutableArray arrayWithArray:searchCategoryArr];
    
        
    }
    
    else if([segue.identifier isEqualToString:@"categorySearch"])
    {
        CategorySearchViewController *obj=segue.destinationViewController;
        obj.searchCategoryArr=[NSMutableArray arrayWithArray:searchCategoryArr];
        
        
    }
    
    else if ([segue.identifier isEqualToString:@"AddInfoSegue"]){
        AddInfoViewController *obj = segue.destinationViewController;
        obj.Database = selectedDB;
        obj.DatabaseID = selectedDBID;
    }
}

-(void)getCategoryList {
    
    [recordArr removeAllObjects];
    [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
    //        NSString *registerUrl=[NSString stringWithFormat:@"%@",HostUrl];
    NSMutableDictionary *userDetail = [[NSMutableDictionary alloc]init];
    [userDetail setValue:kFetchCategoryList forKey:kDefault];
    [userDetail setValue:[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID] forKey:kLoogedInUserID];
    NSLog(@"UsetDetail Dict%@", userDetail);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:HostUrl parameters:userDetail success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSLog(@"Success: %@\n ***** %@", operation.responseString, responseObject);
        id status= [responseObject valueForKey:@"status"];
        if([status isKindOfClass:[NSString class]]){
            [AppDelegate hideHUDForView:self.view animated:YES];
            if([status isEqualToString:@"success"]) {
                
                
                NSArray *dbArr = [responseObject valueForKey:@"MyDatabase"];
                
                for (int i= 0; i <[dbArr count]; i++) {
                    
                    NSString *myJsonString = [[[responseObject  valueForKey:@"MyDatabase"] objectAtIndex:i] valueForKey:@"Catalog"];
                    NSData *jsonData = [myJsonString dataUsingEncoding:NSUTF8StringEncoding];
                    NSError *e;
                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:nil error:&e];
                    NSLog(@"%@", dict);
                    NSArray *titleArr = [dict valueForKey:@"data"];
                    for (int j = 0; j < [titleArr count]; j++) {
                        
                        NSMutableDictionary *dbDict = [[NSMutableDictionary alloc] init];
                        [dbDict setValue:[dict valueForKey:@"myDBID"] forKey:@"DatabaseId"];
                        if ([[dict valueForKey:@"category"]isKindOfClass:[NSNull null]]) {
                             [dbDict setValue:@"" forKey:@"CategoryName"];
                        }
                        else {
                             [dbDict setValue:[dict valueForKey:@"category"] forKey:@"CategoryName"];
                        }
                        [dbDict setValue:[[titleArr objectAtIndex:j] valueForKey:@"Notes_id"] forKey:@"NoteID"];
                        [dbDict setValue:[[titleArr objectAtIndex:j] valueForKey:@"title"] forKey:@"title"];
                        [dbDict setValue:[[titleArr objectAtIndex:j] valueForKey:@"note"] forKey:@"Note"];
                        [dbDict setValue:[[titleArr objectAtIndex:j] valueForKey:@"File_upload"] forKey:@"FileUpload"];
                        [recordArr addObject:dbDict];
                        
                    }
                }
                
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:recordArr forKey:@"CategoryArr"];
                [userDefaults synchronize];
                [_tableView reloadData];
                
            }
            else{
                [AppDelegate hideHUDForView:self.view animated:YES];
            }
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        [AppDelegate hideHUDForView:self.view animated:YES];
        //if(dict)
        [AppDelegate showAlertViewWithTitle:@"Network Error" Message:@"Please Check Your Internet Connection."];
    }];
}


#pragma mark - UITableViewDelegate & UITableViewDataSource
#pragma mark-

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
      if(isSearchActive)
            return searchResultArr.count;
        
    
    else {
        if (isGridView) {
            return 1;
        }
        return categoryListArray.count;
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
   
    
    if (isGridView) {
        return  (50 * (categoryListArray.count /2))+ 100;
    }else {
        return  50;
    }
    
    
   
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
   
        
    
    if(isSearchActive)
    {
        SearchObject *obj=searchResultArr[indexPath.row];
        SearchTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"SearchCellIdentifier" forIndexPath:indexPath];
        [cell.title setTitle:obj.key forState:UIControlStateNormal];
        cell.title.layer.cornerRadius=5;
        cell.title.layer.borderWidth=1;
        cell.countLable.text=[NSString stringWithFormat:@"Found %@ results in",obj.value];
        if([obj.value intValue]==0)
            cell.title.layer.opacity=0.5;
        else
            cell.title.layer.opacity=1.0;
        return cell;
    }
    
    
    else {
        if (isGridView) {
            CollectionTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"collectionCell" forIndexPath:indexPath];
            
            [cell.collectionView reloadData];
            return cell;
            
        }else {

      UITableViewCell *cell= [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
       // if (recordArr.count >0) {
            CategoryObject *notObj =  [categoryListArray objectAtIndex:indexPath.row];
           // cell.textLabel.text= notObj.Title;
            cell.detailTextLabel.text= @"";
            cell.textLabel.text   =  notObj.CategoryName;
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                                   initWithTarget:self
                                                   action:@selector(handleLongPress:)];
        longPress.minimumPressDuration = 1.0;

        cell.textLabel.userInteractionEnabled = YES;
        [cell addGestureRecognizer:longPress];
        cell.tag = indexPath.row;
      //  }

      return cell;
      }
    }
    
    
        
    
    
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *str =  [[NSUserDefaults standardUserDefaults]valueForKey:@"SelectedCategory"];
    selectedIndex=indexPath.row;
       if(isSearchActive)
    {
        switch(indexPath.row)
        {
            case 0:
            {
                if(searchRecorArr.count)
                [self performSegueWithIdentifier:@"MemoDetail" sender:self];
                // searchCategoryArr
                // CategorySegue
            }
                break;
                
            case 1:
            {
                if(searchNoteArr.count)
                [self performSegueWithIdentifier:@"MemoDetail" sender:self];
            }
                break;
                
            case 2:
            {
                
                
                if(searchCategoryArr.count)
                [self performSegueWithIdentifier:@"categorySearch" sender:self];
                
                           }
                break;
            
        }
    }else {
        
        CategoryObject *notObj =  [categoryListArray objectAtIndex:indexPath.row];
        BrowseCategoryViewController * browserVC =  [self.storyboard instantiateViewControllerWithIdentifier:@"BrowseCategoryViewController"];
        browserVC.catTittle = notObj.CategoryName;
        browserVC.catId = [NSString stringWithFormat:@"%lld",notObj.CategoryID];
        browserVC.DBId = selectedDBID;
        [self.navigationController pushViewController:browserVC animated:YES];
        
        
        //[self performSegueWithIdentifier:@"MemoDetail" sender:self];
    }
    
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    
    currentIndex = gesture.view.tag;
   CategoryObject *obj=  [categoryListArray objectAtIndex:currentIndex];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentIndex inSection:0];
    
    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:@"Selected  Category"      //  Must be "nil", otherwise a blank title area will appear above our two buttons
                                message:obj.CategoryName
                                preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* button0 = [UIAlertAction
                              actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleCancel
                              handler:^(UIAlertAction * action)
                              {
                                  //  UIAlertController will automatically dismiss the view
                              }];
    
    UIAlertAction* button1 = [UIAlertAction
                              actionWithTitle:@"Delete"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @""
                                                                                                            message: @"Are you sure you want  to delete this category?"
                                                                                                     preferredStyle:UIAlertControllerStyleAlert];
                                  [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                                              {
                                                                  
                                                                  
                                                                  CategoryObject *notObj =  [categoryListArray objectAtIndex:indexPath.row];
                                                                  
                                                                  [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
                                                                  
                                                                  NSMutableDictionary *userDetail = [[NSMutableDictionary alloc]init];
                                                                  [userDetail setValue:Kdeletecategory forKey:kDefault];
                                                                  [userDetail setValue:[NSNumber numberWithLong:notObj.CategoryID] forKey:@"category_id"];
                                                                  
                                                                  NSLog(@"UsetDetail Dict%@", userDetail);
                                                                  
                                                                  
                                                                  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                                                                  
                                                                  [manager POST:HostUrl parameters:userDetail success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                                                                      
                                                                      
                                                                      NSLog(@"Success: %@\n ***** %@", operation.responseString, responseObject);
                                                                      id status= [responseObject valueForKey:@"status"];
                                                                      if([status isKindOfClass:[NSString class]]){
                                                                          [AppDelegate hideHUDForView:self.view animated:YES];
                                                                          if([status isEqualToString:@"Success"]) {
                                                                              
                                                                              [[DBManager getSharedInstance]deleteCateGory:[NSString stringWithFormat:@"%lld",notObj.CategoryID]];
                                                                              [self viewWillAppear:YES];
                                                                              [[NSUserDefaults standardUserDefaults]setValue:@""forKey:@"SelectedCategory"];
                                                                              
                                                                          }
                                                                          
                                                                          else{
                                                                              [AppDelegate hideHUDForView:self.view animated:YES];
                                                                              //                    [AppDelegate showAlertViewWithTitle:@"Sorry!" Message:@"Email already exists"];
                                                                          }
                                                                      }
                                                                  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                                                                      NSLog(@"Error: %@ ***** %@", operation.responseString, error);
                                                                      
                                                                      [AppDelegate hideHUDForView:self.view animated:YES];
                                                                      //if(dict)
                                                                      [AppDelegate showAlertViewWithTitle:@"Network Error" Message:@"Please Check Your Internet Connection."];
                                                                  }];
                                                                  
                                                                  
                                                                  
                                                                  
                                                                  
                                                                  
                                                              }]];
                                  
                                  [alertController addAction:[UIAlertAction
                                                              actionWithTitle:@"No"
                                                              style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  //Handle no, thanks button
                                                                  
                                                                  
                                                              }]];
                                  
                                  [self presentViewController:alertController animated:YES completion:nil];
                                  
                                  
                              }];
    
    UIAlertAction* button2 = [UIAlertAction
                              actionWithTitle:@"Edit"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  CategoryObject *notObj =  [categoryListArray objectAtIndex:indexPath.row];
                                  
                                  
                                  RenameCatViewController * renameVC =  [self.storyboard instantiateViewControllerWithIdentifier:@"RenameCatViewController"];
                                  renameVC.catName = notObj.CategoryName;
                                  renameVC.CategoryID = [NSString stringWithFormat:@"%lld", notObj.CategoryID];
                                  renameVC.DatabaseID = [NSString stringWithFormat:@"%lld", notObj.DatabaseID];
                                  
                                  [self.navigationController pushViewController:renameVC animated:YES];
                                  
                                  
                              }];
    
    
   
    
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        [alert setModalPresentationStyle:UIModalPresentationPopover];
        
        UIPopoverPresentationController *popPresenter = [alert
                                                         popoverPresentationController];
        UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
        [alert addAction:button0];
        [alert addAction:button1];
        [alert addAction:button2];
       
        popPresenter.sourceView = self.tableView;;
        popPresenter.sourceRect = CGRectMake(cell.bounds.size.width / 2.0, cell.frame.origin.y + cell.bounds.size.height / 2.0, 1.0, 1.0);
        [self presentViewController:alert animated:YES completion:nil];
        
        
    }else{
        
        [alert addAction:button0];
        [alert addAction:button1];
        [alert addAction:button2];
       
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    view.backgroundColor=[UIColor whiteColor];
//    if(section>0)
//    {
//        UIImageView *img=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 3)];
//        img.backgroundColor=[UIColor colorWithRed:(103/255.0f) green:(187/255.0f) blue:(223/255.0f) alpha:1.0f];
//        [view addSubview:img];
//    }
    UILabel *title=[[UILabel alloc]initWithFrame:CGRectMake(10, 10, self.view.frame.size.width-20, 30)];
    title.text=@"Search Results";
    title.font=[UIFont boldSystemFontOfSize:16];
    title.textColor=[UIColor colorWithRed:(101/255.0f) green:(102/255.0f) blue:(103/255.0f) alpha:1.0f];
    [view addSubview:title];
    
    
    return view;
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(isSearchActive && recordArr.count)
      return 40;
    
    return 0;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (isGridView){
        return false;
    }
    else {
         return true;
    }
}
-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isGridView) {
        return nil;
    }
    else {
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                    {
                                        
                                        
                                        // Delete something here
                                        UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @""
                                                                                                                  message: @"Are you sure you want  to delete this category?"
                                                                                                           preferredStyle:UIAlertControllerStyleAlert];
                                        [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                                                    {
                                                                      CategoryObject *notObj =  [categoryListArray objectAtIndex:indexPath.row];
                                                                        
                                                                        [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
                                                                        
                                                                        NSMutableDictionary *userDetail = [[NSMutableDictionary alloc]init];
                                                                        [userDetail setValue:Kdeletecategory forKey:kDefault];
                                                                        [userDetail setValue:[NSNumber numberWithLong:notObj.CategoryID] forKey:@"category_id"];
                                                                        
                                                                        NSLog(@"UsetDetail Dict%@", userDetail);

                                                                        
                                                                        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                                                                        
                                                                        [manager POST:HostUrl parameters:userDetail success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                                                                            
                                                                            
                                                                            NSLog(@"Success: %@\n ***** %@", operation.responseString, responseObject);
                                                                            id status= [responseObject valueForKey:@"status"];
                                                                            if([status isKindOfClass:[NSString class]]){
                                                                                [AppDelegate hideHUDForView:self.view animated:YES];
                                                                                if([status isEqualToString:@"Success"]) {
                                                                                    
                                                                                    [[DBManager getSharedInstance]deleteCateGory:[NSString stringWithFormat:@"%lld",notObj.CategoryID]];
                                                                                    [self viewWillAppear:YES];
                                                                                     [[NSUserDefaults standardUserDefaults]setValue:@""forKey:@"SelectedCategory"];
                                                                                   
                                                                                }
                                                                                
                                                                                else{
                                                                                    [AppDelegate hideHUDForView:self.view animated:YES];
                                                                                    //                    [AppDelegate showAlertViewWithTitle:@"Sorry!" Message:@"Email already exists"];
                                                                                }
                                                                            }
                                                                        } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                                                                            NSLog(@"Error: %@ ***** %@", operation.responseString, error);
                                                                            
                                                                            [AppDelegate hideHUDForView:self.view animated:YES];
                                                                            //if(dict)
                                                                            [AppDelegate showAlertViewWithTitle:@"Network Error" Message:@"Please Check Your Internet Connection."];
                                                                        }];
                                                                        
                                                                        
                                                                       
                                                                        
                                                                       
                                                                        
                                                                    }]];
                                        
                                        [alertController addAction:[UIAlertAction
                                                                    actionWithTitle:@"No"
                                                                    style:UIAlertActionStyleDefault
                                                                    handler:^(UIAlertAction * action) {
                                                                        //Handle no, thanks button
                                                                        
                                                                        
                                                                    }]];
                                        
                                        [self presentViewController:alertController animated:YES completion:nil];
                                    }];
    delete.backgroundColor = [UIColor redColor];
    
    UITableViewRowAction *more = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Rename" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                  {
                                      CategoryObject *notObj =  [categoryListArray objectAtIndex:indexPath.row];
                                      
                                      
                                      RenameCatViewController * renameVC =  [self.storyboard instantiateViewControllerWithIdentifier:@"RenameCatViewController"];
                                      renameVC.catName = notObj.CategoryName;
                                      renameVC.CategoryID = [NSString stringWithFormat:@"%lld", notObj.CategoryID];
                                      renameVC.DatabaseID = [NSString stringWithFormat:@"%lld", notObj.DatabaseID]; 
                                      
                                      [self.navigationController pushViewController:renameVC animated:YES];
                                  }];
    more.backgroundColor = [UIColor colorWithRed:0.188 green:0.514 blue:0.984 alpha:1];
    
    return @[delete, more];
    }
}



#pragma mark - UICollectionView
#pragma mark-

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
   
     return categoryListArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    CategoryCollectionViewCell *ccell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    ccell.btnCat.layer.cornerRadius = 9.0;
    ccell.btnCat.layer.borderColor = [UIColor colorWithRed:46.0/255.0 green:98.0/255.0 blue:204.0/255.0 alpha:1].CGColor;
    ccell.btnCat.layer.borderWidth = 1.5;
    ccell.btnCat.titleLabel.numberOfLines = 1;
    ccell.btnCat.titleLabel.adjustsFontSizeToFitWidth = YES;
    ccell.btnCat.titleLabel.lineBreakMode = NSLineBreakByClipping;
    [ccell.btnCat setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    ccell.btnCat.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
    
    CategoryObject *notObj =  [categoryListArray objectAtIndex:indexPath.row];
               // cell.textLabel.text= notObj.Title;
    
    [ccell.btnCat setTitle: notObj.CategoryName forState:UIControlStateNormal];
    
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                                       initWithTarget:self
                                                       action:@selector(handleLongPressOnButton:)];
            longPress.minimumPressDuration = 1.0;


            [ccell.btnCat addGestureRecognizer:longPress];
            ccell.btnCat.tag = indexPath.row;
    
    [ccell.btnCat addTarget:self action:@selector(btnGridViewClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return ccell;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    float cellWidth = (screenWidth / 2); //Replace the divisor with the column count requirement. Make sure to have it in float.
   
    
    
    CGSize size = CGSizeMake(cellWidth,  60);
    
    
    return size;
}

- (void)handleLongPressOnButton:(UILongPressGestureRecognizer *)gesture {
    
    currentIndex = gesture.view.tag;
    CategoryObject *obj=  [categoryListArray objectAtIndex:currentIndex];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentIndex inSection:0];
    
    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:@"Selected  Category"      //  Must be "nil", otherwise a blank title area will appear above our two buttons
                                message:obj.CategoryName
                                preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* button0 = [UIAlertAction
                              actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleCancel
                              handler:^(UIAlertAction * action)
                              {
                                  //  UIAlertController will automatically dismiss the view
                              }];
    
    UIAlertAction* button1 = [UIAlertAction
                              actionWithTitle:@"Delete"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @""
                                                                                                            message: @"Are you sure you want  to delete this category?"
                                                                                                     preferredStyle:UIAlertControllerStyleAlert];
                                  [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                                              {
                                                                  
                                                                  
                                                                  CategoryObject *notObj =  [categoryListArray objectAtIndex:indexPath.row];
                                                                  
                                                                  [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
                                                                  
                                                                  NSMutableDictionary *userDetail = [[NSMutableDictionary alloc]init];
                                                                  [userDetail setValue:Kdeletecategory forKey:kDefault];
                                                                  [userDetail setValue:[NSNumber numberWithLong:notObj.CategoryID] forKey:@"category_id"];
                                                                  
                                                                  NSLog(@"UsetDetail Dict%@", userDetail);
                                                                  
                                                                  
                                                                  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                                                                  
                                                                  [manager POST:HostUrl parameters:userDetail success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                                                                      
                                                                      
                                                                      NSLog(@"Success: %@\n ***** %@", operation.responseString, responseObject);
                                                                      id status= [responseObject valueForKey:@"status"];
                                                                      if([status isKindOfClass:[NSString class]]){
                                                                          [AppDelegate hideHUDForView:self.view animated:YES];
                                                                          if([status isEqualToString:@"Success"]) {
                                                                              
                                                                              [[DBManager getSharedInstance]deleteCateGory:[NSString stringWithFormat:@"%lld",notObj.CategoryID]];
                                                                              [self viewWillAppear:YES];
                                                                              [[NSUserDefaults standardUserDefaults]setValue:@""forKey:@"SelectedCategory"];
                                                                              
                                                                          }
                                                                          
                                                                          else{
                                                                              [AppDelegate hideHUDForView:self.view animated:YES];
                                                                              //                    [AppDelegate showAlertViewWithTitle:@"Sorry!" Message:@"Email already exists"];
                                                                          }
                                                                      }
                                                                  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                                                                      NSLog(@"Error: %@ ***** %@", operation.responseString, error);
                                                                      
                                                                      [AppDelegate hideHUDForView:self.view animated:YES];
                                                                      //if(dict)
                                                                      [AppDelegate showAlertViewWithTitle:@"Network Error" Message:@"Please Check Your Internet Connection."];
                                                                  }];
                                                                  
                                                                  
                                                                  
                                                                  
                                                                  
                                                                  
                                                              }]];
                                  
                                  [alertController addAction:[UIAlertAction
                                                              actionWithTitle:@"No"
                                                              style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  //Handle no, thanks button
                                                                  
                                                                  
                                                              }]];
                                  
                                  [self presentViewController:alertController animated:YES completion:nil];
                                  
                                  
                              }];
    
    UIAlertAction* button2 = [UIAlertAction
                              actionWithTitle:@"Edit"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  CategoryObject *notObj =  [categoryListArray objectAtIndex:indexPath.row];
                                  
                                  
                                  RenameCatViewController * renameVC =  [self.storyboard instantiateViewControllerWithIdentifier:@"RenameCatViewController"];
                                  renameVC.catName = notObj.CategoryName;
                                  renameVC.CategoryID = [NSString stringWithFormat:@"%lld", notObj.CategoryID];
                                  renameVC.DatabaseID = [NSString stringWithFormat:@"%lld", notObj.DatabaseID];
                                  
                                  [self.navigationController pushViewController:renameVC animated:YES];
                                  
                                  
                              }];
    
    
    
    
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        [alert setModalPresentationStyle:UIModalPresentationPopover];
        
        UIPopoverPresentationController *popPresenter = [alert
                                                         popoverPresentationController];
        UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
        [alert addAction:button0];
        [alert addAction:button1];
        [alert addAction:button2];
        
        popPresenter.sourceView = self.tableView;;
        popPresenter.sourceRect = CGRectMake(cell.bounds.size.width / 2.0, cell.frame.origin.y + cell.bounds.size.height / 2.0, 1.0, 1.0);
        [self presentViewController:alert animated:YES completion:nil];
        
        
    }else{
        
        [alert addAction:button0];
        [alert addAction:button1];
        [alert addAction:button2];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}




-(void)btnGridViewClick :(UIButton*)sender {
    
    UIButton* btn = sender;
    
   NSInteger index =  btn.tag;
    
    CategoryObject *notObj =  [categoryListArray objectAtIndex:index];
    
    BrowseCategoryViewController * browserVC =  [self.storyboard instantiateViewControllerWithIdentifier:@"BrowseCategoryViewController"];
    browserVC.catTittle = notObj.CategoryName;
    browserVC.catId = [NSString stringWithFormat:@"%lld",notObj.CategoryID];
    browserVC.DBId = selectedDBID;
    browserVC.AdminStatus = AdminStatus;
    [self.navigationController pushViewController:browserVC animated:YES];
}

#pragma mark- UISearchDisplayDelegate
#pragma mark-

- (void)filterContentForSearchText:(NSString*)searchText
{
    [searchResultArr removeAllObjects];
     NSPredicate *resultPredicate;
    if(recordArr.count)
    {
        resultPredicate = [NSPredicate predicateWithFormat:@"%K contains[c] %@",@"Title", searchText];
        searchRecorArr = [recordArr filteredArrayUsingPredicate:resultPredicate];
        SearchObject *obj=[[SearchObject alloc]init];
        obj.key=@"Titles";
        obj.value=[NSString stringWithFormat:@"%lu",(unsigned long)searchRecorArr.count];
        [searchResultArr addObject:obj];
        
        resultPredicate = [NSPredicate predicateWithFormat:@"%K contains[c] %@",@"Note", searchText];
        searchNoteArr = [recordArr filteredArrayUsingPredicate:resultPredicate];
        SearchObject *obj2=[[SearchObject alloc]init];
        obj2.key=@"Notes";
        obj2.value=[NSString stringWithFormat:@"%lu",(unsigned long)searchNoteArr.count];
        [searchResultArr addObject:obj2];
        
        resultPredicate = [NSPredicate predicateWithFormat:@"%K contains[c] %@",@"CategoryName", searchText];
        searchCategoryArr = [categoryListArray filteredArrayUsingPredicate:resultPredicate];
        SearchObject *obj3=[[SearchObject alloc]init];
        obj3.key=@"Category";
        obj3.value=[NSString stringWithFormat:@"%lu",(unsigned long)searchCategoryArr.count];
        [searchResultArr addObject:obj3];
        
        
    }
    
    
    [self.tableView reloadData];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(searchBar.text.length)
    {
        isSearchActive=YES;
        [self filterContentForSearchText:searchBar.text];
    }else
    {
        isSearchActive=NO;
        [self.tableView reloadData];
    }
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    // Do the search...
}
-(void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    //This'll Show The cancelButton with Animation
    [searchBar setShowsCancelButton:YES animated:YES];
    //remaining Code'll go here
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    //This'll Hide The cancelButton with Animation
    [self cancelSearchBr];
    
    
}

-(void)cancelSearchBr
{
    _searchBar.text=@"";
    isSearchActive=NO;
    [_searchBar resignFirstResponder];
    [_searchBar setShowsCancelButton:NO animated:YES];
    [self.tableView reloadData];
    
}
-(void)findDBEmptyOrNot
{
    NSArray * data = [[NSArray alloc] init];
    data = [[DBManager getSharedInstance] recordExistOrNot:@"SELECT COUNT(*) FROM MyDatabase"];
    
    if ([[data objectAtIndex:0] intValue] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:
                              @"Database not found" message:nil delegate:nil cancelButtonTitle:
                              @"OK" otherButtonTitles:nil];
        [alert show];
        
    }
    else{
        NSLog(@"%d",[[data objectAtIndex:0] intValue]);
        [[NSUserDefaults standardUserDefaults]setValue:@"" forKey:@"HTMLTEXT"];
        [[NSUserDefaults standardUserDefaults]setValue:@"" forKey:@"SIMPLETEXT"];
        [self performSegueWithIdentifier:@"AddInfoSegue" sender:self];
    }
}

- (IBAction)addRecord:(id)sender {
    [self findDBEmptyOrNot];
   // [self performSegueWithIdentifier:@"AddItemSegue" sender:self];
}


- (IBAction)showMapBtnAction:(id)sender {
    
    
    ShowTeamMapViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ShowTeamMapViewController"];
    
    vc.DBID = selectedDBID;
    vc.DBName = [[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentDbName"];
    vc.adminStatus = AdminStatus;
    vc.lattitude = [NSString stringWithFormat:@"%f", latitude];
    vc.longitude = [NSString stringWithFormat:@"%f", longitude];
    [self.navigationController pushViewController:vc animated:true];
    
}



//-(void)userInfoAction
//{
//    [self performSegueWithIdentifier:@"UserInfoSegue" sender:self];
//}
- (IBAction)settingAction:(id)sender {
    
    [self performSegueWithIdentifier:@"SettingSegue" sender:self];
}


- (IBAction)infoButtonClicked:(id)sender {
    
     [self performSegueWithIdentifier:@"UserInfoSegue" sender:self];
}

- (IBAction)refreshDataFromServer:(id)sender {
    [self.refreshButton setEnabled:NO];
    
    [self importDBList];

    
    [self importDB];
    //[self importDBList];
    [self sharedDbApi];
    
    
}

-(void)refereshDataAfterLogin :(void(^)(BOOL something)) result {
    
    //[self importDBFirstTimeDefault:^(BOOL value) {
   [self importDBListFirstTimeDefault:^(BOOL value) {
        if (value) {
            [self importDBFirstTimeDefault:^(BOOL value) {
                if (value) {
                    [[NSUserDefaults standardUserDefaults]setBool:false forKey:@"FirstTimeLogin"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                   result(YES);
                }
            }];
        }
        
    }];
    
}

-(void)importDBListFirstTimeDefault : (void(^)(BOOL value))result {
    
    //[AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
    // NSString *registerUrl=[NSString stringWithFormat:@"%@",HostUrl];
    NSMutableDictionary *userDetail = [[NSMutableDictionary alloc]init];
    [userDetail setValue:kImportList forKey:kDefault];
    [userDetail setValue:[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID] forKey:@"user_id"];
   // [userDetail setValue:@"688" forKey:@"user_id"];
    // [userDetail setValue:@"27" forKey:kLoogedInUserID];
    
    NSLog(@"UsetDetail Dict%@", userDetail);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:HostUrl parameters:userDetail success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        
        //[AppDelegate hideHUDForView:self.view animated:YES];
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
                NSArray *NotesArray = [dictResult  valueForKey:@"all_notes"];   //valueForKey:@"user_note
                
                [self deleteImportList:[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID]];
                
                [self ImportDatabaseListMydatabaseFromServerResponse:myDataBaseArray];
                [self ImportListDatabseCategoryFromServerResponse:categoryArray];
                [self ImportListDatabaseNotesFromServerResponse:NotesArray];
                [self ImportListDatabaseShareDBFromServerResponse:shareDataBaseArray];
                
                result(YES);
                
            }
            
            else
            {
                
            }
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        
        
        //  [AppDelegate hideHUDForView:self.view animated:YES];
        //if(dict)
        [AppDelegate showAlertViewWithTitle:@"Network Error" Message:@"Please Check Your Internet Connection."];
    }];
    
}


-(void)importDBFirstTimeDefault : (void(^)(BOOL value))result {
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setObject:kImportDB forKey:kDefault];
    [dict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID] forKey:@"user_id"];
     NSLog(@"UsetDetail Dict%@", dict);
    
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
                    
                   // [AppDelegate showAlertViewWithTitle:@"" Message:@"Your DB Imported Successfully."];
                    [self.refreshButton setEnabled:YES];
                    
                    
                    NSArray *defaultDbArray = [[DBManager getSharedInstance]getDefaultDBData];
                    NSString *dbID =   [[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentDbID"];
                    NSString *dbName =   [[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentDbName"];
                     NSString *storageType =   [[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentStorageType"];
                    
                       NSString *adminType =   [[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentAdminType"];
                    
                    if ([dbID isEqualToString:@""] || [dbID length] == 0 || [dbID isKindOfClass:[NSNull class]]) {
                        if (defaultDbArray.count > 0) {
                            DbObject *dbObject = [defaultDbArray objectAtIndex:0];
                            //MyDataBaseObject *dbObject = [defaultDbArray objectAtIndex:0];
                            self.title =  dbObject.DBName;
                            selectedDB =  dbObject.DBName;
                            selectedStorageType = dbObject.StorageType;
                            _storageTypeLabel.text = selectedStorageType;
                            
                            selectedDBID =  [NSString stringWithFormat:@"%lld",dbObject.DatabaseID];
                             AdminStatus =  [NSString stringWithFormat:@"%lld", dbObject.Admin];
                            
                            Admin = dbObject.Admin;
                            LocationStatus = dbObject.LcationStatus;
                            
                            [[NSUserDefaults standardUserDefaults] setValue:selectedDBID forKey:@"CurrentDbID"];
                            [[NSUserDefaults standardUserDefaults] setValue:selectedDB forKey:@"CurrentDbName"];
                             [[NSUserDefaults standardUserDefaults] setValue:selectedStorageType forKey:@"CurrentStorageType"];
                            [_databaseTxt setText:[NSString stringWithFormat:@"Current Database: %@",selectedDB]];
                            
                            [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%lld",Admin] forKey:@"CurrentAdminType"];
                            [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%lld",LocationStatus] forKey:@"CurrentLocationType"];
                            
                            [_picker selectRow:0 inComponent:0 animated:YES];
                            
                            if ((Admin == 0) && (LocationStatus == 0)) {
                                
                                _addRecordBtn.hidden = YES;
                                _showMapBtn.hidden = YES;
                                
                            } else  if ((Admin == 1) && (LocationStatus == 1)) {
                                
                                _addRecordBtn.hidden = NO;
                                _showMapBtn.hidden = NO;
                            }
                            
                            else if ((Admin == 1) && (LocationStatus == 0)) {
                                
                                  _addRecordBtn.hidden = NO;
                                _showMapBtn.hidden = YES;
                                
                            } else  if ((Admin == 0) && (LocationStatus == 1)) {
                                
                                    _addRecordBtn.hidden = YES;
                                    _showMapBtn.hidden = NO;
                            }
 
                        }
                        
                        
                        else  {
                            
                            if (myDataBaseArray.count > 0) {

                                NSDictionary *dic = [myDataBaseArray objectAtIndex:0];
                                //MyDataBaseObject *dbObject = [defaultDbArray objectAtIndex:0];
                                self.title =  [dic valueForKey:@"DBName"];
                                selectedDB =  [dic valueForKey:@"DBName"];
                                selectedStorageType = [dic valueForKey:@"Storage_Type"];
                                _storageTypeLabel.text = selectedStorageType;
                                
                                selectedDBID =  [NSString stringWithFormat:@"%@",[dic valueForKey:@"DatabaseId"]];
                                
                                 AdminStatus =  [NSString stringWithFormat:@"%lld", [[dic valueForKey:@"Admin"] longLongValue]];
                                
                                Admin = [[dic valueForKey:@"Admin"] longLongValue];
                                LocationStatus = [[dic valueForKey:@"Location_Status"] longLongValue];
                                
                                [[NSUserDefaults standardUserDefaults] setValue:selectedDBID forKey:@"CurrentDbID"];
                                [[NSUserDefaults standardUserDefaults] setValue:selectedDB forKey:@"CurrentDbName"];
                                [[NSUserDefaults standardUserDefaults] setValue:selectedStorageType forKey:@"CurrentStorageType"];
                                [_databaseTxt setText:[NSString stringWithFormat:@"Current Database: %@",selectedDB]];
                                
                                 [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%lld",Admin] forKey:@"CurrentAdminType"];
                                [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%lld",LocationStatus] forKey:@"CurrentLocationType"];
                                
                                [_picker selectRow:0 inComponent:0 animated:YES];
                                
                                if ((Admin == 0) && (LocationStatus == 0)) {
                                    
                                   _addRecordBtn.hidden = YES;
                                    _showMapBtn.hidden = YES;
                                    
                                } else  if ((Admin == 1) && (LocationStatus == 1)) {
                                    
                                    _addRecordBtn.hidden = NO;
                                    _showMapBtn.hidden = NO;
                                }
                                
                                else if ((Admin == 1) && (LocationStatus == 0)) {
                                    
                                    _addRecordBtn.hidden = NO;
                                    _showMapBtn.hidden = YES;
                                    
                                } else  if ((Admin == 0) && (LocationStatus == 1)) {
                                    
                                   _addRecordBtn.hidden = YES;
                                    _showMapBtn.hidden = NO;
                                }
                                
                                
                            }
                            
                            
                        }
                    } else if (myDataBaseArray.count > 0) {
                        
                        self.title =  dbName;
                        selectedDB = dbName;
                        selectedDBID = dbID;
                        AdminStatus = adminType;
                        [_databaseTxt setText:[NSString stringWithFormat:@"Current Database: %@",selectedDB]];
                        
                    } else if (myDataBaseArray.count == 0) {
  
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"dbId"];
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"dbName"];
                        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"CurrentDbID"];
                        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"CurrentDbName"];
                        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"CurrentStorageType"];
                        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"CurrentAdminType"];
                        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"CurrentLocationType"];
                        
                        self.title =  @"";
                        [_databaseTxt setText:@""];
                        _storageTypeLabel.text = @"";
                        _addRecordBtn.hidden = NO;
                        _showMapBtn.hidden = YES;
                       
                        
                    }
                    
                   result(YES);
                }
                
                else{
                    [AppDelegate hideHUDForView:self.view animated:YES];
                    [AppDelegate showAlertViewWithTitle:@"Sorry!" Message:@"Try Again."];
                    [self.refreshButton setEnabled:YES];
                }
            }
        } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
            NSLog(@"Error: %@ ***** %@", operation.responseString, error);
            [self.refreshButton setEnabled:YES];
            
            [AppDelegate hideHUDForView:self.view animated:YES];
            //if(dict)
            [AppDelegate showAlertViewWithTitle:@"Network Error" Message:@"Please Check Your Internet Connection."];
        }];
        
    
}



-(void)importDBList
{
    
    //[AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
    // NSString *registerUrl=[NSString stringWithFormat:@"%@",HostUrl];
    NSMutableDictionary *userDetail = [[NSMutableDictionary alloc]init];
    [userDetail setValue:kImportList forKey:kDefault];
    [userDetail setValue:[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID] forKey:@"user_id"];
    // [userDetail setValue:@"27" forKey:kLoogedInUserID];
    
    NSLog(@"UsetDetail Dict%@", userDetail);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:HostUrl parameters:userDetail success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        
        //[AppDelegate hideHUDForView:self.view animated:YES];
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
                
                
                
            }
            
            else
            {
                
            }
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        
        
      //  [AppDelegate hideHUDForView:self.view animated:YES];
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
        myDbObj.StorageType = [[myDataBaseArray objectAtIndex:i]valueForKey:@"Storage_Type"];
        myDbObj.Catelog = @"";
        myDbObj.LastModified =  [[myDataBaseArray objectAtIndex:i] valueForKey:@"LastModified"];
        myDbObj.DBType =  [[myDataBaseArray objectAtIndex:i] valueForKey:@"DBType"];
        
        
        myDbObj.Admin = [[[myDataBaseArray objectAtIndex:i]valueForKey:@"Admin"] longLongValue];
        myDbObj.LocationStatus = [[[myDataBaseArray objectAtIndex:i]valueForKey:@"Location_Status"] longLongValue];
        myDbObj.Latitude = [[myDataBaseArray objectAtIndex:i] valueForKey:@"Latitude"];
        myDbObj.Longitude = [[myDataBaseArray objectAtIndex:i] valueForKey:@"Longitude"];
               
        
        
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
        noteObj.FileUpload =  [[notesArray objectAtIndex:i] valueForKey:@"File_upload"];
        
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
                 [self.refreshButton setEnabled:YES];
                
                
                NSArray *defaultDbArray = [[DBManager getSharedInstance]getDefaultDBData];
                NSString *dbID =   [[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentDbID"];
                NSString *dbName =   [[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentDbName"];
                NSString *admin =   [[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentAdminType"];
                NSString *locationStatus =   [[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentLocationType"];
                
                
                if ([dbID isEqualToString:@""] || [dbID isEqual:nil]|| [dbID isKindOfClass:[NSNull class]]) {
                    if (defaultDbArray.count > 0) {
                        DbObject *dbObject = [defaultDbArray objectAtIndex:0];
                        self.title =  dbObject.DBName;
                        selectedDB =  dbObject.DBName;
                        
                        AdminStatus =  [NSString stringWithFormat:@"%lld",dbObject.Admin];
                        Admin = dbObject.Admin;
                        LocationStatus = dbObject.LcationStatus;
                        
                        selectedDBID =  [NSString stringWithFormat:@"%lld",dbObject.DatabaseID];
                        [[NSUserDefaults standardUserDefaults] setValue:selectedDBID forKey:@"CurrentDbID"];
                        [[NSUserDefaults standardUserDefaults] setValue:selectedDB forKey:@"CurrentDbName"];
                        [_databaseTxt setText:[NSString stringWithFormat:@"Current Database: %@",selectedDB]];
                        
                        
                        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%lld",Admin] forKey:@"CurrentAdminType"];
                        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%lld",LocationStatus] forKey:@"CurrentLocationType"];
                        
                        
                        if ((Admin == 0) && (LocationStatus == 0)) {
                            
                           _addRecordBtn.hidden = YES;
                            _showMapBtn.hidden = YES;
                            
                        } else  if ((Admin == 1) && (LocationStatus == 1)) {
                            
                           _addRecordBtn.hidden = NO;
                            _showMapBtn.hidden = NO;
                        }
                        
                        else if ((Admin == 1) && (LocationStatus == 0)) {
                            
                        _addRecordBtn.hidden = NO;
                        _showMapBtn.hidden = YES;
                            
                        } else  if ((Admin == 0) && (LocationStatus == 1)) {
                            
                           _addRecordBtn.hidden = YES;
                            _showMapBtn.hidden = NO;
                        }
                        
                        
                        
                        
                        
                        [_picker selectRow:0 inComponent:0 animated:YES];
                    }
                }
                
                else if (myDataBaseArray.count > 0) {
                    self.title =  dbName;
                    selectedDB = dbName;
                    selectedDBID = dbID;
                    
                    AdminStatus =  admin;
                    Admin = [admin longLongValue];
                    LocationStatus = [locationStatus longLongValue] ;
                    
                    
                    [_databaseTxt setText:[NSString stringWithFormat:@"Current Database: %@",selectedDB]];
                    
                    
                    NSArray *objcArray = [[NSMutableArray alloc]init];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(SELF.DatabaseId = %@)", dbID];
                    
                    objcArray = [myDataBaseArray filteredArrayUsingPredicate:predicate];
                    NSLog(@"HERE %@",objcArray);
                    
                    if(objcArray.count > 0) {
                        
                        MyDataBaseObject *obj1 = [objcArray objectAtIndex:0];
                        
                        AdminStatus =  [obj1 valueForKey:@"Admin"];
                        Admin = [[obj1 valueForKey:@"Admin"] longLongValue];
                        LocationStatus = [[obj1 valueForKey:@"Location_Status"] longLongValue];
                        
                        if  ((myDataBaseArray.count > 0) && !([locationStatus isEqualToString:[NSString stringWithFormat:@"%lld",LocationStatus]])) {
                            
                            
//                            ( ((myDataBaseArray.count > 0) && !([locationStatus isEqualToString:[NSString stringWithFormat:@"%lld",LocationStatus]])) ||  ((myDataBaseArray.count > 0) && !([admin isEqualToString:[NSString stringWithFormat:@"%lld",Admin]])) )
                            
                            
//
                            if ((Admin == 0) && (LocationStatus == 0)) {
                                
                                _addRecordBtn.hidden = YES;
                                _showMapBtn.hidden = YES;
                                
                            } else  if ((Admin == 1) && (LocationStatus == 1)) {
                                
                                _addRecordBtn.hidden = NO;
                                _showMapBtn.hidden = NO;
                            }
                            
                            else if ((Admin == 1) && (LocationStatus == 0)) {
                                
                                _addRecordBtn.hidden = NO;
                                _showMapBtn.hidden = YES;
                                
                            } else  if ((Admin == 0) && (LocationStatus == 1)) {
                                
                                _addRecordBtn.hidden = YES;
                                _showMapBtn.hidden = NO;
                            }
                            
                            
                            [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%lld",Admin] forKey:@"CurrentAdminType"];
                            [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%lld",LocationStatus] forKey:@"CurrentLocationType"];
                            
                        }
                    }
                    
                    
                    
                    
                    //                    if ((Admin == 0) && (LocationStatus == 0)) {
                    //
                    //                       _addRecordBtn.hidden = YES;
                    //                        _showMapBtn.hidden = YES;
                    //
                    //                    } else  if ((Admin == 1) && (LocationStatus == 1)) {
                    //
                    //                       _addRecordBtn.hidden = NO;
                    //                        _showMapBtn.hidden = NO;
                    //                    }
                    //
                    //                    else if ((Admin == 1) && (LocationStatus == 0)) {
                    //
                    //                    _addRecordBtn.hidden = NO;
                    //                    _showMapBtn.hidden = YES;
                    //
                    //                    } else  if ((Admin == 0) && (LocationStatus == 1)) {
                    //
                    //                       _addRecordBtn.hidden = YES;
                    //                        _showMapBtn.hidden = NO;
                    //                    }
                    
                    
                } else if (myDataBaseArray.count == 0) {
                    
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"dbId"];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"dbName"];
                    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"CurrentDbID"];
                    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"CurrentDbName"];
                    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"CurrentStorageType"];
                    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"CurrentAdminType"];
                    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"CurrentLocationType"];
                    
                     self.title =  @"";
                    [_databaseTxt setText:@""];
                    _storageTypeLabel.text = @"";
                    _addRecordBtn.hidden = NO;
                    _showMapBtn.hidden = YES;

                    
                }
               
                [self viewWillAppear:YES];
            }
            
            else{
                [AppDelegate hideHUDForView:self.view animated:YES];
                [AppDelegate showAlertViewWithTitle:@"Sorry!" Message:@"Try Again."];
                 [self.refreshButton setEnabled:YES];
            }
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
         [self.refreshButton setEnabled:YES];
        
        [AppDelegate hideHUDForView:self.view animated:YES];
        //if(dict)
        [AppDelegate showAlertViewWithTitle:@"Network Error" Message:@"Please Check Your Internet Connection."];
    }];
    
}

-(void)sharedDbApi  {
    
    // [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
    NSMutableDictionary *userDetail = [[NSMutableDictionary alloc] init];
    
    [userDetail setValue:kSahredDb forKey:kDefault];
    
    [userDetail setValue:[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID] forKey:@"user_id"];
    
    
    
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
                
                
                NSArray *shareDataBaseArray = [dictResult  valueForKey:@"MyDatabase"];
                
                if ((shareDataBaseArray.count > 0) && (shareDataBaseArray != nil)) {
                    
                    [[Singleton singleton].globalArray removeAllObjects];
                    
                    for (int i =0; i <= shareDataBaseArray.count-1; i++) {
                        
                        ShareDBObject * obj = [[ShareDBObject alloc] init];
                        obj.DBName = [[shareDataBaseArray objectAtIndex:i] valueForKey:@"DBName"];
                        obj.DBID = [[shareDataBaseArray objectAtIndex:i] valueForKey:@"DatabaseId"];
                        obj.UserID = [[shareDataBaseArray objectAtIndex:i] valueForKey:@"UserId"];
                        obj.Admin = [[shareDataBaseArray objectAtIndex:i] valueForKey:@"Admin"];
                        obj.DBType = [[shareDataBaseArray objectAtIndex:i] valueForKey:@"DBType"];
                        obj.Location_Status = [[shareDataBaseArray objectAtIndex:i] valueForKey:@"Location_Status"];
                        
                        if ([obj.Location_Status isEqualToString:@"1"]) {
                            
                             [sharedLocationArray addObject: obj.DBID];
                        }
                    }
                    
                    [Singleton singleton].globalArray = sharedLocationArray;
                    
                    if ([Singleton singleton].globalArray.count> 0){
                          
                         [Singleton singleton].globalCount = true;

                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                      
                                    [self locationBackgroundUpdate];
                                    
                          
                            });
                        
                      [Singleton singleton].timer =  [NSTimer scheduledTimerWithTimeInterval: 60
                                                         target: self
                                                       selector:@selector(onTick:)
                                                       userInfo: nil repeats:YES];
                        
                    } else {
                        
                        [[Singleton singleton].timer invalidate];
                        
                    }
 
                    
                } else {
                    
                    [[Singleton singleton].timer invalidate];
                  //  [AppDelegate showAlertViewWithTitle:@"" Message:@"No Shared DB Found"];
                    
                }
                
                
                
                
                
                //                [self deleteImportList:[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID]];
                //
                //                [self ImportDatabaseListMydatabaseFromServerResponse:myDataBaseArray];
                //                [self ImportListDatabseCategoryFromServerResponse:categoryArray];
                //                [self ImportListDatabaseNotesFromServerResponse:NotesArray];
                //  [self ImportListDatabaseShareDBFromServerResponse:shareDataBaseArray];
                //
                //                importListViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"importListViewController"];
                //                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
                //
                //                [self.navigationController pushViewController:vc animated:true];
            } else
            {
                
                [[Singleton singleton].timer invalidate];
                
            }
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        
        [AppDelegate hideHUDForView:self.view animated:YES];
        //if(dict)
//        [AppDelegate showAlertViewWithTitle:@"Network Error" Message:@"Please Check Your Internet Connection."];
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
        
        
        myDbObj.Catelog = @"";
        myDbObj.LastModified =  [[myDataBaseArray objectAtIndex:i] valueForKey:@"LastModified"];
        myDbObj.DBType =  [[myDataBaseArray objectAtIndex:i] valueForKey:@"DBType"];
        myDbObj.StorageType = [[myDataBaseArray objectAtIndex:i] valueForKey:@"Storage_Type"];
        myDbObj.Admin = [[[myDataBaseArray objectAtIndex:i]valueForKey:@"Admin"] longLongValue];
        myDbObj.LocationStatus = [[[myDataBaseArray objectAtIndex:i]valueForKey:@"Location_Status"] longLongValue];
        myDbObj.Latitude = [[myDataBaseArray objectAtIndex:i] valueForKey:@"Latitude"];
        myDbObj.Longitude = [[myDataBaseArray objectAtIndex:i] valueForKey:@"Longitude"];
        
        
        [[DBManager getSharedInstance]  importDBFromServer:myDbObj];
        
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
        
        if ([[[notesArray objectAtIndex:i] valueForKey:@"File_upload"] isKindOfClass:[NSNull class]] || [[[notesArray objectAtIndex:i] valueForKey:@"File_upload"] isEqualToString:@""] ){
            noteObj.FileUpload  = @"";
        }
        
        else {
            
            noteObj.FileUpload =  [[notesArray objectAtIndex:i] valueForKey:@"File_upload"];

        }
        
//        if ([[[notesArray objectAtIndex:i] valueForKey:@"File_upload"] isEqualToString:@""]
//            || [[notesArray objectAtIndex:i] valueForKey:@"File_upload"] == nil){
//            noteObj.imageData = nil;
//        }
//
//
//        else{
        
            if ( [noteObj.FileUpload hasPrefix:@"https://"]) {
                
               noteObj.imageData = nil;
            }
            
            else {
                
                if ( [noteObj.FileUpload isEqualToString: @""]) {
                    
                     noteObj.imageData = nil;
                    
                }
                
                else {
                    
                    NSString *url = [NSString stringWithFormat:@"http://app.infopalm.com/uploads/%@",noteObj.FileUpload];
                    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url] options:NSDataReadingUncached error:nil];
                    noteObj.imageData = data;
                    
                }
                
            }
        //}
        [[DBManager getSharedInstance] importNotesFromServer:noteObj];
    }
}

#pragma mark- UIPickerViewDelegate
#pragma mark-
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
   
        return dbArray.count;
   
    
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
        MyDataBaseObject *obj = dbArray[row];
      // _storageTypeLabel .text = obj.StorageType;
    
        return obj.DBName;
    
}

- (IBAction)ChangeDB:(id)sender {
    
    if (dbArray.count > 0) {
         [self showPickerView];
    }else{
       [AppDelegate showAlertViewWithTitle:@"" Message:@"Please Create Database From Setting."];
    }
   
    
    
}

-(void)showPickerView {
   
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
- (IBAction)done:(id)sender {
    
    
    [self hidePickerView];
    
    NSInteger row= [self.picker selectedRowInComponent:0];
    MyDataBaseObject *DbObj =  [dbArray objectAtIndex:row];
    self.title = DbObj.DBName;
    selectedDB  = DbObj.DBName;
    selectedStorageType = DbObj.StorageType;
    _storageTypeLabel.text = selectedStorageType;
    AdminStatus =  [NSString stringWithFormat:@"%lld", DbObj.Admin];
    
    
    if ((DbObj.Admin == 0) && (DbObj.LocationStatus == 0)) {
        
        _addRecordBtn.hidden = YES;
         _showMapBtn.hidden = YES;
        
    } else  if ((DbObj.Admin == 1) && (DbObj.LocationStatus == 1)) {
           
      _addRecordBtn.hidden = NO;
       _showMapBtn.hidden = NO;
    }
    
    else if ((DbObj.Admin == 1) && (DbObj.LocationStatus == 0)) {
        
     _addRecordBtn.hidden = NO;
      _showMapBtn.hidden = YES;
        
    } else  if ((DbObj.Admin == 0) && (DbObj.LocationStatus == 1)) {
           
       _addRecordBtn.hidden = YES;
        _showMapBtn.hidden = NO;
    }
    
    [categoryListArray removeAllObjects];
    categoryListArray =  [[DBManager getSharedInstance] getcategoryListOfSelectedDB :[NSString stringWithFormat:@"%lld", DbObj.Databaseid]];
    selectedDBID = [NSString stringWithFormat:@"%lld", DbObj.Databaseid];
    [self.tableView reloadData];
    _databaseTxt.text = [NSString stringWithFormat:@"Current Database: %@",selectedDB];
    [[NSUserDefaults standardUserDefaults] setValue:selectedDBID forKey:@"CurrentDbID"];
    [[NSUserDefaults standardUserDefaults] setValue:DbObj.DBName forKey:@"CurrentDbName"];
    [[NSUserDefaults standardUserDefaults] setValue:DbObj.StorageType forKey:@"CurrentStorageType"];
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%lld", DbObj.Admin] forKey:@"CurrentAdminType"];
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%lld", DbObj.LocationStatus] forKey:@"CurrentLocationType"];

    [[NSUserDefaults standardUserDefaults]setValue:@""forKey:@"SelectedCategory"];
    [[NSUserDefaults standardUserDefaults]synchronize];
   

}
- (IBAction)btnListGrid:(id)sender {
    if ( isGridView) {
        isGridView = false;
        [self.btnGridLIstView setBackgroundImage:[UIImage imageNamed:@"list.png"] forState:UIControlStateNormal];
        
    }
    else {
        isGridView = true;
        [self.btnGridLIstView setBackgroundImage:[UIImage imageNamed:@"grid.png"] forState:UIControlStateNormal];
    }
    [self.tableView reloadData];
    
}
@end
