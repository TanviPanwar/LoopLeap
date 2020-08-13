//
//  ShareLocationViewController.m
//  SimpleApp
//
//  Created by iOS6 on 18/10/19.
//  Copyright © 2019 MAC. All rights reserved.
//

#import "ShareLocationViewController.h"
#import "ShareDBLocationTableViewCell.h"
#import "DBManager.h"
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "ShareDBObject.h"
#import "ShowTeamMapViewController.h"
#import "Singleton.h"


@interface ShareLocationViewController ()<UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate> {
    
    NSMutableArray *dbArray;
    NSMutableArray *shareDbArray;

    float latitude ;
    float longitude ;
    int selectedIndex;
    ShareDBObject *sharedDBObj;
    BOOL firstTimeLoad;

    NSMutableArray * sharedLocationArray;


}

@property (weak, nonatomic) IBOutlet UITableView *shareDatabaseTableView;

@property (strong, nonatomic) CLLocationManager *locationManager;


@end

@implementation ShareLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self sharedDbApi];
    
    
     sharedLocationArray =  [[NSMutableArray alloc] init];
     shareDbArray  = [[NSMutableArray alloc] init];
     sharedDBObj  = [[ShareDBObject alloc] init];


    if( _locationManager == nil ) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        [_locationManager requestWhenInUseAuthorization];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        [_locationManager startUpdatingLocation];
        
        
        
        //        CLLocationCoordinate2D coordinate = [self getLocation];
        //        NSString *latitude = [NSString stringWithFormat:@"%f", coordinate.latitude];
        //        NSString *longitude = [NSString stringWithFormat:@"%f", coordinate.longitude];
        //
        //        NSLog(@"*dLatitude : %@", latitude);
        //        NSLog(@"*dLongitude : %@",longitude);
    }
    
   
   
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
        
        if ([Singleton singleton].globalArray.count > 0) {
            
            [self locationBackgroundUpdate];
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            //stop your HUD here
            //This is run on the main thread
            
            
        });
    });
    
    
}

- (IBAction)getLocationBtnAction:(id)sender {
    
    float latitude = _locationManager.location.coordinate.latitude;
    float longitude = _locationManager.location.coordinate.longitude;
    NSLog(@"*dLatitude : %f", latitude);
    NSLog(@"*dLongitude : %f",longitude);
}


#pragma mark- Custom Methods

-(void)getMyDBListFromSqlite {
    
    dbArray = [[NSMutableArray alloc] init];
    NSString *ownerID = [[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID];
    
    dbArray = [[DBManager getSharedInstance]getDataFromMyDataBase:ownerID];
    [_shareDatabaseTableView reloadData];

    
}


#pragma mark- TableView Delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return shareDbArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
     ShareDBLocationTableViewCell *cell = (ShareDBLocationTableViewCell *) [self.shareDatabaseTableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
  
   
     ShareDBObject *obj = shareDbArray[indexPath.row];
    
    cell.dbNameLabel.text = obj.DBName;
    cell.checkBtn.tag = indexPath.row;
    cell.showMapBtn.tag = indexPath.row;

    
  
    
    if ([obj.Location_Status  isEqual: @"1"]) {
         
         [cell.checkBtn setImage:[UIImage imageNamed:@"tick"] forState:UIControlStateNormal];
         [cell.showMapBtn setHidden:false];
        
     } else {
         
         [cell.checkBtn setImage:[UIImage imageNamed:@"untick"] forState:UIControlStateNormal];
         [cell.showMapBtn setHidden:true];
     }
    

    
 
//        if ([sharedLocationArray containsObject:obj.DBID]) {
//            [cell.checkBtn setImage:[UIImage imageNamed:@"tick"] forState:UIControlStateNormal];
//            [cell.showMapBtn setHidden:false];
//
//
//        } else {
//
//            [cell.checkBtn setImage:[UIImage imageNamed:@"untick"] forState:UIControlStateNormal];
//            [cell.showMapBtn setHidden:true];
//
//
//    }
    
   // [cell.checkBtn addTarget:self action:@selector(btnCheckClick:) forControlEvents:UIControlEventTouchUpInside];

    
    
    return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


-(IBAction)btnCheckClick:(UIButton*)sender {
    
     NSIndexPath *indexPath =  [NSIndexPath indexPathForItem:sender.tag inSection:0];
     ShareDBLocationTableViewCell *cell =  [self.shareDatabaseTableView cellForRowAtIndexPath:indexPath];
 
    
     ShareDBObject *obj =[shareDbArray objectAtIndex:sender.tag];
    NSString *locationBool;
   
    if (![sharedLocationArray containsObject:obj.DBID]) {
        
        [self checkLocationAccess];
        [sharedLocationArray addObject: obj.DBID];
        obj.Location_Status = @"1";
        [shareDbArray replaceObjectAtIndex:indexPath.row
                                withObject:obj];
        locationBool = @"1";


    } else {

        [sharedLocationArray removeObject:obj.DBID];
        obj.Location_Status = @"0";
        [shareDbArray replaceObjectAtIndex:indexPath.row
                                withObject:obj];
        locationBool = @"0";


    }
    
    [Singleton singleton].globalArray = sharedLocationArray ;
    NSLog(@"%@", sharedLocationArray);
    
   [_shareDatabaseTableView reloadData];
   [self locationUpdateForSingleDB:obj.DBID locationBool:locationBool];
    
  
    
    if (![Singleton singleton].globalCount){
        
      [Singleton singleton].timer =  [NSTimer scheduledTimerWithTimeInterval: 60
                                         target: self
                                       selector:@selector(onTick:)
                                       userInfo: nil repeats:YES];
        
    }
    
    
    
    
}

- (IBAction)showMapBtnAction:(UIButton*)sender {
    
    ShowTeamMapViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ShowTeamMapViewController"];
    
    vc.DBID = [sharedLocationArray objectAtIndex:sender.tag];
    [self.navigationController pushViewController:vc animated:true];
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

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        NSLog(@"allowed"); // allowed
    }
    else if (status == kCLAuthorizationStatusDenied) {
        NSLog(@"denied"); // denied
    }
}

-(CLLocationCoordinate2D) getLocation{
    
    CLLocation *location = [_locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    return coordinate;
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

                    [shareDbArray addObject:obj];
                }
                    
                    [Singleton singleton].globalArray = sharedLocationArray;
                
                    NSLog(@"***********%@", sharedLocationArray);

                    [_shareDatabaseTableView reloadData];
                    
                    
                } else {
                    
                    
                    [AppDelegate showAlertViewWithTitle:@"" Message:@"No Shared DB Found"];
                    
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
                
            }
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        
        [AppDelegate hideHUDForView:self.view animated:YES];
        //if(dict)
        [AppDelegate showAlertViewWithTitle:@"Network Error" Message:@"Please Check Your Internet Connection."];
    }];
    
}

