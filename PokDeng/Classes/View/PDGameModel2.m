//
//  PDGameModel2.m
//  PokDeng
//
//  Created by Sarunporn Pisutwimol on 5/27/2557 BE.
//  Copyright (c) 2557 Sarunporn Pisutwimol. All rights reserved.
//

#import "PDGameModel2.h"
#define kDefaultConnectionTimeOutAmountCheck      1
#define kDefaultRoomAlreadyInActive                 5

@interface PDGameModel2 (){
    int checkLatencyCount;
    int connectionTimeOutCount;
    int timeLimitIncorrectCount;        //นับจำนวนครั้งที่ timelimit ติดลบ
    
    NSString *currentRequestDealerUserId;
    
    int requestEnterChairNumber;
    
    bool isOnUpdatePlayerChip;
    
    float waitingForStartRoomRefreshTimeCount;
    
    bool isFirstCheckRoomState;
    
    bool isGetCardData;
    bool isGetBetData;
    bool isGetCutCardData;
    bool isGetCallCardData;
    bool isGetMatchResult;
    
    
    ServerState observerModeLastServerState;
    
}
-(instancetype) initGameModelInstanceWithTarget:(id<PDGameModelDelegate>)target;

-(void) clearGameData;
-(void) clearGetDataFlag;
-(void) clearConnectionErrorCount;
-(void) resetEmptyChairSet;

-(void) processGetRoomStateWithState:(ServerState)state;
-(void) processObserverGetRoomStateWithState:(ServerState)state;

-(void) activeTimeLimitEndActionWithServerState:(ServerState)serverState;

-(void) processPlayerInfoDataWithAllPlayerData:(NSArray *)allPlayerData;
-(void) processPlayerBetDataWithAllPlayerBetData:(NSArray *)allPlayerBetData;
-(void) processPlayerCardDataWithAllPlayerCardData:(NSArray *)allPlayerCardData;
-(void) processPlayerCutCardDataWithAllPlayerCutCardData:(NSArray *)allPlayerBetData;
-(void) processPlayerCallCardDataWithAllPlayerCallCardData:(NSArray *)allPlayerCallCardData;
-(void) processPlayerMatchResultWithData:(NSArray *)allPlayerMatchResult;
-(void) processQuickJoin;

@end

@implementation PDGameModel2
+(instancetype) initGameModelWithTarget:(id<PDGameModelDelegate>)target{
    return [[self alloc ]initGameModelInstanceWithTarget:target];
}

-(instancetype) initGameModelInstanceWithTarget:(id<PDGameModelDelegate>)target{
    if ((self = [super init])) {
        self.delegate = target;
        
        shareGame = [PDGameSingleton shareInstance];
        shareConnection = [PDShareConnection shareInstance];
        shareConnection.delegate = self;
        
        checkLatencyCount = 0;
        timeLimitIncorrectCount = 0;
        connectionTimeOutCount = 0;
        
        self.allPlayerInfo = [NSMutableArray array];
        self.allPlayerCardData = [NSMutableArray array];
        self.allPlayerBetData = [NSMutableArray array];
        self.allPlayerCutCardData = [NSMutableArray array];
        self.allPlayerCallCardData = [NSMutableArray array];
        self.allPlayerResultData = [NSMutableArray array];
        
        self.currentPlayerStatus = PlayerStatusNone;
        
        
        [self.allPlayerInfo removeAllObjects];
        for (int i = 0; i<kMaxPlayer; i++) {
            [self.allPlayerInfo addObject:[NSNull null]];
        }
        
        [self clearGameData];
        
        self.enterChairStatus = EnterChairStatusNone;
        self.currentServerState = ServerStateWaitingForStart;
        self.currentStateStatus = StateStatusWaitingForNextState;
        
        self.playHandAmount = 1;
        
        self.emptyChairNumberSet = [NSMutableSet set];
        self.aiChairNumberSet = [NSMutableSet set];
        
        self.isOnSkipAnimate = NO;
        
        switch (shareGame.joinRoomType) {
            case JoinRoomTypeServer:{
                DLog(@"JoinRoomTypeServer");
                // ไม่ต้อง enter chair เพราะ ผ่านการ enterchair ตั้งแต่ตอนสร้างห้องแล้ว
                self.currentPlayerStatus = PlayerStatusDealer;
                self.enterChairStatus = EnterChairStatusComplete;
                self.isHaveDealer = true;
                isFirstCheckRoomState = false;
                
                [shareConnection requestSetIsDealerWithUserId:shareGame.userId];
                [shareConnection requestStartRoomWithUserId:shareGame.userId];
            }
                break;
            case JoinRoomTypeNormalJoin:{
                DLog(@"JoinRoomTypeNormalJoin");
                isFirstCheckRoomState = true;
                self.isHaveDealer = YES;
                self.currentPlayerStatus = PlayerStatusObserver;
                self.currentObserverProcessState = ServerStateWaitingForStart;
            }
                break;
            case JoinRoomTypeQuickJoin:{
                DLog(@"JoinRoomTypeQuickJoin");
                isFirstCheckRoomState = true;
                self.isHaveDealer  = YES;
                self.currentPlayerStatus = PlayerStatusObserver;
                self.enterChairStatus = EnterChairStatusSearchingChair;
            }
                break;
            default:
                break;
        }
#ifdef IS_ONLINE
        [shareConnection requestCheckLatencyWithUserId:shareGame.userId startTime:@""];
#endif
    }
    return self;
}

#pragma mark - Clear Data
-(void) clearGameData{
    [self clearGetDataFlag];
    [self.allPlayerCardData removeAllObjects];
    [self.allPlayerBetData removeAllObjects];
    [self.allPlayerCutCardData removeAllObjects];
    [self.allPlayerCallCardData removeAllObjects];
    [self.allPlayerResultData removeAllObjects];
    
    for (int i = 0; i<kMaxPlayer; i++) {
        [self.allPlayerCardData addObject:[NSNull null]];
        [self.allPlayerBetData addObject:[NSNull null]];
        [self.allPlayerCutCardData addObject:[NSNull null]];
        [self.allPlayerCallCardData addObject:[NSNull null]];
        [self.allPlayerResultData addObject:[NSNull null]];
    }
    
    self.isHaveCardData = false;
    self.isHaveAllBetData = false;
    self.isHaveAllCallCardData = false;
    self.isHaveMatchResultData = false;
    

}
-(void) clearGetDataFlag{
    isGetCardData       = false;
    isGetBetData        = false;
    isGetCutCardData    = false;
    isGetCallCardData   = false;
    isGetMatchResult    = false;
    
}
-(void) clearConnectionErrorCount{
    timeLimitIncorrectCount = 0;
    connectionTimeOutCount = 0;
}

