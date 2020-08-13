//
//  FriendListViewController.m
//  WLTG
//
//  Created by MAC on 10/27/15.
//  Copyright (c) 2015 iPhone. All rights reserved.
//

#import "CategoryListViewController.h"
#import "AppDelegate.h"
#import "NoteDetailViewController.h"
//#import "AddItemViewController.h"

#import "RecordListViewController.h"
@interface CategoryListViewController () <UITableViewDataSource,UITableViewDelegate,UISearchDisplayDelegate,UISearchBarDelegate,UIAlertViewDelegate> {
    NSInteger selectedIndex;
    NSArray *searchResultArr;
    NSMutableArray *selectedCategoryArr;
    
    BOOL isSearchActive;

}
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation CategoryListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   // self.navigationController.navigationBarHidden=NO;
   // self.navigationItem.hidesBackButton=YES;
    
    isSearchActive=NO;
    //_categoryArr=[[NSMutableArray alloc]init];
    self.tableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
   // self.tableView.tableHeaderView.frame=CGRectMake(0, 0, self.view.frame.size.width, 44);
    
//    UIBarButtonItem *addBtn=[[UIBarButtonItem alloc]initWithTitle:@"+" style:UIBarButtonItemStylePlain target:self action:@selector(addCategory)];
//    self.navigationItem.rightBarButtonItem=addBtn;
    
//    UIBarButtonItem *logOut=[[UIBarButtonItem alloc]initWithTitle:@"Log out" style:UIBarButtonItemStylePlain target:self action:@selector(logOutAction)];
//    self.navigationItem.leftBarButtonItem=logOut;
    
    

    
}
-(void)viewWillAppear:(BOOL)animated
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBarHidden=NO;
    //self.navigationItem.hidesBackButton=YES;
    //[self fetch];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

#pragma mark- Navigation
#pragma mark-
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
    
    if([segue.identifier isEqualToString:@"MemoDetail"])
    {
        NoteDetailViewController *obj=segue.destinationViewController;
        obj.recordArr=selectedCategoryArr;
         obj.selectedIndex=0;
    
    }
}


//#pragma mark- Navigation
//#pragma mark-
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if([segue.identifier isEqualToString:@"AddItemSegue"])
//    {
//        AddItemViewController *obj=segue.destinationViewController;
//        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
//    
//    }else  if([segue.identifier isEqualToString:@"RecordListSegue"])
//    {
//        RecordListViewController *obj=segue.destinationViewController;
//        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
//        obj.categoryName=[categoryArr[selectedIndex] valueForKey:@"category_name"];;
//    }
//}

//-(void)addCategory
//{
//    [self performSegueWithIdentifier:@"AddItemSegue" sender:self];
//}
#pragma mark - UITableViewDelegate & UITableViewDataSource
#pragma mark-

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(isSearchActive)
        return searchResultArr.count;
   
    return _categoryArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
//    if(isSearchActive)
//        cell.textLabel.text=[searchResultArr[indexPath.row] valueForKey:@"category_name"];
//    else
        cell.textLabel.text=[_categoryArr[indexPath.row] valueForKey:@"category_name"];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedIndex=indexPath.row;
    [self fetchRecord];
     if(selectedCategoryArr.count){
          [self performSegueWithIdentifier:@"MemoDetail" sender:self];
     }else{
         [AppDelegate showAlertViewWithTitle:nil Message:@"Your Category Has No Memo."];
     }
   
  
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndex=indexPath.row;
    [self fetchRecord];
    if(selectedCategoryArr.count>1)
    {
        [AppDelegate showAlertViewWithTitle:@"Sorry!" Message:@"Category Must Contain Only One Note To Be Delete"];
    }else{
       
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            // Delete object from database
            [self deleteDetail];
           
          
        }

    }
}

-(void)deleteDetail{
    
    UIAlertView *alert;
    if(!alert)
    {
        alert = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure want to delete category?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
    }
    [alert show];
    
}


#pragma mark- UIAlertViewDelegate
#pragma mark-

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        [self deleteCategory];
    }
}
-(void)deleteCategory
{
     NSManagedObjectContext *context = [self managedObjectContext];
    [context deleteObject:[self.categoryArr objectAtIndex:selectedIndex]];
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
        return;
    }
    [self.categoryArr removeObjectAtIndex:selectedIndex];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:selectedIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self deleteRecords];
   // [self.tableView reloadData];
    // Remove device from table view
   
}
-(void)deleteRecords
{
    NSManagedObjectContext *context = [self managedObjectContext];
    for(NSManagedObject *record in selectedCategoryArr)
    {
        [context deleteObject:record];
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }

    }
    

    
}
//#pragma mark- UISearchDisplayDelegate
//#pragma mark-
//
//- (void)filterContentForSearchText:(NSString*)searchText
//{
//    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"%K contains[c] %@",@"category_name", searchText];
//   searchResultArr = [_categoryArr filteredArrayUsingPredicate:resultPredicate];
//   [self.tableView reloadData];
//}
//
//
//
//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
//{
//    if(searchBar.text.length)
//    {
//        isSearchActive=YES;
//        [self filterContentForSearchText:searchBar.text];
//    }else
//    {
//         isSearchActive=NO;
//        [self.tableView reloadData];
//    }
//    
//}
//
//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
//{
//    [searchBar resignFirstResponder];
//    // Do the search...
//}
//-(void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar
//{
//    //This'll Show The cancelButton with Animation
//    [searchBar setShowsCancelButton:YES animated:YES];
//    //remaining Code'll go here
//}
//- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
//{
//    //This'll Hide The cancelButton with Animation
//    [self cancelSearchBr];
//    
//    
//}
//
//-(void)cancelSearchBr
//{
//    _searchBar.text=@"";
//    isSearchActive=NO;
//    [_searchBar resignFirstResponder];
//    [_searchBar setShowsCancelButton:NO animated:YES];
//    [self.tableView reloadData];
//
//}
//
//-(void)fetch
//{
//    
//    // Fetch the devices from persistent data store
//    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:CategoryTable];
//    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"email_id == %@",[AppDelegate getUserEmail]];
//    _categoryArr = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
//
//    [self.tableView reloadData];
//
//}

//-(void)logOutAction
//{
//    [self.navigationController popToRootViewControllerAnimated:YES];
//}

-(void)fetchRecord
{
    NSString *categoryName=[_categoryArr[selectedIndex] valueForKey:@"category_name"];
    // Fetch the devices from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:RecordTable];
    NSSortDescriptor *sdSortDate = [NSSortDescriptor sortDescriptorWithKey:@"record_time" ascending:NO];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"email_id == %@ && category_name == %@",[AppDelegate getUserEmail],categoryName];
    fetchRequest.sortDescriptors=@[sdSortDate];
    selectedCategoryArr = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
   
    
}
@end
