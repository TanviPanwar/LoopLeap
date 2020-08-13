//
//  BrowseCategoryViewController.m
//  SimpleApp
//
//  Created by IOS2 on 6/5/17.
//  Copyright © 2017 MAC. All rights reserved.
//

#import "BrowseCategoryViewController.h"
#import "DBManager.h"
#import "BrowseTableViewCell.h"
#import "NoteDetailViewController.h"
#import "RecordListViewController.h"
#import "AppDelegate.h"
#import "CategoryLIstingViewController.h"
//#import "BFRImageViewController.h"
#import <BFRImageViewer/BFRImageViewController.h>
#import <SDWebImage/SDWebImage.h>


@interface BrowseCategoryViewController (){
    NSMutableArray * categoryArray;
    CGFloat cellHeight;
    NSInteger selectedIndex;
    NSInteger currentIndex;
}


@end

@implementation BrowseCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.catTittle;
    // Do any additional setup after loading the view.
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"home"] style:UIBarButtonItemStyleDone target:self action:@selector(homeBtnAction)];
    [[NSUserDefaults standardUserDefaults]setValue:@"Reload" forKey:@"Reload"];
    
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
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // For Imageviewer it reloads everytime
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"Reload"]isEqualToString:@"Reload"])
    {
        categoryArray =  [[NSMutableArray alloc]init];
        categoryArray  = [[DBManager getSharedInstance] getCategoryNotes:_catId];
        [_tableView reloadData];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
      NotesObject *obj =  [categoryArray objectAtIndex:indexPath.row];
      if (obj.expandStatus == 0) {
         return 130;
    }
    else {
        return cellHeight + 110;
    }
    
   
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return categoryArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    BrowseTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NotesObject *obj =  [categoryArray objectAtIndex:indexPath.row];
    
    cell.lblTittle.text = obj.Title;
    NSAttributedString *attributedString = [[NSAttributedString alloc]
                                            initWithData: [obj.Note dataUsingEncoding:NSUnicodeStringEncoding]
                                            options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                                            documentAttributes: nil
                                            error: nil
                                            ];
    cell.lblDescripation.attributedText = attributedString;
   // cell.lblDescripation.text = obj.Note;
        cell.btnPreview.tag = indexPath.row;
    [cell.btnPreview addTarget:self action:@selector(btnPreviewClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.btnEdit.tag = indexPath.row;
    [cell.btnEdit addTarget:self action:@selector(btnEditClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
//    if (_isPublic) {
//        [cell.btnEdit setHidden:true];
//    }
//    else {
//        [cell.btnEdit setHidden:false];
//    }
    
    if ([_AdminStatus isEqual: @"0"]) {
          [cell.btnEdit setHidden:true];
      }
    else if ([_AdminStatus isEqual: @"1"]) {
          [cell.btnEdit setHidden:false];
      }
    
    
     if([obj.FileUpload hasPrefix:@"https://"]) {
        //@"https://drive.google.com/uc?export=view&id=1p_EqLftJHEJufkZVJIg_c97Wf1lZEd_r"
      
         NSString * fileUpload = [obj.FileUpload stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
         
         cell.widthImgCategory.constant = 80;
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                  NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileUpload] options:NSDataReadingUncached error:nil];
             dispatch_async(dispatch_get_main_queue(), ^{
                 [cell.imgCategory setFrame:CGRectMake(cell.imgCategory.frame.origin.x, cell.imgCategory.frame.origin.y, 80, cell.imgCategory.frame.size.height)];
                // cell.imgCategory.image = [UIImage imageWithData:data];
                 
                 [ cell.imgCategory sd_setImageWithURL:[NSURL URLWithString:obj.FileUpload]
                              placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
                 
             });
         });
         cell.imgCategory.tag = indexPath.row;
         cell.imgCategory.userInteractionEnabled = YES;
         UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
         tap.view.tag = indexPath.row;
         [cell.imgCategory addGestureRecognizer:tap];

      
        
    }
    else{
        
        
        NSData *data = obj.imageData;
        if (data == nil || data.bytes == 0){
            cell.widthImgCategory.constant = 0;
            [cell.imgCategory setFrame:CGRectMake(cell.imgCategory.frame.origin.x, cell.imgCategory.frame.origin.y, 0, cell.imgCategory.frame.size.height)];
        }
        
        else {
        cell.widthImgCategory.constant = 80;
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell.imgCategory setFrame:CGRectMake(cell.imgCategory.frame.origin.x, cell.imgCategory.frame.origin.y, 80, cell.imgCategory.frame.size.height)];
             cell.imgCategory.image = [UIImage imageWithData:data];
        });
         });
        cell.imgCategory.tag = indexPath.row;
        cell.imgCategory.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        tap.view.tag = indexPath.row;
       // [cell.imgCategory addGestureRecognsizer:tap];
            [cell.imgCategory addGestureRecognizer:tap];
    }
}
   
    
    if (obj.expandStatus == 1) {
        cell.backgroundColor = [UIColor colorWithRed:228.0f/255.0 green:218.0f/255.0 blue:196.0f/255.0 alpha:1.0];
        if (cell.lblDescripation != nil){
            CGFloat height =  [self getLabelHeight:cell.lblDescripation];
        cell.lblDescripation.numberOfLines = 0 ;
        cell.desHeight.constant = height + 20;
        cell.lblDescripation.frame = CGRectMake(cell.lblDescripation.frame.origin.x, 70, cell.lblDescripation.frame.size.width,  cell.desHeight.constant);
        }
    }else {
        cell.desHeight.constant = 22;
        cell.lblDescripation.frame = CGRectMake(cell.lblDescripation.frame.origin.x, 70, cell.lblDescripation.frame.size.width,  cell.desHeight.constant);
        cell.backgroundColor = [UIColor whiteColor];
    }
    NSLog(@"Frame %f ***** %f",cell.lblDescripation.frame.origin.y , cell.desHeight.constant);
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 1.0;
  
    cell.lblTittle.userInteractionEnabled = YES;
    [cell.lblTittle addGestureRecognizer:longPress];
    cell.lblTittle.tag = indexPath.row;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;

}

