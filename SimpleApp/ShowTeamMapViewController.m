//
//  ShowTeamMapViewController.m
//  SimpleApp
//
//  Created by iOS6 on 22/10/19.
//  Copyright © 2019 MAC. All rights reserved.
//

#import "ShowTeamMapViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "Constant.h"
#import "AppDelegate.h"
#import "LocationObject.h"


@interface ShowTeamMapViewController () {
   
    GMSMapView *mapViw;
    NSMutableArray *locationArray;
    NSTimer *removeLocationtimer;
    NSTimer *updatetimer;
    BOOL isTimerOn;
    
}

@property (weak, nonatomic) IBOutlet UIView *mapView;



@end

@implementation ShowTeamMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Refresh"
                                                                        style:UIBarButtonItemStyleDone
                                                                        target:self
                                                                        action:@selector(refreshButtonAction:)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backArrow"]
                                                                        style:UIBarButtonItemStyleDone
                                                                        target:self
                                                                        action:@selector(backButtonAction:)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    self.navigationItem.title = _DBName;

    
    locationArray = [[NSMutableArray alloc] init];
    [_mapView setHidden:YES];
    
   
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[_lattitude doubleValue]
                                                            longitude:[_longitude doubleValue]
                                                                 zoom:1];
    mapViw = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapViw.myLocationEnabled = YES;
    
    self.view = mapViw;
    
    
    // Creates a marker in the center of the map.
    
//    GMSMarker *marker = [[GMSMarker alloc] init];
//    marker.position = CLLocationCoordinate2DMake(-33.86, 151.20);
//    marker.title = @"Sydney";
//    marker.snippet = @"Australia";
//    marker.map = mapViw;
//
//
//    GMSMarker *marker1 = [[GMSMarker alloc] init];
//    marker1.position = CLLocationCoordinate2DMake(-32.92, 151.78);
//    marker1.title = @"Newcastle";
//    marker1.snippet = @"Australia";
//    marker1.map = mapViw;
    
    
    
    [self getSharedLocationApi];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];

    
}

#pragma mark- Api Methods


-(void)getSharedLocationApi  {
    
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
               
              if (isTimerOn == false) {
               [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
                  
              }
    
           });
    
//    if (isTimerOn == false) {
//     [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
//
//    }
    
    NSMutableDictionary *userDetail = [[NSMutableDictionary alloc] init];
    
    [userDetail setValue:kGetSharedLocation forKey:kDefault];
    
    [userDetail setValue:[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID] forKey:@"userid"];
    
    [userDetail setValue:_DBID forKey:@"dbid"];
    
    
    
    NSLog(@"UsetDetail Dict%@", userDetail);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:HostUrl parameters:userDetail success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            [AppDelegate hideHUDForView:self.view animated:YES];
            
        });
        
        NSLog(@"Success: %@\n ***** %@", operation.responseString, responseObject);
        id status= [responseObject valueForKey:@"status"];
        if([status isKindOfClass:[NSString class]]){
            if([status isEqualToString:@"Success"]) {
                id jsonString  =   [responseObject valueForKey:@"result"];
                NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *dictResult = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
                
                NSArray *locationInfoArray = [dictResult  valueForKey:@"LocationInfo"];
                if ((locationInfoArray.count > 0) && (locationInfoArray != nil)) {
                    
                    [locationArray removeAllObjects];
                    for (int i =0; i <= locationInfoArray.count-1; i++) {
                    
                        LocationObject * obj = [[LocationObject alloc] init];
                        obj.UserID = [[locationInfoArray objectAtIndex:i] valueForKey:@"UserId"];
                        obj.Latitude = [[locationInfoArray objectAtIndex:i] valueForKey:@"Latitude"];
                        obj.Longitude = [[locationInfoArray objectAtIndex:i] valueForKey:@"Longitude"];
                        obj.first_name = [[locationInfoArray objectAtIndex:i] valueForKey:@"first_name"];
                        obj.last_name = [[locationInfoArray objectAtIndex:i] valueForKey:@"last_name"];
                        
                        if((![obj.Latitude isEqual:@""]) && (![obj.Longitude isEqual:@""])) {
                        
                        [locationArray addObject:obj];
                            
                        } else {
                            
                            
                        }

                    }
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        
                        if (locationArray.count > 0) {
                            
                            if (isTimerOn == false) {
                                updatetimer =  [NSTimer scheduledTimerWithTimeInterval: 60
                                                                                target: self
                                                                              selector:@selector(updateLocations:)
                                                                              userInfo: nil repeats:YES];
                                
                                
                                if ([_adminStatus isEqual: @"1"]) {
                                    
                                    removeLocationtimer =  [NSTimer scheduledTimerWithTimeInterval: 300
                                                                                            target: self
                                                                                          selector:@selector(RemoveLocations:)
                                                                                          userInfo: nil repeats:NO];
                                    
                                } else if  ([_adminStatus isEqual: @"0"]) {
                                    
                                    removeLocationtimer =  [NSTimer scheduledTimerWithTimeInterval: 120
                                                                                            target: self
                                                                                          selector:@selector(RemoveLocations:)
                                                                                          userInfo: nil repeats:NO];
                                    
                                }
                                
                                
                                isTimerOn = YES;
                            }
                            
                            [self showLocations];
                            
                        } else {
                            
                            [removeLocationtimer invalidate];
                            [updatetimer invalidate];
                            [mapViw clear];
                            [AppDelegate showAlertViewWithTitle:@"" Message:@"No Data Found"];
                            
                        }
                        
                    });
                   
                    
                    
                    
                    
//                    if (isTimerOn == false) {
//                        updatetimer =  [NSTimer scheduledTimerWithTimeInterval: 60
//                                                                        target: self
//                                                                      selector:@selector(updateLocations:)
//                                                                      userInfo: nil repeats:YES];
//
//                        if ([_adminStatus isEqual: @"1"]) {
//
//                            removeLocationtimer =  [NSTimer scheduledTimerWithTimeInterval: 300
//                                                                                    target: self
//                                                                                  selector:@selector(RemoveLocations:)
//                                                                                  userInfo: nil repeats:NO];
//
//                        } else if  ([_adminStatus isEqual: @"0"]) {
//
//                            removeLocationtimer =  [NSTimer scheduledTimerWithTimeInterval: 120
//                                                                                    target: self
//                                                                                  selector:@selector(RemoveLocations:)
//                                                                                  userInfo: nil repeats:NO];
//
//                        }
//
//
//                        isTimerOn = YES;
//                    }
//
//
//                    [self showLocations];
                    
                } else {
                    
                    
                    [AppDelegate showAlertViewWithTitle:@"" Message:@"No Data Found"];
                    
                }
                

            } else
            {
                [AppDelegate showAlertViewWithTitle:@"" Message:@"No Data Found"];
                
            }
        }
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        
        [AppDelegate hideHUDForView:self.view animated:YES];
        //if(dict)
        [AppDelegate showAlertViewWithTitle:@"Network Error" Message:@"Please Check Your Internet Connection."];
    }];
    
}

