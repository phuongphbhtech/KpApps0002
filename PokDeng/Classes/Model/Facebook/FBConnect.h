//
//  FBConnect.h
//  PokDeng
//
//  Created by Sarunporn Pisutwimol on 12/28/2556 BE.
//  Copyright (c) 2556 Sarunporn Pisutwimol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"

@class FBConnect;
@protocol FBConnectDelegate <NSObject>

@optional
-(void)loginWithFBCompleteWithUserData:(NSDictionary *)data;
-(void)loginWithFBFailWithError:(NSError *)error;

-(void)logoutWithFBComplete;
-(void)logoutWithFBFail;

-(void) facebookRequestErrorCallback:(NSString *)errorString;

@end


@interface FBConnect : NSObject{
    id<FBConnectDelegate> delegate;
}


+(id)initFBConnect;
+(id)initFBConnectWithTarget:(id<FBConnectDelegate>)target;
-(void)login;
-(void)logout;
-(void) setTarget:(id<FBConnectDelegate>)target;
@end
