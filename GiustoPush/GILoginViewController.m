//
//  GILoginViewController.m
//  GiustoPush
//
//  Created by Randall Mardus on 3/23/16.
//  Copyright © 2016 Randall Mardus. All rights reserved.
//

#import "GILoginViewController.h"
#import "GIProfileTabBarController.h"
#import "GIUserProfileViewController.h"
#import "GIHomeViewController.h"
#import "GIValidationBD.h"
#import <Intercom/Intercom.h>

@interface GILoginViewController () <UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation GILoginViewController

- (IBAction)doneSignIn:(id)sender {
    if (self.passwordTextField.text.length > 0) {
        [self loginPressed:nil];
    }
}

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


#pragma mark - Memory Managment

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction Methods -

- (IBAction)loginPressed:(id)sender {
    
    [self.view endEditing:YES];
    
    if (![GIValidationBD isEmailValid:self.emailTextField.text]) {
        [UIAlertView showWithTitle:NSLocalizedString(@"Invalid Email", @"Invalid Email") message:NSLocalizedString(@"Please enter a valid email address", @"Please enter a valid email address") cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil tapBlock:nil];
        
        return;
    }
    
    if (self.passwordTextField.text.length == 0) {
        [UIAlertView showWithTitle:NSLocalizedString(@"No Password Entered", @"No Password entered") message:NSLocalizedString(@"Please enter your password", @"Please enter your password") cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil tapBlock:nil];
        return;
    }
    
    [self.view showProgressHUD];
    
    [[GIUserStore sharedStore] loginInBackgroundWithUsername:self.emailTextField.text password:self.passwordTextField.text completion:^(id sender, BOOL success, NSError *error, id result) {
        
        if (success) {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.view hideProgressHUD];
                [self performSegueWithIdentifier:@"modalManualLoginSuccess" sender:sender];
            }];
            
        } else {
            
            NSString* errorTitle = @"";
            NSString* errorMessage = @"";
            UIAlertView* loginErrorAlert = [[UIAlertView alloc] initWithTitle:errorTitle
                                                                      message:errorMessage
                                                                     delegate:self
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles:nil, nil];;
            
            
            if (error.code == 101) //[Parse Error]: invalid login parameters (Code: 101, Version: 1.7.5)
            {
                errorTitle = @"Wrong password.";
                errorMessage = @"Please, try again.";
            } else if (error.code == 901) //Custom error code created in loginInBackgroundWithUsername:password:completion:
            {
                errorTitle = @"User not found.";
                errorMessage = @"Please sign up or login through Facebook.";
            }
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                [self.view hideProgressHUD];
                
                loginErrorAlert.title = errorTitle;
                loginErrorAlert.message = errorMessage;
                
                [loginErrorAlert show];
            }];
            
        }
    }];
}


- (IBAction)forgotPasswordButtonPressed:(UIButton *)sender
{
    UIAlertView *resetPasswordAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Reset Password", @"Reset Password")
                                                                 message:NSLocalizedString(@"Enter your account's email address", @"Enter your account's email address")
                                                                delegate:self
                                                       cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                       otherButtonTitles:NSLocalizedString(@"Send", @"Send"), nil];
    
    resetPasswordAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [resetPasswordAlert show];
}


- (IBAction)facebookLoginButtonPressed:(UIButton *)sender
{
    [self.view showProgressHUD];
    
    [[GIUserStore sharedStore] loginInBackgroundWithFacebookAndCompletion:^(id sender, BOOL success, NSError *error, id result) {
        
        if (success) {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.view hideProgressHUD];
                [self performSegueWithIdentifier:@"modalManualLoginSuccess" sender:sender];
            }];
            
        } else {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                [self.view hideProgressHUD];
                
                NSString* errorMessage = error.localizedDescription;
                
                NSString *firstChar = [errorMessage substringToIndex:1];
                errorMessage = [[firstChar uppercaseString] stringByAppendingString:[errorMessage substringFromIndex:1]];
                
                //NSLog(@"error.code: %ld", (long)error.code);
                
                if (error) {
                    if (error.code == 203) { // [Error]: the email address nielson.rolim@gmail.com has already been taken (Code: 203, Version: 1.7.5)
                        [UIAlertView showWithTitle:@"E-mail already exists" message:errorMessage cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok") otherButtonTitles:nil tapBlock:NULL];
                    } else {
                        [UIAlertView showWithTitle:NSLocalizedString(@"Error", @"Error") message:errorMessage cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok") otherButtonTitles:nil tapBlock:NULL];
                    }
                }
                
            }];
            
        }
        
    }];
}



#pragma mark - UIAlertview Delegate Methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex != buttonIndex) {
        
        NSString *submittedEmail = [[alertView textFieldAtIndex:0] text];
        
        if ([GIValidationBD isEmailValid:submittedEmail]) {
            [[GIUserStore sharedStore] resetPasswordForEmail:submittedEmail];
        }
        else
        {
            [UIAlertView showWithTitle:NSLocalizedString(@"Invalid Email", @"Invalid Email") message:NSLocalizedString(@"Please enter a valid email address", @"Please enter a valid email address") cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil tapBlock:nil];
        }
        
    }
}


#pragma mark - Navigation -

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"modalManualLoginSuccess"]) {
        
        NSString* userID = [NSString stringWithFormat:@"%@", [GIUserStore sharedStore].currentUser.parseUser.objectId];
        [Intercom registerUserWithUserId:userID];
        
        GIProfileTabBarController *destination = segue.destinationViewController;
        
        GIHomeViewController *destinationTab = [[[destination.viewControllers objectAtIndex:0] viewControllers] firstObject];
        
        [destinationTab configureWithModelObject:[GIUserStore sharedStore].currentUser.userProfile];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            [self.navigationController popToRootViewControllerAnimated:NO];
            
        } afterDelay:1];
    }
}

@end
