//
//  GISignUpViewController.m
//  GiustoPush
//
//  Created by Randall Mardus on 3/23/16.
//  Copyright © 2016 Randall Mardus. All rights reserved.
//

#import "GISignUpViewController.h"
#import "UIImage+MyAdditions.h"
#import "GIProfileTabBarController.h"
#import "GIUserProfileViewController.h"
#import "GIHomeViewController.h"
#import "GIValidationBD.h"

#define kNameTag               0
#define kEmailTag              1
#define kLocationTag           2
#define kPasswordTag           3


@interface GISignUpViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *locationField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *avatarButton;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@property (strong, nonatomic) UIImage *avatarImage;

- (IBAction)addPhotoButtonPressed:(UIButton *)sender;
- (IBAction)doneButtonPressed:(UIBarButtonItem *)sender;

@end

@implementation GISignUpViewController
{
    BOOL _viewWillDisappear;
    
    UITextField *_currentField;
    
}

#pragma mark - Actions

- (IBAction)doneSignUp:(id)sender {
    //    if (self.passwordField.text.length > 0) {
    //        [self doneButtonPressed:sender];
    //    }
}

- (IBAction)doneButtonPressed:(UIBarButtonItem *)sender
{
    if ([[self.nameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
        [UIAlertView showWithTitle:NSLocalizedString(@"No Name Entered", @"No Name entered") message:NSLocalizedString(@"Your name is required to create an account", @"Your name is required to create an account") cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil tapBlock:nil];
        return;
    }
    
    if ([[self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
        [UIAlertView showWithTitle:NSLocalizedString(@"No Password Entered", @"No Password entered") message:NSLocalizedString(@"A password is required to create an account", @"A password is required to create an account") cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil tapBlock:nil];
        return;
    }
    
    if (![GIValidationBD isEmailValid:self.emailField.text]) {
        [UIAlertView showWithTitle:NSLocalizedString(@"Invalid Email", @"Invalid Email") message:NSLocalizedString(@"Please enter a valid email address", @"Please enter a valid email address") cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil tapBlock:nil];
        return;
    }
    
    //    if (self.locationField.text.length == 0) {
    //        [UIAlertView showWithTitle:NSLocalizedString(@"No Location Entered", @"No Location entered") message:NSLocalizedString(@"A location is required to create an account", @"A location is required to create an account") cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil tapBlock:nil];
    //        return;
    //    }
    
    
    NSString* confirmationMessage = [NSString stringWithFormat:@"%@\n "
                                     "%@\n "
                                     "Location: %@",
                                     self.nameField.text,
                                     self.emailField.text,
                                     self.locationField.text];
    
    UIAlertView *confirmAlert = [[UIAlertView alloc] initWithTitle:@"Confirm Sign Up?"
                                                           message:confirmationMessage
                                                          delegate:self
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:@"No", @"Yes", nil];
    confirmAlert.tag = 1;
    [confirmAlert show];
}

- (void) performSignUp {
#pragma message "TODO: refactor this method to take a single full name string."
#pragma message "TODO: refactor this method to take a single location string."
    [[GIUserStore sharedStore] signUpWithFullName:self.nameField.text email:self.emailField.text location:self.locationField.text password:self.passwordField.text photo:self.avatarImage completion:^(id sender, BOOL success, NSError *error, id result) {
        
        //        [self.view hideProgressHUD];
        
        if (success) {
            
            [[GIUserStore sharedStore] loginInBackgroundWithUsername:self.emailField.text password:self.passwordField.text completion:^(id sender, BOOL success, NSError *error, id result) {
                
                if (success) {
                    
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [self.view hideProgressHUD];
                        [self performSegueWithIdentifier:@"modalSignUpSuccess" sender:sender];
                    }];
                    
                } else {
                    
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        
                        [self.view hideProgressHUD];
                        [UIAlertView showWithTitle:@"Error" message:@"Unrecognized email or password." cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:NULL];
                        
                    }];
                    
                }
            }];
            
            //            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            //                [self performSegueWithIdentifier:@"modalSignUpSuccess" sender:sender];
            //            }];
            
        } else {
            [self.view hideProgressHUD];
            NSString *errorMessage = [error.userInfo objectForKey:@"error"];
            if(errorMessage == nil) {
                errorMessage = @"An unknown error has occurred.";
            }
            [UIAlertView showWithTitle:@"Error" message:errorMessage cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:NULL];
        }
        
    }];
}


- (IBAction)addPhotoButtonPressed:(UIButton *)sender
{
    [MYImagePickerController presentPickerWithCompletion:^(id sender, BOOL didPickImage, NSError *error, NSDictionary *info, UIImage *originalImage) {
        if (didPickImage) {
            UIImage *imageMask = [UIImage imageNamed:@"AvatarPhotoMask"];
            self.avatarImage = [UIImage maskImage:[originalImage imageByScalingAndCroppingForSize:CGSizeMake(68,68)] withMask:imageMask];
            self.avatarImageView.image = self.avatarImage;
        } else {
            if (error) {
                [UIAlertView showWithTitle:NSLocalizedString(@"Error", @"Error") message:NSLocalizedString(@"There was an error with the image you selected. Please try again.", @"") cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok") otherButtonTitles:nil tapBlock:NULL];
            }
        }
    }];
}


#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.locationField.keyboardType = UIKeyboardTypeDecimalPad;
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.view.translatesAutoresizingMaskIntoConstraints = YES;
}


#pragma mark - Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"modalSignUpSuccess"]) {
        
        GIProfileTabBarController *destination = segue.destinationViewController;
        
        GIHomeViewController *destinationTab = [[[destination.viewControllers objectAtIndex:0] viewControllers] firstObject];
        
        [destinationTab configureWithModelObject:[GIUserStore sharedStore].currentUser.userProfile];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            [self.navigationController popToRootViewControllerAnimated:NO];
            
        } afterDelay:1];
    }
}

#pragma mark - UITextField Delegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _currentField = textField;
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _currentField = nil;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL rc = YES;
    
    switch (textField.tag) {
        case kLocationTag: {
            NSString *s = [textField.text stringByReplacingCharactersInRange:range withString:string];
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\\d{0,5}$" options:0 error:nil];
            NSTextCheckingResult *match = [regex firstMatchInString:s options:0 range:NSMakeRange(0, [s length])];
            rc = (match != nil);
            break;
        }
    }
    
    return rc;
    
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        
        switch(buttonIndex) {
            case 0: //"No" pressed
                break;
            case 1: //"Yes" pressed
                [self.view showProgressHUD];
                [self performSignUp];
                break;
        }
    }
}

@end