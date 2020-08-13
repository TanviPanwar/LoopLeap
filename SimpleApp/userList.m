//
//  userList.m
//  SimpleApp
//
//  Created by IOS4 on 03/03/17.
//  Copyright © 2017 MAC. All rights reserved.
//

#import "userList.h"
#import "userListTableCell.h"
#import "AppDelegate.h"
#import "CreateContactController.h"

@interface userList ()
{
    NSMutableArray * arrSelected;
    NSMutableArray * selectedContacts;
    NSMutableDictionary *userDetail;
    
}
@end

@implementation userList

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableData = [[NSMutableArray alloc] init];
    
    
   // [self getContactDetail];
    
    [_tableViewUserList setTableFooterView:[[UIView alloc] init]];
    [AppDelegate getContactAuthorizationFromUser];
    [self.tableData removeAllObjects];
//    self.tableData =  [AppDelegate getContacts];
//    NSLog(@"Contacts : %@",self.tableData);
   
    
//    arrSelected = [[NSMutableArray alloc] init];
//    for (int i = 0; i <self.tableData.count; i++) {
//        [arrSelected addObject:[NSNumber numberWithBool:NO]];
//    }
    _tableViewUserList.delegate = self;
    _tableViewUserList.dataSource = self;
    [_tableViewUserList reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated {
     selectedContacts = [[NSMutableArray alloc]init];
     self.tableData = [[NSMutableArray alloc] init];
     self.tableData =  [AppDelegate getContacts];
    

    dispatch_async(dispatch_get_main_queue(), ^{
         [self checkContacts];
//         [_tableViewUserList reloadData];
    });

}

#pragma mark - Table View Data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection: (NSInteger)section
{
   return [self.tableData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"userCell";
    
    userListTableCell *cell = (userListTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
//    cell.firstName.text = [[self.tableData objectAtIndex:indexPath.row] valueForKey:@"Fname"];
    cell.lastName.text = [NSString stringWithFormat:@"%@ %@",[[self.tableData objectAtIndex:indexPath.row] valueForKey:@"Fname"],[[self.tableData objectAtIndex:indexPath.row] valueForKey:@"Lname"] ];
    cell.contactNo.text = [[self.tableData objectAtIndex:indexPath.row] valueForKey:@"phoneno"];
    
//    if ([[[self.tableData objectAtIndex:indexPath.row] valueForKey:@"Status"] isEqualToString:@"1"]) {
//        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
//    }
//    else {
//         [cell setAccessoryType:UITableViewCellAccessoryNone];
//    }
    
    
    if ([[arrSelected objectAtIndex:indexPath.row] boolValue] == YES)
    {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    else{
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // determine the selected data from the IndexPath.row
    
    if ([[arrSelected objectAtIndex:indexPath.row] boolValue] == YES) {
        [arrSelected replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:NO]];
    }
    else{
        [arrSelected replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
    }
    [self.tableViewUserList reloadData];
}

-(void)checkContacts {
      //  self.tableData =  [AppDelegate getContacts];
  
    NSLog(@"%@",self.tableData);
        [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
        NSMutableDictionary   *newUserDetail = [[NSMutableDictionary  alloc] init];
        [newUserDetail removeAllObjects];
        [newUserDetail setObject:self.tableData forKey:@"contacts"];
        NSError *error;
        NSData *postdata = [NSJSONSerialization dataWithJSONObject:newUserDetail options:0 error:&error];
        NSString *responseString = [[NSString alloc] initWithData:postdata encoding:NSUTF8StringEncoding];
        [NSString stringWithFormat:@"%@",HostUrl];
        NSMutableDictionary *dict  = [[NSMutableDictionary alloc] init];
        [dict setValue:kImportContacts forKey:kDefault];
        [dict setValue:responseString forKey:kPhoneBook];
        NSLog(@"JSONSTRING  %@", responseString);
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:HostUrl parameters:dict success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            
                 [AppDelegate hideHUDForView:self.view animated:YES];
            NSLog(@"Success: %@\n ***** %@", operation.responseString, responseObject);
            id status= [responseObject valueForKey:@"status"];
            if([status isKindOfClass:[NSString class]]){
                if([status isEqualToString:@"success"]){
                    
                    [self.tableData removeAllObjects];
                    NSMutableArray *array = [[NSMutableArray alloc] init];
                    array = [responseObject valueForKey:@"result"];
                    
                    for (int i=0; i < array.count; i++) {
                        
                        NSMutableDictionary *contactDict = [[NSMutableDictionary alloc] init];
                        [contactDict setValue:[[array objectAtIndex:i] valueForKey:@"Fname"] forKey:@"Fname"];
                        [contactDict setValue:[[array objectAtIndex:i] valueForKey:@"Lname"] forKey:@"Lname"];
                        [contactDict setValue:[[array objectAtIndex:i] valueForKey:@"userid"] forKey:@"userid"];
                        [contactDict setValue:[[array objectAtIndex:i] valueForKey:@"Status"] forKey:@"Status"];
                        [contactDict setValue:[[array objectAtIndex:i] valueForKey:@"phoneno"] forKey:@"phoneno"];
                        [self.tableData addObject:contactDict];
                        
                    }
                    
                    arrSelected = [[NSMutableArray alloc] init];
                    for (int i = 0; i <self.tableData.count; i++) {
                        if ([[[self.tableData objectAtIndex:i] valueForKey:@"Status"] isEqualToString:@"1"]) {
                            [arrSelected addObject:[NSNumber numberWithBool:YES]];
                            
                        }
                        else {
                             [arrSelected addObject:[NSNumber numberWithBool:NO]];
                        }
                        
                    }
                    [_tableViewUserList reloadData];
                  
                }
                else{
                    
                }
            }
        } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
            NSLog(@"Error: %@ ***** %@", operation.responseString, error);
            [AppDelegate hideHUDForView:self.view animated:YES];
            
            //if(dict)
            //        [AppDelegate showAlertViewWithTitle:@"Network error" Message:@"Please Check your internet connection."];
        }];
    
}

-(void)importAllContactsApi: (NSMutableArray *)Contacts :(NSString *)message {
    
    [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
    NSMutableDictionary   *newUserDetail = [[NSMutableDictionary  alloc] init];
    [newUserDetail removeAllObjects];
    [newUserDetail setObject:Contacts forKey:@"contacts"];
    NSError *error;
    NSData *postdata = [NSJSONSerialization dataWithJSONObject:newUserDetail options:0 error:&error];
    NSString *responseString = [[NSString alloc] initWithData:postdata encoding:NSUTF8StringEncoding];
    [NSString stringWithFormat:@"%@",HostUrl];
    NSMutableDictionary *dict  = [[NSMutableDictionary alloc] init];
    [dict setValue:kAllContacts forKey:kDefault];
    [dict setValue:responseString forKey:kPhoneBook];
    NSLog(@"JSONSTRING  %@", responseString);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:HostUrl parameters:dict success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        [AppDelegate hideHUDForView:self.view animated:YES];
        NSLog(@"Success: %@\n ***** %@", operation.responseString, responseObject);
        id status= [responseObject valueForKey:@"status"];
        if([status isKindOfClass:[NSString class]]){
            if([status isEqualToString:@"success"]){
                
                if ([message isEqualToString:@"All Contacts Added"]) {
                     [self checkContacts];
                }
                [AppDelegate showAlertViewWithTitle:@"Message" Message:message];
            }
            else{
                
            }
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        [AppDelegate hideHUDForView:self.view animated:YES];
        
        //if(dict)
        //        [AppDelegate showAlertViewWithTitle:@"Network error" Message:@"Please Check your internet connection."];
    }];
    
}


- (IBAction)btnaddManually:(id)sender {
    CreateContactController *createContact = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateContactController"];
    [self.navigationController presentViewController:createContact animated:true completion:nil];
}



- (IBAction)btnSave:(id)sender {
   
    selectedContacts = [[NSMutableArray alloc] init];
      for (int i = 0; i <arrSelected.count; i++) {
          if ([[arrSelected objectAtIndex:i] boolValue] == true) {
              
              [selectedContacts addObject:[self.tableData objectAtIndex:i]];
          }
          
      }
    
    [self importAllContactsApi:selectedContacts :@"Selected Contacts Added"];
     NSLog(@"%@", selectedContacts);
    
    
}

- (IBAction)btnImportContact:(id)sender {
    [self importAllContactsApi:self.tableData :@"All Contacts Added"];
}
@end
