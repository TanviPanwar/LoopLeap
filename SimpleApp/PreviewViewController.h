//
//  PreviewViewController.h
//  SimpleApp
//
//  Created by iOS6 on 18/02/20.
//  Copyright © 2020 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PreviewViewController : UIViewController {
    
}


@property(retain , nonatomic) NSMutableArray *notesArray;
@property(retain , nonatomic) NSMutableArray *categoryArray;
@property(retain , nonatomic) NSString *totalCount;
@property(retain , nonatomic) NSString *addCount;
@property(retain , nonatomic) NSString *updateCount;
@property(retain , nonatomic) NSString *skipCount;
@property(retain , nonatomic) NSString *errorCount;
@property(retain , nonatomic) NSString *totalUpdateCount;









@end

NS_ASSUME_NONNULL_END
