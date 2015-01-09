//
//  PDShareConnection.m
//  PokDeng
//
//  Created by Sarunporn Pisutwimol on 5/14/2557 BE.
//  Copyright (c) 2557 Sarunporn Pisutwimol. All rights reserved.
//

#import "PDShareConnection.h"
//@"http://www.minizstudio.com/pokdeng_test/pokdengRequest.php";

//static NSString *const BaseURLString = @"http://www.minizstudio.com/pokdeng_test/pokdengRequest.php";
static NSString *const BaseURLString = @"https://dl.dropboxusercontent.com/s/gxtgosg67yooq9w/PDData.json?dl=0";

#define DEFAULT_TIMEOUT_INTERVAL            15.0f


@interface PDShareConnection(){
    NSURL *baseURL;
}

-(NSString *)getErrorMessage:(NSString *)message;
@end

@implementation PDShareConnection
+(instancetype) shareInstance{
    static PDShareConnection *shareInstance;
    @synchronized(self){
        if (!shareInstance) {
            shareInstance = [[self alloc]init];
        }
    }
    return shareInstance;
}

-(instancetype) init{
    if ((self = [super init])) {
        baseURL = [NSURL URLWithString:BaseURLString];
    }
    return self;
}


-(void) requestGetNewGuessUserWithDeviceId:(NSString *)deviceId{
    DLog(@"requestGetNewGuessUserWithDeviceId");
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:deviceId,@"device_id", nil];
    NSDictionary *sendDataAndKey = [NSDictionary dictionaryWithObjectsAndKeys:params,@"getGuessUser", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDataAndKey options:0 error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT_INTERVAL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:kNilOptions
                              error:nil];
        NSDictionary *dataDict = [json objectForKey:@"getGuessUser"];
        
        DLog(@"requestGetNewGuessUserWithDeviceId %@",json);
        NSString *callbackStatus = [dataDict objectForKey:@"status"];
        if ([callbackStatus rangeOfString:@"Success"].location == NSNotFound) {
            if ([self.delegate respondsToSelector:@selector(requestFailWithConnectionError:errorString:)]) {
                NSString *errorMessage = [self getErrorMessage:callbackStatus];
                [self.delegate requestFailWithConnectionError:RequestConnectionTypeGetNewGuessUser errorString:errorMessage];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(requestCompleteWithRequestType:data:)]) {
                [self.delegate requestCompleteWithRequestType:RequestConnectionTypeGetNewGuessUser data:dataDict];
            }
        
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"requestGetNewGuessUserWithDeviceId failure with error %@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(requestFailWithRequestType:error:)]) {
            [self.delegate requestFailWithRequestType:RequestConnectionTypeGetNewGuessUser error:error];
        }
    }];
    [operation start];
}

-(void) requestLoginWithUsername:(NSString *)username password:(NSString *)password{
    
    //กำหนด parameter ที่จะส่งไปยัง server
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:username,@"username",password,@"password", nil];
    //กำหนด key ของ requestAction (ต้องการทำอะไร)
    NSDictionary *sendDataAndKey = [NSDictionary dictionaryWithObject:params forKey:@"processLogin"];
    // ทำข้อมูลให้เป็น NSData
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDataAndKey options:0 error:nil];

    // กำหนดรายละเอียดของ Request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT_INTERVAL];
    DLog(@"postData %@",jsonData);

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:kNilOptions
                              error:nil];
        NSDictionary *dataDict = [json objectForKey:@"processLogin"];
        DLog(@"dataDict %@",dataDict);
        
        NSString *callbackStatus = [dataDict objectForKey:@"status"];
        if ([callbackStatus rangeOfString:@"Success"].location == NSNotFound) {
            if ([self.delegate respondsToSelector:@selector(requestFailWithConnectionError:errorString:)]) {
                NSString *errorMessage = [self getErrorMessage:callbackStatus];
                [self.delegate requestFailWithConnectionError:RequestConnectionTypeLogin errorString:errorMessage];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(requestCompleteWithRequestType:data:)]) {
                [self.delegate requestCompleteWithRequestType:RequestConnectionTypeLogin data:dataDict];
            }
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"operation %@",operation);
        DLog(@"%@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(requestFailWithRequestType:error:)]) {
            [self.delegate requestFailWithRequestType:RequestConnectionTypeLogin error:error];
        }
    }];
     [operation start];
}

-(void) requestFBLoginWithToken:(NSString *)token email:(NSString *)email{
    DLog(@"requestFBLoginWithToken");
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:token,@"facebook_token",
                            email,@"email",
                            nil];
    NSDictionary *sendDataAndKey = [NSDictionary dictionaryWithObjectsAndKeys:params,@"facebookLogin", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDataAndKey options:0 error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT_INTERVAL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:kNilOptions
                              error:nil];
        NSDictionary *dataDict = [json objectForKey:@"facebookLogin"];
        
        DLog(@"requestFBLoginWithToken %@",json);
        NSString *callbackStatus = [dataDict objectForKey:@"status"];
        if ([callbackStatus rangeOfString:@"Success"].location == NSNotFound) {
            NSString *errorMessage = [self getErrorMessage:callbackStatus];
            if ([self.delegate respondsToSelector:@selector(requestFailWithConnectionError:errorString:)]) {
                [self.delegate requestFailWithConnectionError:RequestConnectionTypeFBLogin errorString:errorMessage];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(requestCompleteWithRequestType:data:)]) {
                [self.delegate requestCompleteWithRequestType:RequestConnectionTypeFBLogin data:dataDict];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"requestFBLoginWithToken failure with error %@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(requestFailWithRequestType:error:)]) {
            [self.delegate requestFailWithRequestType:RequestConnectionTypeFBLogin error:error];
        }
    }];
    [operation start];
}

-(void) requestLogoutWithUserId:(NSString *)userId{
    DLog(@"requestLogoutWithUserId");
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:userId,@"user_id",nil];
    NSDictionary *sendDataAndKey = [NSDictionary dictionaryWithObjectsAndKeys:params,@"processLogout", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDataAndKey options:0 error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT_INTERVAL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:kNilOptions
                              error:nil];
        NSDictionary *dataDict = [json objectForKey:@"processLogout"];
        
        DLog(@"requestLogoutWithUserId %@",json);
        NSString *callbackStatus = [dataDict objectForKey:@"status"];
        if ([callbackStatus rangeOfString:@"Success"].location == NSNotFound) {
            
            NSString *errorMessage = [self getErrorMessage:callbackStatus];
            if ([self.delegate respondsToSelector:@selector(requestFailWithConnectionError:errorString:)]) {
                [self.delegate requestFailWithConnectionError:RequestConnectionTypeLogout errorString:errorMessage];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(requestCompleteWithRequestType:data:)]) {
                [self.delegate requestCompleteWithRequestType:RequestConnectionTypeLogout data:dataDict];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"requestLogoutWithUserId failure with error %@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(requestFailWithRequestType:error:)]) {
            [self.delegate requestFailWithRequestType:RequestConnectionTypeLogout error:error];
        }
    }];
    [operation start];
}

