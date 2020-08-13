//
//  importListViewController.m
//  SimpleApp
//
//  Created by IOS4 on 14/03/17.
//  Copyright © 2017 MAC. All rights reserved.
//

/*#import "importListViewController.h"
#import "AFNetworking.h"
#import "NoteDetailViewController.h"
#import "AppDelegate.h"
#import "SearchTableViewCell.h"
#include "SearchObject.h"
#import "CategoryListViewController.h"
@interface importListViewController ()

    {
        NSMutableArray *recordArr,*categoryArr;
        BOOL isSearchActive;
        NSMutableArray *searchResultArr;
        NSInteger selectedIndex;
        NSArray *searchRecorArr;
        NSArray *searchNoteArr;
        NSArray *searchCategoryArr;
        
    }

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation importListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    recordArr=[[NSMutableArray alloc]init];
    categoryArr=[[NSMutableArray alloc]init];
    searchResultArr=[[NSMutableArray alloc]init];
    searchNoteArr=[[NSArray alloc]init];
    isSearchActive=NO;
    self.title = @"Import DB List";
    
   // [self ApiCall];
}

-(void)ApiCall
{
    [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
    // NSString *registerUrl=[NSString stringWithFormat:@"%@",HostUrl];
    NSMutableDictionary *userDetail = [[NSMutableDictionary alloc]init];
    [userDetail setValue:kImportList forKey:kDefault];
     [userDetail setValue:[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID] forKey:kLoogedInUserID];
   // [userDetail setValue:@"27" forKey:kLoogedInUserID];
    
    NSLog(@"UsetDetail Dict%@", userDetail);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:HostUrl parameters:userDetail success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        [AppDelegate hideHUDForView:self.view animated:YES];
        NSLog(@"Success: %@\n ***** %@", operation.responseString, responseObject);
        id status= [responseObject valueForKey:@"status"];
        if([status isKindOfClass:[NSString class]]){
            if([status isEqualToString:@"success"]) {
             
            }
            
            else
            {
                //                    [AppDelegate showAlertViewWithTitle:@"Sorry!" Message:@"Email already exists"];
            }
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        
        [AppDelegate hideHUDForView:self.view animated:YES];
        //if(dict)
        [AppDelegate showAlertViewWithTitle:@"Network error" Message:@"Please Check your internet connection"];
    }];

}

-(void)viewWillAppear:(BOOL)animated
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBarHidden=NO;
    
    //    [self fetchRecord];
    //    [self fetchCategory];
    [self getCategoryList];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self cancelSearchBr];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                case 1:
                {
                    obj.recordArr=[NSMutableArray arrayWithArray:searchRecorArr];
                    obj.selectedIndex=0;
                }
                    break;
                    
                case 2:
                {
                    obj.recordArr=[NSMutableArray arrayWithArray:searchNoteArr];
                    obj.selectedIndex=0;
                }
                    break;
                    
            }
            
        }else{
            obj.recordArr=recordArr;
        }
        
        
    }else if([segue.identifier isEqualToString:@"CategorySegue"])
    {
        CategoryListViewController *obj=segue.destinationViewController;
        obj.categoryArr=[NSMutableArray arrayWithArray:searchCategoryArr];
        
        
    }
}

-(void)getCategoryList {
    
    [recordArr removeAllObjects];
    [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
    // NSString *registerUrl=[NSString stringWithFormat:@"%@",HostUrl];
    NSMutableDictionary *userDetail = [[NSMutableDictionary alloc]init];
    [userDetail setValue:kImportList forKey:kDefault];
     [userDetail setValue:[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID] forKey:kLoogedInUserID];
  //  [userDetail setValue:@"27" forKey:kLoogedInUserID];
    
    NSLog(@"UsetDetail Dict%@", userDetail);

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:HostUrl parameters:userDetail success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        [AppDelegate hideHUDForView:self.view animated:YES];
        NSLog(@"Success: %@\n ***** %@", operation.responseString, responseObject);
        id status= [responseObject valueForKey:@"status"];
        if([status isKindOfClass:[NSString class]]){
            if([status isEqualToString:@"success"]) {
                
                NSArray *dbArr = [responseObject valueForKey:@"Import Database"];
                
                for (int i= 0; i <[dbArr count]; i++) {
                    
                    NSString *myJsonString = [[[responseObject  valueForKey:@"Import Database"] objectAtIndex:i] valueForKey:@"Catalog"];
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
                //    [[NSUserDefaults standardUserDefaults] setObject:recordArr forKey:@"CategoryArray"];
                [userDefaults synchronize];
                [_tableView reloadData];
                
            }
            else{
                
            }
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        
        [AppDelegate hideHUDForView:self.view animated:YES];
        //if(dict)
        [AppDelegate showAlertViewWithTitle:@"Network error" Message:@"Please Check your internet connection"];
    }];
   
}


#pragma mark - UITableViewDelegate & UITableViewDataSource
#pragma mark-

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(isSearchActive)
        return searchResultArr.count;
    
    return recordArr.count;
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
    }else{
        
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
        cell.textLabel.text=[recordArr[indexPath.row] valueForKey:@"title"];
        cell.detailTextLabel.text=[recordArr[indexPath.row] valueForKey:@"Note"];
        return cell;
    }
    
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedIndex=indexPath.row;
    if(isSearchActive)
    {
        switch(indexPath.row)
        {
            case 0:
            {
                if(searchRecorArr.count)
                    [self performSegueWithIdentifier:@"MemoDetail" sender:self];
                //searchCategoryArr
                // CategorySegue
            }
                break;
                
            case 1:
            {
                if(searchRecorArr.count)
                    [self performSegueWithIdentifier:@"MemoDetail" sender:self];
            }
                break;
                
            case 2:
            {
                if(searchNoteArr.count)
                    [self performSegueWithIdentifier:@"MemoDetail" sender:self];
            }
                break;
                
        }
    }else {
        [self performSegueWithIdentifier:@"MemoDetail" sender:self];
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



#pragma mark- UISearchDisplayDelegate
#pragma mark-

- (void)filterContentForSearchText:(NSString*)searchText
{
    [searchResultArr removeAllObjects];
    NSPredicate *resultPredicate;
    if(categoryArr.count){
        resultPredicate = [NSPredicate predicateWithFormat:@"%K contains[c] %@",@"category_name", searchText];
        searchCategoryArr = [categoryArr filteredArrayUsingPredicate:resultPredicate];
        
        SearchObject *obj=[[SearchObject alloc]init];
        obj.key=@"Categories";
        obj.value=[NSString stringWithFormat:@"%lu",(unsigned long)searchCategoryArr.count];
        [searchResultArr addObject:obj];
        
    }
    
    if(recordArr.count)
    {
        resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
        NSArray *arrTitle = [recordArr valueForKey:@"title"];
        searchRecorArr = [arrTitle filteredArrayUsingPredicate:resultPredicate];
        SearchObject *obj=[[SearchObject alloc]init];
        obj.key=@"Titles";
        obj.value=[NSString stringWithFormat:@"%lu",(unsigned long)searchRecorArr.count];
        [searchResultArr addObject:obj];
        resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
        NSArray *arrNote = [recordArr valueForKey:@"Note"];
        searchNoteArr = [arrNote filteredArrayUsingPredicate:resultPredicate];
        SearchObject *obj2=[[SearchObject alloc]init];
        obj2.key=@"Notes";
        obj2.value=[NSString stringWithFormat:@"%lu",(unsigned long)searchNoteArr.count];
        [searchResultArr addObject:obj2];
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




@end*/


