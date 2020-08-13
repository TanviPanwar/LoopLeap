//
//  CategorySearchViewController.m
//  SimpleApp
//
//  Created by IOS2 on 6/12/17.
//  Copyright © 2017 MAC. All rights reserved.
//

#import "CategorySearchViewController.h"
#import "BrowseCategoryViewController.h"
#import "RecordListViewController.h"
#import "RenameCatViewController.h"
#import "AppDelegate.h"
#import "AFHTTPSessionManager.h"

@interface CategorySearchViewController ()

@end

@implementation CategorySearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Category List";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"home"] style:UIBarButtonItemStyleDone target:self action:@selector(homeBtnAction)];
    
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
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
    return self.searchCategoryArr.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    CategoryObject *obj =  [self.searchCategoryArr objectAtIndex:indexPath.row];
    cell.textLabel.text = obj.CategoryName;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 1.0;
    
    cell.textLabel.userInteractionEnabled = YES;
    [cell addGestureRecognizer:longPress];
    cell.tag = indexPath.row;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CategoryObject *notObj =  [self.searchCategoryArr objectAtIndex:indexPath.row];
    
    BrowseCategoryViewController * browserVC =  [self.storyboard instantiateViewControllerWithIdentifier:@"BrowseCategoryViewController"];
    browserVC.catTittle = notObj.CategoryName;
    browserVC.catId = [NSString stringWithFormat:@"%lld",notObj.CategoryID];
    
    [self.navigationController pushViewController:browserVC animated:YES];
}
/*-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                    {
                                        {
                                            
                                            
                                            CategoryObject *notObj =  [self.searchCategoryArr objectAtIndex:indexPath.row];
                                            
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
                                            
                                            
                                            
                                            
                                            
                                            
                                        }
                                    }];
    delete.backgroundColor = [UIColor redColor];
    
    UITableViewRowAction *more = [UITableViewRowAction rowActionWithStyle:                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         UITableViewRowActionStyleDefault title:@"Rename" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                  {
                                      CategoryObject *notObj =  [self.searchCategoryArr  objectAtIndex:indexPath.row];
                                      
                                      
                                      RenameCatViewController * renameVC =  [self.storyboard instantiateViewControllerWithIdentifier:@"RenameCatViewController"];
                                      renameVC.catName = notObj.CategoryName;
                                      renameVC.CategoryID = [NSString stringWithFormat:@"%lld", notObj.CategoryID];
                                      renameVC.DatabaseID = [NSString stringWithFormat:@"%lld", notObj.DatabaseID];
                                      
                                      
                                      [self.navigationController pushViewController:renameVC animated:YES];
                                  }];
    more.backgroundColor = [UIColor colorWithRed:0.188 green:0.514 blue:0.984 alpha:1];
    
    return @[delete, more];
}*/


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    
    currentIndex = gesture.view.tag;
    CategoryObject *obj=  [_searchCategoryArr objectAtIndex:currentIndex];
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
                                                                  
                                                                  
                                                                  CategoryObject *notObj =  [_searchCategoryArr objectAtIndex:indexPath.row];
                                                                  
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
                                                                            
                                                                              [[NSUserDefaults standardUserDefaults]setValue:@""forKey:@"SelectedCategory"];
                                                                              
                                                                              NSArray *array = self.navigationController.viewControllers;
                                                                              
                                                                              for (UIViewController *controller in array) {
                                                                                  if ([controller isKindOfClass:[RecordListViewController class]]) {
                                                                                      [self.navigationController popToViewController:controller animated:true];
                                                                                  }
                                                                              }
                                                                              
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
                                  CategoryObject *notObj =  [_searchCategoryArr objectAtIndex:indexPath.row];
                                  
                                  
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





@end