-(void) requestCreateRoomWithUserId:(NSString *)userId roomSize:(int)roomSize minbet:(NSInteger)min maxbet:(NSInteger)max{
    DLog(@"requestCreateRoomWithUserId");
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:userId,@"user_id",
                            [NSString stringWithFormat:@"%i",roomSize],@"size",
                            [NSString stringWithFormat:@"%li",(long)min],@"min_bet",
                            [NSString stringWithFormat:@"%li",(long)max],@"max_bet", nil];
    NSDictionary *sendDataAndKey = [NSDictionary dictionaryWithObjectsAndKeys:params,@"createRoom", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDataAndKey options:0 error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT_INTERVAL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:kNilOptions
                              error:nil];
        NSDictionary *dataDict = [json objectForKey:@"createRoom"];
        
        DLog(@"requestCreateRoomWithUserId %@",json);
        NSString *callbackStatus = [dataDict objectForKey:@"status"];
        if ([callbackStatus rangeOfString:@"Success"].location == NSNotFound) {
            NSString *errorMessage = [self getErrorMessage:callbackStatus];
            if ([self.delegate respondsToSelector:@selector(requestFailWithConnectionError:errorString:)]) {
                [self.delegate requestFailWithConnectionError:RequestConnectionTypeCreateRoom errorString:errorMessage];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(requestCompleteWithRequestType:data:)]) {
                [self.delegate requestCompleteWithRequestType:RequestConnectionTypeCreateRoom data:dataDict];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"requestCreateRoomWithUserId failure with error %@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(requestFailWithRequestType:error:)]) {
            [self.delegate requestFailWithRequestType:RequestConnectionTypeCreateRoom error:error];
        }
    }];
    [operation start];
}

-(void) requestJoinRoomWithUserId:(NSString *)userId roomId:(NSString *)roomId{
    DLog(@"requestJoinRoomWithUserId");
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:userId,@"user_id",
                            roomId,@"room_id", nil];
    NSDictionary *sendDataAndKey = [NSDictionary dictionaryWithObjectsAndKeys:params,@"joinRoom", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDataAndKey options:0 error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT_INTERVAL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:kNilOptions
                              error:nil];
        NSDictionary *dataDict = [json objectForKey:@"joinRoom"];
        
        DLog(@"requestJoinRoomWithUserId %@",json);
        NSString *callbackStatus = [dataDict objectForKey:@"status"];
        if ([callbackStatus rangeOfString:@"Success"].location == NSNotFound) {
            
            NSString *errorMessage = [self getErrorMessage:callbackStatus];
            DLog(@"RequestConnectionTypeJoinRoom error String %@",errorMessage);
            if ([self.delegate respondsToSelector:@selector(requestFailWithConnectionError:errorString:)]) {
                DLog(@"respondsToSelector RequestConnectionTypeJoinRoom error String %@",errorMessage);
                [self.delegate requestFailWithConnectionError:RequestConnectionTypeJoinRoom errorString:errorMessage];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(requestCompleteWithRequestType:data:)]) {
                [self.delegate requestCompleteWithRequestType:RequestConnectionTypeJoinRoom data:dataDict];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"requestJoinRoomWithUserId failure with error %@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(requestFailWithRequestType:error:)]) {
            [self.delegate requestFailWithRequestType:RequestConnectionTypeJoinRoom error:error];
        }
    }];
    [operation start];
}
-(void) requestQuitRoomWithUserId:(NSString *)userId{
    DLog(@"requestQuitRoomWithUserId");
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:userId,@"user_id", nil];
    NSDictionary *sendDataAndKey = [NSDictionary dictionaryWithObjectsAndKeys:params,@"quitRoom", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDataAndKey options:0 error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT_INTERVAL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        

        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:kNilOptions
                              error:nil];
        NSDictionary *dataDict = [json objectForKey:@"quitRoom"];
        
        DLog(@"requestQuitRoomWithUserId %@",json);
        NSString *callbackStatus = [dataDict objectForKey:@"status"];
        if ([callbackStatus rangeOfString:@"Success"].location == NSNotFound) {
            NSString *errorMessage = [self getErrorMessage:callbackStatus];
            if ([self.delegate respondsToSelector:@selector(requestFailWithConnectionError:errorString:)]) {
                [self.delegate requestFailWithConnectionError:RequestConnectionTypeQuitRoom errorString:errorMessage];
            }
            
        }else{
            if ([self.delegate respondsToSelector:@selector(requestCompleteWithRequestType:data:)]) {
                [self.delegate requestCompleteWithRequestType:RequestConnectionTypeQuitRoom data:dataDict];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"requestQuitRoomWithUserId failure with error %@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(requestFailWithRequestType:error:)]) {
            [self.delegate requestFailWithRequestType:RequestConnectionTypeQuitRoom error:error];
        }
    }];
    [operation start];
}

-(void) requestEnterChairWithUserId:(NSString *)userId chairOrder:(int)chairOrder{
    DLog(@"requestEnterChairWithUserId");
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:userId,@"user_id",
                            [NSString stringWithFormat:@"%i",chairOrder],@"chair_order",
                            nil];
    NSDictionary *sendDataAndKey = [NSDictionary dictionaryWithObjectsAndKeys:params,@"enterChair", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDataAndKey options:0 error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT_INTERVAL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:kNilOptions
                              error:nil];
        NSDictionary *dataDict = [json objectForKey:@"enterChair"];
        
        DLog(@"requestEnterChairWithUserId %@",json);
        NSString *callbackStatus = [dataDict objectForKey:@"status"];
        if ([callbackStatus rangeOfString:@"Success"].location == NSNotFound) {
            NSString *errorMessage = [self getErrorMessage:callbackStatus];
            if ([self.delegate respondsToSelector:@selector(requestFailWithConnectionError:errorString:)]) {
                [self.delegate requestFailWithConnectionError:RequestConnectionTypeEnterChair errorString:errorMessage];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(requestCompleteWithRequestType:data:)]) {
                [self.delegate requestCompleteWithRequestType:RequestConnectionTypeEnterChair data:dataDict];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"requestEnterChairWithUserId failure with error %@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(requestFailWithRequestType:error:)]) {
            [self.delegate requestFailWithRequestType:RequestConnectionTypeEnterChair error:error];
        }
    }];
    [operation start];
}
-(void) requestStandUpFromChairWithUserId:(NSString *)userId{
    DLog(@"requestStandUpFromChairWithUserId");
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:userId,@"user_id",
                             nil];
    NSDictionary *sendDataAndKey = [NSDictionary dictionaryWithObjectsAndKeys:params,@"quitChair", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDataAndKey options:0 error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT_INTERVAL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:kNilOptions
                              error:nil];
        NSDictionary *dataDict = [json objectForKey:@"quitChair"];
        
        DLog(@"requestStandUpFromChairWithUserId %@",json);
        NSString *callbackStatus = [dataDict objectForKey:@"status"];
        if ([callbackStatus rangeOfString:@"Success"].location == NSNotFound) {
            
            NSString *errorMessage = [self getErrorMessage:callbackStatus];
            DLog(@"requestStandUpFromChairWithUserId error String %@",errorMessage);
            if ([self.delegate respondsToSelector:@selector(requestFailWithConnectionError:errorString:)]) {
                DLog(@"respondsToSelector RequestConnectionTypeJoinRoom error String %@",errorMessage);
                [self.delegate requestFailWithConnectionError:RequestConnectionTypeStandUpFromChair errorString:errorMessage];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(requestCompleteWithRequestType:data:)]) {
                [self.delegate requestCompleteWithRequestType:RequestConnectionTypeStandUpFromChair data:dataDict];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"requestStandUpFromChairWithUserId failure with error %@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(requestFailWithRequestType:error:)]) {
            [self.delegate requestFailWithRequestType:RequestConnectionTypeStandUpFromChair error:error];
        }
    }];
    [operation start];
}