-(void)locationUpdateForSingleDB : (NSString *)dbID locationBool: (NSString *)locationBool  {
    
    // [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
    NSMutableDictionary *userDetail = [[NSMutableDictionary alloc] init];
    
    [userDetail setValue:kLocationUpdate forKey:kDefault];
    
    [userDetail setValue:[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID] forKey:@"userid"];
    [userDetail setValue:dbID forKey:@"dbid"];
    [userDetail setValue:[NSString stringWithFormat:@"%f", latitude] forKey:@"lat"];

    [userDetail setValue:[NSString stringWithFormat:@"%f", longitude] forKey:@"long"];
    [userDetail setValue:locationBool forKey:@"bool"];

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
        [AppDelegate showAlertViewWithTitle:@"Network Error" Message:@"Please Check Your Internet Connection."];
    }];
    
}


-(void)locationBackgroundUpdate{
    
    // [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
    NSMutableDictionary *userDetail = [[NSMutableDictionary alloc] init];
    
    [userDetail setValue:kLocationUpdateCrown forKey:kDefault];
    
    [userDetail setValue:[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID] forKey:@"userid"];
    
    NSError *error;

    NSString *createJSONStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[Singleton singleton].globalArray
                                                                                             options:NSJSONWritingPrettyPrinted
                                                                                               error:&error] encoding:NSUTF8StringEncoding];
    
    [userDetail setValue:createJSONStr forKey:@"dbids"];
    [userDetail setValue:[NSString stringWithFormat:@"%f", latitude] forKey:@"lat"];
    
    [userDetail setValue:[NSString stringWithFormat:@"%f", longitude] forKey:@"long"];
    
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
        [AppDelegate showAlertViewWithTitle:@"Network Error" Message:@"Please Check Your Internet Connection."];
    }];
    
}








//-(void)ImportListDatabaseShareDBFromServerResponse : (NSArray*)shareArrList {
//
//    for(int i = 0;i<[shareArrList count];i++) {
//
//        ShareDBObject *dbObj = [[ShareDBObject alloc] init];
//        dbObj.DatabaseID = [[[shareArrList objectAtIndex:i] valueForKey:@"DatabaseId"] longLongValue];
//        dbObj.Admin = [[[shareArrList objectAtIndex:i] valueForKey:@"Admin"] longLongValue];
//        dbObj.UserID = [[[shareArrList objectAtIndex:i] valueForKey:@"UserId"] longLongValue];
//       shareDbArray = [[DBManager getSharedInstance] importShareDBUsersFromServer:dbObj];
//
//    }
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
