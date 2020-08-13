//
//  BrowseTableViewCell.h
//  SimpleApp
//
//  Created by IOS2 on 6/5/17.
//  Copyright © 2017 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BrowseTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lblTittle;
@property (strong, nonatomic) IBOutlet UILabel *lblDescripation;
@property (strong, nonatomic) IBOutlet UIButton *btnEdit;
@property (strong, nonatomic) IBOutlet UIButton *btnPreview;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *desHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tittleHeight;
@property (weak, nonatomic) IBOutlet UIImageView *imgCategory;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthImgCategory;

@end
