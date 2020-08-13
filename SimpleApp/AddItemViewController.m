//
//  AddItemViewController.m
//  SimpleApp
//
//  Created by IOS1 on 1/27/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import "AddItemViewController.h"
#import "AppDelegate.h"


@interface AddItemViewController ()<UITextFieldDelegate,UITextViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource , UIImagePickerControllerDelegate, UINavigationControllerDelegate , UIActionSheetDelegate >
{
    
    NSInteger selectedTag;
    NSString *tableName;
    UITextField *activeTextField;
    NSString *db_name;
    NSString *db_ID;
    NSString * owner_ID;
    NSMutableArray *categoryArr;
    NSMutableArray *dbArray;
    AppDelegate *appDelegate;
    UIImagePickerController *imagePicker;
}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIView *pickerView;
@property (strong, nonatomic) IBOutlet UITextField *selectedCategory;
@property (strong, nonatomic) IBOutlet UITextField *categoryNew;
@property (strong, nonatomic) IBOutlet UITextField *record_title;
@property (strong, nonatomic) IBOutlet UITextView *notes;
@property (strong, nonatomic) IBOutlet UIButton *saveBtn;
@property (strong, nonatomic) IBOutlet UIPickerView *picker;
@property (strong, nonatomic) IBOutlet UILabel *orLbl;


@end

@implementation AddItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     self.title=@"Add Record";
    _notes.textColor = [UIColor lightGrayColor];
    [_notes setText:@"Description"];
    _notes.delegate = self;
    appDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
     tableName=RecordTable;
    //categoryArr=[[NSMutableArray alloc]init];
    dbArray=[[NSMutableArray alloc]init];
    self.selectedCategory.tag=1;
    self.categoryNew.tag=2;
    self.record_title.tag=3;
    self.chooseDBTextField.tag = 4;
   // self.selectedCategory.rightViewMode=UITextFieldViewModeAlways;
    //_selectedCategory.rightView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 20)];
    
    self.chooseDBTextField.rightViewMode=UITextFieldViewModeAlways;
    _chooseDBTextField.rightView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 20)];
  //  [self getCategoryList];
    
    //[self getDBList];
    
    if ([self.isFrom isEqualToString:@"ImportList"]) {
        [self getImportDBListFromSqlite];
    }
    else{
       [self getMyDBListFromSqlite];
    }
    
    
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hidePickerAndKeyboard)];
    tap.numberOfTapsRequired=1;
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
//    [self fetchCategory];
    
   
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)hidePickerAndKeyboard
{
    [self hidePickerView];
    [self hideKeyboard];
}
-(void)hideKeyboard
{
    [self.notes resignFirstResponder];
    [activeTextField resignFirstResponder];
}
- (IBAction)save:(id)sender {
    [self hideKeyboard];
    [self hidePickerView];
    NSString *record,*notes;
   // category_name=[category_name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    record=[self.record_title.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    notes=[self.notes.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(!db_name.length)
    {
        [AppDelegate showAlertViewWithTitle:nil Message:@"Please Fill Category."];
    }
    else if(!record.length){
        [AppDelegate showAlertViewWithTitle:nil Message:@"Please Fill Title."];
    }else if(!notes.length || [notes isEqualToString:@"Description"]){
        [AppDelegate showAlertViewWithTitle:nil Message:@"Please Fill Description."];
    }
    
    else{

            [self addNewCategory];

    }
    
    
   
}
-(IBAction)AddActionSheet
{
    //    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"Add Photo From" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo",@"Gallery",@"Remove Photo", nil];
//    
//    popupQuery.actionSheetStyle = UIActionSheetStyleDefault;
//    
//    [popupQuery showInView:self.view];
    
    
    
    
   
    
  
    
}