#pragma mark- Custom Methods

- (IBAction)backButtonAction:(id)sender {
    
    
    [removeLocationtimer invalidate];
    [updatetimer invalidate];
    [self.navigationController popViewControllerAnimated:true];
    
}


- (IBAction)refreshButtonAction:(id)sender {
    // code for right Button
    
    isTimerOn = false;
    [self getSharedLocationApi];
    
// updatetimer =  [NSTimer scheduledTimerWithTimeInterval: 60
//                                                  target: self
//                                                selector:@selector(updateLocations:)
//                                                userInfo: nil repeats:YES];

}

-(void)RemoveLocations:(NSTimer *)timer {
    //do smth
    NSLog(@"%@", @"5 Minutes" );
    
    //    [mapViw clear];
    //    [updatetimer invalidate];
    //    [AppDelegate showAlertViewWithTitle:@"" Message:@"Your location updation has been stopped, to enable it, please refresh the button above."];
    
    
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Alert"
                                                                       message:@"For your privacy, your location has timed out. Please Click Continue to resume or Cancel to remove you Map Location "
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* continueAction = [UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {
            
            if ([_adminStatus isEqual: @"1"]) {
                
                removeLocationtimer =  [NSTimer scheduledTimerWithTimeInterval: 300
                                                                        target: self
                                                                      selector:@selector(RemoveLocations:)
                                                                      userInfo: nil repeats:NO];
                
            } else if  ([_adminStatus isEqual: @"0"]) {
                
                removeLocationtimer =  [NSTimer scheduledTimerWithTimeInterval: 120
                                                                        target: self
                                                                      selector:@selector(RemoveLocations:)
                                                                      userInfo: nil repeats:NO];
                
            }
            
            
        }];
        
        UIAlertAction* canceltAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                
                [mapViw clear];
                [updatetimer invalidate];
                [removeLocationtimer invalidate];
  
            
        }];
        
        [alert addAction:continueAction];
        [alert addAction:canceltAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        
    });
    
    
}

-(void)updateLocations:(NSTimer *)timer {
    //do smth
    NSLog(@"%@", @"60 Seconds" );
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self getSharedLocationApi];
        
    });
    
}

-(void)showLocations  {
    
    [mapViw clear];
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] init];

    for (int i =0; i <= locationArray.count-1; i++) {
       
        LocationObject *objc = [locationArray objectAtIndex:i];
        
        if (!([objc.Latitude  isEqual: @""]) && (![objc.Longitude  isEqual: @""])) {
        
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake([objc.Latitude doubleValue], [objc.Longitude doubleValue]);
        bounds = [bounds includingCoordinate:marker.position];
        marker.title = [NSString stringWithFormat:@"%@%s%@", objc.first_name," ", objc.last_name];
        //marker.snippet = @"Australia";
        marker.map = mapViw;
        
    }
        
   }
    
    [mapViw animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:100.0f]];

    
    
//    // Creates a marker in the center of the map.
//    GMSMarker *marker = [[GMSMarker alloc] init];
//    marker.position = CLLocationCoordinate2DMake(-33.86, 151.20);
//    marker.title = @"Sydney";
//    marker.snippet = @"Australia";
//    marker.map = mapViw;
//
//
//    GMSMarker *marker1 = [[GMSMarker alloc] init];
//    marker1.position = CLLocationCoordinate2DMake(-32.92, 151.78);
//    marker1.title = @"Newcastle";
//    marker1.snippet = @"Australia";
//    marker1.map = mapViw;
//

    
    
    
}


-(void)appWillResignActive:(NSNotification*)note
{
    
    [removeLocationtimer invalidate];
    [updatetimer invalidate];

}

-(void)appWillEnterForeground:(NSNotification*)note
{
    
    isTimerOn = false;
    [self getSharedLocationApi];

}

//-(void)appWillTerminate:(NSNotification*)note
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
//
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