-(void)tapGesture : (UITapGestureRecognizer *)gesture{
    NSLog(@"Gesture Tag %li",gesture.view.tag);
    NSIndexPath *index = [NSIndexPath indexPathForItem:gesture.view.tag inSection:0];
    BrowseTableViewCell *cell = [self.tableView cellForRowAtIndexPath:index];
   // NotesObject *obj =  [categoryArray objectAtIndex:gesture.view.tag];
    
    if (cell.imgCategory.image != nil) {
        BFRImageViewController *imageVC = [[BFRImageViewController alloc] initWithImageSource:@[cell.imgCategory.image]];
        [[NSUserDefaults standardUserDefaults]setValue:@"noReload" forKey:@"Reload"];
        [self presentViewController:imageVC animated:YES completion:nil];
        
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
   
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    
    currentIndex = gesture.view.tag;
     NotesObject *obj =  [categoryArray objectAtIndex:currentIndex];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentIndex inSection:0];
    
    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:@"Selected Title"      //  Must be "nil", otherwise a blank title area will appear above our two buttons
                                message:obj.Title
                                preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* button0 = [UIAlertAction
                              actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleCancel
                              handler:^(UIAlertAction * action)
                              {
                                  //  UIAlertController will automatically dismiss the view
                              }];
    
    UIAlertAction* button1 = [UIAlertAction
                              actionWithTitle:@"Move"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  NotesObject *obj =  [categoryArray objectAtIndex:currentIndex];
                                  
                                  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                   CategoryLIstingViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"CategoryLIstingViewController"];
                                  vc.dbID = self.DBId;
                                  vc.selectedObj = obj;
                               [self presentViewController:vc animated:YES completion:nil];
                                  
                                
                              }];
    
    UIAlertAction* button2 = [UIAlertAction
                              actionWithTitle:@"Delete"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [self deleteRecord];
                                  
                                  
                              }];
    
    
    UIAlertAction* button3 = [UIAlertAction
                              actionWithTitle:@"Edit"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  selectedIndex = gesture.view.tag;
                                  [self performSegueWithIdentifier:@"MemoDetail" sender:self];
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
        [alert addAction:button3];
        popPresenter.sourceView = self.tableView;;
        popPresenter.sourceRect = CGRectMake(cell.bounds.size.width / 2.0, cell.frame.origin.y + cell.bounds.size.height / 2.0, 1.0, 1.0);
        [self presentViewController:alert animated:YES completion:nil];
        
        
    }else{
    
    [alert addAction:button0];
    [alert addAction:button1];
    [alert addAction:button2];
    [alert addAction:button3];
    [self presentViewController:alert animated:YES completion:nil];
    
    }
}


