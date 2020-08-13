//
//  CreateContactController.m
//  SimpleApp
//
//  Created by IOS3 on 07/03/17.
//  Copyright © 2017 MAC. All rights reserved.
//

#import "CreateContactController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "AppDelegate.h"
@interface CreateContactController ()
@property (weak, nonatomic) IBOutlet UITextField *firstNameTxtFld;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTxtFld;
@property (weak, nonatomic) IBOutlet UITextField *contactTxtFld;

@end

@implementation CreateContactController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)createContactAction:(id)sender {
    
    if (_firstNameTxtFld.text.length == 0 && _contactTxtFld.text.length == 0) {
         [AppDelegate showAlertViewWithTitle:@"Message" Message:@"Please Fill All Fields."];
    }
   else   if (_firstNameTxtFld.text.length == 0) {
        [AppDelegate showAlertViewWithTitle:@"Message" Message:@"Enter First Name."];
        
    }
    else if (_lastNameTxtFld.text.length == 0) {
        [AppDelegate showAlertViewWithTitle:@"Message" Message:@"Enter Last Name."];
    
    }
    else if (_contactTxtFld.text.length == 0) {
          [AppDelegate showAlertViewWithTitle:@"Message" Message:@"Enter Contact Number."];
    }
    else {
        CFErrorRef error = NULL;
        NSLog(@"%@", [self description]);
        ABAddressBookRef iPhoneAddressBook = ABAddressBookCreate();
    
        ABRecordRef newPerson = ABPersonCreate();
    
        ABRecordSetValue(newPerson, kABPersonFirstNameProperty, (__bridge CFTypeRef)(_firstNameTxtFld.text), &error);
        ABRecordSetValue(newPerson, kABPersonLastNameProperty, (__bridge CFTypeRef)(_lastNameTxtFld.text), &error);
    
        ABMutableMultiValueRef multiPhone =     ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(_contactTxtFld.text), kABPersonPhoneMainLabel, NULL);
        ABMultiValueAddValueAndLabel(multiPhone, @"", kABOtherLabel, NULL);
        ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiPhone,nil);
        CFRelease(multiPhone);
        // ...
        // Set other properties
        // ...
        ABAddressBookAddRecord(iPhoneAddressBook, newPerson, &error);
    
        ABAddressBookSave(iPhoneAddressBook, &error);
        CFRelease(newPerson);
        CFRelease(iPhoneAddressBook);
        if (error != NULL)
        {
            CFStringRef errorDesc = CFErrorCopyDescription(error);
            NSLog(@"Contact not saved: %@", errorDesc);
            CFRelease(errorDesc);        
        }
        [self.view endEditing:true];
         [self dismissViewControllerAnimated:true completion:nil];
    }
    

}
- (IBAction)cancel_Action:(id)sender {
    [self.view endEditing:true];
    [self dismissViewControllerAnimated:true completion:nil];
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

@end
