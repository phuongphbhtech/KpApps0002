//
//  PDGameModel.m
//  PokDeng
//
//  Created by Sarunporn Pisutwimol on 5/18/2557 BE.
//  Copyright (c) 2557 Sarunporn Pisutwimol. All rights reserved.
//

#import "PDGameModel.h"

#define DEFAULT_REFRESH_TIME_INTERVAL       2.0f

#define IS_CONNECT_TO_SERVER                YES

@interface PDGameModel(){
    float refreshTimeCount;
    int checkLatencyCount;
    float stateTimeLimit;
    
    GameState currentGameState;
    
    NSString *currentRequestDealerUserId;
    
    int requestEnterChairNumber;
    
    BOOL isOnUpdatePlayerChip;
    
    BOOL isOnObserverProcess;
    
}
-(id) initGameModeInstanceWithTarget:(id<PDGameModelDelegate>)target;

// Reset Data
-(void) resetEmptyChairSet;
-(void) resetGameDataToDefault;
// Init Data
-(void) initAllPlayerDictionary;

// Run GameState
-(void) runGameState:(GameState)gameState;
-(void) observerModeProcess:(GameState)gameState;

-(void) processPlayerDataDict;
-(void) processTimeLimitWithTimeLimit:(float)timeLimit state:(int)state;
@end

@implementation PDGameModel
+(instancetype) initGameModelWithTarget:(id<PDGameModelDelegate>)target{
    return [[self alloc]initGameModeInstanceWithTarget:target];
}

-(id) initGameModeInstanceWithTarget:(id<PDGameModelDelegate>)target{
    if ((self = [super init])) {
        self.delegate = target;
        
        self.shareGame = [PDGameSingleton shareInstance];
        shareConnection = [PDShareConnection shareInstance];
        shareConnection.delegate = self;
        
        self.playerInfoArray = [NSMutableArray array];
        
        self.currentChairNumber = 0;
        self.playHandAmount = 1;
        self.emptyChairNumberSet = [NSMutableSet set];
        self.aiChairNumberSet = [NSMutableSet set];
        self.isHaveDealer = false;
        self.currentJoinStatus = JoinRoomTypeNone;
        
        currentGameState = GameStateNone;
        
        checkLatencyCount = 0;
        stateTimeLimit = 0.0f;
        
        
        
        if (self.shareGame.isDealer) {
            self.currentPlayerStatus = PlayerStatusDealer;
            self.isHaveDealer = true;
            
            if (IS_CONNECT_TO_SERVER) {
                [shareConnection requestSetIsDealerWithUserId:self.shareGame.userId];
                [shareConnection requestStartRoomWithUserId:self.shareGame.userId];
            }
        }else{
            switch (self.shareGame.joinRoomType) {
                case JoinRoomTypeNormalJoin:{
                    self.currentPlayerStatus = PlayerStatusObserver;
                    isOnObserverProcess = YES;
                }
                    break;
                case JoinRoomTypeQuickJoin:{
                    self.currentPlayerStatus = PlayerStatusObserver;
                    self.currentJoinStatus = PlayerJoinStateWaitingForEnterChair;
                }
                    break;
                    
                default:
                    break;
            }
        }
        if (IS_CONNECT_TO_SERVER) {
            [shareConnection requestCheckLatencyWithUserId:self.shareGame.userId startTime:@""];
        }
    }
    return self;
}