- (IBAction)browse_Action:(id)sender {
    [self.view endEditing:true];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Add Photo From"
                                                                             message:@""
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"Take Photo"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction *action) {
                                                                [self performSelector:@selector(camera)];
                                                                
                                                            }];
    UIAlertAction *galleryAction = [UIAlertAction actionWithTitle:@"Gallery"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [self performSelector:@selector(photoGallery)];
                                                              
                                                          }];
    UIAlertAction *removePhotoAction = [UIAlertAction actionWithTitle:@"Remove Photo"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                                  _imageView.image = nil;
                                                                  
                                                              }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    [alertController addAction:takePhotoAction];
    [alertController addAction:galleryAction];
    [alertController addAction:removePhotoAction];
    [alertController addAction:cancelAction];
    
   
    [self presentViewController:alertController animated:YES completion:nil];
    [self setModalPresentationStyle:UIModalPresentationPopover];
    [alertController.popoverPresentationController setSourceView:sender];
}

- (IBAction)arrowBtnAction:(id)sender {
    if(categoryArr.count) {
        selectedTag = 1;
        [_picker reloadAllComponents];
        [self showPickerView];
    }
}
- (IBAction)dbArrowAction:(id)sender {
    if(dbArray.count) {
        selectedTag = 4;
        [_picker reloadAllComponents];
        [self showPickerView];
    }
    
}

#pragma mark UIAction Sheet Delegate Methods
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    
    if (buttonIndex == 0) {
        
        [self performSelector:@selector(camera)];
        
        
    } else if (buttonIndex == 1) {
        
        [self performSelector:@selector(photoGallery)];
        
    }
    else
    {
        _imageView.image = nil;
    }
}


-(void)photoGallery
{
    [self selectPhotos];
}

- (void)selectPhotos

{   [self dismissViewControllerAnimated:false completion:nil];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = (id)self;
    [self presentViewController:picker animated:YES completion:nil];
    
    
}

-(void)camera
{
    [self dismissViewControllerAnimated:false completion:nil];
    imagePicker = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        // Set source to the camera
        imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
        
        imagePicker.allowsEditing = NO;
        
        // Delegate is self
        imagePicker.delegate = (id)self;
        
        // Show image picker
        
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    }
    else {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"No Camera Device Found" message:nil delegate:self
                                            cancelButtonTitle:@"Ok" otherButtonTitles:nil ];
        [alert show];
        
    }
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    _imageView.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

-(void)save
{

    
//    if(self.categoryNew.text.length)
//     {
//         if(![self saveCategory])
//             return;
//     }
//    
//    NSDate *today=[NSDate date];
//    // Create a new managed object
//    NSManagedObjectContext *context = [self managedObjectContext];
//    NSManagedObject *entity = [NSEntityDescription insertNewObjectForEntityForName:tableName inManagedObjectContext:context];
//    [entity setValue:category_name forKey:@"category_name"];
//    [entity setValue:[AppDelegate getUserEmail] forKey:@"email_id"];
//    [entity setValue:self.record_title.text forKey:@"record_title"];
//    [entity setValue:self.notes.text forKey:@"note"];
//    [entity setValue:today forKey:@"record_time"];
//    
//    
//    NSError *error = nil;
//    // Save the object to persistent store
//    if (![context save:&error]) {
//        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
//    }else{
//        /// [AppDelegate showAlertViewWithTitle:nil Message:@"Saved Successfully"];
////        [self.navigationController popViewControllerAnimated:YES];
//        //[self performSegueWithIdentifier:@"LoginSegue" sender:self];
//    }

    
   
    
}

-(BOOL)saveCategory
{
//    NSManagedObjectContext *context = [self managedObjectContext];
//    NSManagedObject *entity = [NSEntityDescription insertNewObjectForEntityForName:CategoryTable inManagedObjectContext:context];
//    [entity setValue:category_name forKey:@"category_name"];
//    [entity setValue:[AppDelegate getUserEmail] forKey:@"email_id"];
//    
//    NSError *error = nil;
//    // Save the object to persistent store
//    if (![context save:&error]) {
//        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
//        return NO;
//    }
//    //else{
////        /// [AppDelegate showAlertViewWithTitle:nil Message:@"Saved Successfully"];
////        [self.navigationController popViewControllerAnimated:YES];
////        //[self performSegueWithIdentifier:@"LoginSegue" sender:self];
////    }
    return YES;
}

