//
//  FBConnect.m
//  PokDeng
//
//  Created by Sarunporn Pisutwimol on 12/28/2556 BE.
//  Copyright (c) 2556 Sarunporn Pisutwimol. All rights reserved.
//

#import "FBConnect.h"

@interface FBConnect ()
-(id) initFBWithTarget:(id<FBConnectDelegate>)target;
@end

@implementation FBConnect

+(id)initFBConnect{
    return [[self alloc]initWithTarget:nil];
}
+(id)initFBConnectWithTarget:(id<FBConnectDelegate>)target{
    return [[self alloc]initFBWithTarget:target];
}

-(id) initFBWithTarget:(id<FBConnectDelegate>)target{
    if ((self = [super init])) {
        delegate = target;
//        [self logout];
        if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
            NSArray *permissions = @[@"basic_info",@"read_friendlists", @"email"];
            // If there's one, just open the session silently, without showing the user the login UI
            [FBSession openActiveSessionWithReadPermissions:permissions
                                               allowLoginUI:NO
                                          completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                              // Handler for session state changes
                                              // This method will be called EACH time the session state changes,
                                              // also for intermediate states and NOT just when the session open
                                              [self sessionStateChanged:session state:state error:error];
                                          }];
        }
        
        if (FBSession.activeSession.state != FBSessionStateOpen) {
            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:FALSE] forKey:@"isOnFbLogin"];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
    }
    return self;
}
-(void) setTarget:(id<FBConnectDelegate>)target{
    delegate = target;
}
-(void)login{
    bool isOnFBLogin = [[[NSUserDefaults standardUserDefaults]objectForKey:@"isOnFbLogin"]boolValue];
    if (!isOnFBLogin) {
        // If the session state is any of the two "open" states when the button is clicked
        if (FBSession.activeSession.state == FBSessionStateOpen
            || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
            // Close the session and remove the access token from the cache
            // The session state handler (in the app delegate) will be called automatically
//            NSLog(@"login !isOnFBlogin");
            [FBSession.activeSession closeAndClearTokenInformation];
            [self login];
            // If the session state is not any of the two "open" states when the button is clicked
        } else {
            //         NSLog(@"! FBSession.activeSession.state == FBSessionStateOpen || FBSession.activeSession.state == FBSessionStateOpenTokenExtended");
            // Open a session showing the user the login UI
            // You must ALWAYS ask for basic_info permissions when opening a session
            NSArray *permissions = @[@"basic_info",@"read_friendlists", @"email"];
            [FBSession openActiveSessionWithReadPermissions:permissions
                                               allowLoginUI:YES
                                          completionHandler:
             ^(FBSession *session, FBSessionState state, NSError *error) {
                 [self sessionStateChanged:session state:state error:error];
                 
             }];
        }
    }else{
        NSString *tempAccessToken = [[FBSession.activeSession accessTokenData] accessToken];
        
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary<FBGraphUser> *user,
           NSError *error) {
             if (!error) {
                 NSString *email = [user objectForKey:@"email"];
                 //                 NSLog(@"email %@",email);
                 NSDictionary* dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:tempAccessToken,@"token",user.username,@"username",email,@"email", nil];
                 //                 NSLog(@"dict %@",dict);
                 [[NSUserDefaults standardUserDefaults]setObject:tempAccessToken forKey:@"token"];
                 [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:TRUE] forKey:@"isOnFbLogin"];
                 [[NSUserDefaults standardUserDefaults]synchronize];
                 [delegate loginWithFBCompleteWithUserData:dict];
             }else{
                 [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:FALSE] forKey:@"isOnFbLogin"];
                 [[NSUserDefaults standardUserDefaults]synchronize];
                 [delegate loginWithFBFailWithError:error];
             }
         }];
    }
}
-(void)logout{
    [FBSession.activeSession closeAndClearTokenInformation];
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:FALSE] forKey:@"isOnFbLogin"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error){
        if (state == FBSessionStateOpen) {
            // Show the user the logged-in UI
            //        [self userLoggedIn];
            NSString *tempAccessToken = [[FBSession.activeSession accessTokenData] accessToken];
            
            
            [[FBRequest requestForMe] startWithCompletionHandler:
             ^(FBRequestConnection *connection,
               NSDictionary<FBGraphUser> *user,
               NSError *error) {
                 if (!error) {
                     //                 NSLog(@"sessionStateChanged !error");
                     NSString *email = [user objectForKey:@"email"];
                     //                 NSLog(@"email %@",email);
                     NSDictionary* dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:tempAccessToken,@"token",user.username,@"username",email,@"email", nil];
                     //                 NSLog(@"dict %@",dict);
                     [[NSUserDefaults standardUserDefaults]setObject:tempAccessToken forKey:@"token"];
                     [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:TRUE] forKey:@"isOnFbLogin"];
                     [[NSUserDefaults standardUserDefaults]synchronize];
                     [delegate loginWithFBCompleteWithUserData:dict];
                 }else{
                     //                 NSLog(@"error %@",error);
                     [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:FALSE] forKey:@"isOnFbLogin"];
                     [[NSUserDefaults standardUserDefaults]synchronize];
                     [delegate loginWithFBFailWithError:error];
                 }
             }];
            return;
        }else if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
            switch (state) {
                case FBSessionStateClosedLoginFailed:{
                    
                }
                    break;
                case FBSessionStateClosed:{
//                    [delegate facebookRequestErrorCallback:@"Cannot Login with facebook please check your connection."];
                }
                    
                    break;
                default:
                    break;
            }
            // If the session is closed
            //        NSLog(@"Session closed");
            // Show the user the logged-out UI
            //        [self userLoggedOut];
            [delegate logoutWithFBComplete];
            
        }
        
    }else{
            //        NSLog(@"Error");
            NSString *alertText;
            NSString *alertTitle;
            // If the error requires people using an app to make an action outside of the app in order to recover
            if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
                //            alertTitle = @"Something went wrong";
                alertText = [FBErrorUtility userMessageForError:error];
                //            [self showMessage:alertText withTitle:alertTitle];
            } else {
                
                // If the user cancelled login, do nothing
                if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                    //                NSLog(@"User cancelled login");
                    [delegate loginWithFBFailWithError:error];
                    // Handle session closures that happen outside of the app
                } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                    alertTitle = @"Session Error";
                    alertText = @"Your current session is no longer valid. Please log in again.";
                    //                [self showMessage:alertText withTitle:alertTitle];
                    
                    // Here we will handle all other errors with a generic error message.
                    // We recommend you check our Handling Errors guide for more information
                    // https://developers.facebook.com/docs/ios/errors/
                } else {
                    //Get more error information from the error
                    NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                    
                    // Show the user an error message
                    alertTitle = @"Something went wrong";
                    alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                    //                [self showMessage:alertText withTitle:alertTitle];
                }
            }
            // Clear this token
            //        [self logout];
            // Show the user the logged-out UI
            //        [self userLoggedOut];
        
    }
}

@end