-(void) update:(float)dt{
    if (IS_CONNECT_TO_SERVER) {
        refreshTimeCount += dt;
        if (refreshTimeCount >= DEFAULT_REFRESH_TIME_INTERVAL) {
            
            if (stateTimeLimit <= 0) {
                [shareConnection requestGetRoomStateWithUserId:self.shareGame.userId];
            }
            
        }
        
        switch (currentGameState) {
            case GameStateWaitingForStart:{
                if (refreshTimeCount >= DEFAULT_REFRESH_TIME_INTERVAL) {
                    if (self.currentPlayerStatus == PlayerStatusDealer) {
                        [shareConnection requestGetRequestDealerWithUserId:self.shareGame.userId];
                        
                    }
                }
            }
                break;
            case GameStateStart:{
                if (stateTimeLimit > 0) {
                    stateTimeLimit -= dt;
//                    NSLog(@"Start In %f",stateTimeLimit);
                    if (stateTimeLimit <= 0) {
                        
                    }
                }
            }
                break;
            case GameStateSetBet:{
                if (stateTimeLimit > 0) {
                    stateTimeLimit -= dt;
//                    NSLog(@"GameStateSetBet %f",stateTimeLimit);
                    if (stateTimeLimit <= 0) {
                        [shareConnection requestGetAllBetWithUserId:self.shareGame.userId];
                    }
                }
            }
                break;
            case GameStateSetCutCard:{
                if (stateTimeLimit > 0) {
                    stateTimeLimit -= dt;
//                    NSLog(@"GameStateSetCutCard %f",stateTimeLimit);
                    if (stateTimeLimit <= 0) {
                        [shareConnection requestGetAllCutCardWithUserId:self.shareGame.userId];
                    }
                }
            }
                break;
            case GameStateSetCallCard:{
                if (stateTimeLimit > 0) {
                    stateTimeLimit -= dt;
//                    NSLog(@"GameStateSetCallCard %f",stateTimeLimit);
                    if (stateTimeLimit <= 0) {
                        //จบช่วงนี้ต้อง get ค่า all cut card
                        
                    }
                }
            }
                break;
            case GameStateGetResult:{
                if (stateTimeLimit > 0) {
                    stateTimeLimit -= dt;
//                    NSLog(@"Show Result Time & startClearTableIn %f",stateTimeLimit);
                    
                    if (stateTimeLimit <= 0) {
                        [self runGameState:GameStateEndGame];
                    }
                }
            }
                break;
                
            default:
                break;
        }
        
        if (stateTimeLimit > 0) {
            if ([self.delegate respondsToSelector:@selector(countDownTimeCallback:state:)]) {
                [self.delegate countDownTimeCallback:stateTimeLimit state:currentGameState];
            }
        }
        
        if (refreshTimeCount >= DEFAULT_REFRESH_TIME_INTERVAL) {
            refreshTimeCount = 0;
        }
    }
}

#pragma mark - Room
-(void) startGame{
    [shareConnection requestStartPlayingWithUserId:self.shareGame.userId];
}

-(void) quitRoom{
    [shareConnection requestQuitRoomWithUserId:self.shareGame.userId];
}

-(void) enterChairNumber:(int)chairNumber{
    requestEnterChairNumber = chairNumber;
    self.currentJoinStatus = PlayerJoinStateWaitingForEnterChair;
    [shareConnection requestEnterChairWithUserId:self.shareGame.userId chairOrder:chairNumber];
}

-(void) requestQuitChair{
    [shareConnection requestStandUpFromChairWithUserId:self.shareGame.userId];
}

-(void) requestUpdatePlayerChip{
    isOnUpdatePlayerChip = TRUE;
    [shareConnection requestGetPlayerProfileWithUserId:self.shareGame.userId];
}

#pragma mark - Dealer Request
-(void) requestDealer{
    if (self.isHaveDealer) {
        [shareConnection requestSetRequestDealerWithUserId:self.shareGame.userId];
    }else{
        [shareConnection requestSetIsDealerWithUserId:self.shareGame.userId];
    }
}

-(void) allowRequestDealer{
    //สลับสิทธิ์การเป็นเจ้ามือของผู้เล่น
    [shareConnection requestSetIsDealerWithUserId:currentRequestDealerUserId];
    [shareConnection requestClearRequestDealerWithUserId:self.shareGame.userId];
}
-(void) declineRequestDealer{
    [shareConnection requestClearRequestDealerWithUserId:self.shareGame.userId];
}
#pragma mark - AI Request

-(void) addAIToChair:(int)chairNumber{
    [shareConnection requestAddAiWithUserId:self.shareGame.userId chairOrder:chairNumber];
}
-(void) removeAIOnChair:(int)chairNumber{
    [self.aiChairNumberSet removeObject:[NSNumber numberWithInt:chairNumber]];
    [shareConnection requestRemoveAiWithUserId:self.shareGame.userId chairOrder:chairNumber];
}

#pragma mark - Get User Data
-(void) getUserDataWithUserId:(NSString *)userId{
    [shareConnection requestGetPlayerProfileWithUserId:userId];
}

#pragma mark - Request Get Data
-(void) requestGetAllBetData{
    [shareConnection requestGetAllBetWithUserId:self.shareGame.userId];
}
-(void) requestGetAllCardData{
    [shareConnection requestGetCardDataWithUserId:self.shareGame.userId];
    
}
-(void) requestGetAllCallcardData{
    [shareConnection requestGetAllCallCardWithUserId:self.shareGame.userId];
    
}

-(void) requestGetMatchResult{
    [shareConnection requestGetMatchResultWithUserId:self.shareGame.userId];
}

#pragma mark - Send Data
-(void) sendBetHand1:(NSInteger)hand1Bet hand2:(NSInteger)hand2Bet{
    [shareConnection requestSetBetWithUserId:self.shareGame.userId betHand1:hand1Bet betHand2:hand2Bet];
}
-(void) sendCutCard:(BOOL)cutCard{
    int cutCardNum = 10*cutCard;
    [shareConnection requestSetCutCardWithUserId:self.shareGame.userId cutCardNumber:cutCardNum];
}
-(void) sendCallCardHand1:(BOOL)hand1CallCard hand2:(BOOL)hand2CallCard{
    [shareConnection requestSetCallCardWithUserId:self.shareGame.userId callCardHand1:hand1CallCard callCardHand2:hand2CallCard];
}

