//
//  AddItemViewController.h
//  SimpleApp
//
//  Created by IOS1 on 1/27/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyDataBaseObject.h"
#import "DBManager.h"
#import <GoogleSignIn/GoogleSignIn.h>
#import <GoogleAPIClientForREST/GoogleAPIClientForREST-umbrella.h>
#import <GTMSessionFetcher/GTMSessionFetcher.h>

@interface AddInfoViewController : UIViewController <GIDSignInDelegate , GIDSignInUIDelegate>{
    NSData *imageData ;
}
//@property(nonatomic,strong)NSString *categoryName;
//@property(nonatomic,assign) BOOL isFromCategory;
@property (strong, nonatomic) IBOutlet UILabel *lblOr;
@property (strong, nonatomic) IBOutlet UIButton *arrowBtn;
- (IBAction)arrowBtnAction:(id)sender;

@property (strong, nonatomic) NSString *isFrom;
@property (strong, nonatomic) NSString *Database;

@property (strong, nonatomic) NSString *DatabaseID;
@end
