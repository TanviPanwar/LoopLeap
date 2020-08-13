//
//  CategoriesViewController.m
//  SimpleApp
//
//  Created by IOS3 on 26/10/18.
//  Copyright © 2018 MAC. All rights reserved.
//

#import "CategoriesViewController.h"
#import "CategoryObject.h"
#import "CollectionTableViewCell.h"
#import "BrowseCategoryViewController.h"
#import "CategoryCollectionViewCell.h"
@interface CategoriesViewController ()<UITableViewDelegate , UITableViewDataSource, UICollectionViewDelegate , UICollectionViewDataSource>
{
     NSMutableArray  *categoryListArray,*dbArray;
     BOOL isGridView;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation CategoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _dbObj.DBName;
    categoryListArray = [[NSMutableArray alloc] init];
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"GridView"]) {
        isGridView = true;
    }else{
        isGridView = false;
    }
    [self.tableView reloadData];
    // Do any additional setup after loading the view.
}
#pragma mark - UITableViewDelegate & UITableViewDataSource
#pragma mark-

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        if (isGridView) {
            return 1;
        }
        return categoryListArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isGridView) {
        return  (50 * (categoryListArray.count /2))+ 100;
    }else {
        return  50;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    
        if (isGridView) {
            CollectionTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"CollectionTableViewCell" forIndexPath:indexPath];
            
            [cell.collectionView reloadData];
            return cell;
            
        }else {
            
            UITableViewCell *cell= [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
            // if (recordArr.count >0) {
            CategoryObject *notObj =  [categoryListArray objectAtIndex:indexPath.row];
            // cell.textLabel.text= notObj.Title;
            cell.detailTextLabel.text= @"";
            cell.textLabel.text   =  notObj.CategoryName;
            
            cell.tag = indexPath.row;
            //  }
            
            return cell;
        }
   
    
    
    
    
    
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
 

        CategoryObject *notObj =  [categoryListArray objectAtIndex:indexPath.row];
        BrowseCategoryViewController * browserVC =  [self.storyboard instantiateViewControllerWithIdentifier:@"BrowseCategoryViewController"];
        browserVC.catTittle = notObj.CategoryName;
        browserVC.isPublic = true;
        browserVC.catId = [NSString stringWithFormat:@"%lld",notObj.CategoryID];
        browserVC.DBId = [ NSString stringWithFormat:@"%lld", _dbObj.Databaseid ];
        [self.navigationController pushViewController:browserVC animated:YES];
        
        
        //[self performSegueWithIdentifier:@"MemoDetail" sender:self];
   
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#pragma mark - Collectionview Delegates & datasources

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return categoryListArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    CategoryCollectionViewCell *ccell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CategoryCollectionViewCell" forIndexPath:indexPath];
    ccell.btnCat.layer.cornerRadius = 9.0;
    ccell.btnCat.layer.borderColor = [UIColor colorWithRed:46.0/255.0 green:98.0/255.0 blue:204.0/255.0 alpha:1].CGColor;
    ccell.btnCat.layer.borderWidth = 1.5;
    ccell.btnCat.titleLabel.numberOfLines = 1;
    ccell.btnCat.titleLabel.adjustsFontSizeToFitWidth = YES;
    ccell.btnCat.titleLabel.lineBreakMode = NSLineBreakByClipping;
    [ccell.btnCat setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    ccell.btnCat.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
    
    CategoryObject *notObj =  [categoryListArray objectAtIndex:indexPath.row];
    // cell.textLabel.text= notObj.Title;
    
    [ccell.btnCat setTitle: notObj.CategoryName forState:UIControlStateNormal];
    
    ccell.btnCat.tag = indexPath.row;
    
    [ccell.btnCat addTarget:self action:@selector(btnGridViewClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return ccell;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    float cellWidth = (screenWidth / 2); //Replace the divisor with the column count requirement. Make sure to have it in float.
    
    
    
    CGSize size = CGSizeMake(cellWidth,  60);
    
    
    return size;
}

-(void)btnGridViewClick :(UIButton*)sender {
    
    UIButton* btn = sender;
    
    NSInteger index =  btn.tag;
    
    CategoryObject *notObj =  [categoryListArray objectAtIndex:index];
    
    BrowseCategoryViewController * browserVC =  [self.storyboard instantiateViewControllerWithIdentifier:@"BrowseCategoryViewController"];
    browserVC.catTittle = notObj.CategoryName;
     browserVC.isPublic = true;
    browserVC.catId = [NSString stringWithFormat:@"%lld",notObj.CategoryID];
    browserVC.DBId = [ NSString stringWithFormat:@"%lld", _dbObj.Databaseid ];
    [self.navigationController pushViewController:browserVC animated:YES];
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
