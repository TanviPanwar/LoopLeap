//
//  SelectDatabaseVC.m
//  SimpleApp
//
//  Created by IOS3 on 15/06/18.
//  Copyright © 2018 MAC. All rights reserved.
//

#import "SelectDatabaseVC.h"
#import "AppDelegate.h"

@interface SelectDatabaseVC ()
{
    NSMutableArray *dbArray;
  
}
@end

@implementation SelectDatabaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *dbName =   [[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentDbName"];
    if (![_screenType isEqualToString:@"Delete"]) {
        if ([dbName isEqualToString:@""]|| dbName == (NSString *)[NSNull null] || dbName == nil) {
            self.title = [NSString stringWithFormat:@"No Database Selected"];
        }
        else {
        self.title = [NSString stringWithFormat:@"Current Database: %@",dbName ];
        }
    }
    else {
        
        if ([dbName isEqualToString:@""]|| dbName == (NSString *)[NSNull null] || dbName == nil) {
            self.title = [NSString stringWithFormat:@"No Database Found"];
        }
        else {
           self.title = @"Databases";
        }
        
        
        [_databaseTable setEditing:YES animated:YES];
        UIBarButtonItem *delete = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteAction)];
        self.navigationItem.rightBarButtonItem = delete;
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }
    [self getMyDBListFromSqlite];
    // Do any additional setup after loading the view.
}
-(void)getMyDBListFromSqlite {
    
    _databaseTable.tableFooterView = [UIView new];
    dbArray = [[NSMutableArray alloc] init];
    NSString *ownerID = [[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID];
    dbArray = [[DBManager getSharedInstance]getDataFromMyDataBase:ownerID];
    [_databaseTable reloadData];
    
}
-(void)deleteAction {
    
    
    
    NSString *dbID =  [[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentDbID"];
    NSArray *arr = [_databaseTable indexPathsForSelectedRows];
    NSMutableArray *idArr = [[NSMutableArray alloc] init];
    for(int i = 0; i<arr.count ; i++) {
    NSIndexPath *indexpath = [arr objectAtIndex:i];
    MyDataBaseObject * obj = [dbArray objectAtIndex:indexpath.row];
        [idArr addObject:[NSString stringWithFormat:@"%lld",obj.Databaseid]];
    }
    
    [self deleteDB:idArr];
    
    
    
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dbArray.count;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![_screenType isEqualToString:@"Delete"]) {
        return 0;
    }
    else {
        return 3;
    }
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell= [tableView dequeueReusableCellWithIdentifier:@"selectDatabaseCell" forIndexPath:indexPath];
    MyDataBaseObject *obj = dbArray[indexPath.row];
    
    NSString *dbID =  [[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentDbID"];
    NSString *dbName =   [[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentDbName"];
    if (![_screenType isEqualToString:@"Delete"]) {
        if([[NSString stringWithFormat:@"%lld", obj.Databaseid] isEqualToString:dbID]) {
            [_databaseTable selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
        else {
            [_databaseTable deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
    else {
        
    }
    
    cell.textLabel.text = obj.DBName;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MyDataBaseObject *obj = dbArray[indexPath.row];
    if (![_screenType isEqualToString:@"Delete"]) {
        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%lld", obj.Databaseid] forKey:@"CurrentDbID"];
        [[NSUserDefaults standardUserDefaults] setValue:obj.DBName forKey:@"CurrentDbName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshDatabase" object:self];
        self.title = [NSString stringWithFormat:@"Current Database: %@",obj.DBName ];
    }
    else {
        
        NSArray *arr = [_databaseTable indexPathsForSelectedRows];
        if (arr.count > 0) {
            [self.navigationItem.rightBarButtonItem setEnabled:YES];
        }
        else {
             [self.navigationItem.rightBarButtonItem setEnabled:NO];
        }
    }
    
    
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_screenType isEqualToString:@"Delete"]) {
        NSArray *arr = [_databaseTable indexPathsForSelectedRows];
        if (arr.count > 0) {
            [self.navigationItem.rightBarButtonItem setEnabled:YES];
        }
        else {
            [self.navigationItem.rightBarButtonItem setEnabled:NO];
        }
    }
}

-(void)deleteDB:(NSMutableArray*)array{
    NSMutableString *idStr = [[NSMutableString alloc] init];
    for (int i = 0;i < array.count ;i++) {
        [idStr appendString:[array objectAtIndex:i]];
        [idStr appendString:@","];
    }
    if ([idStr length] > 0) {
    idStr = [idStr substringToIndex:[idStr length] - 1];
    }
    NSLog(@"idStr ** %@",[NSString stringWithFormat:@"%@",idStr]);
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setObject:KDeleteDatabase forKey:kDefault];
    [dict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID] forKey:@"owner_id"];
    [dict setValue:idStr forKey:@"database_id"];
    NSLog(@"dict =%@",dict);
    [self hitApi:dict arr:array];
    
    //  NSData *data=[NSJSONSerialization en ]
}
-(void)hitApi:(NSMutableDictionary*)dict  arr:(NSMutableArray *)idArr
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
            [[DBManager getSharedInstance] deleteDatabaseFrom:idArr];
             NSString *dbID =  [[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentDbID"];
                if ([idArr containsObject:dbID]) {
                    if (dbArray.count > 0 ) {
                        MyDataBaseObject * obj = [dbArray objectAtIndex:0];
                        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%lld", obj.Databaseid] forKey:@"CurrentDbID"];
                        [[NSUserDefaults standardUserDefaults] setValue:obj.DBName forKey:@"CurrentDbName"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshDatabase" object:self];
                    }
                    else {
                        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"CurrentDbID"];
                        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"CurrentDbName"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshDatabase" object:self];
                    }
                }
                [self getMyDBListFromSqlite];
                
                [AppDelegate showAlertViewWithTitle:@"" Message:@"Databases Deleted Successfully."];
                  
            }
            
            else{
                [AppDelegate hideHUDForView:self.view animated:YES];
                [AppDelegate showAlertViewWithTitle:@"Sorry!" Message:@"Try Again."];
            
            }
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
       
        
        [AppDelegate hideHUDForView:self.view animated:YES];
        //if(dict)
        [AppDelegate showAlertViewWithTitle:@"Network Error" Message:@"Please Check Your Internet Connection."];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */



@end