-(void) requestAddAiWithUserId:(NSString *)userId chairOrder:(int)chairOrder{
    DLog(@"requestAddAiWithUserId");
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:userId,@"user_id",
                            [NSString stringWithFormat:@"%i",chairOrder],@"chair_order",
                            nil];
    NSDictionary *sendDataAndKey = [NSDictionary dictionaryWithObjectsAndKeys:params,@"addAI", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDataAndKey options:0 error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT_INTERVAL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:kNilOptions
                              error:nil];
        NSDictionary *dataDict = [json objectForKey:@"addAI"];
        
        DLog(@"requestAddAiWithUserId %@",json);
        NSString *callbackStatus = [dataDict objectForKey:@"status"];
        if ([callbackStatus rangeOfString:@"Success"].location == NSNotFound) {
            NSString *errorMessage = [self getErrorMessage:callbackStatus];
            if ([self.delegate respondsToSelector:@selector(requestFailWithConnectionError:errorString:)]) {
                [self.delegate requestFailWithConnectionError:RequestConnectionTypeAddAi errorString:errorMessage];
            }
            
        }else{
            if ([self.delegate respondsToSelector:@selector(requestCompleteWithRequestType:data:)]) {
                [self.delegate requestCompleteWithRequestType:RequestConnectionTypeAddAi data:dataDict];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"requestAddAiWithUserId failure with error %@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(requestFailWithRequestType:error:)]) {
            [self.delegate requestFailWithRequestType:RequestConnectionTypeAddAi error:error];
        }
    }];
    [operation start];
}
-(void) requestRemoveAiWithUserId:(NSString *)userId chairOrder:(int)chairOrder{
    DLog(@"requestRemoveAiWithUserId");
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:userId,@"user_id",
                            [NSString stringWithFormat:@"%i",chairOrder],@"chair_order",
                            nil];
    NSDictionary *sendDataAndKey = [NSDictionary dictionaryWithObjectsAndKeys:params,@"removePlayer", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDataAndKey options:0 error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT_INTERVAL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:kNilOptions
                              error:nil];
        NSDictionary *dataDict = [json objectForKey:@"removePlayer"];
        
        DLog(@"requestRemoveAiWithUserId %@",json);
        NSString *callbackStatus = [dataDict objectForKey:@"status"];
        if ([callbackStatus rangeOfString:@"Success"].location == NSNotFound) {
            NSString *errorMessage = [self getErrorMessage:callbackStatus];
            if ([self.delegate respondsToSelector:@selector(requestFailWithConnectionError:errorString:)]) {
                [self.delegate requestFailWithConnectionError:RequestConnectionTypeRemoveAi errorString:errorMessage];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(requestCompleteWithRequestType:data:)]) {
                [self.delegate requestCompleteWithRequestType:RequestConnectionTypeRemoveAi data:dataDict];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"requestRemoveAiWithUserId failure with error %@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(requestFailWithRequestType:error:)]) {
            [self.delegate requestFailWithRequestType:RequestConnectionTypeRemoveAi error:error];
        }
    }];
    [operation start];
}


-(void) requestStartRoomWithUserId:(NSString *)userId{
    DLog(@"requestStartRoomWithUserId");
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:userId,@"user_id",
                             nil];
    NSDictionary *sendDataAndKey = [NSDictionary dictionaryWithObjectsAndKeys:params,@"startRoom", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDataAndKey options:0 error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT_INTERVAL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:kNilOptions
                              error:nil];
        NSDictionary *dataDict = [json objectForKey:@"startRoom"];
        
        DLog(@"requestStartRoomWithUserId %@",json);
        NSString *callbackStatus = [dataDict objectForKey:@"status"];
        if ([callbackStatus rangeOfString:@"Success"].location == NSNotFound) {
            
            NSString *errorMessage = [self getErrorMessage:callbackStatus];
            if ([self.delegate respondsToSelector:@selector(requestFailWithConnectionError:errorString:)]) {
                [self.delegate requestFailWithConnectionError:RequestConnectionTypeStartRoom errorString:errorMessage];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(requestCompleteWithRequestType:data:)]) {
                [self.delegate requestCompleteWithRequestType:RequestConnectionTypeStartRoom data:dataDict];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"requestStartRoomWithUserId failure with error %@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(requestFailWithRequestType:error:)]) {
            [self.delegate requestFailWithRequestType:RequestConnectionTypeStartRoom error:error];
        }
    }];
    [operation start];
}

