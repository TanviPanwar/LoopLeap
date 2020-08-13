//
//  CategoryLIstingViewController.m
//  SimpleApp
//
//  Created by IOS2 on 6/28/17.
//  Copyright © 2017 MAC. All rights reserved.
//

#import "CategoryLIstingViewController.h"
#import "BrowseCategoryViewController.h"
#import "RecordListViewController.h"
#import "DBManager.h"
#import "AppDelegate.h"
#import "RenameCatViewController.h"

@interface CategoryLIstingViewController (){
    NSArray *searchResultArr;
    BOOL isSearchActive;
     NSInteger currentIndex;
}
@property (strong, nonatomic) IBOutlet UISearchBar *searchController;

@end

@implementation CategoryLIstingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.title = @"Category List";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"home"] style:UIBarButtonItemStyleDone target:self action:@selector(homeBtnAction)];
    
    _searchCategoryArr =  [[DBManager getSharedInstance] getcategoryListOfSelectedDB : self.dbID];
    
    // Do any additional setup after loading the view.
}

-(void)homeBtnAction {
    NSArray *array = self.navigationController.viewControllers;
    
    for (UIViewController *controller in array) {
        if ([controller isKindOfClass:[RecordListViewController class]]) {
            [self.navigationController popToViewController:controller animated:true];
        }
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (isSearchActive) {
        return searchResultArr.count;
    }
    return self.searchCategoryArr.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    if (isSearchActive) {
        CategoryObject *obj =  [searchResultArr objectAtIndex:indexPath.row];
        cell.textLabel.text = obj.CategoryName;

    }else{
    
    CategoryObject *obj =  [self.searchCategoryArr objectAtIndex:indexPath.row];
    cell.textLabel.text = obj.CategoryName;
    }
    
   
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CategoryObject *notObj;
    
     if (isSearchActive) {
          notObj =  [searchResultArr objectAtIndex:indexPath.row];
     }
     else
     {
          notObj =  [self.searchCategoryArr objectAtIndex:indexPath.row];
     }
   
    
    [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
  
    NSMutableDictionary *userDetail = [[NSMutableDictionary alloc]init];
    [userDetail setValue:KMoveNotes forKey:kDefault];
    [userDetail setValue:[NSString stringWithFormat:@"%lld",notObj.CategoryID] forKey:@"category_id"];
    [userDetail setValue:[NSString stringWithFormat:@"%lld",self.selectedObj.NotesID]  forKey:@"notes_id"];
   
    
    NSLog(@"UsetDetail Dict%@", userDetail);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:HostUrl parameters:userDetail success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        [AppDelegate hideHUDForView:self.view animated:YES];
        NSLog(@"Success: %@\n ***** %@", operation.responseString, responseObject);
        id status= [responseObject valueForKey:@"status"];
        if([status isKindOfClass:[NSString class]]){
            if([status isEqualToString:@"Success"]) {
                
                [[DBManager getSharedInstance]MoveNotesFromCategory:[NSString stringWithFormat:@"%lld",notObj.CategoryID ]withNoteID:[NSString stringWithFormat:@"%lld",self.selectedObj.NotesID] withDbID:[NSString stringWithFormat:@"%lld",self.selectedObj.DatabaseID]];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else{
                 [AppDelegate showAlertViewWithTitle:@"" Message:@"Please try again."];
            }
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        
        [AppDelegate hideHUDForView:self.view animated:YES];
        //if(dict)
        [AppDelegate showAlertViewWithTitle:@"Network Error" Message:@"Please Check Your Internet Connection."];
    }];

    
   
   
}

#pragma mark- UISearchDisplayDelegate

- (void)filterContentForSearchText:(NSString*)searchText
{
    searchResultArr = [NSArray new];
    NSPredicate *resultPredicate;
    if(self.searchCategoryArr.count)
    
    {
        resultPredicate = [NSPredicate predicateWithFormat:@"SELF.CategoryName CONTAINS[cd] %@ ", searchText];
       searchResultArr = [self.searchCategoryArr filteredArrayUsingPredicate:resultPredicate];
        
        
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

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
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
    _searchController.text=@"";
    isSearchActive=NO;
    [_searchController resignFirstResponder];
    [_searchController setShowsCancelButton:NO animated:YES];
    [self.tableView reloadData];
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
