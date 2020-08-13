//
//  RecordListViewController.h
//  SimpleApp
//
//  Created by IOS1 on 1/27/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordListViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource> {
    BOOL isGridView;
}


@property (weak, nonatomic) IBOutlet UILabel *storageTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *databaseTxt;
- (IBAction)infoButtonClicked:(id)sender;
- (IBAction)refreshDataFromServer:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *pickerView;
@property (strong, nonatomic) IBOutlet UIPickerView *picker;
- (IBAction)done:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
- (IBAction)btnListGrid:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblViewCat;
@property (weak, nonatomic) IBOutlet UIButton *btnGridLIstView;
- (IBAction)buttonInformation:(id)sender;

@property(nonatomic,strong)NSString *categoryName;
- (IBAction)ChangeDB:(id)sender;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (weak, nonatomic) IBOutlet UIButton *addRecordBtn;
@property (weak, nonatomic) IBOutlet UIButton *showMapBtn;




@end
