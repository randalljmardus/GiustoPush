//
//  GISplashViewController.m
//  GiustoPush
//
//  Created by Randall Mardus on 3/23/16.
//  Copyright © 2016 Randall Mardus. All rights reserved.
//

#import "GISplashViewController.h"
#import "GIUserProfileViewController.h"
#import "GIProfileTabBarController.h"
#import "GIUser.h"

@interface GISplashViewController ()

@end

@implementation GISplashViewController

#pragma mark - UIViewController Methods

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        if ([GIUserStore sharedStore].authenticated) {
            [self updatedFacebookInfo];
            [self performSegueWithIdentifier:@"modalAutoLoginSuccess" sender:self];
        }
    }
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        if ([GIUserStore sharedStore].authenticated) {
            [self updatedFacebookInfo];
            [self performSegueWithIdentifier:@"modalAutoLoginSuccess" sender:self];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
}


#pragma mark - Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation -

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"modalAutoLoginSuccess"]) {
        
        GIProfileTabBarController *destination = segue.destinationViewController;
        
        GIUserProfileViewController *destinationTab = [[[destination.viewControllers objectAtIndex:0] viewControllers] firstObject];
        
        [destinationTab configureWithModelObject:[GIUserStore sharedStore].currentUser.userProfile];
        
        //        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        //            [self.navigationController popToRootViewControllerAnimated:NO];
        //        } afterDelay:1];
    }
}


- (void) updatedFacebookInfo {
    
    if ([FBSDKAccessToken currentAccessToken]) {
        
        GIUser *currentUser = [GIUserStore sharedStore].currentUser;
        
        if (currentUser.email.length == 0 || currentUser.facebookId.length == 0) {
            
            NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
            [parameters setValue:@"id,email" forKey:@"fields"];
            
            FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters];
            [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                
                NSDictionary *userData = (NSDictionary *)result;
                
                NSString *facebookId = userData[@"id"];
                NSString *email = userData[@"email"];
                
                if (currentUser.email.length == 0) {
                    currentUser.parseUser.email = email;
                }
                
                if (currentUser.facebookId.length == 0) {
                    currentUser.facebookId = facebookId;
                }
                
                [currentUser.parseUser saveInBackground];
            }];
        }
    }
}


@end