/*-(BOOL)searchRecord
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RecordTable];
    
    request.predicate = [NSPredicate predicateWithFormat:@"record_title == %@ && category_name == %@  && email_id == %@ ",_record_title.text,category_name,[AppDelegate getUserEmail]];
    NSArray *results = [managedObjectContext executeFetchRequest:request error:nil];
    if(results.count)
    {
        return YES;
    }
    return NO;
}

-(BOOL)searchCategory
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:CategoryTable];
    
    request.predicate = [NSPredicate predicateWithFormat:@"category_name == %@  && email_id == %@ ",_record_title.text,category_name,[AppDelegate getUserEmail]];
    NSArray *results = [managedObjectContext executeFetchRequest:request error:nil];
    if(results.count)
    {
        return YES;
    }
    return NO;
}*/

-(void)showPickerView {
    [self hideKeyboard];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    self.pickerView.frame = CGRectMake(0, self.view.frame.size.height-self.pickerView.frame.size.height, self.pickerView.frame.size.width, self.pickerView.frame.size.height);
    [UIView commitAnimations];
}

-(void)hidePickerView {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    self.pickerView.frame = CGRectMake(0, self.view.frame.size.height, self.pickerView.frame.size.width , self.pickerView.frame.size.height);
    [UIView commitAnimations];
}

#pragma mark- UITextFieldDelegate
#pragma mark-


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    selectedTag = textField.tag;
    if(textField.tag==4)
    {
      
        if(dbArray.count){
             [_picker reloadAllComponents];
          [self showPickerView];
        }
        
        return NO;
    }
    if(textField.tag==1)
    {
     if (categoryArr.count > 0) {
        [_picker reloadAllComponents];
        [self showPickerView];
      }
       return NO;
    }

//    else if(textField.tag==2 && self.selectedCategory.text.length){
//        return NO;
//    }
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
      activeTextField=textField;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if(textField.tag==2 )
    {
        if (textField.text.length > 0) {
//            category_name=textField.text;
            self.selectedCategory.text=@"";
        }
       
    }
}

#pragma mark- UITextViewDelegate
#pragma mark-
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if([textView.textColor isEqual:[UIColor lightGrayColor]]){
        textView.textColor = [UIColor blackColor];
        textView.text = @"";
    }
    CGRect frame=self.view.frame;
    frame.origin.y=-120;
    [self.view setFrame:frame];
}



-(void)textViewDidEndEditing:(UITextView *)textView
{
    if([textView.text isEqual:@""]){
        textView.textColor = [UIColor lightGrayColor];
        [textView setText:@"Description"];
    }
    CGRect frame=self.view.frame;
    frame.origin.y=0;
    [self.view setFrame:frame];
   
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if([textView.textColor isEqual:[UIColor lightGrayColor]]){
        textView.textColor = [UIColor blackColor];
        textView.text = @"";
    }
    
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
//    if(_notes.text.length == 0){
//        _notes.textColor = [UIColor lightGrayColor];
//        _notes.text = @"Description";
//        [_notes resignFirstResponder];
//    }
}
- (IBAction)done:(id)sender {
    [self hidePickerView];
    
    NSInteger row= [self.picker selectedRowInComponent:0];
    
    if (selectedTag == 4) {
        MyDataBaseObject *DbObj =  [dbArray objectAtIndex:row];
        self.chooseDBTextField.text= DbObj.DBName;
        db_name=self.chooseDBTextField.text;
        db_ID = [NSString stringWithFormat:@"%lld", DbObj.Databaseid];
        owner_ID = [NSString stringWithFormat:@"%lld", DbObj.Owner_Userid];

        _selectedCategory.text=@"";
        [self fetchCategoriesUsingDB:db_ID];

    }
    else {
          CategoryObject *catObj =  [categoryArr objectAtIndex:row];
          self.selectedCategory.text = catObj.CategoryName;
          self.categoryNew.text = @"";
    }
}

