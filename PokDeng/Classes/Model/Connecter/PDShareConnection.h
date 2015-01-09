//
//  PDShareConnection.h
//  PokDeng
//
//  Created by Sarunporn Pisutwimol on 5/14/2557 BE.
//  Copyright (c) 2557 Sarunporn Pisutwimol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef enum {
    RequestConnectionTypeGetNewGuessUser,
    RequestConnectionTypeLogin,
    RequestConnectionTypeFBLogin,
    
    RequestConnectionTypeLogout,
    
    RequestConnectionTypeCreateRoom,
    RequestConnectionTypeJoinRoom,
    RequestConnectionTypeQuitRoom,
    
    RequestConnectionTypeEnterChair,
    RequestConnectionTypeStandUpFromChair,
    
    RequestConnectionTypeAddAi,
    RequestConnectionTypeRemoveAi,
    
    RequestConnectionTypeStartRoom,
    

    RequestConnectionTypeSetIsDealer,
    RequestConnectionTypeSetRequestDealer,
    RequestConnectionTypeGetRequestDealer,
    RequestConnectionTypeClearRequestDealer,
    
    RequestConnectionTypeStartPlaying,
    
    RequestConnectionTypeGetRoomState,
    RequestConnectionTypeGetRoomStartStatus,
    
    RequestConnectionTypeGetAllRoomDataByBet,
    
    RequestConnectionTypeGetCardData,
    
    RequestConnectionTypeGetBetLimitation,
    
    RequestConnectionTypeSetBet,
    RequestConnectionTypeGetAllBet,
    
    RequestConnectionTypeSetCutCard,
    RequestConnectionTypeGetAllCutCard,
    
    RequestConnectionTypeSetCallCard,
    RequestConnectionTypeGetAllCallCard,
    
    RequestConnectionTypeGetMatchResult,
    RequestConnectionTypeGetTimeLimit,
    RequestConnectionTypeCheckLatency,
    
    RequestConnectionTypeSetPlayerChip,
    RequestConnectionTypeSetPlayerDisplayName,
    RequestConnectionTypeSetPlayerDisplayPictureName,
    
    RequestConnectionTypeGetFBFriendList,
    RequestConnectionTypeGetPlayerProfile,
    
}RequestConnectionType;

@protocol PDShareConnectionDelegate <NSObject>

-(void) requestCompleteWithRequestType:(RequestConnectionType)requestType data:(NSDictionary *)data;
-(void) requestFailWithRequestType:(RequestConnectionType)requestType error:(NSError *)error;
-(void) requestFailWithConnectionError:(RequestConnectionType)requestType errorString:(NSString *)errorString;

@end

@interface PDShareConnection : NSObject <NSURLConnectionDelegate>{

}
@property (nonatomic) id <PDShareConnectionDelegate> delegate;
+(instancetype ) shareInstance;


// New Function For Guess Register
-(void) requestGetNewGuessUserWithDeviceId:(NSString *)deviceId;

//-(void) requestRegisterNewUserWithUsername:(NSString *)username password:(NSString *)password;
-(void) requestLoginWithUsername:(NSString *)username password:(NSString *)password;
-(void) requestFBLoginWithToken:(NSString *)token email:(NSString *)email;

-(void) requestLogoutWithUserId:(NSString *)userId;

-(void) requestCreateRoomWithUserId:(NSString *)userId roomSize:(int)roomSize minbet:(NSInteger)min maxbet:(NSInteger)max;
-(void) requestJoinRoomWithUserId:(NSString *)userId roomId:(NSString *)roomId;
-(void) requestQuitRoomWithUserId:(NSString *)userId;

-(void) requestEnterChairWithUserId:(NSString *)userId chairOrder:(int)chairOrder;
-(void) requestStandUpFromChairWithUserId:(NSString *)userId;

-(void) requestAddAiWithUserId:(NSString *)userId chairOrder:(int)chairOrder;
-(void) requestRemoveAiWithUserId:(NSString *)userId chairOrder:(int)chairOrder;

-(void) requestStartRoomWithUserId:(NSString *)userId;

// Set Dealer
-(void) requestSetIsDealerWithUserId:(NSString *)userId;
-(void) requestSetRequestDealerWithUserId:(NSString *)userId;
-(void) requestGetRequestDealerWithUserId:(NSString *)userId;
-(void) requestClearRequestDealerWithUserId:(NSString *)userId;

// Use for Start Playing
-(void) requestStartPlayingWithUserId:(NSString *)userId;

// Use for Play Scene Room Data
-(void) requestGetRoomStateWithUserId:(NSString *)userId;
-(void) requestGetRoomStartStatusWithUserId:(NSString *)userId;

// Use for search room
-(void) requestGetAllRoomsDataByBetWithUserId:(NSString *)userId minbet:(NSInteger)min maxbet:(NSInteger)max;

-(void) requestGetCardDataWithUserId:(NSString *)userId;
//Bet Limit
-(void) requestGetBetLimitationWithUserId:(NSString *)userId;

// Bet Decision
-(void) requestSetBetWithUserId:(NSString *)userId betHand1:(NSInteger)bet1 betHand2:(NSInteger)bet2;
-(void) requestGetAllBetWithUserId:(NSString *)userId;

// Cut Card Decision
-(void) requestSetCutCardWithUserId:(NSString *)userId cutCardNumber:(int)cutCardNumber;
-(void) requestGetAllCutCardWithUserId:(NSString *)userId;

// Call Card Decision
-(void) requestSetCallCardWithUserId:(NSString *)userId callCardHand1:(BOOL)callCard1 callCardHand2:(BOOL)callCard2;
-(void) requestGetAllCallCardWithUserId:(NSString *)userId;

-(void) requestGetMatchResultWithUserId:(NSString *)userId;
-(void) requestGetTimeLimitWithUserId:(NSString *)userId;
-(void) requestCheckLatencyWithUserId:(NSString *)userId startTime:(NSString *)startTime;

// Set Player Data
-(void) requestSetPlayerChipWithUserId:(NSString *)userId chip:(NSInteger)chip;
-(void) requestSetPlayerDisplayNameWithUserId:(NSString *)userId displayName:(NSString *)displayName;
-(void) requestSetPlayerDisplayPictureNameWithUserId:(NSString *)userId  displayPictureName:(NSString *)displayPictureName;

// FB Friend
-(void) requestGetFBFriendListWithUserId:(NSString *)userId;
// Player Profile
-(void) requestGetPlayerProfileWithUserId:(NSString *)userId;


@end