-(void) resetEmptyChairSet{
    [self.emptyChairNumberSet removeAllObjects];
    for (int i = 0; i<6; i++) {
        [self.emptyChairNumberSet addObject:[NSNumber numberWithInt:i]];
    }
}

#pragma mark - Action Active
-(void) startGame{
    [shareConnection requestStartPlayingWithUserId:shareGame.userId];
}
-(void) quitRoom{
    self.currentPlayerStatus = PlayerStatusNone;
    shareGame.joinRoomType = JoinRoomTypeNone;
    [shareConnection requestQuitRoomWithUserId:shareGame.userId];
}
-(void) enterChairNumber:(int)chairNumber{
    requestEnterChairNumber = chairNumber;
    self.enterChairStatus = EnterChairStatusSendingRequest;
    [shareConnection requestEnterChairWithUserId:shareGame.userId chairOrder:chairNumber];
}

-(void) requestQuitChair{
    self.currentPlayerStatus = PlayerStatusObserver;
    self.enterChairStatus = EnterChairStatusNone;
    [shareConnection requestStandUpFromChairWithUserId:shareGame.userId];
}

-(void) requestUpdatePlayerChip{
    isOnUpdatePlayerChip = true;
    [shareConnection requestGetPlayerProfileWithUserId:shareGame.userId];
}

#pragma mark - Dealer Request
-(void) requestDealer{
    if (self.isHaveDealer) {
        [shareConnection requestSetRequestDealerWithUserId:shareGame.userId];
    }else{
        [shareConnection requestSetIsDealerWithUserId:shareGame.userId];
    }
}

-(void) allowRequestDealer{
    //สลับสิทธิ์การเป็นเจ้ามือของผู้เล่น
    [shareConnection requestSetIsDealerWithUserId:currentRequestDealerUserId];
    [shareConnection requestClearRequestDealerWithUserId:shareGame.userId];
}
-(void) declineRequestDealer{
    [shareConnection requestClearRequestDealerWithUserId:shareGame.userId];
}
#pragma mark - AI Request

-(void) addAIToChair:(int)chairNumber{
    [shareConnection requestAddAiWithUserId:shareGame.userId chairOrder:chairNumber];
}
-(void) removeAIOnChair:(int)chairNumber{
    [self.aiChairNumberSet removeObject:[NSNumber numberWithInt:chairNumber]];
    [shareConnection requestRemoveAiWithUserId:shareGame.userId chairOrder:chairNumber];
}

#pragma mark - Get User Data
-(void) getUserDataWithUserId:(NSString *)userId{
    [shareConnection requestGetPlayerProfileWithUserId:userId];
}

#pragma mark - Set Data To Server
-(void) sendBetHand1:(NSInteger)hand1Bet hand2:(NSInteger)hand2Bet{
    [shareConnection requestSetBetWithUserId:shareGame.userId betHand1:hand1Bet betHand2:hand2Bet];
}
-(void) sendCutCard:(BOOL)cutCard{
    int sendValue = 0;
    if (cutCard) {
        sendValue = 1;
    }
    [shareConnection requestSetCutCardWithUserId:shareGame.userId cutCardNumber:sendValue];
}
-(void) sendCallCardHand1:(BOOL)hand1CallCard hand2:(BOOL)hand2CallCard{
    [shareConnection requestSetCallCardWithUserId:shareGame.userId callCardHand1:hand1CallCard callCardHand2:hand2CallCard];
}
#pragma mark - Request Get Data
-(void) requestGetAllBetData{
    if (!isGetBetData) {
        isGetBetData = true;
        [shareConnection requestGetAllBetWithUserId:shareGame.userId];
    }
}
-(void) requestGetAllCardData{
    if (!isGetCardData) {
        isGetCardData = true;
        [shareConnection requestGetCardDataWithUserId:shareGame.userId];
    }
}

-(void) requestGetAllCutCardData{
    if (!isGetCutCardData) {
        isGetCutCardData = true;
        [shareConnection requestGetAllCutCardWithUserId:shareGame.userId];
    }
}
-(void) requestGetAllCallcardData{
    if (!isGetCallCardData) {
        isGetCallCardData  = true;
        [shareConnection requestGetAllCallCardWithUserId:shareGame.userId];
    }
}

-(void) requestGetMatchResult{
    if(!isGetMatchResult){
        isGetMatchResult = true;
        [shareConnection requestGetMatchResultWithUserId:shareGame.userId];
    }
}

#pragma mark - Update
-(void) update:(float)delta{
//    DLog(@"self.currentServerState %i",self.currentServerState);
    switch (self.currentServerState) {
        case ServerStateWaitingForStart:{
            waitingForStartRoomRefreshTimeCount += delta;
            if (waitingForStartRoomRefreshTimeCount > kDefaultWaitingForRoomStartRefreshRate) {
                waitingForStartRoomRefreshTimeCount = 0.0f;
                [shareConnection requestGetRoomStateWithUserId:shareGame.userId];
                if (self.currentPlayerStatus == PlayerStatusDealer) {
                    [shareConnection requestGetRequestDealerWithUserId:shareGame.userId];
                    
                }
            }
        }
            break;
            
        default:
            break;
    }
    
    switch (self.currentStateStatus) {
        case StateStatusCountdownTimeLimit:{
            self.timeLimitCount += delta;
           
//            DLog(@"stateTimeCountDown %f",self.currentStateTimeLimit - self.timeLimitCount);
            if (self.timeLimitCount >= self.currentStateTimeLimit) {
                self.currentStateStatus = StateStatusActiveTimeLimitEndAction;
                [self activeTimeLimitEndActionWithServerState:self.currentServerState];
            }
        }
            break;
        case StateStatusCountDownForRefreshTimeLimit:{
            self.timeLimitCount += delta;
//            DLog(@"refreshTimeLimit In %f",self.currentStateTimeLimit - self.timeLimitCount);
            if (self.timeLimitCount >= self.currentStateTimeLimit) {
                self.currentStateStatus = StateStatusRequestGetTimeLimit;
                [shareConnection requestGetTimeLimitWithUserId:shareGame.userId];
            }
        }
            break;
            /*
        case StateStatusEnd:{
            self.timeLimitCount += delta;
            if (self.timeLimitCount < self.currentStateTimeLimit) {
                self.currentStateStatus = StateStatusCountdownTimeLimit;
            }
        }
            break;
             */
        default:
            
            break;
    }
}