#pragma mark - Set Dealer
-(void) requestSetIsDealerWithUserId:(NSString *)userId{
    NSDictionary *param = @{@"user_id":userId,
                            };
    
    NSDictionary *sendDataAndKey = @{@"setIsDealer": param};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDataAndKey options:0 error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT_INTERVAL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:kNilOptions
                              error:nil];
        NSDictionary *dataDict = [json objectForKey:@"setIsDealer"];
        
        DLog(@"requestSetIsDealerWithUserId %@",json);
        NSString *callbackStatus = [dataDict objectForKey:@"status"];
        if ([callbackStatus rangeOfString:@"Success"].location == NSNotFound) {
            NSString *errorMessage = [self getErrorMessage:callbackStatus];
            if ([self.delegate respondsToSelector:@selector(requestFailWithConnectionError:errorString:)]) {
                [self.delegate requestFailWithConnectionError:RequestConnectionTypeSetIsDealer errorString:errorMessage];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(requestCompleteWithRequestType:data:)]) {
                [self.delegate requestCompleteWithRequestType:RequestConnectionTypeSetIsDealer data:dataDict];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"requestSetIsDealerWithUserId failure with error %@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(requestFailWithRequestType:error:)]) {
            [self.delegate requestFailWithRequestType:RequestConnectionTypeSetIsDealer error:error];
        }
    }];
    [operation start];
}
-(void) requestSetRequestDealerWithUserId:(NSString *)userId{
    NSDictionary *param = @{@"user_id" : userId ,
                            @"request_dealer" : @1};
    NSDictionary *sendDataAndKey = @{@"setRequestDealer" : param  };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDataAndKey options:0 error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT_INTERVAL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:kNilOptions
                              error:nil];
        NSDictionary *dataDict = [json objectForKey:@"setRequestDealer"];
        
        DLog(@"requestSetRequestDealerWithUserId %@",json);
        NSString *callbackStatus = [dataDict objectForKey:@"status"];
        if ([callbackStatus rangeOfString:@"Success"].location == NSNotFound) {
            NSString *errorMessage = [self getErrorMessage:callbackStatus];
            if ([self.delegate respondsToSelector:@selector(requestFailWithConnectionError:errorString:)]) {
                [self.delegate requestFailWithConnectionError:RequestConnectionTypeSetRequestDealer errorString:errorMessage];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(requestCompleteWithRequestType:data:)]) {
                [self.delegate requestCompleteWithRequestType:RequestConnectionTypeSetRequestDealer data:dataDict];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"requestSetRequestDealerWithUserId failure with error %@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(requestFailWithRequestType:error:)]) {
            [self.delegate requestFailWithRequestType:RequestConnectionTypeSetRequestDealer error:error];
        }
    }];
    [operation start];
}
-(void) requestGetRequestDealerWithUserId:(NSString *)userId{
    NSDictionary *param = @{@"user_id" : userId };
    NSDictionary *sendDataAndKey = @{ @"getRequestDealer" : param};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDataAndKey options:0 error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT_INTERVAL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:kNilOptions
                              error:nil];
        NSDictionary *dataDict = [json objectForKey:@"getRequestDealer"];
        
        DLog(@"requestGetRequestDealerWithUserId %@",json);
        NSString *callbackStatus = [dataDict objectForKey:@"status"];
        if ([callbackStatus rangeOfString:@"Success"].location == NSNotFound) {
            NSString *errorMessage = [self getErrorMessage:callbackStatus];
            if ([self.delegate respondsToSelector:@selector(requestFailWithConnectionError:errorString:)]) {
                [self.delegate requestFailWithConnectionError:RequestConnectionTypeGetRequestDealer errorString:errorMessage];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(requestCompleteWithRequestType:data:)]) {
                [self.delegate requestCompleteWithRequestType:RequestConnectionTypeGetRequestDealer data:dataDict];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"requestGetRequestDealerWithUserId failure with error %@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(requestFailWithRequestType:error:)]) {
            [self.delegate requestFailWithRequestType:RequestConnectionTypeGetRequestDealer error:error];
        }
    }];
    [operation start];
}

-(void) requestClearRequestDealerWithUserId:(NSString *)userId{
    NSDictionary *param = @{@"user_id" : userId };
    NSDictionary *sendDataAndKey = @{ @"clearRequestDealer" : param};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDataAndKey options:0 error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT_INTERVAL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:kNilOptions
                              error:nil];
        NSDictionary *dataDict = [json objectForKey:@"clearRequestDealer"];
        
        DLog(@"requestClearRequestDealerWithUserId %@",json);
        NSString *callbackStatus = [dataDict objectForKey:@"status"];
        if ([callbackStatus rangeOfString:@"Success"].location == NSNotFound) {
            NSString *errorMessage = [self getErrorMessage:callbackStatus];
            if ([self.delegate respondsToSelector:@selector(requestFailWithConnectionError:errorString:)]) {
                [self.delegate requestFailWithConnectionError:RequestConnectionTypeClearRequestDealer errorString:errorMessage];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(requestCompleteWithRequestType:data:)]) {
                [self.delegate requestCompleteWithRequestType:RequestConnectionTypeClearRequestDealer data:dataDict];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"requestClearRequestDealerWithUserId failure with error %@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(requestFailWithRequestType:error:)]) {
            [self.delegate requestFailWithRequestType:RequestConnectionTypeClearRequestDealer error:error];
        }
    }];
    [operation start];
}
#pragma mark - Start Playing
-(void) requestStartPlayingWithUserId:(NSString *)userId{
    DLog(@"requestStartPlayingWithUserId");
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:userId,@"user_id",
                            nil];
    NSDictionary *sendDataAndKey = [NSDictionary dictionaryWithObjectsAndKeys:params,@"startPlaying", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDataAndKey options:0 error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT_INTERVAL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:kNilOptions
                              error:nil];
        NSDictionary *dataDict = [json objectForKey:@"startPlaying"];
        
        DLog(@"requestStartPlayingWithUserId %@",json);
        NSString *callbackStatus = [dataDict objectForKey:@"status"];
        if ([callbackStatus rangeOfString:@"Success"].location == NSNotFound) {
            NSString *errorMessage = [self getErrorMessage:callbackStatus];
            if ([self.delegate respondsToSelector:@selector(requestFailWithConnectionError:errorString:)]) {
                [self.delegate requestFailWithConnectionError:RequestConnectionTypeStartPlaying errorString:errorMessage];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(requestCompleteWithRequestType:data:)]) {
                [self.delegate requestCompleteWithRequestType:RequestConnectionTypeStartPlaying data:dataDict];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"requestStartPlayingWithUserId failure with error %@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(requestFailWithRequestType:error:)]) {
            [self.delegate requestFailWithRequestType:RequestConnectionTypeStartPlaying error:error];
        }
    }];
    [operation start];
}