#pragma mark - Convinien Function
-(int) getCardChair:(int)chairNumber hand:(int)hand cardOnHand:(int)cardOnHand{
    NSArray *playerCardArray = [self.allPlayerCardsDict objectForKey:[NSString stringWithFormat:@"%i",chairNumber]];
    NSArray *handArray = [playerCardArray objectAtIndex:hand];
    int cardNumber = [[handArray objectAtIndex:cardOnHand]intValue];
    return cardNumber;
}
-(int) getBetChair:(int)chairNumber hand:(int)hand{
    NSArray *playerBetArray = [self.allPlayerBetDict objectForKey:[NSString stringWithFormat:@"%i",chairNumber]];
    int bet = [[playerBetArray objectAtIndex:hand]intValue];
    return bet;
}

-(int) getCutCardChair:(int)chairNumber{
    int cutCard = [[self.allPlayerCutCardDict objectForKey:[NSString stringWithFormat:@"%i",chairNumber]]intValue];
    return cutCard;
}

-(int) getPlayHandNum:(int)chairNumber{
    int playHandNum = 1;
    if ([self getBetChair:chairNumber hand:1] > 0) {
        playHandNum = 2;
    }
    return playHandNum;
}

-(int) getCardPointChair:(int)chairNumber hand:(int)hand cardOnHandNumber:(int)cardOnHandNumber{
    int cardNum;
    int sum = 0;
    for (int i = 0; i<cardOnHandNumber; i++) {
        cardNum = [self getCardChair:chairNumber hand:hand cardOnHand:i];
        sum = sum + [PDHelperFunction getCardPointWithCardNum:cardNum];
    }
    sum = sum%10;
    return sum;
}
-(CardRankType) getCardRankTypeChair:(int)chairNumber hand:(int)hand{
    int cardNum;
    int cardPoint[2];
    for (int i = 0; i<2; i++) {
        cardNum = [self getCardChair:chairNumber hand:hand cardOnHand:i];
        cardPoint[i] = [PDHelperFunction getCardPointWithCardNum:cardNum];
    }
    int sumPoint = [self getCardPointChair:chairNumber hand:hand cardOnHandNumber:2];
    
    if (sumPoint == 9) {
        return CardRankType9;
    }else if (sumPoint == 8){
        return CardRankType8;
    }else{
        return CardRankTypeNone;
    }
    
}

-(BOOL) isAllGamblerPok{
    NSArray *allPlayerKey = [self.allPlayerDict allKeys];
    bool isAllGamblerPok;
    int playerPokCount = 0;
    for (int i = 0; i<self.allPlayerDict.count ; i++ ) {
        NSString *key = [allPlayerKey objectAtIndex:i];
        int chair = [key intValue];
        if (chair != self.dealerChairNum) {//ไม่คิดของ Dealer
            int maxHand = [self getPlayHandNum:chair];
            if (maxHand == 1) {
                if ([self getCardRankTypeChair:chair hand:0]!=CardRankTypeNone) {
                    playerPokCount ++;
                }
            }else if (maxHand == 2) {
                if ([self getCardRankTypeChair:chair hand:0]!=CardRankTypeNone && [self getCardRankTypeChair:chair hand:1]!=CardRankTypeNone) {
                    playerPokCount ++;
                }
            }
        }
    }
    if (playerPokCount == allPlayerKey.count-1) {
        isAllGamblerPok = true;
    }else{
        isAllGamblerPok = false;
    }
    return isAllGamblerPok;
}

-(BOOL) getIsCallChair:(int)chairNumber hand:(int)hand{
    NSArray *playerIsCallArray = [self.allPlayerCallCardDict objectForKey:[NSString stringWithFormat:@"%i",chairNumber]];
    bool isCall = [[playerIsCallArray objectAtIndex:hand]boolValue];
    return isCall;
}
-(int) getResultChair:(int)chairNumber hand:(int)hand{
    NSArray *playerResultArray = [self.allPlayerResultDict objectForKey:[NSString stringWithFormat:@"%i",chairNumber]];
    int result = [[playerResultArray objectAtIndex:hand]intValue];
    return result;
}

-(ResultType) getResultTypeChair:(int)chairNumber hand:(int)hand{
    int result = [self getResultChair:chairNumber hand:hand];
    if (result < 0) {
        return ResultTypeLose;
    }else if (result == 0){
        return ResultTypeDraw;
    }else if (result > 0){
        return ResultTypeWin;
    }else{
        return ResultTypeDraw;
    }
}