#pragma mark - Convinient Function
-(int) getCardChair:(int)chairNumber hand:(int)hand cardOnHand:(int)cardOnHand{
    NSArray *playerCardArray = self.allPlayerCardData[chairNumber];
    if (![playerCardArray isEqual:[NSNull null]]) {
        int startHandIndex;
        if (hand == 0) {
            startHandIndex = 0;
        }else{
            startHandIndex = 5;
        }
//        DLog(@"startHandIndex %i cardOnHand %i",startHandIndex,cardOnHand);
        return [playerCardArray[startHandIndex+cardOnHand] intValue];
    }else{
        return 1;
    }
    
}

-(NSInteger) getBetChair:(int)chairNumber hand:(int)hand{
    NSArray *betData = self.allPlayerBetData[chairNumber];
    if (![betData isEqual:[NSNull null]]) {
        return [betData[hand] integerValue];
    }else{
        return 0;
    }
    
}

-(int) getCutCardChair:(int)chairNumber{
    NSNumber *cutCardNumber = self.allPlayerCutCardData[chairNumber];
    if (![cutCardNumber isEqual:[NSNull null]]) {
        return [cutCardNumber intValue];
    }else{
        return 0;
    }
}

-(int) getPlayHandNum:(int)chairNumber{
    //ถ้าจำนวน bet ในมือที่ 2 มีมากกว่า 0 แปลว่าเล่น 2 มื
    NSInteger hand2Bet = [self getBetChair:chairNumber hand:1];
    if (hand2Bet > 0) {
        return 2;
    }else{
        return 1;
    }
    return 1;
}

-(int) getCardPointChair:(int)chairNumber hand:(int)hand cardOnHandNumber:(int)cardOnHandNumber{
    //ขอคะแนนของไพ่ โดยกำหนดหมายเลขลำดับเก้าอี้ หมายเลขมือ และ จำนวนไพ่บนมือ
    int cardSumPoint = 0;
    for (int i = 0; i<cardOnHandNumber; i++) {
        
        int cardPoint = [PDHelperFunction getCardPointWithCardNum:[self getCardChair:chairNumber hand:hand cardOnHand:i]];
        cardSumPoint += cardPoint;
    }
    cardSumPoint %= 10;
    return cardSumPoint;
}

-(CardsRankType) getCardRankTypeChair:(int)chairNumber hand:(int)hand cardOnHandNumber:(int)cardOnHandNumber{
    NSArray *cardArray = self.allPlayerCardData [chairNumber];
    if (![cardArray isEqual:[NSNull null]]) {
        int startHandIndex;
        if (hand == 0) {
            startHandIndex = 2;
        }else if(hand == 1){
            startHandIndex = 7;
        }
        int getDataIndex = startHandIndex + cardOnHandNumber - 1;
        if (getDataIndex > cardArray.count) {
            getDataIndex = (int)cardArray.count - 1;
        }
        return [cardArray[getDataIndex]intValue];
    }else{
        return 1;
    }
    
}

-(BOOL) isAllGamblerPok{
    bool isAllGamblerPok = TRUE;
    for (int i = 0; i<kMaxPlayer; i++) {
        if (![[self.allPlayerInfo objectAtIndex:i] isEqual:[NSNull null]] && i != self.dealerChairNum) {
            int handCount = [self getPlayHandNum:i];
            for (int j = 0; j<handCount; j++) {
                CardsRankType cardRank = [self getCardRankTypeChair:i hand:j cardOnHandNumber:2];
                if (cardRank == CardsRankTypePok) {
                    isAllGamblerPok &= YES;
                }else{
                    isAllGamblerPok &= NO;
                }
            }
        }
    }
    return isAllGamblerPok;
}

-(BOOL) isDealerPok{
    CardsRankType cardRank = [self getCardRankTypeChair:self.currentChairNumber hand:0 cardOnHandNumber:2];
    if (cardRank == CardsRankTypePok) {
        return YES;
    }else{
        return NO;
    }
}

-(BOOL) getIsCallChair:(int)chairNumber hand:(int)hand{
    NSArray *isCallArray = self.allPlayerCallCardData[chairNumber];
    return [isCallArray[hand] boolValue];
}

-(NSInteger) getResultChair:(int)chairNumber hand:(int)hand{
    NSArray *resultArray = self.allPlayerResultData[chairNumber];
    return [resultArray[hand] integerValue];
}