// Use for Play Scene Room Data
-(void) requestGetRoomStateWithUserId:(NSString *)userId{
    DLog(@"requestGetRoomStateWithUserId");
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:userId,@"user_id",
                            nil];
    NSDictionary *sendDataAndKey = [NSDictionary dictionaryWithObjectsAndKeys:params,@"getRoomState", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDataAndKey options:0 error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT_INTERVAL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:kNilOptions
                              error:nil];
        NSDictionary *dataDict = [json objectForKey:@"getRoomState"];
        DLog(@"requestGetRoomStateWithUserId %@",json);
        NSString *callbackStatus = [dataDict objectForKey:@"status"];
        if ([callbackStatus rangeOfString:@"Success"].location == NSNotFound) {
            NSString *errorMessage = [self getErrorMessage:callbackStatus];
            if ([self.delegate respondsToSelector:@selector(requestFailWithConnectionError:errorString:)]) {
                [self.delegate requestFailWithConnectionError:RequestConnectionTypeGetRoomState errorString:errorMessage];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(requestCompleteWithRequestType:data:)]) {
                [self.delegate requestCompleteWithRequestType:RequestConnectionTypeGetRoomState data:dataDict];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"requestGetRoomStateWithUserId failure with error %@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(requestFailWithRequestType:error:)]) {
            [self.delegate requestFailWithRequestType:RequestConnectionTypeGetRoomState error:error];
        }
    }];
    [operation start];
}
-(void) requestGetRoomStartStatusWithUserId:(NSString *)userId{
    DLog(@"requestGetRoomStartStatusWithUserId");
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:userId,@"user_id",
                            nil];
    NSDictionary *sendDataAndKey = [NSDictionary dictionaryWithObjectsAndKeys:params,@"getRoomStartingStatus", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDataAndKey options:0 error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT_INTERVAL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:kNilOptions
                              error:nil];
        NSDictionary *dataDict = [json objectForKey:@"getRoomStartingStatus"];
        
        DLog(@"requestGetRoomStartStatusWithUserId %@",json);
        NSString *callbackStatus = [dataDict objectForKey:@"status"];
        if ([callbackStatus rangeOfString:@"Success"].location == NSNotFound) {
            NSString *errorMessage = [self getErrorMessage:callbackStatus];
            if ([self.delegate respondsToSelector:@selector(requestFailWithConnectionError:errorString:)]) {
                [self.delegate requestFailWithConnectionError:RequestConnectionTypeGetRoomStartStatus errorString:errorMessage];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(requestCompleteWithRequestType:data:)]) {
                [self.delegate requestCompleteWithRequestType:RequestConnectionTypeGetRoomStartStatus data:dataDict];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"requestGetRoomStartStatusWithUserId failure with error %@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(requestFailWithRequestType:error:)]) {
            [self.delegate requestFailWithRequestType:RequestConnectionTypeGetRoomStartStatus error:error];
        }
    }];
    [operation start];
}

// Use for search room
-(void) requestGetAllRoomsDataByBetWithUserId:(NSString *)userId minbet:(NSInteger)min maxbet:(NSInteger)max{
    DLog(@"requestGetAllRoomsDataByBetWithUserId");
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:userId,@"user_id",
                            [NSString stringWithFormat:@"%li",(long)min],@"min_bet",
                            [NSString stringWithFormat:@"%li",(long)max],@"max_bet",
                            nil];
    NSDictionary *sendDataAndKey = [NSDictionary dictionaryWithObjectsAndKeys:params,@"getRoomsByBet", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDataAndKey options:0 error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT_INTERVAL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:kNilOptions
                              error:nil];
        NSDictionary *dataDict = [json objectForKey:@"getRoomsByBet"];
        
        DLog(@"requestGetAllRoomsDataByBetWithUserId %@",json);
        NSString *callbackStatus = [dataDict objectForKey:@"status"];
        if ([callbackStatus rangeOfString:@"Success"].location == NSNotFound) {
            NSString *errorMessage = [self getErrorMessage:callbackStatus];
            if ([self.delegate respondsToSelector:@selector(requestFailWithConnectionError:errorString:)]) {
                [self.delegate requestFailWithConnectionError:RequestConnectionTypeGetAllRoomDataByBet errorString:errorMessage];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(requestCompleteWithRequestType:data:)]) {
                [self.delegate requestCompleteWithRequestType:RequestConnectionTypeGetAllRoomDataByBet data:dataDict];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"requestGetAllRoomsDataByBetWithUserId failure with error %@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(requestFailWithRequestType:error:)]) {
            [self.delegate requestFailWithRequestType:RequestConnectionTypeGetAllRoomDataByBet error:error];
        }
    }];
    [operation start];
}

-(void) requestGetCardDataWithUserId:(NSString *)userId{
    DLog(@"requestGetCardDataWithUserId");
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:userId,@"user_id",
                            nil];
    NSDictionary *sendDataAndKey = [NSDictionary dictionaryWithObjectsAndKeys:params,@"getCards", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDataAndKey options:0 error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT_INTERVAL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:kNilOptions
                              error:nil];
        NSDictionary *dataDict = [json objectForKey:@"getCards"];
        
        DLog(@"requestGetCardDataWithUserId %@",json);
        NSString *callbackStatus = [dataDict objectForKey:@"status"];
        if ([callbackStatus rangeOfString:@"Success"].location == NSNotFound) {
            NSString *errorMessage = [self getErrorMessage:callbackStatus];
            if ([self.delegate respondsToSelector:@selector(requestFailWithConnectionError:errorString:)]) {
                [self.delegate requestFailWithConnectionError:RequestConnectionTypeGetCardData errorString:errorMessage];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(requestCompleteWithRequestType:data:)]) {
                [self.delegate requestCompleteWithRequestType:RequestConnectionTypeGetCardData data:dataDict];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"requestGetCardDataWithUserId failure with error %@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(requestFailWithRequestType:error:)]) {
            [self.delegate requestFailWithRequestType:RequestConnectionTypeGetCardData error:error];
        }
    }];
    [operation start];
}
//Bet Limit
-(void) requestGetBetLimitationWithUserId:(NSString *)userId{
    DLog(@"requestGetBetLimitationWithUserId");
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:userId,@"user_id",
                            nil];
    NSDictionary *sendDataAndKey = [NSDictionary dictionaryWithObjectsAndKeys:params,@"getBetLimitation", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDataAndKey options:0 error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT_INTERVAL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:kNilOptions
                              error:nil];
        NSDictionary *dataDict = [json objectForKey:@"getBetLimitation"];
        
        DLog(@"requestGetBetLimitationWithUserId %@",json);
        NSString *callbackStatus = [dataDict objectForKey:@"status"];
        if ([callbackStatus rangeOfString:@"Success"].location == NSNotFound) {
            NSString *errorMessage = [self getErrorMessage:callbackStatus];
            if ([self.delegate respondsToSelector:@selector(requestFailWithConnectionError:errorString:)]) {
                [self.delegate requestFailWithConnectionError:RequestConnectionTypeGetBetLimitation errorString:errorMessage];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(requestCompleteWithRequestType:data:)]) {
                [self.delegate requestCompleteWithRequestType:RequestConnectionTypeGetBetLimitation data:dataDict];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"requestGetBetLimitationWithUserId failure with error %@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(requestFailWithRequestType:error:)]) {
            [self.delegate requestFailWithRequestType:RequestConnectionTypeGetBetLimitation error:error];
        }
    }];
    [operation start];
}