-(BOOL) is2CardsLower4Point:(int)chair hand:(int)hand{
    int sumPoint = [self getCardPointChair:chair hand:hand cardOnHandNumber:2];
    if (sumPoint < 4) {
        return true;
    }else{
        return false;
    }
}

-(int) getCardRankChair:(int)chairNumber hand:(int)hand cardOnHandAmount:(int)cardAmount{
    NSArray *playerCardArray = [self.allPlayerCardsDict objectForKey:[NSString stringWithFormat:@"%i",chairNumber]];
    if (playerCardArray.count > 2+hand) {
        NSArray *handArray = [playerCardArray objectAtIndex:2+hand];
        if (cardAmount == 2) {
            return [[handArray objectAtIndex:0]intValue];
        }else{
            return [[handArray objectAtIndex:1]intValue];
        }
    }else{
        DLog(@"Data not complete");
        return 0;
    }
}

#pragma mark - Reset Data
-(void) resetEmptyChairSet{
    [self.emptyChairNumberSet removeAllObjects];
    for (int i = 0; i<6; i++) {
        [self.emptyChairNumberSet addObject:[NSNumber numberWithInt:i]];
    }
}
-(void) resetGameDataToDefault{
    stateTimeLimit = 0.0f;
}

#pragma mark - Init Data

-(void) initAllPlayerDictionary{
    [self resetEmptyChairSet];
    int aiCount = 0;
    BOOL tempIsHaveDealer = FALSE;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (int i = 0; i< self.playerInfoArray.count; i++) {
        NSDictionary *playerDict = [self.playerInfoArray objectAtIndex:i];
        NSString *chairOrder = [playerDict objectForKey:@"chair_order"];
        NSString *tempUserId = [playerDict objectForKey:@"user_id"];
        NSString *displayName = [playerDict objectForKey:@"displayname"];
        BOOL isDealer = [[playerDict objectForKey:@"is_dealer"]boolValue];
        tempIsHaveDealer = tempIsHaveDealer | isDealer;
        if (isDealer) {
            self.dealerChairNum = [chairOrder intValue];
            if ([chairOrder intValue] == self.currentChairNumber) {
                //ถ้าหมายเลขเก้าอี้เจ้ามือตรงกับของผู้เล่น
                if (self.currentPlayerStatus == PlayerStatusDealer) {
                }else if (self.currentPlayerStatus == PlayerStatusPlayer){

//                    self.shareGame.isDealer = isDealer;
                    self.currentPlayerStatus = PlayerStatusDealer;
                    [self.delegate actionCompleteCallbackWithActionType:CallbackActionTypeChangeFromPlayerToDealer data:nil];
                    
                }
            }else{
                //เช็คว่าก่อนหน้านี้เป็น dealer หรือไม่ ถ้าก่อนหน้านี้เราเป็นเจ้ามือ แปลว่ามีการสลับสิทธิ์เป็นเจ้ามือ
                if (self.currentPlayerStatus == PlayerStatusDealer) {
                    self.currentPlayerStatus = PlayerStatusPlayer;
//                    self.shareGame.isDealer = FALSE;
                    //แจ้งกลับไปที่ playScene เพื่อแสดงผล
                    [self.delegate actionCompleteCallbackWithActionType:CallbackActionTypeChangeFromDealerToPlayer data:nil];
                }
            }
        }
        
        NSArray *detailArray = [NSArray arrayWithObjects:tempUserId,displayName,chairOrder, nil];
        [dict setObject:detailArray forKey:chairOrder];
        if ([tempUserId isEqualToString:@"0"]) {
            aiCount ++;
            [self.aiChairNumberSet addObject:[NSNumber numberWithInteger:[chairOrder intValue]]];
        }
        [self.emptyChairNumberSet removeObject:[NSNumber numberWithInteger:[chairOrder intValue]]];
        
    }
    self.isHaveDealer = tempIsHaveDealer;
    //    NSLog(@"aiCount = %i",aiCount);
    //    NSLog(@"self.playerInfoArray.count %i",self.playerInfoArray.count);
    
    self.allPlayerDict = [[NSDictionary alloc]initWithDictionary:dict];
    DLog(@"self.allPlayerDict %@",self.allPlayerDict);
    DLog(@"emptyChairSet = %@",self.emptyChairNumberSet);
    
    [self.delegate actionCompleteCallbackWithActionType:CallbackActionTypeUpdatePlayerOnChairData data:nil];
}

