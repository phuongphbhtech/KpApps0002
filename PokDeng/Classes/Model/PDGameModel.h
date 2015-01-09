//
//  PDGameModel.h
//  PokDeng
//
//  Created by Sarunporn Pisutwimol on 5/18/2557 BE.
//  Copyright (c) 2557 Sarunporn Pisutwimol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDGameSingleton.h"
#import "PDShareConnection.h"
#import "PDHelperFunction.h"

#import "DefineEnumData.h"
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

/*
 const k_RANK_VALUE='1';
 const k_RANK_COLOR='2';
 const k_RANK_3BORDER='3';
 const k_RANK_RUNNING='4';
 const k_RANK_TRIPPLE='5';
 const k_RANK_RUNNINGROYAL='6';
 const k_RANK_POK='7';
 
 */




/*
typedef enum {
    PlayerStatusDealer,                         //เจ้ามือ
    PlayerStatusPlayer,                         //ผู้เล่นทั่วไป
    PlayerStatusObserver,                       //observer mode
}PlayerStatus;
*/
typedef enum {
    PlayerJoinStateNone,                            //ไม่ได้ทำอะไร
    PlayerJoinStateWaitingForEnterChair,            //รอส่งคำร้องขอนั่งเก้าอี้
    PlayerJoinStateSendingRequestForEnterChair,     //อยู่ระหว่างส่งคำร้องขอนั่งเก้าอี้
    PlayerJoinStateWaitingForNextGame,              //สถานะนั่งเก้าอี้ แต่ยังไม่สามารถเข้าร่วมเกมในรอบนั้นได้
    PlayerJoinStateJoinComplete                     //นั่งเก้าอี้เรียบร้อย พร้อมเล่น
    
}PlayerJoinState;



@protocol PDGameModelDelegate <NSObject>

-(void) actionCompleteCallbackWithActionType:(CallbackActionType)actionType data:(NSDictionary *)data;
-(void) actionFailureCallbackWithActionType:(CallbackActionType)actionType errorString:(NSString *)errorString;
-(void) gameStateActiveCallback:(GameState)gameState;
-(void) observerModeStateCallback:(GameState) gameState;
-(void) countDownTimeCallback:(float)countDownTime state:(GameState)state;
@end

@interface PDGameModel : NSObject <PDShareConnectionDelegate>{
    PDShareConnection *shareConnection;
}
@property (nonatomic , retain) id<PDGameModelDelegate> delegate;
@property (nonatomic) PDGameSingleton *shareGame;
@property (nonatomic) PlayerStatus currentPlayerStatus;
@property (nonatomic) PlayerJoinState currentJoinStatus;

@property (nonatomic) int currentChairNumber;

// Game Data
@property (nonatomic , retain) NSMutableArray *playerInfoArray;
@property (nonatomic , retain) NSDictionary *allPlayerDict;
@property (nonatomic , retain) NSDictionary *allPlayerCardsDict;
@property (nonatomic , retain) NSDictionary *betLimitedDataDict;
@property (nonatomic , retain) NSDictionary *allPlayerBetDict;
@property (nonatomic , retain) NSDictionary *allPlayerCutCardDict;
@property (nonatomic , retain) NSDictionary *allPlayerCallCardDict;
@property (nonatomic , retain) NSDictionary *allPlayerResultDict;

@property (nonatomic , retain) NSMutableSet *emptyChairNumberSet;
@property (nonatomic , retain) NSMutableSet *aiChairNumberSet;
@property (nonatomic , assign) NSInteger roomMaxBet;
@property (nonatomic , assign) NSInteger roomMinBet;
@property (nonatomic , assign) int maxBetPerRound;  //จำนวนเงินเดิมพันสูงสุดที่วางได้ในรอบนั้น
@property (nonatomic , assign) int dealerChairNum;
@property (nonatomic , assign) bool isHaveDealer;

//Player Data
@property (nonatomic , assign) int playHandAmount;  //จำนวนมือที่เล่น


//Dealer Data


+(instancetype) initGameModelWithTarget:(id<PDGameModelDelegate>)target;

-(void) update:(float)dt;

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
-(void) getUserDataWithUserId:(NSString *)userId;

//Data Request
-(void) requestGetAllBetData;
-(void) requestGetAllCardData;
-(void) requestGetAllCallcardData;
-(void) requestGetMatchResult;
// Send Data
-(void) sendBetHand1:(NSInteger)hand1Bet hand2:(NSInteger)hand2Bet;
-(void) sendCutCard:(BOOL)cutCard;
-(void) sendCallCardHand1:(BOOL)hand1CallCard hand2:(BOOL)hand2CallCard;

//Convinien Function
-(int) getCardChair:(int)chairNumber hand:(int)hand cardOnHand:(int)cardOnHand;
-(int) getBetChair:(int)chairNumber hand:(int)hand;
-(int) getCutCardChair:(int)chairNumber;
-(int) getPlayHandNum:(int)chairNumber;
-(int) getCardPointChair:(int)chairNumber hand:(int)hand cardOnHandNumber:(int)cardOnHandNumber;
-(CardRankType) getCardRankTypeChair:(int)chairNumber hand:(int)hand;
-(BOOL) isAllGamblerPok;
-(BOOL) getIsCallChair:(int)chairNumber hand:(int)hand;
-(int) getResultChair:(int)chairNumber hand:(int)hand;
-(ResultType) getResultTypeChair:(int)chairNumber hand:(int)hand;
-(BOOL) is2CardsLower4Point:(int)chair hand:(int)hand;

-(int) getCardRankChair:(int)chairNumber hand:(int)hand cardOnHandAmount:(int)cardAmount;
@end
