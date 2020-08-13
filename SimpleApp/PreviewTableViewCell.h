//
//  PreviewTableViewCell.h
//  SimpleApp
//
//  Created by iOS6 on 18/02/20.
//  Copyright © 2020 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PreviewTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *fileNoLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

NS_ASSUME_NONNULL_END
