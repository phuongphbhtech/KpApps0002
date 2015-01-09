//
//  PDGameModel2.h
//  PokDeng
//
//  Created by Sarunporn Pisutwimol on 5/27/2557 BE.
//  Copyright (c) 2557 Sarunporn Pisutwimol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDGameSingleton.h"
#import "PDShareConnection.h"
#import "DefineEnumData.h"
#import "PDHelperFunction.h"

typedef enum {
    GameStateNone = 999,
    GameStateWaitingForStart = 0,
    GameStateStart,         //1
    GameStateSetBet,        //2
    GameStateSetCutCard,    //3
    GameStateSetCallCard,   //4
    GameStateGetResult,     //5
    GameStateEndGame,       //6
}GameState;

@protocol PDGameModelDelegate <NSObject>
-(void) getDataCompleteWithDataType:(GetDataType)dataType;
-(void) observerModeLoadDataCompleteCallbackWithDataType:(GetDataType)dataType;
-(void) connectionTimeOutCallbackWithDetailString:(NSString *)detailString;
-(void) roomNotActiveCallbackWithDetailString:(NSString *)detailString;

-(void) serverChangeStateCallback:(ServerState)serverState;
-(void) actionCompleteCallbackWithActionType:(CallbackActionType)actionType data:(NSDictionary *)data;
-(void) actionFailureCallbackWithActionType:(CallbackActionType)actiontype failureString:(NSString *)failureString;
@end


@interface PDGameModel2 : NSObject <PDShareConnectionDelegate>{
    PDGameSingleton *shareGame;
    PDShareConnection *shareConnection;
}

@property (nonatomic , weak) id<PDGameModelDelegate> delegate;

@property (readwrite , assign) ServerState currentServerState;
@property (readwrite , assign) StateStatus currentStateStatus;
@property (readwrite , assign) ServerState currentObserverProcessState;


@property (readwrite , assign) float currentStateTimeLimit;
@property (readwrite , assign) float timeLimitCount;

@property (readwrite , assign) PlayerStatus currentPlayerStatus;
@property (readwrite , assign) EnterChairStatus enterChairStatus;
@property (readonly , assign) NSInteger roomMaxBet;
@property (readonly , assign) NSInteger roomMinBet;

@property (nonatomic , retain) NSMutableArray *allPlayerInfo;
@property (nonatomic , retain) NSMutableArray *allPlayerCardData;
@property (nonatomic , retain) NSMutableArray *allPlayerBetData;
@property (nonatomic , retain) NSMutableArray *allPlayerCutCardData;
@property (nonatomic , retain) NSMutableArray *allPlayerCallCardData;
@property (nonatomic , retain) NSMutableArray *allPlayerResultData;


@property (nonatomic , retain) NSMutableSet *emptyChairNumberSet;
@property (nonatomic , retain) NSMutableSet *aiChairNumberSet;

@property (readwrite , assign) bool isOnSkipAnimate;
@property (readwrite , assign) bool isWaitingForUpdateObserverData;


@property (readwrite , assign) int playHandAmount;
@property (readwrite , assign) int currentChairNumber;
@property (readwrite , assign) int dealerChairNum;
@property (readwrite , assign) bool isHaveDealer;


@property (readwrite , assign) bool isHaveAllPlayerInfoData;
@property (readwrite , assign) bool isHaveCardData;
@property (readwrite , assign) bool isHaveAllBetData;
@property (readwrite , assign) bool isHaveAllCallCardData;
@property (readwrite , assign) bool isHaveMatchResultData;

+(instancetype) initGameModelWithTarget:(id<PDGameModelDelegate>)target;

//Action Active
-(void) startGame;
-(void) quitRoom;
-(void) enterChairNumber:(int)chairNumber;
-(void) requestQuitChair;
-(void) requestUpdatePlayerChip;


// Dealer Request
-(void) requestDealer;
-(void) allowRequestDealer;
-(void) declineRequestDealer;
// Ai Request
-(void) addAIToChair:(int)chairNumber;
-(void) removeAIOnChair:(int)chairNumber;

// Get User Data
-(void) getUserDataWithUserId:(NSString *)userId;

//Set Data To Server
-(void) sendBetHand1:(NSInteger)hand1Bet hand2:(NSInteger)hand2Bet;
-(void) sendCutCard:(BOOL)cutCard;
-(void) sendCallCardHand1:(BOOL)hand1CallCard hand2:(BOOL)hand2CallCard;

//Data Request
-(void) requestGetAllBetData;
-(void) requestGetAllCardData;
-(void) requestGetAllCutCardData;
-(void) requestGetAllCallcardData;
-(void) requestGetMatchResult;

// Update
-(void) update:(float)delta;

// Convinient Function
-(int) getCardChair:(int)chairNumber hand:(int)hand cardOnHand:(int)cardOnHand;
-(NSInteger) getBetChair:(int)chairNumber hand:(int)hand;
-(int) getCutCardChair:(int)chairNumber;
-(int) getPlayHandNum:(int)chairNumber;
-(int) getCardPointChair:(int)chairNumber hand:(int)hand cardOnHandNumber:(int)cardOnHandNumber;
-(CardsRankType) getCardRankTypeChair:(int)chairNumber hand:(int)hand cardOnHandNumber:(int)cardOnHandNumber;
-(BOOL) isAllGamblerPok;
-(BOOL) isDealerPok;

-(BOOL) getIsCallChair:(int)chairNumber hand:(int)hand;
-(NSInteger) getResultChair:(int)chairNumber hand:(int)hand;
-(ResultType) getResultTypeChair:(int)chairNumber hand:(int)hand;
-(BOOL) is2CardsLower4Point:(int)chair hand:(int)hand;

-(int) getCardRankChair:(int)chairNumber hand:(int)hand cardOnHandAmount:(int)cardAmount;
@end