//
//  RecordListViewController.m
//  SimpleApp
//
//  Created by IOS1 on 1/27/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import "importListViewController.h"
#import "NoteDetailViewController.h"
#import "AppDelegate.h"
#import "SearchTableViewCell.h"
#include "SearchObject.h"
#import "CategoryListViewController.h"
#import "AddItemViewController.h"

#define ROOTVIEW [[[UIApplication sharedApplication] keyWindow] rootViewController]
@interface importListViewController ()


{
    NSMutableArray *recordArr,*categoryArr;
    BOOL isSearchActive;
    NSMutableArray *searchResultArr;
    NSInteger selectedIndex;
    NSArray *searchRecorArr;
    NSArray *searchNoteArr;
    NSArray *searchCategoryArr;
    
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSString * enteredPincode;
@end

@implementation importListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    recordArr=[[NSMutableArray alloc]init];
    categoryArr=[[NSMutableArray alloc]init];
    searchResultArr=[[NSMutableArray alloc]init];
    searchNoteArr=[[NSArray alloc]init];
    isSearchActive=NO;
    self.title = @"Shared DB info";
    
}

- (IBAction)AddCat:(id)sender {
    
    NSString * userID =   [[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID];
    NSArray * data = [[NSArray alloc] init];
    NSString *query = [NSString stringWithFormat:@"SELECT COUNT(*)  FROM SharedDatabases WHERE  UserId =%lld and Admin = 1",[userID longLongValue]];
    data = [[DBManager getSharedInstance] recordExistOrNot:query];
    
    if ([[data objectAtIndex:0] intValue] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:
                              @"Share Database not found" message:nil delegate:nil cancelButtonTitle:
                              @"OK" otherButtonTitles:nil];
        [alert show];
        
    }
    else
    {
        NSLog(@"%d",[[data objectAtIndex:0] intValue]);
        [self performSegueWithIdentifier:@"AddItemSegue" sender:self];
    }

}