#pragma mark- UIPickerViewDelegate
#pragma mark-
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (selectedTag == 4) {
        return dbArray.count;
    }
    else {
        return categoryArr.count;
    }
   
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (selectedTag == 4) {
        MyDataBaseObject *obj = dbArray[row];
        return obj.DBName;
    }
    else {
        CategoryObject *obj = categoryArr[row];
         return obj.CategoryName;
    }
   
}


-(void)fetchCategory
{
    // Fetch the devices from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:CategoryTable];
   // NSSortDescriptor *sdSortDate = [NSSortDescriptor sortDescriptorWithKey:@"record_time" ascending:NO];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"email_id == %@ ",[AppDelegate getUserEmail]];
    //fetchRequest.sortDescriptors=@[sdSortDate];
    // fetchRequest.predicate = [NSPredicate predicateWithFormat:@"email_id == %@",[AppDelegate getUserEmail]];
    dbArray = [[managedObjectContext executeFetchRequest:fetchRequest error:nil]mutableCopy];
    if(dbArray.count==0)
    {
        self.chooseDBTextField.hidden=YES;
        self.arrowBtn.hidden=YES;
        self.orLbl.hidden=YES;
    }
    


}




-(void)getDBList {
    
    [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
   
    NSMutableDictionary *userDetail = [[NSMutableDictionary alloc]init];
    [userDetail setValue:kGetMyDbList forKey:kDefault];
    [userDetail setValue:[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID] forKey:kLoogedInUserID];
    NSLog(@"UsetDetail Dict%@", userDetail);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:HostUrl parameters:userDetail success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        [AppDelegate hideHUDForView:self.view animated:YES];
        
        NSLog(@"Success: %@\n ***** %@", operation.responseString, responseObject);
        id status= [responseObject valueForKey:@"status"];
        if([status isKindOfClass:[NSString class]]){
            if([status isEqualToString:@"success"]) {
                dbArray = [[NSMutableArray alloc] init];
                dbArray = [responseObject valueForKey:@"MyDatabase"];
                [_picker reloadAllComponents];
            }
            else
            {
                
            }
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        
        [AppDelegate hideHUDForView:self.view animated:YES];
        //if(dict)
        [AppDelegate showAlertViewWithTitle:@"Network error" Message:@"Please Check Your Internet Connection."];
    }];

}


//-(void)getCategoryList
//{
//    
//    [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
////        NSString *registerUrl=[NSString stringWithFormat:@"%@",HostUrl];
//        NSMutableDictionary *userDetail = [[NSMutableDictionary alloc]init];
//       [userDetail setValue:kGetCategories forKey:kDefault];
//       [userDetail setValue:[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID] forKey:kLoogedInUserID];
//        NSLog(@"UsetDetail Dict%@", userDetail);
//        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//        [manager POST:HostUrl parameters:userDetail success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
//            
//            [AppDelegate hideHUDForView:self.view animated:YES];
//           
//            NSLog(@"Success: %@\n ***** %@", operation.responseString, responseObject);
//            id status= [responseObject valueForKey:@"status"];
//            if([status isKindOfClass:[NSString class]]){
//                if([status isEqualToString:@"success"]) {
//                    categoryArr = [[NSMutableArray alloc] init];
//                    categoryArr = [responseObject valueForKey:@"MyDatabase"];
//                    [_picker reloadAllComponents];
//                }
//                else
//                {
//
//                }
//            }
//        } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
//            NSLog(@"Error: %@ ***** %@", operation.responseString, error);
//            
//            [AppDelegate hideHUDForView:self.view animated:YES];
//            //if(dict)
//            [AppDelegate showAlertViewWithTitle:@"Network error" Message:@"Please Check your internet connection"];
//        }];
//}