-(void)deleteRecord{
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:nil
                                 message:@"Are you sure you want to delete this Record ?"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Delete"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    
                                    [self deleteTitleAPI];
                                    //Handle your yes please button action here
                                }];
    
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   //Handle no, thanks button
                               }];
    
    [alert addAction:yesButton];
    [alert addAction:noButton];
    
    [self presentViewController:alert animated:YES completion:nil];

   

}


-(void)deleteTitleAPI {
    
    NotesObject *obj = categoryArray[currentIndex];
    [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
    //        NSString *registerUrl=[NSString stringWithFormat:@"%@",HostUrl];
    NSMutableDictionary *userDetail = [[NSMutableDictionary alloc]init];
    [userDetail setValue:kDeleteNotes forKey:kDefault];
    [userDetail setValue:[NSString stringWithFormat:@"%lld",obj.DatabaseID] forKey:@"db_id"];
    [userDetail setValue:[NSString stringWithFormat:@"%lld",obj.NotesID]  forKey:@"notes_id"];
    [userDetail setValue:[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID] forKey:kDeleteUserID];
    
    NSLog(@"UsetDetail Dict%@", userDetail);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:HostUrl parameters:userDetail success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        [AppDelegate hideHUDForView:self.view animated:YES];
        NSLog(@"Success: %@\n ***** %@", operation.responseString, responseObject);
        id status= [responseObject valueForKey:@"status"];
        if([status isKindOfClass:[NSString class]]){
            if([status isEqualToString:@"Success"]) {
                [self deleteNotesFromSqlite];
                
                [categoryArray removeObjectAtIndex:currentIndex];
                NSIndexPath *path = [NSIndexPath indexPathForRow:currentIndex inSection:0];
                [self.tableView  deleteRowsAtIndexPaths: [NSArray  arrayWithObject:path] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView reloadData];
                
                //[self.navigationController popViewControllerAnimated:true];
                
            }
            else{
                
            }
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        
        [AppDelegate hideHUDForView:self.view animated:YES];
        //if(dict)
        [AppDelegate showAlertViewWithTitle:@"Network Error" Message:@"Please Check Your Internet Connection."];
    }];
    
    
}



-(void)deleteNotesFromSqlite{
    NotesObject *obj = categoryArray[currentIndex];
    [[DBManager getSharedInstance]deleteNotes:[NSString stringWithFormat:@"%lld",obj.NotesID] forUserID:[NSString stringWithFormat:@"%lld",obj.DatabaseID]];
    
    
}


#pragma mark- Navigation
#pragma mark-
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
    
    if([segue.identifier isEqualToString:@"MemoDetail"])
    {
        NoteDetailViewController *obj=segue.destinationViewController;
        
        obj.selectedIndex = selectedIndex;
        obj.navTittle = self.title;

        
        obj.recordArr = categoryArray;
        
 
        
        
    }
}

-(void)btnEditClick:(UIButton*)sender {
        selectedIndex = sender.tag;
      [self performSegueWithIdentifier:@"MemoDetail" sender:self];
}


-(void)btnPreviewClick:(UIButton*)sender {
    
    for (int i = 0; i < categoryArray.count; i++) {
     NotesObject *obj =  [categoryArray objectAtIndex:i];
       if (obj.expandStatus == 1)  {
            obj.expandStatus = 0 ;
       }else {
           if (i == sender.tag) {
                obj.expandStatus = 1;
           }
           
       }
    }
    NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:sender.tag inSection:0];
    BrowseTableViewCell *cell =  [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell.lblDescripation != nil){
      cellHeight = [self getLabelHeight:cell.lblDescripation];
       [self.tableView reloadData];
    }
}

- (CGFloat)getLabelHeight:(UILabel*)label
{
    CGSize constraint = CGSizeMake(label.frame.size.width, CGFLOAT_MAX);
    CGSize size;
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [label.text boundingRectWithSize:constraint
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:label.font}
                                                  context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return size.height;
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