#pragma mark - GameState
-(void) runGameState:(GameState)gameState{
    switch (gameState) {
        case GameStateWaitingForStart:
            if (currentGameState != GameStateWaitingForStart) {
                currentGameState = GameStateWaitingForStart;
                if ([self.delegate respondsToSelector:@selector(gameStateActiveCallback:)]) {
                    [self.delegate gameStateActiveCallback:GameStateWaitingForStart];
                }
            }
            break;
        case GameStateStart:{
            if (currentGameState != GameStateStart) {
                currentGameState = GameStateStart;
                if ([self.delegate respondsToSelector:@selector(gameStateActiveCallback:)]) {
                    [self.delegate gameStateActiveCallback:GameStateStart];
                }
                [shareConnection requestGetTimeLimitWithUserId:self.shareGame.userId];
                [shareConnection requestGetRoomStateWithUserId:self.shareGame.userId];
            }
        }
            break;
        case GameStateSetBet:{
            if (currentGameState != GameStateSetBet) {
                currentGameState = GameStateSetBet;
                if ([self.delegate respondsToSelector:@selector(gameStateActiveCallback:)]) {
                    [self.delegate gameStateActiveCallback:GameStateSetBet];
                }
                [shareConnection requestGetCardDataWithUserId:self.shareGame.userId];
                [shareConnection requestGetTimeLimitWithUserId:self.shareGame.userId];
            }
        }
            break;
        case GameStateSetCutCard:{
            if (currentGameState != GameStateSetCutCard) {
                currentGameState = GameStateSetCutCard;
                if ([self.delegate respondsToSelector:@selector(gameStateActiveCallback:)]) {
                    [self.delegate gameStateActiveCallback:GameStateSetCutCard];
                }
                [shareConnection requestGetTimeLimitWithUserId:self.shareGame.userId];
            }
        }
            break;
        case GameStateSetCallCard:{
            if (currentGameState != GameStateSetCallCard) {
                currentGameState = GameStateSetCallCard;
                if ([self.delegate respondsToSelector:@selector(gameStateActiveCallback:)]) {
                    [self.delegate gameStateActiveCallback:GameStateSetCallCard];
                }
                [shareConnection requestGetTimeLimitWithUserId:self.shareGame.userId];
            }
        }
            break;
        case GameStateGetResult:{
            if (currentGameState != GameStateGetResult) {
                if (currentGameState < GameStateGetResult) {
                    currentGameState = GameStateGetResult;
                    if ([self.delegate respondsToSelector:@selector(gameStateActiveCallback:)]) {
                        [self.delegate gameStateActiveCallback:GameStateGetResult];
                    }
                    [shareConnection requestGetAllCallCardWithUserId:self.shareGame.userId];
                    [shareConnection requestGetTimeLimitWithUserId:self.shareGame.userId];
                }
            }
        }
            break;
        case GameStateEndGame:{
            if (currentGameState != GameStateEndGame) {
                currentGameState = GameStateEndGame;
                if ([self.delegate respondsToSelector:@selector(gameStateActiveCallback:)]) {
                    [self.delegate gameStateActiveCallback:GameStateEndGame];
                }
                
            }
        }
            break;
        default:
            break;
    }
}


-(void) observerModeProcess:(GameState)gameState{
    if (currentGameState == GameStateNone) {
        switch (gameState) {
            case GameStateWaitingForStart:{
                isOnObserverProcess = false;
            }
                break;
            case GameStateSetBet:{
                [shareConnection requestGetCardDataWithUserId:self.shareGame.userId];
            }
                break;
                
            default:
                break;
        }
    }else{
        int deltaState = gameState - currentGameState;
        if (deltaState > 1) {
            //ห่างกันมากกว่า 1 ระดับ
            NSLog(@"State range > 1");
            
        }else if(deltaState == 0){
            NSLog(@"Same State");
        }
    }
}

#pragma mark - Process Data
-(void) processPlayerDataDict{
    DLog(@"processPlayerDataDict");
    if (self.currentJoinStatus == PlayerJoinStateWaitingForEnterChair) {
        self.currentJoinStatus = PlayerJoinStateSendingRequestForEnterChair;
        NSArray *emptyChair = [self.emptyChairNumberSet allObjects];
        int enterIndex = arc4random()%emptyChair.count;
        DLog(@"randomEnterChairIndex = %i",enterIndex);
        requestEnterChairNumber = [emptyChair[enterIndex] intValue];

        [shareConnection requestEnterChairWithUserId:self.shareGame.userId chairOrder:requestEnterChairNumber];
    }
    
}
-(void) processTimeLimitWithTimeLimit:(float)timeLimit state:(int)state{
    
}

