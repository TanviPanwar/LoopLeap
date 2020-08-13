//
//  CategoryViewTableViewController.m
//  SimpleApp
//
//  Created by IOS2 on 8/24/18.
//  Copyright © 2018 MAC. All rights reserved.
//

#import "CategoryViewTableViewController.h"

@interface CategoryViewTableViewController ()

@end

@implementation CategoryViewTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Category View";
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
   
    
    if (indexPath.row == 0) {
        cell.imageView.image = [UIImage imageNamed:@"list.png"];
        cell.textLabel.text = @"List View" ;
      
        if ([[NSUserDefaults standardUserDefaults]boolForKey:@"GridView"] == false)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }else {
        cell.imageView.image = [UIImage imageNamed:@"grid.png"];
        cell.textLabel.text = @"Icon View" ;
        if ([[NSUserDefaults standardUserDefaults]boolForKey:@"GridView"]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    // Configure the cell...
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ( indexPath.row == 0) {
        [[NSUserDefaults standardUserDefaults]setBool:false forKey:@"GridView"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }else {
        [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"GridView"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
       NSLog(@"%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"GridView"]);
    [self.tableView reloadData];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
