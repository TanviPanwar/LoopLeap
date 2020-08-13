//
//  PublicDBViewController.m
//  SimpleApp
//
//  Created by IOS3 on 25/10/18.
//  Copyright © 2018 MAC. All rights reserved.
//

#import "PublicDBViewController.h"
#import "AppDelegate.h"
#import "CreateDBController.h"
#import "LoadMoreTableViewCell.h"
#import "CategoriesViewController.h"
@interface PublicDBViewController ()<UITableViewDataSource , UITableViewDelegate>
{
    NSMutableArray *dbArray;
    NSInteger pageNo;
    UIActivityIndicatorView * spinner;
    UIButton *loadMoreBtn;
    BOOL hideLoadMoreBtn;
}
@end

@implementation PublicDBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    pageNo = 1;
    self.title = @"Public Databases";
    dbArray = [[NSMutableArray alloc] init];
     _tableViw.tableFooterView = [UIView new];
    [self GetPublicDatabasesFromServer:true];
 
    // Do any additional setup after loading the view.
}

- (IBAction)loadMoreAction:(UIButton *)sender {
    
    [loadMoreBtn setHidden:true];
    [spinner startAnimating];
    [spinner setHidden:false];
    pageNo = pageNo + 1;
    [self GetPublicDatabasesFromServer:false];
    
}

#pragma mark -
#pragma mark - Webservice Method
-(void)GetPublicDatabasesFromServer :(BOOL)showLoader
{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setObject:[NSString stringWithFormat:@"%ld", (long)pageNo] forKey:@"currentpage"];
    [dict setObject:kPublicDataBases forKey:kDefault];
    [dict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID] forKey:@"userid"];
    
    NSLog(@"dict =%@",dict);
    if (showLoader) {
    
    [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
    }
    NSString *hostUrl=[NSString stringWithFormat:@"%@",HostUrl];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:hostUrl parameters:dict success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        if (showLoader) {
        [AppDelegate hideHUDForView:self.view animated:YES];
        }
        else {
            [loadMoreBtn setHidden:false];
            [spinner stopAnimating];
            [spinner setHidden:true];
        }
       
        NSLog(@"Success: %@\n ***** %@", operation.responseString, responseObject);
        id status= [responseObject valueForKey:@"status"];
        if([status isKindOfClass:[NSString class]]){
            if([status isEqualToString:@"Success"]){
               
                NSArray *arr = [responseObject valueForKey:@"result"];
                
                if (arr.count == 0)  {
                    
                    hideLoadMoreBtn = true;
                }
                else {
                    hideLoadMoreBtn = false;
                for (int i = 0;i <arr.count ;i++ ){
                    NSDictionary *newDict = [arr objectAtIndex:i];
                    MyDataBaseObject *obj = [[MyDataBaseObject alloc] init];
                    obj.DBName = [newDict valueForKey:@"DBName"];
                    obj.DBType = [newDict valueForKey:@"DBType"];
                    obj.Databaseid = [[newDict valueForKey:@"DatabaseId"] longLongValue];
                    [dbArray addObject:obj];
                }
                }
                [self.tableViw reloadData];
                
                
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

#pragma mark -
#pragma mark - Tableview Delegate Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dbArray.count ;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"publicCell" forIndexPath:indexPath];
    MyDataBaseObject *obj = [dbArray objectAtIndex: indexPath.row];
    cell.textLabel.text = obj.DBName;
    return cell;
    
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     MyDataBaseObject *obj = [dbArray objectAtIndex: indexPath.row];
    CategoriesViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CategoriesViewController"];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
    vc.dbObj  =  obj;
    [self.navigationController pushViewController:vc animated:true];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (hideLoadMoreBtn ||  dbArray.count < 20){
       return 0;
    }
    else {
         return 45;
    }
   
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    return [UIView new];
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (hideLoadMoreBtn ||  dbArray.count < 20) {
        
        return [UIView new];
    }
    else {
    UIView * viw = [[UIView alloc] initWithFrame:CGRectMake(0, 0,tableView.frame.size.width, 45)];
    
   loadMoreBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,tableView.frame.size.width, 45)];
    
    [loadMoreBtn setTitle:@"Load More" forState:UIControlStateNormal];
    [loadMoreBtn addTarget:self action:@selector(loadMoreAction:) forControlEvents:UIControlEventTouchUpInside];
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 24)/2 , 10, 24, 24);
    [loadMoreBtn setTitleColor:[UIColor colorWithRed:20/255.0f green:123/255.0f blue:255/255.0f alpha:1.0] forState:UIControlStateNormal];
    [viw addSubview:spinner];
    [viw addSubview:loadMoreBtn];
    return viw;
    }
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