#pragma mark - PDShareConnectionDelegate
-(void) requestCompleteWithRequestType:(RequestConnectionType)requestType data:(NSDictionary *)data{
    NSDictionary *gotData = [data objectForKey:@"data"];
    switch (requestType) {
        case RequestConnectionTypeStartRoom:{
            DLog(@"RequestConnectionTypeStartRoom");
        }
            break;
        case RequestConnectionTypeStartPlaying:{
            
        }
            break;
        case RequestConnectionTypeGetRoomStartStatus:{
            
        }
            break;
        case RequestConnectionTypeSetIsDealer:{
            if ([self.delegate respondsToSelector:@selector(actionCompleteCallbackWithActionType:data:)]) {
                [self.delegate actionCompleteCallbackWithActionType:RequestConnectionTypeSetIsDealer data:nil];
            }
        }
            break;
        case RequestConnectionTypeSetRequestDealer:{
            
        }
            break;
        case RequestConnectionTypeGetRequestDealer:{
            NSArray *requestDealerInfo = [gotData objectForKey:@"request_dealer_info"];
            if (requestDealerInfo.count > 0) {
                NSDictionary *requestData = [requestDealerInfo objectAtIndex:0];
                currentRequestDealerUserId = [requestData objectForKey:@"user_id"];
                self.dealerChairNum = self.currentChairNumber;
                if ([self.delegate respondsToSelector:@selector(actionCompleteCallbackWithActionType:data:)]) {
                    [self.delegate actionCompleteCallbackWithActionType:CallbackActionTypeGetRequestDealer data:requestData];
                }
            }
        }
            break;
        case RequestConnectionTypeGetRoomState:{
            NSDictionary *gotData = [data objectForKey:@"data"];
            
            NSString *stateString = [gotData objectForKey:@"state"];
            int state = [stateString intValue];
            
            DLog(@"room state %@",stateString);
            NSArray *playersInfo = [gotData objectForKey:@"user_info"];
            if (self.playerInfoArray.count > 0) {
                [self.playerInfoArray removeAllObjects];
            }
            [self.playerInfoArray setArray:playersInfo];
            DLog(@"self.playerInfoArray %@",self.playerInfoArray);
            [self initAllPlayerDictionary];
            [self processPlayerDataDict];
            
            /*
            if (isOnObserverProcess) {
                [self observerModeProcess:state];
            }else{
                [self runGameState:state];
            }
            */
            [self runGameState:state];
        }
            break;
        case RequestConnectionTypeGetBetLimitation:{
            self.betLimitedDataDict = [[NSDictionary alloc]initWithDictionary:gotData];
            self.roomMaxBet = [[self.betLimitedDataDict objectForKey:@"max_bet"]integerValue];
            self.roomMinBet = [[self.betLimitedDataDict objectForKey:@"min_bet"]integerValue];
            DLog(@"self.betLimitedDataDict %@",self.betLimitedDataDict);
        }
            break;
        case RequestConnectionTypeGetCardData:{
            NSArray *cardDataArray = [gotData objectForKey:@"cards_info"];
            DLog(@"cardDataArray %@",cardDataArray);
            NSMutableDictionary *cardsDict = [NSMutableDictionary dictionary];
            for (int i = 0; i<cardDataArray.count; i++) {
                NSDictionary *cardDict = [cardDataArray objectAtIndex:i];
                NSString *key = [cardDict objectForKey:@"chair_order"];
                NSArray *hand1CardsArray = [NSArray arrayWithObjects:[cardDict objectForKey:@"hand1_card1"],[cardDict objectForKey:@"hand1_card2"],[cardDict objectForKey:@"hand1_card3"], nil];
                NSArray *hand2CardsArray = [NSArray arrayWithObjects:[cardDict objectForKey:@"hand2_card1"],[cardDict objectForKey:@"hand2_card2"],[cardDict objectForKey:@"hand2_card3"], nil];
                NSArray *hand1CardsRank = [NSArray arrayWithObjects:[cardDict objectForKey:@"hand1_rank1"],[cardDict objectForKey:@"hand1_rank2"], nil];
                NSArray *hand2CardsRank = [NSArray arrayWithObjects:[cardDict objectForKey:@"hand2_rank1"],[cardDict objectForKey:@"hand2_rank2"], nil];
                NSArray *cardsHandArray = [NSArray arrayWithObjects:hand1CardsArray,hand2CardsArray,hand1CardsRank,hand2CardsRank, nil];
                [cardsDict setObject:cardsHandArray forKey:key];
            }
            self.allPlayerCardsDict = [[NSDictionary alloc]initWithDictionary:cardsDict];
            DLog(@"self.allPlayerCardsDict %@",self.allPlayerCardsDict);
        }
            break;
        case RequestConnectionTypeSetBet:{
            
        }
            break;
        case RequestConnectionTypeGetAllBet:{
            NSArray *array = [NSArray arrayWithArray:[gotData objectForKey:@"bet_info"]];
            NSMutableDictionary *betDict = [NSMutableDictionary dictionary];
            for (int i = 0; i<array.count; i++) {
                NSDictionary *playerBetDict = [NSDictionary dictionaryWithDictionary:[array objectAtIndex:i]];
                NSString *key = [playerBetDict objectForKey:@"chair_order"];
                NSArray *betArray = [NSArray arrayWithObjects:[playerBetDict objectForKey:@"bet_1"],[playerBetDict objectForKey:@"bet_2"], nil];
                [betDict setObject:betArray forKey:key];
            }
            self.allPlayerBetDict = [[NSDictionary alloc]initWithDictionary:betDict];
            
            if ([self.delegate respondsToSelector:@selector(actionCompleteCallbackWithActionType:data:)]) {
                [self.delegate actionCompleteCallbackWithActionType:CallbackActionTypeGetAllBetComplete data:nil ];
            }
        }
            break;
        case RequestConnectionTypeSetCutCard:{
            
        }
            break;
        case RequestConnectionTypeGetAllCutCard:{
            NSArray *array = [NSArray arrayWithArray:[gotData objectForKey:@"cut_cards_info"]];
            NSMutableDictionary *cutCardDict = [NSMutableDictionary dictionary];
            
            for (int i = 0; i<array.count; i++) {
                NSDictionary *dict = [NSDictionary dictionaryWithDictionary:[array objectAtIndex:i]];
                NSString *key = [dict objectForKey:@"chair_order"];
                NSString *cutCard = [dict objectForKey:@"cut_cards"];
                [cutCardDict setObject:cutCard forKey:key];
            }
            self.allPlayerCutCardDict = [[NSDictionary alloc]initWithDictionary:cutCardDict];
            DLog(@"self.allPlayerCutCard %@",self.allPlayerCutCardDict);
            if ([self.delegate respondsToSelector:@selector(actionCompleteCallbackWithActionType:data:)]) {
                [self.delegate actionCompleteCallbackWithActionType:CallbackActionTypeGetAllCutCardComplete data:nil ];
            }
        }
            break;
        case RequestConnectionTypeSetCallCard:{
            
        }
            break;
        case RequestConnectionTypeGetAllCallCard:{
            NSArray *array = [gotData objectForKey:@"is_call_info"];
            NSMutableDictionary *callCardsDict = [NSMutableDictionary dictionary];
            for (int i = 0; i<array.count; i++) {
                NSDictionary *callCardDict = [array objectAtIndex:i];
                NSString *key = [callCardDict objectForKey:@"chair_order"];
                NSArray *callCardArray = [NSArray arrayWithObjects:[callCardDict objectForKey:@"is_call_1"],[callCardDict objectForKey:@"is_call_2"], nil];
                [callCardsDict setObject:callCardArray forKey:key];
            }
            self.allPlayerCallCardDict = [[NSDictionary alloc]initWithDictionary:callCardsDict];
            DLog(@"self.allPlayerCallCard %@",self.allPlayerCallCardDict);
            if ([self.delegate respondsToSelector:@selector(actionCompleteCallbackWithActionType:data:)]) {
                [self.delegate actionCompleteCallbackWithActionType:CallbackActionTypeGetAllCallCardComplete data:nil ];
            }
        }
            break;
        case RequestConnectionTypeEnterChair:{
            if (self.shareGame.isDealer) {
                DLog(@"Enter Chair To be Dealer");
            }
            self.currentPlayerStatus = PlayerStatusPlayer;
            self.currentChairNumber = requestEnterChairNumber;
            self.currentJoinStatus = PlayerJoinStateJoinComplete;
            
            DLog(@"player Enterchair Complete %i",self.currentChairNumber);
            if (self.shareGame.isDealer) {
                self.currentPlayerStatus = PlayerStatusDealer;
            }
            
            [self.delegate actionCompleteCallbackWithActionType:CallbackActionTypeEnterChairComplete data:nil];
        }
            break;
            
        case RequestConnectionTypeStandUpFromChair:{
            self.shareGame.isDealer = false;
            self.currentPlayerStatus = PlayerStatusObserver;
            [self.delegate actionCompleteCallbackWithActionType:CallbackActionTypeStandUpFromChair data:nil];
        }
            break;
        case RequestConnectionTypeAddAi:{
            if ([self.delegate respondsToSelector:@selector(actionCompleteCallbackWithActionType:data:)]) {
                [self.delegate actionCompleteCallbackWithActionType:CallbackActionTypeAddAi data:nil ];
            }
        }
            break;
        case RequestConnectionTypeRemoveAi:{
            if ([self.delegate respondsToSelector:@selector(actionCompleteCallbackWithActionType:data:)]) {
                [self.delegate actionCompleteCallbackWithActionType:CallbackActionTypeRemoveAi data:nil ];
            }
        }
            break;
        case RequestConnectionTypeQuitRoom:{
            if ([self.delegate respondsToSelector:@selector(actionCompleteCallbackWithActionType:data:)]) {
                shareConnection.delegate = nil;
                self.shareGame.isDealer = FALSE;
                self.currentPlayerStatus = PlayerStatusObserver;
                self.shareGame.joinRoomType = JoinRoomTypeNone;
                [self.delegate actionCompleteCallbackWithActionType:CallbackActionTypeQuitRoom data:nil ];
            }
        }
            break;
        case RequestConnectionTypeCheckLatency:{
            checkLatencyCount ++;
            if (checkLatencyCount < 2) {
                NSString *startTime = [gotData objectForKey:@"start_time"];
                [shareConnection requestCheckLatencyWithUserId:self.shareGame.userId startTime:startTime];
            }else{
                if (self.betLimitedDataDict == nil) {
                    [shareConnection requestGetBetLimitationWithUserId:self.shareGame.userId];
                    [shareConnection requestGetRoomStateWithUserId:self.shareGame.userId];
                }
            }
        }
            break;
        case RequestConnectionTypeGetMatchResult:{
            NSArray *array = [NSArray arrayWithArray:[gotData objectForKey:@"results_info"]];
            NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
            for (int i = 0; i<array.count; i++) {
                NSDictionary *dict = [NSDictionary dictionaryWithDictionary:[array objectAtIndex:i]];
                NSString *key = [dict objectForKey:@"chair_order"];
                NSArray *result = [NSArray arrayWithObjects:[dict objectForKey:@"result_1"],[dict objectForKey:@"result_2"], nil];
                [resultDict setObject:result forKey:key];
            }
            self.allPlayerResultDict = [[NSDictionary alloc]initWithDictionary:resultDict];
            DLog(@"self.allPlayerResultDict %@",self.allPlayerResultDict);
            if ([self.delegate respondsToSelector:@selector(actionCompleteCallbackWithActionType:data:)]) {
                [self.delegate actionCompleteCallbackWithActionType:CallbackActionTypeGetGameResultComplete data:nil ];
            }
        
        }
            break;
        case RequestConnectionTypeGetPlayerProfile:{
            if ([self.delegate respondsToSelector:@selector(actionCompleteCallbackWithActionType:data:)]) {
                NSDictionary *playerProfile = [[data objectForKey:@"data"]objectAtIndex:0];
                [self.delegate actionCompleteCallbackWithActionType:CallbackActionTypeGetPlayerInfo data:playerProfile];
                
                if (isOnUpdatePlayerChip) {
                    NSString *profileId = [playerProfile objectForKey:@"user_id"];
                    if ([self.shareGame.userId isEqualToString:profileId]) {
                        self.shareGame.chip = [[playerProfile objectForKey:@"chips"]integerValue];
                        [self.delegate actionCompleteCallbackWithActionType:CallbackActionTypeUpdatePlayerChip data:nil];
                        isOnUpdatePlayerChip = FALSE;
                    }
                }
            }
        }
            break;
        case RequestConnectionTypeGetTimeLimit:{
            float tempTime = [[gotData objectForKey:@"time_limit"]floatValue];
            int tempState = [[gotData objectForKey:@"state"]intValue];
            stateTimeLimit = tempTime;
            [self processTimeLimitWithTimeLimit:tempTime state:tempState];
        }
            break;

        default:
            break;
    }
}