-(void)viewWillAppear:(BOOL)animated
{
    
    [categoryArr removeAllObjects ];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBarHidden=NO;
    self.navigationItem.hidesBackButton=NO;
    recordArr = [[NSMutableArray alloc]init];
    recordArr  = [[DBManager getSharedInstance] getNotesDataUsingImportListFromUserNotes:[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID]];
    for (int i = 0; i < recordArr.count; i++) {
        NotesObject *notes =  [recordArr objectAtIndex:i];
        NSMutableDictionary * dict  = [[NSMutableDictionary alloc] init];
        [dict setValue:notes.Title forKey:@"title"];
        [dict setValue:notes.Note forKey:@"Note"];
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
    
    else if([segue.identifier isEqualToString:@"AddItemSegue"])
    {
        AddItemViewController *obj=segue.destinationViewController;
        
        obj.isFrom = @"ImportList";
        
        
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
                //    [[NSUserDefaults standardUserDefaults] setObject:recordArr forKey:@"CategoryArray"];
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(isSearchActive)
        return searchResultArr.count;
    
    return recordArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(isSearchActive)
    {
        SearchObject *obj=searchResultArr[indexPath.row];
        SearchTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"SearchCellIdentifier" forIndexPath:indexPath];
        [cell.title setTitle:obj.key forState:UIControlStateNormal];
//        cell.title.layer.cornerRadius=5;
//        cell.title.layer.borderWidth=1;
        cell.countLable.text=[NSString stringWithFormat:@"Found %@ results in",obj.value];
        if([obj.value intValue]==0)
            cell.title.layer.opacity=0.5;
        else
            cell.title.layer.opacity=1.0;
        
        
        return cell;
    }else {
        
        UITableViewCell *cell= [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
        if (recordArr.count >0) {
            
            NotesObject *notObj =  [recordArr objectAtIndex:indexPath.row];
            cell.textLabel.text= notObj.Title;
            cell.detailTextLabel.text=notObj.Note;

            NSString *htmlDes =  notObj.Note;
            NSAttributedString *attributedString = [[NSAttributedString alloc]
                                                    initWithData: [htmlDes dataUsingEncoding:NSUnicodeStringEncoding]
                                                    options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                                                    documentAttributes: nil
                                                    error: nil
                                                    ];
            cell.detailTextLabel.attributedText = attributedString;
        }
        
        return cell;
    }
    
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
                if(searchNoteArr.count)
                    [self performSegueWithIdentifier:@"MemoDetail" sender:self];
            }
                break;
                
        }
    }else {
        
        
        [self performSegueWithIdentifier:@"MemoDetail" sender:self];
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
    else
    {
        NSLog(@"%d",[[data objectAtIndex:0] intValue]);
        [self performSegueWithIdentifier:@"AddItemSegue" sender:self];
    }
}

- (IBAction)addRecord:(id)sender {
    
    
    [self findDBEmptyOrNot];

}

-(void)userInfoAction
{
    [self performSegueWithIdentifier:@"UserInfoSegue" sender:self];
}
- (IBAction)settingAction:(id)sender {
    
    [self performSegueWithIdentifier:@"SettingSegue" sender:self];
}


@end