// Bet Decision
-(void) requestSetBetWithUserId:(NSString *)userId betHand1:(NSInteger)bet1 betHand2:(NSInteger)bet2{
    DLog(@"requestSetBetWithUserId");
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:userId,@"user_id",
                            [NSString stringWithFormat:@"%li",(long)bet1],@"bet_1",
                            [NSString stringWithFormat:@"%li",(long)bet2],@"bet_2",
                            nil];
    NSDictionary *sendDataAndKey = [NSDictionary dictionaryWithObjectsAndKeys:params,@"setBet", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDataAndKey options:0 error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT_INTERVAL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:kNilOptions
                              error:nil];
        NSDictionary *dataDict = [json objectForKey:@"setBet"];
        
        DLog(@"requestSetBetWithUserId %@",json);
        NSString *callbackStatus = [dataDict objectForKey:@"status"];
        if ([callbackStatus rangeOfString:@"Success"].location == NSNotFound) {
            NSString *errorMessage = [self getErrorMessage:callbackStatus];
            if ([self.delegate respondsToSelector:@selector(requestFailWithConnectionError:errorString:)]) {
                [self.delegate requestFailWithConnectionError:RequestConnectionTypeSetBet errorString:errorMessage];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(requestCompleteWithRequestType:data:)]) {
                [self.delegate requestCompleteWithRequestType:RequestConnectionTypeSetBet data:dataDict];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"requestSetBetWithUserId failure with error %@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(requestFailWithRequestType:error:)]) {
            [self.delegate requestFailWithRequestType:RequestConnectionTypeSetBet error:error];
        }
    }];
    [operation start];
}
-(void) requestGetAllBetWithUserId:(NSString *)userId{
    DLog(@"requestGetAllBetWithUserId");
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:userId,@"user_id",
                            nil];
    NSDictionary *sendDataAndKey = [NSDictionary dictionaryWithObjectsAndKeys:params,@"getBet", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDataAndKey options:0 error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT_INTERVAL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:kNilOptions
                              error:nil];
        NSDictionary *dataDict = [json objectForKey:@"getBet"];
        
        DLog(@"requestGetAllBetWithUserId %@",json);
        NSString *callbackStatus = [dataDict objectForKey:@"status"];
        if ([callbackStatus rangeOfString:@"Success"].location == NSNotFound) {
            NSString *errorMessage = [self getErrorMessage:callbackStatus];
            if ([self.delegate respondsToSelector:@selector(requestFailWithConnectionError:errorString:)]) {
                [self.delegate requestFailWithConnectionError:RequestConnectionTypeGetAllBet errorString:errorMessage];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(requestCompleteWithRequestType:data:)]) {
                [self.delegate requestCompleteWithRequestType:RequestConnectionTypeGetAllBet data:dataDict];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"requestGetAllBetWithUserId failure with error %@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(requestFailWithRequestType:error:)]) {
            [self.delegate requestFailWithRequestType:RequestConnectionTypeGetAllBet error:error];
        }
    }];
    [operation start];
}

// Cut Card Decision
-(void) requestSetCutCardWithUserId:(NSString *)userId cutCardNumber:(int)cutCardNumber{
    DLog(@"requestSetCutCardWithUserId");
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:userId,@"user_id",
                            [NSString stringWithFormat:@"%i",cutCardNumber],@"cut_cards",
                            nil];
    NSDictionary *sendDataAndKey = [NSDictionary dictionaryWithObjectsAndKeys:params,@"setCutCards", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDataAndKey options:0 error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT_INTERVAL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:kNilOptions
                              error:nil];
        NSDictionary *dataDict = [json objectForKey:@"setCutCards"];
        
        DLog(@"requestSetCutCardWithUserId %@",json);
        NSString *callbackStatus = [dataDict objectForKey:@"status"];
        if ([callbackStatus rangeOfString:@"Success"].location == NSNotFound) {
            NSString *errorMessage = [self getErrorMessage:callbackStatus];
            if ([self.delegate respondsToSelector:@selector(requestFailWithConnectionError:errorString:)]) {
                [self.delegate requestFailWithConnectionError:RequestConnectionTypeSetCutCard errorString:errorMessage];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(requestCompleteWithRequestType:data:)]) {
                [self.delegate requestCompleteWithRequestType:RequestConnectionTypeSetCutCard data:dataDict];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"requestSetCutCardWithUserId failure with error %@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(requestFailWithRequestType:error:)]) {
            [self.delegate requestFailWithRequestType:RequestConnectionTypeSetCutCard error:error];
        }
    }];
    [operation start];
}

-(void) requestGetAllCutCardWithUserId:(NSString *)userId{
    DLog(@"requestGetAllCutCardWithUserId");
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:userId,@"user_id",
                            nil];
    NSDictionary *sendDataAndKey = [NSDictionary dictionaryWithObjectsAndKeys:params,@"getCutCards", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDataAndKey options:0 error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT_INTERVAL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:kNilOptions
                              error:nil];
        NSDictionary *dataDict = [json objectForKey:@"getCutCards"];
        
        DLog(@"requestGetAllCutCardWithUserId %@",json);
        NSString *callbackStatus = [dataDict objectForKey:@"status"];
        if ([callbackStatus rangeOfString:@"Success"].location == NSNotFound) {
            NSString *errorMessage = [self getErrorMessage:callbackStatus];
            if ([self.delegate respondsToSelector:@selector(requestFailWithConnectionError:errorString:)]) {
                [self.delegate requestFailWithConnectionError:RequestConnectionTypeGetAllCutCard errorString:errorMessage];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(requestCompleteWithRequestType:data:)]) {
                [self.delegate requestCompleteWithRequestType:RequestConnectionTypeGetAllCutCard data:dataDict];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"requestGetAllCutCardWithUserId failure with error %@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(requestFailWithRequestType:error:)]) {
            [self.delegate requestFailWithRequestType:RequestConnectionTypeGetAllCutCard error:error];
        }
    }];
    [operation start];
}