-(void)addNewCategory
{
    if ([db_ID isEqualToString: @""]) {
        
    }else {
        [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
        NSMutableDictionary *userDetail = [[NSMutableDictionary alloc]init];
        [userDetail setValue:db_ID forKey:kCategory];
        
            if (_categoryNew.text.length == 0)
            {
                NSInteger row= [self.picker selectedRowInComponent:0];
                CategoryObject *catObj = categoryArr[row];
        
                [userDetail setValue:catObj.CategoryName  forKey:kNewCategory];
            }
            else {
                NSString *strCateName = _categoryNew.text;
                
                strCateName = [strCateName stringByReplacingOccurrencesOfString:@"\"" withString:@"~#~"];
                strCateName = [strCateName stringByReplacingOccurrencesOfString:@"\'" withString:@"~!~"];
                
                
                [userDetail setValue:strCateName  forKey:kNewCategory];
            }
        
        [userDetail setValue:kAddCategory forKey:kDefault];
        if ([_isFrom isEqualToString:@"ImportList"]) {
            
            [userDetail setValue: owner_ID forKey:kLoogedInUserID];
            
        }
        else
        {
           [userDetail setValue:[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID] forKey:kLoogedInUserID];
        }
        
         //noteObj.Note =  [noteObj.Note stringByReplacingOccurrencesOfString:@"\"" withString:@"~#~"];
         NSString *strTittleName = _record_title.text;
        strTittleName = [strTittleName stringByReplacingOccurrencesOfString:@"\"" withString:@"~#~"];
        strTittleName = [strTittleName stringByReplacingOccurrencesOfString:@"\'" withString:@"~!~"];
        
        NSString *strNote = _notes.text;
        strNote = [strNote stringByReplacingOccurrencesOfString:@"\"" withString:@"~#~"];
        strNote = [strNote stringByReplacingOccurrencesOfString:@"\'" withString:@"~!~"];
        
        
        
        [userDetail setValue:strTittleName forKey:kTitle];
        [userDetail setValue:strNote forKey:kDescription];
   
    
   
    
    NSLog(@"UsetDetail Dict%@", userDetail);
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:HostUrl]];
        
        if (_imageView.image != nil) {
            imageData = UIImageJPEGRepresentation(_imageView.image, 0.5);
        }
        
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
   
    AFHTTPRequestOperation *op = [manager POST:HostUrl parameters:userDetail constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
         if (_imageView.image != nil) {
               [formData appendPartWithFileData:imageData name:@"fileupload" fileName:@"photo.jpg" mimeType:@"image/jpeg"];
         }
        
        //do not put image inside parameters dictionary as I did, but append it!
      
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
          [AppDelegate hideHUDForView:self.view animated:YES];
        NSError *error;
        NSLog(@"Success: %@***** ", operation.responseString);
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject
                                                             options:NSJSONReadingMutableContainers
                                                               error:&error];
        NSLog(@"JSON ==%@", json);
        id status= [json valueForKey:@"status"];
                if([status isKindOfClass:[NSString class]]){
                    if([status isEqualToString:@"Success"]) {
                       
                         NSDictionary *dictResult = [json  valueForKey:@"result"];
                        if ([[dictResult valueForKey:@"notes_info"] isKindOfClass:[NSDictionary class]]) {
                            NSDictionary *noteDict = [dictResult valueForKey:@"notes_info"];
                            NotesObject *noteObj = [[NotesObject alloc] init];
                            noteObj.DatabaseID = [[noteDict valueForKey:@"DatabaseId"] longLongValue];
                            noteObj.NotesID = [[noteDict valueForKey:@"Notes_id"] longLongValue];
                            noteObj.CategoryID = [[noteDict valueForKey:@"category_id"] longLongValue];
                            noteObj.Note = [noteDict valueForKey:@"note"];
                            noteObj.Title = [noteDict valueForKey:@"title"];
                            noteObj.UserID = [[noteDict valueForKey:@"userid"] longLongValue];
                            noteObj.FileUpload = @"";
                            [[DBManager getSharedInstance] importNotesFromServer:noteObj];
                        }
                        
                        if ([[dictResult valueForKey:@"cat_info"] isKindOfClass:[NSDictionary class]]) {
                            NSDictionary *catDict = [dictResult valueForKey:@"cat_info"];
                            CategoryObject *catObj = [[CategoryObject alloc] init];
                            catObj.DatabaseID = [[catDict valueForKey:@"DatabaseId"] longLongValue];
                            catObj.CategoryName = [catDict valueForKey:@"category_name"];
                            catObj.CategoryID = [[catDict valueForKey:@"category_id"] longLongValue];
                            catObj.UserID = [[catDict valueForKey:@"userid"] longLongValue];
                           ;
                            [[DBManager getSharedInstance] importCategoriesFromServer:catObj];
                        }

                        
                      [self.navigationController popViewControllerAnimated:YES];
        
                    }
                    else{
                        [AppDelegate showAlertViewWithTitle:@"Network Error" Message:@"Please Check Your Internet Connection."];
               
                    }
                }

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          [AppDelegate hideHUDForView:self.view animated:YES];
          [AppDelegate showAlertViewWithTitle:@"Network Error" Message:@"Please Check Your Internet Connection."];
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
    }];
    [op start];
    
    }

}

