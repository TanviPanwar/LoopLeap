//
//  DBListViewController.m
//  SimpleApp
//
//  Created by IOS3 on 25/10/18.
//  Copyright © 2018 MAC. All rights reserved.
//

#import "DBListViewController.h"
#import "AppDelegate.h"
#import "CreateDBController.h"
@interface DBListViewController ()<UITableViewDelegate , UITableViewDataSource>
{
    NSMutableArray *dbArray;
    NSArray *filterArray;
}
@end

@implementation DBListViewController

#pragma mark -
#pragma mark - View Life Cycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"My Databases";
    
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self getMyDBListFromSqlite];
}

#pragma mark -
#pragma mark - IBAction Method



- (IBAction)segmentAction:(UISegmentedControl*)sender {
    if (sender.selectedSegmentIndex == 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.DBType == %@ ",@"Public"];
        filterArray = [dbArray filteredArrayUsingPredicate:predicate];
        
    }
    else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.DBType == %@ ",@"Personal"];
        filterArray = [dbArray filteredArrayUsingPredicate:predicate];
    }
    [self.tableViw reloadData];
    
}

#pragma mark -
#pragma mark - Tableview Delegate Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return filterArray.count;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"dbListCell" forIndexPath:indexPath];
    MyDataBaseObject *obj = [filterArray objectAtIndex: indexPath.row];
    cell.textLabel.text = obj.DBName;
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MyDataBaseObject *obj = [filterArray objectAtIndex: indexPath.row];
    CreateDBController *dbController = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateDBController"];
    dbController.screenType = @"Edit";
    dbController.dbObj = obj;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:dbController];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark -
#pragma mark - Get Data From Local Database
-(void)getMyDBListFromSqlite {
    
    _tableViw.tableFooterView = [UIView new];
    dbArray = [[NSMutableArray alloc] init];
    NSString *ownerID = [[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID];
    dbArray = [[DBManager getSharedInstance]getDataFromMyDataBase:ownerID];
    
    if (_segmentControl.selectedSegmentIndex == 0) {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.DBType == %@ ",@"Public"];
    filterArray = [dbArray filteredArrayUsingPredicate:predicate];
        
    }
    else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.DBType == %@ ",@"Personal"];
        filterArray = [dbArray filteredArrayUsingPredicate:predicate];
        
    }
    [_tableViw reloadData];
    
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