-(void) requestFailWithRequestType:(RequestConnectionType)requestType error:(NSError *)error{
    
    if (error.code == NSURLErrorTimedOut) {
        [self.delegate actionFailureCallbackWithActionType:CallbackActionTypeConnectionTimeOut errorString:error.localizedDescription];
        
    }
    
    switch (requestType) {
        case RequestConnectionTypeGetCardData:{
            [shareConnection requestGetCardDataWithUserId:self.shareGame.userId];
        }
            break;
        case RequestConnectionTypeGetAllBet:{
            [shareConnection requestGetAllBetWithUserId:self.shareGame.userId];
        }
            break;
        case RequestConnectionTypeGetAllCallCard:{
            [shareConnection requestGetAllCallCardWithUserId:self.shareGame.userId];
        }
            break;
        case RequestConnectionTypeGetMatchResult:{
            [shareConnection requestGetMatchResultWithUserId:self.shareGame.userId];
        }
            break;
        default:
            break;
    }
}

-(void) requestFailWithConnectionError:(RequestConnectionType)requestType errorString:(NSString *)errorString{
    
    switch (requestType) {
        case RequestConnectionTypeEnterChair:{
            [self.delegate actionFailureCallbackWithActionType:CallbackActionTypeEnterChairComplete errorString:errorString];
        }
            break;
        case RequestConnectionTypeGetCardData:{
            [shareConnection requestGetAllCallCardWithUserId:self.shareGame.userId];
        }
            break;
        case RequestConnectionTypeSetRequestDealer:{
            [self.delegate actionFailureCallbackWithActionType:CallbackActionTypeSetRequestDealerUncomplete errorString:errorString];
            
        }
            break;
        default:
            break;
    }
}
@end