-(void)addNewCategory1
{
  
    [AppDelegate showHUDAddedTo:self.view animated:YES withLabel:nil detailsLabel:nil];
    NSMutableDictionary *userDetail = [[NSMutableDictionary alloc]init];
//    if (_categoryNew.text.length == 0)
//    {
//        NSInteger row= [self.picker selectedRowInComponent:0];
//
//        [userDetail setValue:[dbArray[row] valueForKey:@"DatabaseId"] forKey:kCategory];
//    }
//    else
//    {
        [userDetail setValue:_categoryNew.text forKey:kNewCategory];
    //}
    [userDetail setValue:kAddCategory forKey:kDefault];
    [userDetail setValue:[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID] forKey:kLoogedInUserID];
    [userDetail setValue:_record_title.text forKey:kTitle];
    [userDetail setValue:_notes.text forKey:kDescription];
    
    
    NSLog(@"UsetDetail Dict%@", userDetail);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:HostUrl parameters:userDetail success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        [AppDelegate hideHUDForView:self.view animated:YES];
              NSLog(@"Success: %@***** ", operation.responseString);
        NSDictionary *json = responseObject;
        id status= [json valueForKey:@"status"];
        if([status isKindOfClass:[NSString class]]){
            if([status isEqualToString:@"Success"]) {
                //[self getCategoryList];
                //[self getDBList];
                
                
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                
                [AppDelegate showAlertViewWithTitle:@"Network Error" Message:@"Please Check Your Internet Connection."];
            }
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        
        [AppDelegate hideHUDForView:self.view animated:YES];
        //if(dict)
        [AppDelegate showAlertViewWithTitle:@"Network Error" Message:@"Please Check Your Internet Connection."];
    }];

    
    
    
}


-(void)getMyDBListFromSqlite {
    
    dbArray = [[NSMutableArray alloc] init];
    NSString *ownerID = [[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID];
    
    dbArray = [[DBManager getSharedInstance]getDataFromMyDataBase:ownerID];
    
    
}

-(void)fetchCategoriesUsingDB : (NSString*)DbId{
    categoryArr =  [[NSMutableArray alloc]init];
    
    categoryArr =  [[DBManager getSharedInstance]getDataFromUserCategories:DbId];

    
}


-(void)getImportDBListFromSqlite {
    
    dbArray = [[NSMutableArray alloc] init];
    NSString *ownerID = [[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID];
    
    dbArray = [[DBManager getSharedInstance]getImportDataFromMyDataBase:ownerID];
    
    
}




@end