-(ResultType) getResultTypeChair:(int)chairNumber hand:(int)hand{
    NSInteger result = [self getResultChair:chairNumber hand:hand];
    if (result > 0) {
        return ResultTypeWin;
    }else if(result == 0){
        return  ResultTypeDraw;
    }else{
        return ResultTypeLose;
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
    int startHandIndex;
    if (hand == 0) {
        startHandIndex = 2;
    }else{
        startHandIndex = 5;
    }
    NSArray *playerCardArray = self.allPlayerCardData[chairNumber];
    
    return [playerCardArray[startHandIndex+cardAmount-1] intValue];
}



#pragma mark - State

-(void) processGetRoomStateWithState:(ServerState)state{
    DLog(@"clientState %i serverState %i",self.currentServerState , state);
    if (state != self.currentServerState) {
        DLog(@"state is change");
        switch (state) {
            case ServerStateWaitingForStart:{
                if(self.currentServerState != ServerStateWaitingForStart){
                    DLog(@"ServerStateWaitingForStart");
                    [self clearGameData];
                    self.currentServerState = ServerStateWaitingForStart;
                    [self.delegate serverChangeStateCallback:ServerStateWaitingForStart];
                }
            }
                break;
            case ServerStateStart:{
                if(self.currentServerState != ServerStateStart){
                    DLog(@"ServerStateStart");
                    // Callback กลับไปยัง playScene เพื่อให้รู้ว่าเริ่มเกมแล้ว
                    [self.delegate serverChangeStateCallback:ServerStateStart];
                }
            }
                break;
            case ServerStateSetBet:{
                DLog(@"ServerStateSetBet");
                //Callback For SetBet
                [self.delegate serverChangeStateCallback:ServerStateSetBet];
            }
                break;
            case ServerStateSetCutCard:{
                DLog(@"ServerStateSetCutCard");
//             [self.delegate serverChangeStateCallback:GameStateSetCutCard];
                
            }
                break;
            case ServerStateSetCallCard:{
                DLog(@"ServerStateSetCallCard");
                [self.delegate serverChangeStateCallback:GameStateSetCallCard];
                
            }
                break;
            case ServerStateGetResult:{
                DLog(@"ServerStateGetResult");
                [self requestGetMatchResult];
            }
                break;
            case ServerStatePrepareForNewGame:{
                DLog(@"ServerStatePrepareForNewGame");
                
                
            }
                
            default:
                break;
        }
        self.currentStateStatus = StateStatusRequestGetTimeLimit;
        [shareConnection requestGetTimeLimitWithUserId:shareGame.userId];
    }else{
        DLog(@"same state");
        switch (state) {
            case ServerStateWaitingForStart:{
                DLog(@"ServerStateWaitingForStart");
                [self clearGetDataFlag];
                [self clearConnectionErrorCount];
                self.currentStateStatus = StateStatusWaitingForNextState;
                
            }
                break;
            case ServerStateStart:{
                self.currentStateStatus = StateStatusRequestGetTimeLimit;
                [shareConnection requestGetTimeLimitWithUserId:shareGame.userId];
            }
                break;
            case ServerStateSetBet:{
                self.currentStateStatus = StateStatusRequestGetTimeLimit;
                [shareConnection requestGetTimeLimitWithUserId:shareGame.userId];
            }
                break;
            case ServerStateSetCutCard:{
                self.currentStateStatus = StateStatusRequestGetTimeLimit;
                [shareConnection requestGetTimeLimitWithUserId:shareGame.userId];
                
            }
                break;
            case ServerStateSetCallCard:{
                self.currentStateStatus = StateStatusRequestGetTimeLimit;
                [shareConnection requestGetTimeLimitWithUserId:shareGame.userId];
            }
                break;
            case ServerStateGetResult:{
                self.currentStateStatus = StateStatusRequestGetTimeLimit;
                [shareConnection requestGetTimeLimitWithUserId:shareGame.userId];
            }
                break;
            case ServerStatePrepareForNewGame:{
                self.currentStateStatus = StateStatusWaitingForNextState;
            }
                break;
            default:
                break;
        }
    }
}

/*For Process*/
-(void) processObserverGetRoomStateWithState:(ServerState)state{
    DLog(@"processObserverGetRoomStateWithState %i",state)
    
    switch (state) {
        case ServerStateWaitingForStart:{
            if (self.currentServerState != ServerStateWaitingForStart) {
                [self clearGameData];
                self.isOnSkipAnimate = FALSE;
                self.currentServerState = ServerStateWaitingForStart;
                [self.delegate serverChangeStateCallback:ServerStateWaitingForStart];
            }
        }
            break;
        case ServerStateStart:{
            if (self.currentServerState != ServerStateStart) {
                self.currentServerState = ServerStateStart;
                self.currentStateStatus = StateStatusRequestGetTimeLimit;
                [shareConnection requestGetTimeLimitWithUserId:shareGame.userId];
                
                
            }
        }
            break;
        case ServerStateSetBet:{
            if (self.currentServerState != ServerStateSetBet) {
                self.currentServerState = ServerStateSetBet;
                self.currentStateStatus = StateStatusRequestGetTimeLimit;
                [shareConnection requestGetTimeLimitWithUserId:shareGame.userId];
                [self requestGetAllCardData];
            }
        }
            break;
        case ServerStateSetCutCard:{
            if (self.currentServerState != ServerStateSetCutCard) {
                self.currentServerState = ServerStateSetCutCard;
                self.currentStateStatus = StateStatusRequestGetTimeLimit;
                [shareConnection requestGetTimeLimitWithUserId:shareGame.userId];
                [self requestGetAllCardData];
            }
        }
            break;
        case ServerStateSetCallCard:{
            if (self.currentServerState != ServerStateSetCallCard) {
                self.currentServerState = ServerStateSetCallCard;
                self.currentStateStatus = StateStatusRequestGetTimeLimit;
                [shareConnection requestGetTimeLimitWithUserId:shareGame.userId];
//                [self requestGetAllCallcardData];
                [self requestGetAllCardData];
            }
        }
            break;
        case ServerStateGetResult:{
            if (self.currentServerState != ServerStateGetResult) {
                self.currentServerState = ServerStateGetResult;
                self.currentStateStatus = StateStatusRequestGetTimeLimit;
                [shareConnection requestGetTimeLimitWithUserId:shareGame.userId];
                [self requestGetAllBetData];
                [self requestGetAllCardData];
                [self requestGetAllCallcardData];
                [self requestGetMatchResult];

            }
        }
            break;
        case ServerStatePrepareForNewGame:{
            self.currentStateStatus = StateStatusWaitingForNextState;
        }
            break;
        default:
            break;
    }
}

-(void) activeTimeLimitEndActionWithServerState:(ServerState)serverState{
    switch (serverState) {
        case ServerStateStart:{
            //Call back to scene for init set bet menu
            [shareConnection requestGetRoomStateWithUserId:shareGame.userId];
        }
            break;
        case ServerStateSetBet:{
            //หมดเวลา setbet
            [shareConnection requestGetAllBetWithUserId:shareGame.userId];
            self.currentStateStatus = StateStatusEnd;
            
            [shareConnection requestGetCardDataWithUserId:shareGame.userId];
            [shareConnection requestGetRoomStateWithUserId:shareGame.userId];
        }
            break;
        case ServerStateSetCutCard:{
            [shareConnection requestGetAllCutCardWithUserId:shareGame.userId];
            self.currentStateStatus = StateStatusEnd;
            
            [shareConnection requestGetRoomStateWithUserId:shareGame.userId];
        }
            break;
        case ServerStateSetCallCard:{
            [shareConnection requestGetAllCallCardWithUserId:shareGame.userId];
            [shareConnection requestGetRoomStateWithUserId:shareGame.userId];
        }
            break;
        case ServerStateGetResult:{
            DLog(@"End ServerStateGetResult");
            
            [shareConnection requestGetRoomStateWithUserId:shareGame.userId];
        }
            break;
        case ServerStatePrepareForNewGame:{
            DLog(@"End Game");
            [shareConnection requestGetRoomStateWithUserId:shareGame.userId];
        }
            break;
        default:
            break;
    }
    
}

-(void) processTimeLimitWithState:(ServerState)getState timeLimit:(float)timeLimit{
    /*Check Connection Timeout*/
    if (timeLimit < 0) {
        
        timeLimitIncorrectCount ++;
        if (timeLimitIncorrectCount >= kDefaultRoomAlreadyInActive) {
#pragma mark Room Not Active
            [self.delegate roomNotActiveCallbackWithDetailString:@"This room is already close."];
        }
        timeLimit = kDefaultRefreshGetTimeLimitRate;
    }
    
    
    switch (self.currentStateStatus) {
        case StateStatusRequestGetTimeLimit:{
            DLog(@"self.currentServerState %i : tempState %i",self.currentServerState,getState);
            
            if (self.currentServerState != getState) {
                DLog(@"Get Time Limit State Change");
                timeLimitIncorrectCount = 0;
                self.currentStateStatus = StateStatusCountdownTimeLimit;
                if (getState == ServerStateWaitingForStart) {
                    [self.delegate serverChangeStateCallback:ServerStateWaitingForStart];
                }else{
                    [self processGetRoomStateWithState:getState];
                }
            }else{
                if (timeLimit < kDefaultRefreshGetTimeLimitRate) {
                    self.currentStateStatus = StateStatusCountDownForRefreshTimeLimit;
                }else{
                    self.currentStateStatus = StateStatusCountdownTimeLimit;
                }
            }
            
            if (self.currentServerState != getState) {
                switch (self.currentPlayerStatus) {
                    case PlayerStatusDealer:
                        self.currentServerState = getState;
                        break;
                    case PlayerStatusPlayer:{
                        self.currentServerState = getState;
                    }
                        break;
                    case PlayerStatusObserver:{
                        [self processObserverGetRoomStateWithState:getState];
                    }
                        break;
                        
                    default:
                        break;
                }
            }
            self.currentStateTimeLimit = timeLimit;
            self.timeLimitCount = 0.0f;
        }
            break;
        case StateStatusCountdownTimeLimit:{
            
        }
            break;
        default:
            break;
    }
    
    
}

#pragma mark - Process Data
-(void) processPlayerInfoDataWithAllPlayerData:(NSArray *)allPlayerData{
    [self.allPlayerInfo removeAllObjects];
    for (int i = 0; i<kMaxPlayer; i++) {
        [self.emptyChairNumberSet addObject:[NSNumber numberWithInt:i]];
        [self.allPlayerInfo addObject:[NSNull null]];
    }
    BOOL tempIsHaveDealer = NO;
    bool isAlsoHaveData = false;   //เช็คว่ายังมีข้อมูลของผู้เล่นอยู่ในห้องหรือไม่
    
    for (NSDictionary *dict in allPlayerData) {
        int chair = [[dict objectForKey:@"chair_order"]intValue];
        NSString *userId = [dict objectForKey:@"user_id"];
        NSString *username;
        NSString *displayName;
        NSString *pic;
        bool isDealer;

        if ([userId intValue] != 0) {
            username = [dict objectForKey:@"username"];
            displayName = [dict objectForKey:@"displayname"];
            pic = [dict objectForKey:@"pic"];
            isDealer = [[dict objectForKey:@"is_dealer"]boolValue];
            if ([shareGame.userId isEqualToString:userId]) {
                self.currentChairNumber = chair;
                isAlsoHaveData = true;
            }
        }else{
            //AI
            username = @"AI";
            displayName = @"";
            isDealer = false;
            pic = @"";
        }

        if (isDealer) {
            self.isHaveDealer = YES;
            self.dealerChairNum = chair;
            
            if ([userId isEqualToString:shareGame.userId]) {
                //ถ้าid ของข้อมูลที่เป็นเจ้ามือ ตรงกับ id ของผู้เล่น ให้กำหนดสถานะเจ้ามือ
                if (self.currentPlayerStatus == PlayerStatusDealer) {
                }else if (self.currentPlayerStatus == PlayerStatusPlayer){
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
        tempIsHaveDealer |= isDealer;
        
        NSArray *playerData = @[userId,username,displayName,pic,[NSNumber numberWithBool:isDealer]];
        [self.allPlayerInfo setObject:playerData atIndexedSubscript:chair];
        
        if ([userId isEqualToString:@"0"]) {
            [self.aiChairNumberSet addObject:[NSNumber numberWithInteger:chair]];
        }
        [self.emptyChairNumberSet removeObject:[NSNumber numberWithInteger:chair]];
    }
    
    self.isHaveDealer = tempIsHaveDealer;
    
    if (!self.isHaveAllPlayerInfoData) {
        self.isHaveAllPlayerInfoData = true;
    }
    DLog(@"isAlsoHaveData %i",isAlsoHaveData);
    
    if (isAlsoHaveData == false) {
        if (self.currentPlayerStatus == PlayerStatusDealer || self.currentPlayerStatus == PlayerStatusPlayer) {
            if (self.enterChairStatus != EnterChairStatusWaitingForNextGame) {
                self.currentPlayerStatus = PlayerStatusObserver;
                [self.delegate connectionTimeOutCallbackWithDetailString:@"Connection Timeout"];
            }
        }
    }
    
    if (self.isWaitingForUpdateObserverData) {
        self.isWaitingForUpdateObserverData = false;
        [self.delegate observerModeLoadDataCompleteCallbackWithDataType:GetDataTypeRoomState];
    }
}


-(void) processPlayerBetDataWithAllPlayerBetData:(NSArray *)allPlayerBetData{
    
    for (NSDictionary *dict in allPlayerBetData) {
        int chair = [[dict objectForKey:@"chair_order"]intValue];
        NSArray *betData = @[[dict objectForKey:@"bet_1"],
                             [dict objectForKey:@"bet_2"]];
        [self.allPlayerBetData setObject:betData atIndexedSubscript:chair];
    }
    self.isHaveAllBetData = true;
    
    DLog(@"self.allPlayerBetData %@",self.allPlayerBetData);
}
-(void) processPlayerCardDataWithAllPlayerCardData:(NSArray *)allPlayerCardData{
    
    for (NSDictionary *dict in allPlayerCardData) {
        int chair = [[dict objectForKey:@"chair_order"]intValue];
        NSArray *cardData = @[[dict objectForKey:@"hand1_card1"],
                             [dict objectForKey:@"hand1_card2"],
                             [dict objectForKey:@"hand1_card3"],
                             
                             [dict objectForKey:@"hand1_rank1"],
                             [dict objectForKey:@"hand1_rank2"],
                             
                             [dict objectForKey:@"hand2_card1"],
                             [dict objectForKey:@"hand2_card2"],
                             [dict objectForKey:@"hand2_card3"],
                             
                             [dict objectForKey:@"hand2_rank1"],
                             [dict objectForKey:@"hand2_rank2"],
                             ];
        [self.allPlayerCardData setObject:cardData atIndexedSubscript:chair];
    }
    self.isHaveCardData = true;
//    DLog(@"self.allPlayerCardData %@",self.allPlayerCardData);
}

-(void) processPlayerCutCardDataWithAllPlayerCutCardData:(NSArray *)allPlayerBetData{
    for (NSDictionary *dict in allPlayerBetData) {
        int chair = [[dict objectForKey:@"chair_order"]intValue];
        [self.allPlayerCutCardData setObject:[dict objectForKey:@"cut_cards"] atIndexedSubscript:chair];
    }
//    DLog(@"self.allPlayerCutCardData %@",self.allPlayerCutCardData);
}

-(void) processPlayerCallCardDataWithAllPlayerCallCardData:(NSArray *)allPlayerCallCardData{
 
    for (NSDictionary *dict in allPlayerCallCardData) {
        int chair = [[dict objectForKey:@"chair_order"]intValue];
        NSArray *isCallArray = @[[dict objectForKey:@"is_call_1"],
                                 [dict objectForKey:@"is_call_2"]];
        [self.allPlayerCallCardData setObject:isCallArray atIndexedSubscript:chair];
    }
    self.isHaveAllCallCardData = true;
//    DLog(@"self.allPlayerCallCardData %@",self.allPlayerCallCardData);
}
-(void) processPlayerMatchResultWithData:(NSArray *)allPlayerMatchResult{

    for (NSDictionary *dict in allPlayerMatchResult){
        int chair = [[dict objectForKey:@"chair_order"]intValue];
        NSArray *resultArray = @[[dict objectForKey:@"result_1"]
                                  ,[dict objectForKey:@"result_2"]];
        [self.allPlayerResultData setObject:resultArray atIndexedSubscript:chair];
    }
    self.isHaveMatchResultData = true;
//    DLog(@"self.allPlayerResultData %@",self.allPlayerResultData );
}

-(void) processQuickJoin{
    NSMutableArray *emptyChairIndex = [NSMutableArray array];
    for (int i = 0; i<self.allPlayerInfo.count; i++) {
        if ([self.allPlayerInfo[i] isEqual:[NSNull null]]) {
            [emptyChairIndex addObject:[NSNumber numberWithInt:i]];
        }
    }
    
    if (emptyChairIndex.count > 0) {
        int randomIndex = arc4random()%emptyChairIndex.count;
        int randomEnterChairIndex = [emptyChairIndex[randomIndex] intValue];
        [shareConnection requestEnterChairWithUserId:shareGame.userId chairOrder:randomEnterChairIndex];
        self.enterChairStatus = EnterChairStatusSendingRequest;
    }else{
        
        DLog(@"This room is full");
    }
}
#pragma mark - PDShareConnectionDelegate
-(void) requestCompleteWithRequestType:(RequestConnectionType)requestType data:(NSDictionary *)data{
    switch (requestType) {
        case RequestConnectionTypeCheckLatency:{
            checkLatencyCount ++;
            DLog(@"checkLatencyCount %i",checkLatencyCount);
            if (checkLatencyCount < 2) {
                NSString *startTime = [[data objectForKey:@"data"]objectForKey:@"start_time"];
                [shareConnection requestCheckLatencyWithUserId:shareGame.userId startTime:startTime];
                [shareConnection requestGetBetLimitationWithUserId:shareGame.userId];
            }else{
                [shareConnection requestGetRoomStateWithUserId:shareGame.userId];
            }
        }
            break;
        case RequestConnectionTypeEnterChair:{
            switch (shareGame.joinRoomType) {
                case JoinRoomTypeServer:
                    self.currentPlayerStatus = PlayerStatusDealer;
                    [shareConnection requestSetIsDealerWithUserId:shareGame.userId];
                    break;
                    
                case JoinRoomTypeNormalJoin:
                case JoinRoomTypeQuickJoin:{
                    
                    self.currentPlayerStatus = PlayerStatusPlayer;
                }
                    break;
                default:
                    break;
            }
            if (self.currentServerState != ServerStateWaitingForStart) {
                self.enterChairStatus = EnterChairStatusWaitingForNextGame;
            }else{
                self.enterChairStatus = EnterChairStatusComplete;
            }
            self.currentChairNumber = requestEnterChairNumber;
            [self.delegate actionCompleteCallbackWithActionType:CallbackActionTypeEnterChairComplete data:nil];

        }
            break;
        case RequestConnectionTypeQuitRoom:{
            shareConnection.delegate = nil;
            [self.delegate actionCompleteCallbackWithActionType:CallbackActionTypeQuitRoom data:nil];
        }
            break;
        case RequestConnectionTypeStandUpFromChair:{
            self.currentPlayerStatus = PlayerStatusObserver;
            self.enterChairStatus = EnterChairStatusNone;
            shareGame.joinRoomType = JoinRoomTypeNormalJoin;
            
            [self.delegate actionCompleteCallbackWithActionType:CallbackActionTypeQuitChairComplete data:nil];
            [shareConnection requestGetRoomStateWithUserId:shareGame.userId];
        }
            break;
#pragma mark Get RoomState
        case RequestConnectionTypeGetRoomState:{
            //ใช้สำหรับดู state ห้อง และ ข้อมูลของผู้เล่นในห้อง และ จะมีการเปลี่ยน state จากการ getRoomState แค่ตอนที่ state เปลี่ยนจาก 0 -> 1 เท่านั้น
            NSDictionary *roomStateData = [data objectForKey:@"data"];
            ServerState getServerState = [[roomStateData objectForKey:@"state"]intValue];
            
            NSArray *playerInfo = [NSArray arrayWithArray:[roomStateData objectForKey:@"user_info"]];
            [self processPlayerInfoDataWithAllPlayerData:playerInfo];
            
            if (self.enterChairStatus == EnterChairStatusWaitingForNextGame) {
                self.enterChairStatus = EnterChairStatusComplete;
            }
            
            switch (self.currentPlayerStatus) {
                case PlayerStatusDealer:{
                    [self processGetRoomStateWithState:getServerState];
                    [self.delegate actionCompleteCallbackWithActionType:CallbackActionTypeUpdatePlayerOnChairData data:nil];
                }
                    break;
                case PlayerStatusPlayer:{
                    [self processGetRoomStateWithState:getServerState];
                    [self.delegate actionCompleteCallbackWithActionType:CallbackActionTypeUpdatePlayerOnChairData data:nil];
                    
                }
                    break;
                case PlayerStatusObserver:{
                    [self processObserverGetRoomStateWithState:getServerState];
                    DLog(@"RequestConnectionTypeGetRoomState PlayerStatusObserver");
                    //Process Room State
                    if (self.enterChairStatus == EnterChairStatusSearchingChair && self.currentPlayerStatus == PlayerStatusObserver) {
                        DLog(@"self.enterChairStatus == EnterChairStatusSearchingChair && self.currentPlayerStatus == PlayerStatusObserver");
                        [self processQuickJoin];
                    }else{
                        DLog(@"else self.enterChairStatus == EnterChairStatusSearchingChair && self.currentPlayerStatus == PlayerStatusObserver");
                        if (isFirstCheckRoomState) {
                            isFirstCheckRoomState = false;
                            int serverStateDelta = getServerState - self.currentServerState;
                            DLog(@"serverStateDelta %i",serverStateDelta);
                            if (serverStateDelta > 1) {
                                observerModeLastServerState = getServerState;
                                self.isWaitingForUpdateObserverData = true;
                                self.currentObserverProcessState = ServerStateStart;
                                self.isOnSkipAnimate  = YES;
                                [self processGetRoomStateWithState:getServerState];
                                
                            }else{
                                [self processGetRoomStateWithState:getServerState];
                                [self.delegate actionCompleteCallbackWithActionType:CallbackActionTypeUpdatePlayerOnChairData data:nil];
                            }
                        }
                        
                        
                        switch (self.enterChairStatus) {
                            case EnterChairStatusComplete:{
                                self.currentPlayerStatus = PlayerStatusPlayer;
                                [self processGetRoomStateWithState:getServerState];
                                [self.delegate actionCompleteCallbackWithActionType:CallbackActionTypeUpdatePlayerOnChairData data:nil];
                            }
                                break;
                            case EnterChairStatusWaitingForNextGame:{
                                
                            }
                                break;
                            case EnterChairStatusNone:{
                                [self processGetRoomStateWithState:getServerState];
                                [self.delegate actionCompleteCallbackWithActionType:CallbackActionTypeUpdatePlayerOnChairData data:nil];
                            }
                                break;
                            default:
                                break;
                        }
                    }
                    
                }
                    break;
                default:
                    break;
            }
        }
            break;
#pragma mark Get Time Limit
        case RequestConnectionTypeGetTimeLimit:{
            //ใช้สำหรับตรวจค่า state และ เวลาที่จะหมด state เมื่อเวลาหมด จะทำการขอ timelimit ใหม่ แต่ถ้าขอมาแล้ว state ยังเป็นค่าเดิม แปลว่า state ยังไม่เปลี่ยน
            NSDictionary *timeLimitData = [data objectForKey:@"data"];
            float tempTime = [[timeLimitData objectForKey:@"time_limit"]floatValue];
            DLog(@"tempTime %f",tempTime);
            ServerState tempState = [[timeLimitData objectForKey:@"state"]intValue];
            [self processTimeLimitWithState:tempState timeLimit:tempTime];
            DLog(@"RequestConnectionTypeGetTimeLimit %@",data);
        }
            break;
        case RequestConnectionTypeGetBetLimitation:{
            NSDictionary *betDataDict = [data objectForKey:@"data"];
            _roomMaxBet = [[betDataDict objectForKey:@"max_bet"]integerValue];
            _roomMinBet = [[betDataDict objectForKey:@"min_bet"]integerValue];
            
            DLog(@"roomMaxBet %li : roomMinBet %li",(long)self.roomMaxBet,(long)self.roomMinBet);
        }
            break;
        case RequestConnectionTypeStartPlaying:{

        }
            break;
#pragma mark Callback Request about Get Player Profile
        case RequestConnectionTypeGetPlayerProfile:{
            if ([self.delegate respondsToSelector:@selector(actionCompleteCallbackWithActionType:data:)]) {
                NSDictionary *playerProfile = [[data objectForKey:@"data"]objectAtIndex:0];
                [self.delegate actionCompleteCallbackWithActionType:CallbackActionTypeGetPlayerInfo data:playerProfile];
                
                if (isOnUpdatePlayerChip) {
                    NSString *profileId = [playerProfile objectForKey:@"user_id"];
                    if ([shareGame.userId isEqualToString:profileId]) {
                        shareGame.chip = [[playerProfile objectForKey:@"chips"]integerValue];
                        [self.delegate actionCompleteCallbackWithActionType:CallbackActionTypeUpdatePlayerChip data:nil];
                        isOnUpdatePlayerChip = FALSE;
                    }
                }
            }
        }
            break;
#pragma mark Callback Request about Get Game Data
        case RequestConnectionTypeGetCardData:{
            NSDictionary *getAllCardData = [data objectForKey:@"data"];
            DLog(@"getAllCardData %@",getAllCardData);
            NSArray *cardData = [NSArray arrayWithArray:[getAllCardData objectForKey:@"cards_info"]];
            [self processPlayerCardDataWithAllPlayerCardData:cardData];
            
            if (self.isOnSkipAnimate) {
                [self.delegate observerModeLoadDataCompleteCallbackWithDataType:GetDataTypeAllCardData];
            }
        }
            break;
        case RequestConnectionTypeGetAllBet:{
            NSDictionary *getAllBetData = [data objectForKey:@"data"];
            DLog(@"getAllBetData %@",getAllBetData);
            NSArray *betData = [NSArray arrayWithArray:[getAllBetData objectForKey:@"bet_info"]];
            [self processPlayerBetDataWithAllPlayerBetData:betData];
            
            if (self.isOnSkipAnimate) {
                [self.delegate observerModeLoadDataCompleteCallbackWithDataType:GetDataTypeAllBet];
            }else{
                [self.delegate getDataCompleteWithDataType:GetDataTypeAllBet];
            }
        }
            break;
        case RequestConnectionTypeGetAllCutCard:{
            NSDictionary *getAllCutCardData = [data objectForKey:@"data"];
            DLog(@"getAllCutCardData %@",getAllCutCardData);
            NSArray *cutCardData = [NSArray arrayWithArray:[getAllCutCardData objectForKey:@"cut_cards_info"]];
            [self processPlayerCutCardDataWithAllPlayerCutCardData:cutCardData];
            
            if (self.isOnSkipAnimate) {
                [self.delegate observerModeLoadDataCompleteCallbackWithDataType:GetDataTypeAllCutCard];
            }else{
                [self.delegate getDataCompleteWithDataType:GetDataTypeAllCutCard];
            }
            
        }
            break;
        case RequestConnectionTypeGetAllCallCard:{
            NSDictionary *getAllCallCard = [data objectForKey:@"data"];
            DLog(@"getAllCallCard %@",getAllCallCard);
            NSArray *callCardData = [getAllCallCard objectForKey:@"is_call_info"];
            [self processPlayerCallCardDataWithAllPlayerCallCardData:callCardData];
            
            if (self.isOnSkipAnimate) {
                [self.delegate observerModeLoadDataCompleteCallbackWithDataType:GetDataTypeAllCallThirdCard];
            }else{
                [self.delegate getDataCompleteWithDataType:GetDataTypeAllCallThirdCard];
            }
        }
            break;
        case RequestConnectionTypeGetMatchResult:{
            NSDictionary *getAllMatchResult = [data objectForKey:@"data"];
            DLog(@"getAllMatchResult %@",getAllMatchResult);
            NSArray *matchResult = [NSArray arrayWithArray:[getAllMatchResult objectForKey:@"results_info"]];
            [self processPlayerMatchResultWithData:matchResult];
            
            if (self.isOnSkipAnimate) {
                [self.delegate observerModeLoadDataCompleteCallbackWithDataType:GetDataTypeAllResult];
            }else{
                [self.delegate getDataCompleteWithDataType:GetDataTypeAllResult];
            }
        }
            break;
#pragma mark AI
        case RequestConnectionTypeAddAi:{

        }
            break;
        case RequestConnectionTypeRemoveAi:{
            
        }
            break;
#pragma mark Dealer Request
        case RequestConnectionTypeSetIsDealer:{
            if ([self.delegate respondsToSelector:@selector(actionCompleteCallbackWithActionType:data:)]) {
                [self.delegate actionCompleteCallbackWithActionType:RequestConnectionTypeSetIsDealer data:nil];
            }
        }
            break;
        case RequestConnectionTypeSetRequestDealer:{
            //ส่งคำขอสำหรับเป็น Dealer เรียบร้อย
        }
            break;
        case RequestConnectionTypeGetRequestDealer:{
            NSDictionary *getRequestData = [data objectForKey:@"data"];
            NSArray *requestDealerInfo = [getRequestData objectForKey:@"request_dealer_info"];
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
        case RequestConnectionTypeClearRequestDealer:{
            
        }
            break;
        default:
            break;
    }
}

-(void) requestFailWithConnectionError:(RequestConnectionType)requestType errorString:(NSString *)errorString{
    switch (requestType) {
        case RequestConnectionTypeEnterChair:{
            self.enterChairStatus = EnterChairStatusNone;
            [self.delegate actionFailureCallbackWithActionType:CallbackActionTypeEnterChairComplete failureString:errorString];
        }
            break;
        default:
            break;
    }
}

-(void) requestFailWithRequestType:(RequestConnectionType)requestType error:(NSError *)error{
    if (requestType != RequestConnectionTypeStartRoom) {
        if (error.code == NSURLErrorTimedOut || error.code == NSURLErrorNetworkConnectionLost || error.code == NSURLErrorSecureConnectionFailed) {
            connectionTimeOutCount += 1;
            if (connectionTimeOutCount >= kDefaultConnectionTimeOutAmountCheck) {
                if ([self.delegate respondsToSelector:@selector(connectionTimeOutCallbackWithDetailString:)]) {
                    [self.delegate connectionTimeOutCallbackWithDetailString:error.localizedDescription];
                }
            }
        }
    }
    
    
    switch (requestType) {
        case RequestConnectionTypeGetRoomState:{
            [shareConnection requestGetRoomStateWithUserId:shareGame.userId];
        }
            break;
        case RequestConnectionTypeGetTimeLimit:{
            [shareConnection requestGetTimeLimitWithUserId:shareGame.userId];
        }
            break;
            
        default:
            break;
    }
}

@end