// Call Card Decision
-(void) requestSetCallCardWithUserId:(NSString *)userId callCardHand1:(BOOL)callCard1 callCardHand2:(BOOL)callCard2{
    DLog(@"requestSetBetWithUserId");
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:userId,@"user_id",
                            [NSString stringWithFormat:@"%i",callCard1],@"is_call_1",
                            [NSString stringWithFormat:@"%i",callCard2],@"is_call_2",
                            nil];
    NSDictionary *sendDataAndKey = [NSDictionary dictionaryWithObjectsAndKeys:params,@"setIsCall", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDataAndKey options:0 error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT_INTERVAL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:kNilOptions
                              error:nil];
        NSDictionary *dataDict = [json objectForKey:@"setIsCall"];
        
        DLog(@"requestSetBetWithUserId %@",json);
        NSString *callbackStatus = [dataDict objectForKey:@"status"];
        if ([callbackStatus rangeOfString:@"Success"].location == NSNotFound) {
            NSString *errorMessage = [self getErrorMessage:callbackStatus];
            if ([self.delegate respondsToSelector:@selector(requestFailWithConnectionError:errorString:)]) {
                [self.delegate requestFailWithConnectionError:RequestConnectionTypeSetCallCard errorString:errorMessage];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(requestCompleteWithRequestType:data:)]) {
                [self.delegate requestCompleteWithRequestType:RequestConnectionTypeSetCallCard data:dataDict];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"requestSetBetWithUserId failure with error %@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(requestFailWithRequestType:error:)]) {
            [self.delegate requestFailWithRequestType:RequestConnectionTypeSetCallCard error:error];
        }
    }];
    [operation start];
}
-(void) requestGetAllCallCardWithUserId:(NSString *)userId{
    DLog(@"requestGetAllCallCardWithUserId");
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:userId,@"user_id",
                            nil];
    NSDictionary *sendDataAndKey = [NSDictionary dictionaryWithObjectsAndKeys:params,@"getIsCall", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDataAndKey options:0 error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT_INTERVAL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:kNilOptions
                              error:nil];
        NSDictionary *dataDict = [json objectForKey:@"getIsCall"];
        
        DLog(@"requestGetAllCallCardWithUserId %@",json);
        NSString *callbackStatus = [dataDict objectForKey:@"status"];
        if ([callbackStatus rangeOfString:@"Success"].location == NSNotFound) {
            NSString *errorMessage = [self getErrorMessage:callbackStatus];
            if ([self.delegate respondsToSelector:@selector(requestFailWithConnectionError:errorString:)]) {
                [self.delegate requestFailWithConnectionError:RequestConnectionTypeGetAllCallCard errorString:errorMessage];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(requestCompleteWithRequestType:data:)]) {
                [self.delegate requestCompleteWithRequestType:RequestConnectionTypeGetAllCallCard data:dataDict];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"requestGetAllCallCardWithUserId failure with error %@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(requestFailWithRequestType:error:)]) {
            [self.delegate requestFailWithRequestType:RequestConnectionTypeGetAllCallCard error:error];
        }
    }];
    [operation start];
}

-(void) requestGetMatchResultWithUserId:(NSString *)userId{
    DLog(@"requestGetMatchResultWithUserId");
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:userId,@"user_id",
                            nil];
    NSDictionary *sendDataAndKey = [NSDictionary dictionaryWithObjectsAndKeys:params,@"getResults", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDataAndKey options:0 error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT_INTERVAL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:kNilOptions
                              error:nil];
        NSDictionary *dataDict = [json objectForKey:@"getResults"];
        
        DLog(@"requestGetMatchResultWithUserId %@",json);
        NSString *callbackStatus = [dataDict objectForKey:@"status"];
        if ([callbackStatus rangeOfString:@"Success"].location == NSNotFound) {
            NSString *errorMessage = [self getErrorMessage:callbackStatus];
            if ([self.delegate respondsToSelector:@selector(requestFailWithConnectionError:errorString:)]) {
                [self.delegate requestFailWithConnectionError:RequestConnectionTypeGetMatchResult errorString:errorMessage];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(requestCompleteWithRequestType:data:)]) {
                [self.delegate requestCompleteWithRequestType:RequestConnectionTypeGetMatchResult data:dataDict];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"requestGetMatchResultWithUserId failure with error %@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(requestFailWithRequestType:error:)]) {
            [self.delegate requestFailWithRequestType:RequestConnectionTypeGetMatchResult error:error];
        }
    }];
    [operation start];
}
-(void) requestGetTimeLimitWithUserId:(NSString *)userId{
    DLog(@"requestGetTimeLimitWithUserId");
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:userId,@"user_id",
                            nil];
    NSDictionary *sendDataAndKey = [NSDictionary dictionaryWithObjectsAndKeys:params,@"getTimeLimit", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDataAndKey options:0 error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT_INTERVAL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:kNilOptions
                              error:nil];
        NSDictionary *dataDict = [json objectForKey:@"getTimeLimit"];
        
        DLog(@"requestGetTimeLimitWithUserId %@",json);
        NSString *callbackStatus = [dataDict objectForKey:@"status"];
        if ([callbackStatus rangeOfString:@"Success"].location == NSNotFound) {
            NSString *errorMessage = [self getErrorMessage:callbackStatus];
            if ([self.delegate respondsToSelector:@selector(requestFailWithConnectionError:errorString:)]) {
                [self.delegate requestFailWithConnectionError:RequestConnectionTypeGetTimeLimit errorString:errorMessage];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(requestCompleteWithRequestType:data:)]) {
                [self.delegate requestCompleteWithRequestType:RequestConnectionTypeGetTimeLimit data:dataDict];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"requestGetTimeLimitWithUserId failure with error %@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(requestFailWithRequestType:error:)]) {
            [self.delegate requestFailWithRequestType:RequestConnectionTypeGetTimeLimit error:error];
        }
    }];
    [operation start];
}
-(void) requestCheckLatencyWithUserId:(NSString *)userId startTime:(NSString *)startTime{
    DLog(@"requestCheckLatencyWithUserId");
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:userId,@"user_id",startTime,@"start_time",
                            nil];
    NSDictionary *sendDataAndKey = [NSDictionary dictionaryWithObjectsAndKeys:params,@"checkLatency", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDataAndKey options:0 error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT_INTERVAL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:kNilOptions
                              error:nil];
        NSDictionary *dataDict = [json objectForKey:@"checkLatency"];
        
        DLog(@"requestCheckLatencyWithUserId %@",json);
        NSString *callbackStatus = [dataDict objectForKey:@"status"];
        if ([callbackStatus rangeOfString:@"Success"].location == NSNotFound) {
            NSString *errorMessage = [self getErrorMessage:callbackStatus];
            if ([self.delegate respondsToSelector:@selector(requestFailWithConnectionError:errorString:)]) {
                [self.delegate requestFailWithConnectionError:RequestConnectionTypeCheckLatency errorString:errorMessage];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(requestCompleteWithRequestType:data:)]) {
                [self.delegate requestCompleteWithRequestType:RequestConnectionTypeCheckLatency data:dataDict];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"requestCheckLatencyWithUserId failure with error %@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(requestFailWithRequestType:error:)]) {
            [self.delegate requestFailWithRequestType:RequestConnectionTypeCheckLatency error:error];
        }
    }];
    [operation start];
}

