//
//  PasscodeViewController.m
//  SimpleApp
//
//  Created by IOS4 on 23/03/17.
//  Copyright © 2017 MAC. All rights reserved.
//

#import "PasscodeViewController.h"
#import "JKLLockScreenViewController.h"
@interface PasscodeViewController ()<JKLLockScreenViewControllerDataSource, JKLLockScreenViewControllerDelegate>
@property (nonatomic, strong) NSString * enteredPincode;
@end

@implementation PasscodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
 NSString * switchState =  [[NSUserDefaults standardUserDefaults] valueForKey:@"switch"];
    
    if (![switchState isKindOfClass:[NSNull class]] || switchState != nil)
    {
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"switch"] isEqualToString:@"On"]) {
        NSLog(@"Switch is on");
        [_passcodeSwitchOutlet setOn:YES animated:YES];
        [_btnChangePassOutlet setEnabled:YES];
    } else {
        NSLog(@"Switch is Off");
        [_passcodeSwitchOutlet setOn:NO animated:YES];
        [_btnChangePassOutlet setEnabled:NO];
    }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)passcodeSwitchAction:(id)sender
{
    if ([self.passcodeSwitchOutlet isOn]) {
        NSLog(@"Switch is on");
        [_passcodeSwitchOutlet setOn:YES animated:YES];
        [_btnChangePassOutlet setEnabled:YES];
        [self setPasscode];
        [[NSUserDefaults standardUserDefaults] setValue:@"On" forKey:@"switch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        NSLog(@"Switch is Off");
        [_passcodeSwitchOutlet setOn:NO animated:YES];
         [_btnChangePassOutlet setEnabled:NO];
        [[NSUserDefaults standardUserDefaults] setValue:@"Off" forKey:@"switch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
-(void)setPasscode
{
  //  JKLLockScreenViewController * viewController = [[JKLLockScreenViewController alloc] initWithNibName:NSStringFromClass([JKLLockScreenViewController class]) bundle:nil];
    
    JKLLockScreenViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"JKLLockScreenViewController"];
  //  self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
    
  //  [self.navigationController pushViewController:vc animated:true];
    
    [viewController setLockScreenMode:1];    // enum { LockScreenModeNormal, LockScreenModeNew, LockScreenModeChange }
    [viewController setDelegate:self];
    [viewController setDataSource:self];
    [viewController setTintColor:[UIColor redColor]];
    
    [self presentViewController:viewController animated:YES completion:NULL];
    
}
#pragma mark -
#pragma mark YMDLockScreenViewControllerDelegate
- (void)unlockWasCancelledLockScreenViewController:(JKLLockScreenViewController *)lockScreenViewController {
    
    NSLog(@"LockScreenViewController dismiss because of cancel");
    
    NSLog(@"Switch is Off");
    [_passcodeSwitchOutlet setOn:NO animated:YES];
    [_btnChangePassOutlet setEnabled:NO];
    [[NSUserDefaults standardUserDefaults] setValue:@"Off" forKey:@"switch"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)unlockWasSuccessfulLockScreenViewController:(JKLLockScreenViewController *)lockScreenViewController pincode:(NSString *)pincode
{
    
    self.enteredPincode = pincode;
    [[NSUserDefaults standardUserDefaults] setValue:self.enteredPincode forKey:@"pin"];
    
}

#pragma mark -
#pragma mark YMDLockScreenViewControllerDataSource
- (BOOL)lockScreenViewController:(JKLLockScreenViewController *)lockScreenViewController pincode:(NSString *)pincode {
    
#ifdef DEBUG
    NSLog(@"Entered Pincode : %@", self.enteredPincode);
#endif
    
    return [self.enteredPincode isEqualToString:pincode];
}

- (BOOL)allowTouchIDLockScreenViewController:(JKLLockScreenViewController *)lockScreenViewController {
    
    return YES;
}

- (IBAction)btnChangePassAction:(id)sender {
    JKLLockScreenViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"JKLLockScreenViewController"];
    [viewController setLockScreenMode:2];    // enum { LockScreenModeNormal, LockScreenModeNew, LockScreenModeChange }
    [viewController setDelegate:self];
    [viewController setDataSource:self];
    [viewController setTintColor:[UIColor redColor]];
    
    [self presentViewController:viewController animated:YES completion:NULL];
}
- (IBAction)setPassCodeAction:(id)sender {
}
@end