// Set Player Data
-(void) requestSetPlayerChipWithUserId:(NSString *)userId chip:(NSInteger)chip{
    DLog(@"requestSetPlayerChipWithUserId");
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:userId,@"user_id",
                            chip,@"chips", nil];
    NSDictionary *sendDataAndKey = [NSDictionary dictionaryWithObjectsAndKeys:params,@"setChips", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDataAndKey options:0 error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT_INTERVAL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:kNilOptions
                              error:nil];
        NSDictionary *dataDict = [json objectForKey:@"setChips"];
        
        DLog(@"requestSetPlayerChipWithUserId %@",json);
        NSString *callbackStatus = [dataDict objectForKey:@"status"];
        if ([callbackStatus rangeOfString:@"Success"].location == NSNotFound) {
            NSString *errorMessage = [self getErrorMessage:callbackStatus];
            if ([self.delegate respondsToSelector:@selector(requestFailWithConnectionError:errorString:)]) {
                [self.delegate requestFailWithConnectionError:RequestConnectionTypeSetPlayerChip errorString:errorMessage];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(requestCompleteWithRequestType:data:)]) {
                [self.delegate requestCompleteWithRequestType:RequestConnectionTypeSetPlayerChip data:dataDict];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"requestSetPlayerChipWithUserId failure with error %@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(requestFailWithRequestType:error:)]) {
            [self.delegate requestFailWithRequestType:RequestConnectionTypeSetPlayerChip error:error];
        }
    }];
    [operation start];
}
-(void) requestSetPlayerDisplayNameWithUserId:(NSString *)userId displayName:(NSString *)displayName{
    DLog(@"requestSetPlayerDisplayNameWithUserId");
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:userId,@"user_id",displayName,@"displayname", nil];
    NSDictionary *sendDataAndKey = [NSDictionary dictionaryWithObjectsAndKeys:params,@"setDisplayName", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDataAndKey options:0 error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT_INTERVAL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:kNilOptions
                              error:nil];
        NSDictionary *dataDict = [json objectForKey:@"setDisplayName"];
        
        DLog(@"requestSetPlayerDisplayNameWithUserId %@",json);
        NSString *callbackStatus = [dataDict objectForKey:@"status"];
        if ([callbackStatus rangeOfString:@"Success"].location == NSNotFound) {
            NSString *errorMessage = [self getErrorMessage:callbackStatus];
            if ([self.delegate respondsToSelector:@selector(requestFailWithConnectionError:errorString:)]) {
                [self.delegate requestFailWithConnectionError:RequestConnectionTypeSetPlayerDisplayName errorString:errorMessage];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(requestCompleteWithRequestType:data:)]) {
                [self.delegate requestCompleteWithRequestType:RequestConnectionTypeSetPlayerDisplayName data:dataDict];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"requestSetPlayerDisplayNameWithUserId failure with error %@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(requestFailWithRequestType:error:)]) {
            [self.delegate requestFailWithRequestType:RequestConnectionTypeSetPlayerDisplayName error:error];
        }
    }];
    [operation start];
}
-(void) requestSetPlayerDisplayPictureNameWithUserId:(NSString *)userId  displayPictureName:(NSString *)displayPictureName{
    DLog(@"requestSetPlayerDisplayPictureNameWithUserId");
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:userId,@"user_id",displayPictureName,@"pic", nil];
    NSDictionary *sendDataAndKey = [NSDictionary dictionaryWithObjectsAndKeys:params,@"setDisplayPicture", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDataAndKey options:0 error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT_INTERVAL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:kNilOptions
                              error:nil];
        NSDictionary *dataDict = [json objectForKey:@"setDisplayPicture"];
        
        DLog(@"requestSetPlayerDisplayPictureNameWithUserId %@",json);
        NSString *callbackStatus = [dataDict objectForKey:@"status"];
        if ([callbackStatus rangeOfString:@"Success"].location == NSNotFound) {
            NSString *errorMessage = [self getErrorMessage:callbackStatus];
            if ([self.delegate respondsToSelector:@selector(requestFailWithConnectionError:errorString:)]) {
                [self.delegate requestFailWithConnectionError:RequestConnectionTypeSetPlayerDisplayPictureName errorString:errorMessage];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(requestCompleteWithRequestType:data:)]) {
                [self.delegate requestCompleteWithRequestType:RequestConnectionTypeSetPlayerDisplayPictureName data:dataDict];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"requestSetPlayerDisplayPictureNameWithUserId failure with error %@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(requestFailWithRequestType:error:)]) {
            [self.delegate requestFailWithRequestType:RequestConnectionTypeSetPlayerDisplayPictureName error:error];
        }
    }];
    [operation start];
}

// FB Friend
-(void) requestGetFBFriendListWithUserId:(NSString *)userId{
    DLog(@"requestGetFBFriendListWithUserId");
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:userId,@"user_id",
                            nil];
    NSDictionary *sendDataAndKey = [NSDictionary dictionaryWithObjectsAndKeys:params,@"getFacebookFriendlist", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDataAndKey options:0 error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT_INTERVAL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:kNilOptions
                              error:nil];
        NSDictionary *dataDict = [json objectForKey:@"getFacebookFriendlist"];
        
        DLog(@"requestGetFBFriendListWithUserId %@",json);
        NSString *callbackStatus = [dataDict objectForKey:@"status"];
        if ([callbackStatus rangeOfString:@"Success"].location == NSNotFound) {
            NSString *errorMessage = [self getErrorMessage:callbackStatus];
            if ([self.delegate respondsToSelector:@selector(requestFailWithConnectionError:errorString:)]) {
                [self.delegate requestFailWithConnectionError:RequestConnectionTypeGetFBFriendList errorString:errorMessage];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(requestCompleteWithRequestType:data:)]) {
                [self.delegate requestCompleteWithRequestType:RequestConnectionTypeGetFBFriendList data:dataDict];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"requestGetFBFriendListWithUserId failure with error %@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(requestFailWithRequestType:error:)]) {
            [self.delegate requestFailWithRequestType:RequestConnectionTypeGetFBFriendList error:error];
        }
    }];
    [operation start];
}
// Player Profile
-(void) requestGetPlayerProfileWithUserId:(NSString *)userId{
    DLog(@"requestGetPlayerProfileWithUserId");
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:userId,@"user_id",
                            nil];
    NSDictionary *sendDataAndKey = [NSDictionary dictionaryWithObjectsAndKeys:params,@"getProfile", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDataAndKey options:0 error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT_INTERVAL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:kNilOptions
                              error:nil];
        NSDictionary *dataDict = [json objectForKey:@"getProfile"];
        
        DLog(@"requestGetPlayerProfileWithUserId %@",json);
        NSString *callbackStatus = [dataDict objectForKey:@"status"];
        if ([callbackStatus rangeOfString:@"Success"].location == NSNotFound) {
            NSString *errorMessage = [self getErrorMessage:callbackStatus];
            if ([self.delegate respondsToSelector:@selector(requestFailWithConnectionError:errorString:)]) {
                [self.delegate requestFailWithConnectionError:RequestConnectionTypeGetPlayerProfile errorString:errorMessage];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(requestCompleteWithRequestType:data:)]) {
                [self.delegate requestCompleteWithRequestType:RequestConnectionTypeGetPlayerProfile data:dataDict];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"requestGetPlayerProfileWithUserId failure with error %@",error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(requestFailWithRequestType:error:)]) {
            [self.delegate requestFailWithRequestType:RequestConnectionTypeGetPlayerProfile error:error];
        }
    }];
    [operation start];
}


-(NSString *)getErrorMessage:(NSString *)message{
    NSArray *errorMessageArray = [message componentsSeparatedByString:@":"];
    NSString *errorMessage = [errorMessageArray lastObject];
    return errorMessage;
}

@end
