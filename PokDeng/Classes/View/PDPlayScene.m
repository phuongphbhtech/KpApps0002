//
//  PDPlayScreen.m
//  PokDeng
//
//  Created by Sarunporn Pisutwimol on 5/14/2557 BE.
//  Copyright 2557 Sarunporn Pisutwimol. All rights reserved.
//

#define DEFAULT_COUNTDOWN_TIME_INTERVAL             1.0f

#define kMaxPlayer                                  6

typedef enum {
    zOrderBackground = 0,
    zOrderPlayHandDetail,       //กรอบแสดงข้อมูลไพ่ด้านล่าง
    zOrderChair,
    zOrderTable,
    zOrderChipBetting,
    zOrderDeck,
    zOrderCard,
    zOrderChipSending,
    zOrderAvatar,
    zOrderEffect,
    zOrderMenu,
    zOrderPopUp,
}zOrder;

typedef enum {
    DecisionTypeNone = 1,
    DecisionTypeSetHand,
    DecisionTypeSetBet,
    DecisionTypeCutCard,
    DecisionTypeCallCard,
    
}DecisionType;

#import "PDPlayScene.h"
@interface PDPlayScene (){
    BOOL isPlayerInfoPopUpOn;
    DeckNode *deckNode;
    
    int currentActiveHand;
    NSInteger currentBet;
    
    NSInteger placeBet[2];
    bool isCutCard;
    bool isCallCard[2];
    
    //PopUpCheck
    bool isRequestDealerPopUpOn;
    bool isOnSendRequestDealer;
    bool isPreparingPopUpOn;
    bool isOnRequestPlayerInfo;   //เช็คว่า อยู่ระหว่างขอข้อมูลผู้เล่นคนอื่นหรือไม่
    bool isSetHandComplete;
    //Countdown timer
    float countDownTick;
    NSTimer *countdownTimer;
    
    DecisionType currentDecision;
    
    bool isDealerPressStartGame;
    bool isDealerPok;
    
    bool isAnimateShuffleCard;
    bool isAnimateCutCard;
    

    bool isHaveAllPlayerDisplay;
    bool isDrawBet;
    bool isHandOutCard;
    bool isHandOutThirdCard;
    bool isShowResult;
    //สำหรับเช็คว่าอยู่ในช่วง อัพเดทข้อมูล chip ของผู้เล่นหรือไม่
    BOOL isOnUpdatePlayerChip;
    
    int timeOutCount;
 
    PDLoadingNode *loadingNode;
    
    BOOL isComeToSceneFirstTime;
}

@property (nonatomic,retain) NSMutableArray *chairSpriteArray;
@property (nonatomic , retain) NSMutableArray *aiButtonArray;
@property (nonatomic , retain) NSMutableArray *allUserDisplayUIArray;
@property (nonatomic , retain) NSMutableArray *allSitButtonArray;

@property (nonatomic , retain) NSMutableArray *allRemoveObjectArray;        //เก็บ node ของ object ที่ต้องการ Remove หลังจบเกมแต่ละรอบ

@property (nonatomic , retain) NSMutableDictionary *allHandDisplayCardSlot;
@property (nonatomic , retain) NSMutableDictionary *allPlayerCardDataDict; //เก็บข้อมูลไพ่ในมือของผู้เล่นแต่ละคน
@property (nonatomic , retain) NSMutableDictionary *allPlayerChipDataDict;  //เก็บข้อมูล chip ของผู้เล่นแต่ละคน


@property (nonatomic , retain) NSMutableArray *currentChairOrderIndex;      //ลำดับการประมวลผลเก้าอี้

-(id) initSceneFromLobbySceneType:(PDLobbySceneType)sceneType;

-(void) loadSpritesheet;
-(void) removeSpriteSheet;

-(void) runSceneActionState:(SceneActionState)actionState;


-(void) initBackground;
-(void) initPlayerChipDisplay;
-(void) initQuitButtonToLobbySceneType:(PDLobbySceneType)sceneType;
-(void) initQuitChairButton;

-(void) setQuitButtonEnable:(BOOL)enable;
-(void) setQuitChairButtonEnable:(BOOL)enable;

-(void) initStartGameButton;
-(void) removeStartGameButton;
//LoadingNode
-(void) initLoadingNode;
-(void) removeLoadingNode;

// Preparing
-(void) initPreparing;
-(void) removePreparing;

// Observer Mode
-(void) initObserverModeWindow;
-(void) removeObserverModeWindow;




// AI Manage
-(void) initAIButton;
-(void) removeAIButton;

-(void) initAddAIButtonToChair:(int)chairNumber;
-(void) removeAddAIButtonOnChair:(int)chairNumber;

-(void) initRemoveAIButtonToChair:(int)chairNumber;
-(void) removeRemoveAIButtonOnChair:(int)chairNumber;

// Sit Button
-(void) initSitButton;
-(void) removeSitButton;
-(void) initSitButtonToChair:(int)chairNumber;

// Player Display
-(void) drawPlayerDisplay;
-(void) setPlayerInfoButtonEnable:(BOOL)enable;
//Hand
-(void) initSetHandMenu;
-(void) removeSetHandMenu;
-(void) pressSetHandButton:(id)sender;
-(void) initPlayerHandDetail;
-(void) removePlayerHandDetail;
-(void) setPlayerhandDetailEnable:(BOOL)enable;
-(void) setDealerHandDetail;
-(void) setEnableSecondHandEnable:(BOOL)enable;

//Bet
-(void) initWaitingSetBetPopUp;
-(void) removeWaitingSetBetPopUp;

-(void) initSetBetMenu;
-(void) removeSetBetMenu;
-(void) drawPlayerBet;
-(void) moveBetFromChair:(int)senderChair hand:(int)senderHand handAmount:(int)senderHandAmount toChair:(int)receiverChair hand:(int)receiverHand handAmount:(int)receiverHandAmount;

//Cut Card
-(void) initWaitingSetCutCardPopUp;
-(void) removeWaitingSetCutCardPopUp;

-(void) initCutCardMenu;
-(void) removeCutCardMenu;

//Call Card
-(void) initCallCardMenu;
-(void) removeCallCardMenu;
-(void) pressCallCardMenuButton:(id) sender;

// Handout Card
-(void) handOutCard;
-(void) handOutCardWithNoAnimate;
-(void) handOutThirdCard;
-(void) handOutThirdCardWithNoAnimate;

// Open Card
-(void) openPokCard;
-(void) openCardChair:(int)chairNumber handNumber:(int)handNumber;

// CardEffect
-(void) showCardEffectWithChairNumber:(int)chairNumber handNumber:(int)handNumber handAmount:(int)handAmount cardEffectType:(CardEffectNodeType)cardEffectType;

// Game Result 
-(void) showResult;

// Countdown decision timer
-(void) initCountDownWithTime:(float)time withPosition:(CGPoint)pos;
-(void) updateCountDown;

// PopUp
-(void) initAlertPopUpWithString:(NSString *)alertString popUpName:(NSString *)popUpName;
-(void) initPlayerProfilePopUpWithData:(NSDictionary *)playerData;

// Start Play
-(void) setStartButtonEnable:(BOOL)enable;

//Request Dealer
-(BOOL) canRequestDealer;
-(void) initRequestDealerButton;
-(void) removeRequestDealerButton;
-(void) initGetRequestDealerPopUpWithRequestData:(NSDictionary *)requestData;
-(void) removeGetRequestDealerPopUp;

-(void) pressQuitButton:(id)sender;
-(void) pressQuitChairButton:(id)sender;

// Process
-(void) processCurrentChairOrderData;

-(int) getChairIndexDisplay:(int)chairNumber;
-(CGPoint) getChairPos:(int) chairNumber;
-(CGPoint) getChipDefaultPosWithChairNumber:(int)chairNumber handNumber:(int)handNumber allHandAmount:(int)allHandAmount; //chairNumber 0-5 , handNumber 0-1 , allHandAmount  1-2

-(CGPoint) getCardOriginPosWithChairNumber:(int)chairNumber handNumber:(int)handNumber cardOnHandIndex:(int)cardOnHandIndex allHandAmount:(int)allHandAmount; //chairNumber 0-5 , handNumber 0-1 , cardOnHandIndex 0-2 , allHandAmount  1-2

// Clear Data
-(void) resetValueToDefault;
-(void) clearTable;
-(void) removeChildWithName:(NSString *)childName;

-(void) goToLobbySceneWithLobbySceneType:(PDLobbySceneType)sceneType;


@end

@implementation PDPlayScene

+(CCScene *)scene{
    return [[self alloc]initSceneFromLobbySceneType:PDLobbySceneTypePlay];
}
+(CCScene *)sceneFromLobbySceneType:(PDLobbySceneType)sceneType{
    return [[self alloc]initSceneFromLobbySceneType:sceneType];
}
-(id) initSceneFromLobbySceneType:(PDLobbySceneType)sceneType{
    if ((self = [super init])) {
        self.userInteractionEnabled = YES;
        gameModel = [PDGameModel2 initGameModelWithTarget:self];
        shareGame = [PDGameSingleton shareInstance];
        
        comeFromLobbySceneType = sceneType;
        
        self.allUserDisplayUIArray = [NSMutableArray array];
        self.allSitButtonArray = [NSMutableArray array];
        self.allRemoveObjectArray = [NSMutableArray array];
        self.allPlayerCardDataDict = [NSMutableDictionary dictionary];
        self.allPlayerChipDataDict = [NSMutableDictionary dictionary];
        self.allHandDisplayCardSlot = [NSMutableDictionary dictionary];
        
        self.currentChairOrderIndex = [NSMutableArray array];
        
        isSetHandComplete = false;
        
        isPlayerInfoPopUpOn = FALSE;
        
        currentActiveHand = 1;
        
        
        // Set Decision Default value
        [self resetValueToDefault];
        
        [self loadSpritesheet];
        [self initBackground];
        [self initPlayerChipDisplay];
        [self initQuitButtonToLobbySceneType:sceneType];
        [self initQuitChairButton];
        [self setQuitChairButtonEnable:NO];
        [self initPreparing];
        
        currentActionState = SceneActionStateWaitingForStart;
        switch (gameModel.currentPlayerStatus) {
            case PlayerStatusDealer:{
                [self initPlayerHandDetail];
                [self setEnableSecondHandEnable:NO];
                [self setQuitChairButtonEnable:YES];
            }
                break;
            case PlayerStatusPlayer:{
                
            }
                break;
            case PlayerStatusObserver:{
                isComeToSceneFirstTime = YES;
            }
                break;
            default:
                break;
        }
    }
    return self;
}


-(void) loadSpritesheet{
    [[CCTextureCache sharedTextureCache]addImage:@"playSceneBG.jpg"];
    [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:@"PlaySceneSpritesheet.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:@"CardSet02ShuffleSpritesheet.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:@"CardSet02Spritesheet.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:@"PlayerProfileSceneSpritesheet.plist"];
}
-(void) removeSpriteSheet{
    [[CCTextureCache sharedTextureCache]removeUnusedTextures];
    [[CCSpriteFrameCache sharedSpriteFrameCache]removeSpriteFramesFromFile:@"PlaySceneSpritesheet.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache]removeSpriteFramesFromFile:@"CardSet02ShuffleSpritesheet.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache]removeSpriteFramesFromFile:@"CardSet02Spritesheet.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache]removeSpriteFramesFromFile:@"PlayerProfileSceneSpritesheet.plist"];
}

#pragma mark - Action State
-(void) runSceneActionState:(SceneActionState)actionState{
    switch (actionState) {
        case SceneActionStateNone:{
        }
            break;
        case SceneActionStateWaitingForStart:{
            if (currentActionState != SceneActionStateWaitingForStart) {
                currentActionState = SceneActionStateWaitingForStart;
                DLog(@"runSceneActionState SceneActionStateWaitingForStart");
            }
        }
            break;
        case SceneActionStateSetBet:{
            if (currentActionState != SceneActionStateSetBet) {
                currentActionState = SceneActionStateSetBet;
                [self removeLoadingNode];
                switch (gameModel.currentPlayerStatus) {
                    case PlayerStatusDealer:{
                        [self initWaitingSetBetPopUp];
                    }
                        break;
                    case PlayerStatusPlayer:{
                        [self setEnableSecondHandEnable:NO];
                        currentDecision = DecisionTypeSetBet;
                        currentActiveHand = 1;
                        [self initSetBetMenu];
                    }
                        break;
                    case PlayerStatusObserver:{
                        
                    }
                        break;
                    default:
                        break;
                }
            }
        }
            break;
        case SceneActionStateDrawBet:{
            if (currentActionState != SceneActionStateDrawBet) {
                
                currentActionState = SceneActionStateDrawBet;
                [self drawPlayerBet];
                if (!gameModel.isOnSkipAnimate) {
                    [self runSceneActionState:SceneActionStateShuffleCard];
                }else{
                    
                }
            }
        }
            break;
        case SceneActionStateShuffleCard:{
            [self removeLoadingNode];
            if (currentActionState != SceneActionStateShuffleCard) {
                currentActionState = SceneActionStateShuffleCard;
                
                [self removeWaitingSetBetPopUp];
                [self removeSetBetMenu];
                [self removeTimer];
                
                switch (gameModel.currentPlayerStatus) {
                    case PlayerStatusDealer:{
                        if (!isAnimateShuffleCard) {
                            [deckNode runAnimationShuffle];
                            isAnimateShuffleCard = true;
                        }
                    }
                        break;
                    case PlayerStatusPlayer:{
                        if (!isAnimateShuffleCard) {
                            [deckNode runAnimationShuffle];
                            isAnimateShuffleCard = true;
                        }
                    }
                        break;
                    case PlayerStatusObserver:{
                        if (!isAnimateShuffleCard && !gameModel.isOnSkipAnimate) {
                            if (!gameModel.isOnSkipAnimate) {
                                [deckNode runAnimationShuffle];
                                isAnimateShuffleCard = true;
                            }else{
                                isAnimateShuffleCard = true;
                            }
                        }
                    }
                        break;
                        
                    default:
                        break;
                }
                
            }
        }
            break;
        case SceneActionStateSetCutCard:{
            if (currentActionState != SceneActionStateSetCutCard) {
                currentActionState = SceneActionStateSetCutCard;
                [self removeLoadingNode];
                switch (gameModel.currentPlayerStatus) {
                    case PlayerStatusDealer:{
                        currentDecision = DecisionTypeCutCard;
                        [self initWaitingSetCutCardPopUp];
                    }
                        break;
                    case PlayerStatusPlayer:{
                        currentDecision = DecisionTypeCutCard;
                        [self initCutCardMenu];
                    }
                        break;
                    case PlayerStatusObserver:{
                        
                    }
                        break;
                    default:
                        break;
                }
            }
        }
            break;
        case SceneActionStateCutCard:{
            if (currentActionState != SceneActionStateCutCard) {
                currentActionState = SceneActionStateCutCard;
                switch (gameModel.currentPlayerStatus) {
                    case PlayerStatusDealer:
                        if (!isAnimateCutCard) {
                            [deckNode stopAllActions];
                            [deckNode runAnimationCutTheCardWithCardNumber:10];
                            isAnimateCutCard = true;
                        }
                        break;
                    case PlayerStatusPlayer:{
                        if (!isAnimateCutCard) {
                            [deckNode stopAllActions];
                            [deckNode runAnimationCutTheCardWithCardNumber:10];
                            isAnimateCutCard = true;
                        }
                    }
                        break;
                    case PlayerStatusObserver:{
                        if (!isAnimateCutCard) {
                            if (!gameModel.isOnSkipAnimate) {
                                [deckNode stopAllActions];
                                [deckNode runAnimationCutTheCardWithCardNumber:10];
                                isAnimateCutCard = true;
                            }else{
                                isAnimateCutCard = true;
                            }
                        }
                    }
                        break;
                    default:
                        break;
                }
                
            }
        }
            break;
        case SceneActionStateHandOutCard:{
            if (currentActionState != SceneActionStateHandOutCard) {
                [self removeLoadingNode];
                currentActionState = SceneActionStateHandOutCard;
                
                [self handOutCard];
            }
        }
            break;
        case SceneActionStateShowPok:{
            DLog(@"SceneActionStateShowPok");
            if (currentActionState != SceneActionStateShowPok) {
                currentActionState = SceneActionStateShowPok;
                [self initLoadingNode];
                [self openPokCard];
                if (!gameModel.isOnSkipAnimate) {
                    CCActionDelay *actionDelay = [CCActionDelay actionWithDuration:1.0f];
                    CCActionCallBlock *callNextState = [CCActionCallBlock actionWithBlock:^(void){
                        [self runSceneActionState:SceneActionStateSetCallCard];

                    }];
                    CCActionSequence *seq = [CCActionSequence actions:actionDelay,callNextState, nil];
                    [self runAction:seq];
                }else{
                    DLog(@"gameModel.isOnSkipAnimate == true");
                    [self runSceneActionState:SceneActionStateSetCallCard];
                }
            }
        }
            break;
        case SceneActionStateSetCallCard:{
            if (currentActionState != SceneActionStateSetCallCard) {
                currentActionState = SceneActionStateSetCallCard;
                
                if (gameModel.isAllGamblerPok || isDealerPok) {
                    [gameModel sendCallCardHand1:NO hand2:NO];
                    [self initLoadingNode];
                }else{
                    [self removeLoadingNode];
                    switch (gameModel.currentPlayerStatus) {
                        case PlayerStatusDealer:{
                            currentDecision = DecisionTypeCallCard;
                            currentActiveHand = 1;
                            [self initCallCardMenu];
                        }
                            break;
                        case PlayerStatusPlayer:{
                            currentDecision = DecisionTypeCallCard;
                            currentActiveHand = 1;
                            [self initCallCardMenu];
                        }
                            break;
                        case PlayerStatusObserver:{
                            
                        }
                            break;
                        default:
                            break;
                    }
                }
            }
        }
            break;
        case SceneActionStateHandOutThirdCard:{
            if (currentActionState != SceneActionStateHandOutThirdCard) {
                currentActionState = SceneActionStateHandOutThirdCard;
                if (currentActionState != SceneActionStateWaitingForStart) {
                    if (!(gameModel.isAllGamblerPok || isDealerPok)) {
                        [self handOutThirdCard];
                    }
                }
            }
        }
            break;
        case SceneActionStateCheckResult:{
            if (currentActionState != SceneActionStateCheckResult) {
                currentActionState = SceneActionStateCheckResult;
                
            }
        }
            break;
        case SceneActionStateClearTable:{
            DLog(@"SceneActionStateClearTable");
            if (currentActionState != SceneActionStateClearTable) {
                currentActionState = SceneActionStateClearTable;
                [self clearTable];
                [self initLoadingNode];
                switch (gameModel.currentPlayerStatus) {
                    case PlayerStatusDealer:{
                        isDealerPressStartGame = NO;
                    }
                        break;
                    case PlayerStatusPlayer:{
                        
                    }
                        break;
                    case PlayerStatusObserver:{
                        
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

#pragma mark - UI
-(void) initBackground{
    //Bg
    CCSprite *background = [CCSprite spriteWithImageNamed:@"playSceneBG.jpg"];
    background.position = ccp(WINS.width*0.5f, WINS.height*0.5f);
    [self addChild:background z:zOrderBackground name:@"background"];
    
    if ([PDHelperFunction getScreenHeight]>960) {
        CCSprite *borderTop = [CCSprite spriteWithImageNamed:@"iphone5border.png"];
        borderTop.position = ccp(WINS.width*0.5f,background.contentSize.height-borderTop.contentSize.height*0.5f);
        [self addChild:borderTop z:zOrderBackground];
        
        CCSprite *borderBottom = [CCSprite spriteWithImageNamed:@"iphone5border.png"];
        borderBottom.flipY = YES;
        borderBottom.position = ccp(WINS.width*0.5f,borderBottom.contentSize.height*0.5f);
        [self addChild:borderBottom z:zOrderBackground];
    }
    
    //Table
    CCSprite *table = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"bg_table.png"]];
    table.position = ccp(WINS.width*0.5f, WINS.height*0.5f);
    [self addChild:table z:zOrderTable];
    
    //Chair
    CGPoint chairPos[6];
    chairPos[0] = ccp(WINS.width*0.5f, WINS.height*0.5f-table.contentSize.height*0.58f);    //Bottom Chair
    chairPos[1] = ccp(WINS.width*0.5f+table.contentSize.width*0.64f, WINS.height*0.5f-table.contentSize.height*0.22f);    //Right Bottom Chair
    chairPos[2] = ccp(WINS.width*0.5f+table.contentSize.width*0.64f, WINS.height*0.5f+table.contentSize.height*0.22f);    //Right Top Chair
    chairPos[3] = ccp(WINS.width*0.5f, WINS.height*0.5f+table.contentSize.height*0.6f);    //Top Chair
    chairPos[4] = ccp(WINS.width*0.5f-table.contentSize.width*0.64f, WINS.height*0.5f+table.contentSize.height*0.22f);    //Left Top Chair
    chairPos[5] = ccp(WINS.width*0.5f-table.contentSize.width*0.64f, WINS.height*0.5f-table.contentSize.height*0.22f);    //Left Bottom Chair
    
    float chairRotate[6];
    chairRotate[0] = 0;
    chairRotate[1] = -90;
    chairRotate[2] = -90;
    chairRotate[3] = -180;
    chairRotate[4] = 90;
    chairRotate[5] = 90;
    
    self.chairSpriteArray = [NSMutableArray array];
    for (int i = 0; i<6; i++) {
        CCSprite *chair = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"bg_chair.png"]];
        chair.position = chairPos[i];
        chair.rotation = chairRotate[i];
        [self addChild:chair z:zOrderChair name:[NSString stringWithFormat:@"chair%i",i]];
        [self.chairSpriteArray addObject:chair];
    }
    
    
    //Deck
    deckNode = [DeckNode initDeckWithTarget:self];
    deckNode.position = ccp(WINS.width*0.5f,WINS.height*0.5f);
    deckNode.scale = 0.5f;
    [self addChild:deckNode z:zOrderDeck];
    
}
-(void) initPlayerChipDisplay{
    CCSprite *background = (CCSprite *)[self getChildByName:@"background" recursively:NO];
    CCSprite *chipBg = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"bg_chips.png"]];
    chipBg.position = ccp(WINS.width-chipBg.contentSize.width*0.5f,WINS.height*0.5f+background.contentSize.height*0.38);
    [self addChild:chipBg z:zOrderMenu];
    
    CCLabelTTF *playerChipLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"$%@",[PDHelperFunction getChipStringWithChip:shareGame.chip]] fontName:FONT_TRAJANPRO_BOLD fontSize:16];
    playerChipLabel.color = [CCColor colorWithCcColor3b:FONT_COLOR];
    playerChipLabel.anchorPoint = ccp(1.0f, 0.5f);
    playerChipLabel.position = ccp(WINS.width*0.95f, WINS.height*0.5f+background.contentSize.height*0.389f);
    [self addChild:playerChipLabel z:zOrderMenu name:@"playerChipLabel"];
}

-(void) initQuitButtonToLobbySceneType:(PDLobbySceneType)sceneType{
    CCSprite *background = (CCSprite *)[self getChildByName:@"background" recursively:NO];
    
    CCButton *quitButton = [CCButton buttonWithTitle:nil
                                        spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_leave02_lobby.png"]
                             highlightedSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_leave02_lobbyC.png"]
                                disabledSpriteFrame:nil];
    quitButton.position = ccp(quitButton.contentSize.width*0.55f,WINS.height*0.5f+background.contentSize.height*0.389f);
//    quitButton.position = ccp(quitButton.contentSize.width*0.55f,WINS.width*0.5f+background.contentSize.height*0.389f);
    [self addChild:quitButton z:zOrderMenu name:@"quitButton"];
    [quitButton setTarget:self selector:@selector(pressQuitButton:)];
}

-(void) initQuitChairButton{
    CCSprite *background = (CCSprite *)[self getChildByName:@"background" recursively:NO];
    CCButton *quitChairButton = [CCButton buttonWithTitle:nil
                                         spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_leave01_stand.png"]
                              highlightedSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_leave01_standC.png"]
                                 disabledSpriteFrame:nil];
    quitChairButton.position = ccp(quitChairButton.contentSize.width*0.55f,WINS.height*0.5f+background.contentSize.height*0.34f);
    //    quitButton.position = ccp(quitButton.contentSize.width*0.55f,WINS.width*0.5f+background.contentSize.height*0.389f);
    [self addChild:quitChairButton z:zOrderMenu name:@"quitChairButton"];
    [quitChairButton setTarget:self selector:@selector(pressQuitChairButton:)];
}

-(void) setQuitButtonEnable:(BOOL)enable{
    CCButton *quitButton = (CCButton *)[self getChildByName:@"quitButton" recursively:NO];
    quitButton.enabled = enable;
    quitButton.visible = enable;
}


-(void) setQuitChairButtonEnable:(BOOL)enable{
    CCButton *quitChairButton = (CCButton *)[self getChildByName:@"quitChairButton" recursively:NO];
    quitChairButton.enabled = enable;
    quitChairButton.visible = enable;
}

-(void) initStartGameButton{
    [self removeStartGameButton];
    CCButton *startGameButton = [CCButton buttonWithTitle:nil
                                              spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_start.png"]
                                   highlightedSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_startC.png"]
                                      disabledSpriteFrame:nil];
    startGameButton.position = ccp(WINS.width*0.5f, WINS.height*0.5f);
    [self addChild:startGameButton z:zOrderMenu name:@"startGameButton"];
    [startGameButton setBlock:^(id sender) {
        [self initLoadingNode];
        isDealerPressStartGame = YES;
        [self setQuitButtonEnable:NO];
        [self setQuitChairButtonEnable:NO];
        
        [self removeAIButton];
        [self removeStartGameButton];

        [gameModel startGame];
    }];
}

-(void) removeStartGameButton{
    [self removeChildWithName:@"startGameButton"];
}

#pragma mark - LoadingNode
-(void) initLoadingNode{
    DLog(@"PDPlayScene loadingNode");
    [self removeLoadingNode];
    
    if (loadingNode == nil) {
        CCSprite *background = (CCSprite *)[self getChildByName:@"background" recursively:NO];
        loadingNode = [PDLoadingNode initLoadingNode];
        loadingNode.position = ccp(WINS.width*0.5f, WINS.height*0.5f-background.contentSize.height*0.1f);
        [self addChild:loadingNode z:zOrderPopUp];
    }
}
-(void) removeLoadingNode{
    [loadingNode stopAllActions];
    [loadingNode removeFromParentAndCleanup:YES];
    loadingNode = nil;
    /*
    if (loadingNode) {
        [loadingNode removeFromParentAndCleanup:YES];
    }
     */
}

#pragma mark - Preparing
-(void) initPreparing{
    CCNodeColor *nodeColor = [CCNodeColor nodeWithColor:[CCColor colorWithCcColor4b:ccc4(100, 100, 100, 100)]];
    nodeColor.contentSize = CGSizeMake(WINS.width, WINS.height);

    [self addChild:nodeColor z:zOrderPopUp name:@"nodeColor"];
    
    CCSprite *preparingBG = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"bg_popup.png"]];
    preparingBG.position = ccp(WINS.width*0.5f, WINS.height*0.5f);
    [self addChild:preparingBG z:zOrderPopUp name:@"preparingBG"];
    
    CCLabelTTF *preparingLabel = [CCLabelTTF labelWithString:@"Preparing" fontName:FONT_TRAJANPRO_BOLD fontSize:20];
    preparingLabel.position = ccp(WINS.width*0.5f, WINS.height*0.5f);
    [self addChild:preparingLabel z:zOrderPopUp name:@"preparingLabel"];
}
-(void) removePreparing{
    [self removeChildWithName:@"nodeColor"];
    [self removeChildWithName:@"preparingBG"];
    [self removeChildWithName:@"preparingLabel"];
}


#pragma mark - Observer Mode
-(void) initObserverModeWindow{
    [self removePreparing];
    [self removeObserverModeWindow];
    
    CCLabelTTF *observerModeLabel = [CCLabelTTF labelWithString:@"Observing" fontName:FONT_TRAJANPRO_BOLD fontSize:20];
    observerModeLabel.position = ccp(WINS.width*0.5f, WINS.height*0.5f);
    observerModeLabel.color = [CCColor colorWithCcColor3b:FONT_COLOR];
    [self addChild:observerModeLabel z:zOrderPopUp name:@"observermodeLabel"];
    
}
-(void) removeObserverModeWindow{
    [self removeChildWithName:@"observermodeLabel"];
}

#pragma mark - Ai Menu Manage
-(void) initAIButton{
    [self removeAIButton];
    
    // Add Ai Button
    if (gameModel.isHaveAllPlayerInfoData) {
        for (int chair = 0; chair<kMaxPlayer; chair++) {
            if (self.currentChairOrderIndex.count > chair) {
                int dataIndex = [self.currentChairOrderIndex[chair] intValue];
                
                NSArray *playerInfo = gameModel.allPlayerInfo[dataIndex];
                //        DLog(@"playerInfo %@",playerInfo);
                if (![playerInfo isEqual:[NSNull null]]) {
                    //ถ้า userId == 0 ถือว่าเป็น AI
                    if ([playerInfo[0] isEqualToString:@"0"]) {
                        [self initRemoveAIButtonToChair:chair];
                    }
                }else{
                    [self initAddAIButtonToChair:chair];
                }
            }
        }
    }
    
}

-(void) removeAIButton{
    if (!self.aiButtonArray) {
        self.aiButtonArray = [NSMutableArray array];
    }else{
        for (CCButton *button in self.aiButtonArray) {
            [self removeChild:button cleanup:YES];
        }
        [self.aiButtonArray removeAllObjects];
    }
}

-(void) initAddAIButtonToChair:(int)chairNumber{
//    int chairIndexForShow = [self getChairIndexDisplay:chairNumber];
    
    CCSprite *chair = (CCSprite *)[self.chairSpriteArray objectAtIndex:chairNumber ];
    if (gameModel.isHaveAllPlayerInfoData) {
        if (self.currentChairOrderIndex.count > chairNumber) {
            int dataIndex = [self.currentChairOrderIndex[chairNumber] intValue];
            
            CCButton *addAiButton = (CCButton *)[self getChildByName:[NSString stringWithFormat:@"addAIButton%i",chairNumber] recursively:NO];
            if (!addAiButton) {
                addAiButton = [CCButton buttonWithTitle:nil
                                            spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_aiAdd.png"]
                                 highlightedSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_aiAddC.png"]
                                    disabledSpriteFrame:nil];
                
                addAiButton.position = ccp(chair.position.x,chair.position.y);
                [self addChild:addAiButton z:zOrderMenu name:[NSString stringWithFormat:@"addAIButton%i",chairNumber]];
                [self.aiButtonArray addObject:addAiButton];
                
                [addAiButton setBlock:^(id sender) {
                    
                    [gameModel addAIToChair:dataIndex];
                    [self removeAddAIButtonOnChair:chairNumber];
                }];
            }
        }
    }
}

-(void) removeAddAIButtonOnChair:(int)chairNumber{
    CCButton *button = (CCButton *)[self getChildByName:[NSString stringWithFormat:@"addAIButton%i",chairNumber] recursively:NO];
    [self.aiButtonArray removeObject:button];
    [self removeChild:button cleanup:YES];
}

-(void) initRemoveAIButtonToChair:(int)chairNumber{
    if (self.currentChairOrderIndex.count > chairNumber) {
        int dataIndex = [self.currentChairOrderIndex[chairNumber] intValue];
        //    int chairIndexForShow = [self getChairIndexDisplay:chairNumber];
        CCSprite *chair = (CCSprite *)[self.chairSpriteArray objectAtIndex:chairNumber];
        
        CCButton *removeAiButton = (CCButton *)[self getChildByName:[NSString stringWithFormat:@"removeAIButton%i",chairNumber] recursively:NO];
        
        if (!removeAiButton) {
            removeAiButton = [CCButton buttonWithTitle:nil
                                           spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_aiRomove.png"]
                                highlightedSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_aiRomoveC.png"]
                                   disabledSpriteFrame:nil];
            
            removeAiButton.position = ccp(chair.position.x,chair.position.y);
            [self addChild:removeAiButton z:zOrderMenu name:[NSString stringWithFormat:@"removeAIButton%i",chairNumber]];
            [self.aiButtonArray addObject:removeAiButton];
            
            [removeAiButton setBlock:^(id sender) {
                DLog(@"removeAi on Chair %i",chairNumber);
                [gameModel removeAIOnChair:dataIndex];
                [self removeRemoveAIButtonOnChair:chairNumber];
            }];
        }
    }
}
-(void) removeRemoveAIButtonOnChair:(int)chairNumber{
    CCButton *button = (CCButton *)[self getChildByName:[NSString stringWithFormat:@"removeAIButton%i",chairNumber] recursively:NO];
    [self.aiButtonArray removeObject:button];
    [self removeChild:button cleanup:YES];
}


#pragma mark - Sit Button
-(void) initSitButton{
    //วาดปุ่มนั่ง สำหรับผู้เล่นที่มีสถานะเป็น observer
    if (gameModel.isHaveAllPlayerInfoData) {
        for (int chair = 0; chair<kMaxPlayer; chair++) {
            if (self.currentChairOrderIndex.count > chair) {
                int dataIndex = [self.currentChairOrderIndex[chair] intValue];
                
                NSArray *playerInfo = gameModel.allPlayerInfo[dataIndex];
                //        DLog(@"playerInfo %@",playerInfo);
                if ([playerInfo isEqual:[NSNull null]]) {
                    [self initSitButtonToChair:chair];
                }
            }
        }
    }
}
-(void) removeSitButton{
    for (CCButton *sitButton in self.allSitButtonArray) {
        [self removeChild:sitButton cleanup:YES];
    }
    [self.allSitButtonArray removeAllObjects];
}

-(void) initSitButtonToChair:(int)chairNumber{
    CCSprite *chair = (CCSprite *)[self.chairSpriteArray objectAtIndex:chairNumber ];
    if (self.currentChairOrderIndex.count > chairNumber) {
        int dataIndex = [self.currentChairOrderIndex[chairNumber] intValue];
        
        CCButton *sitButton = (CCButton *) [self getChildByName:[NSString stringWithFormat:@"sitButton%i",chairNumber] recursively:NO];
        if (!sitButton) {
            sitButton = [CCButton buttonWithTitle:nil
                                      spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_sit.png"]
                           highlightedSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_sitC.png"]
                              disabledSpriteFrame:nil];
            
            sitButton.position = ccp(chair.position.x,chair.position.y);
            [self addChild:sitButton z:zOrderMenu name:[NSString stringWithFormat:@"sitButton%i",chairNumber]];
            [self.allSitButtonArray addObject:sitButton];
            
            [sitButton setBlock:^(id sender) {
                //        gameModel.shareGame.isDealer = FALSE;
                [gameModel enterChairNumber:dataIndex];
                [self removeSitButton];
            }];
        }
    }
}
#pragma mark - Draw Player Display
-(void) drawPlayerDisplay{
    //remove ของเดิม
    for (CCNode *node in self.allUserDisplayUIArray) {
        [self removeChild:node cleanup:YES];
    }
    [self.allUserDisplayUIArray removeAllObjects];
    
    if (gameModel.isHaveAllPlayerInfoData) {
        for (int i = 0; i<kMaxPlayer; i++) {
            int chairOrder = [self.currentChairOrderIndex[i] intValue];
            
            NSArray *playerInfo = [gameModel.allPlayerInfo objectAtIndex:chairOrder];
            if (![playerInfo isEqual:[NSNull null]]) {
                NSString *pic = playerInfo[3];
                NSString *displayName = playerInfo[2];
                NSString *userId = playerInfo[0];
                bool isDealer = [playerInfo[4] boolValue];
                
                CCSprite *displaySprite;
                if (pic) {
                    displaySprite = [PDHelperFunction GetSpriteWithURL:pic];
                }
                
                if (displaySprite == nil) {
                    pic = @"basic04.png";
                    displaySprite = [PDHelperFunction GetSpriteWithURL:pic];
                }
                
                CCSprite *chairSprite = (CCSprite *)self.chairSpriteArray[i];
                [self addChild:displaySprite z:zOrderAvatar];
                
                CCButton *avatarFrame;
                if (isDealer) {
                    avatarFrame = [CCButton buttonWithTitle:nil spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"frame_dealer.png"]];
                }else{
                    avatarFrame = [CCButton buttonWithTitle:nil spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"frame_player.png"]];
                }
                avatarFrame.position = ccp(chairSprite.position.x, chairSprite.position.y);
                [self addChild:avatarFrame z:zOrderAvatar ];
                
                
                [avatarFrame setBlock:^(id sender){
                    if (![userId isEqualToString:@"0"]) {
                        //ถ้า เป็น 0 หมายถึง AI
                        isOnRequestPlayerInfo = YES;
                        [gameModel getUserDataWithUserId:userId];
                        [self setPlayerInfoButtonEnable:NO];
                    }
                    
                }];
                
                //ปรับให้ภาพ display อยู่ในกรอบ
                //ขนาดขอบในของกรอบ = 130x157
                //            CGSize frameSize = CGSizeMake(130, 157);
                if ([PDHelperFunction getIsGameDisplayPic:pic]) {
                    displaySprite.scale = 0.9f;
                }else{
                    displaySprite.scale = 0.6f;
                }
                if (displayName == nil) {
                    displayName = @"";
                }
                
                
                displaySprite.position = ccp(chairSprite.position.x, avatarFrame.position.y+avatarFrame.contentSize.height*0.05f);
                
                CCLabelTTF *displayNameLabel = [CCLabelTTF labelWithString:displayName fontName:FONT_COOPER_BLACK fontSize:8];
                displayNameLabel.horizontalAlignment = CCTextAlignmentCenter;
                [displayNameLabel setDimensions:CGSizeMake(avatarFrame.contentSize.width*0.9f, avatarFrame.contentSize.height*0.1f)];
                displayNameLabel.position = ccp(chairSprite.position.x, chairSprite.position.y-avatarFrame.contentSize.height*0.35f);
                [self addChild:displayNameLabel z:zOrderAvatar];
                
                [self.allUserDisplayUIArray addObjectsFromArray:@[displaySprite,avatarFrame,displayNameLabel]];
            }
        }
    }
}

-(void) setPlayerInfoButtonEnable:(BOOL)enable{
    for (CCButton *button in self.allUserDisplayUIArray) {
        if ([button isKindOfClass:[CCButton class]]) {
            button.enabled = enable;
        }
    }
}


#pragma mark - Hand Amount Setting

-(void) initSetHandMenu{
    [self removeSetHandMenu];
    
    CCSprite *popUpBackground = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"bg_popup.png"] ];
    popUpBackground.position = ccp(WINS.width*0.5f, WINS.height*0.5f);
    [self addChild:popUpBackground z:zOrderMenu name:@"popUpBackground"];
    
    CCLabelTTF *selectHandLabel = [CCLabelTTF labelWithString:@"Select number of play hand." fontName:FONT_TRAJANPRO_BOLD fontSize:14];
    selectHandLabel.color = [CCColor colorWithCcColor3b:FONT_COLOR];
    selectHandLabel.position = ccp(WINS.width*0.5f,WINS.height*0.5f+popUpBackground.contentSize.height*0.1f);
    [self addChild:selectHandLabel z:zOrderMenu name:@"selectHandLabel"];
    
    CCButton *oneHandButton = [CCButton buttonWithTitle:nil
                                            spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_hand01.png"]
                                 highlightedSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_hand01C.png"]
                                    disabledSpriteFrame:nil];
    CCButton *twoHandButton = [CCButton buttonWithTitle:nil
                                            spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_hand02.png"]
                                 highlightedSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_hand02C.png"]
                                    disabledSpriteFrame:nil];
    
    oneHandButton.position = ccp(WINS.width*0.5f-oneHandButton.contentSize.width*0.6f, WINS.height*0.5f - popUpBackground.contentSize.height*0.1f);
    twoHandButton.position = ccp(WINS.width*0.5f+oneHandButton.contentSize.width*0.6f, WINS.height*0.5f - popUpBackground.contentSize.height*0.1f);
    
    [self addChild:oneHandButton z:zOrderMenu name:@"oneHandButton"];
    [self addChild:twoHandButton z:zOrderMenu name:@"twoHandButton"];
    
    [oneHandButton setTarget:self selector:@selector(pressSetHandButton:)];
    [twoHandButton setTarget:self selector:@selector(pressSetHandButton:)];
}

-(void) removeSetHandMenu{
    [self removeChildWithName:@"popUpBackground"];
    [self removeChildWithName:@"selectHandLabel"];
    [self removeChildWithName:@"oneHandButton"];
    [self removeChildWithName:@"twoHandButton"];
}

-(void) pressSetHandButton:(id)sender{
    CCButton *button = (CCButton *)sender;
    if ([button.name isEqualToString:@"oneHandButton"]) {
        gameModel.playHandAmount = 1;
    }else{
        gameModel.playHandAmount = 2;
    }
    [self removeChildWithName:@"popUpBackground"];
    [self removeChildWithName:@"selectHandLabel"];
    [self removeChildWithName:@"oneHandButton"];
    [self removeChildWithName:@"twoHandButton"];
    
    [self removePlayerHandDetail];
    [self initPlayerHandDetail];
    isSetHandComplete = YES;
}

-(void) initPlayerHandDetail{
    CCSprite *background = (CCSprite *)[self getChildByName:@"background" recursively:NO];
    
    //Background
    CCSprite *hand1DisplayBackground = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"playingHand_bg.png"]];
    hand1DisplayBackground.position = ccp(WINS.width*0.5f-hand1DisplayBackground.contentSize.width*0.5f, WINS.height*0.5f-background.contentSize.height*0.335);
    [self addChild:hand1DisplayBackground z:zOrderPlayHandDetail name:@"hand1DisplayBackground"];
    
    CCSprite *hand2DisplayBackground = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"playingHand_bg.png"]];
    hand2DisplayBackground.position = ccp(WINS.width*0.5f+hand1DisplayBackground.contentSize.width*0.5f, WINS.height*0.5f-background.contentSize.height*0.335);
    hand2DisplayBackground.flipX = YES;
    [self addChild:hand2DisplayBackground z:zOrderPlayHandDetail name:@"hand2DisplayBackground"];
    
    //Frame
    CCSprite *hand1DisplayFrame = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"playingHand_frame.png"] ];
    hand1DisplayFrame.position = ccp(hand1DisplayBackground.position.x-hand1DisplayBackground.contentSize.width*0.02f,hand1DisplayBackground.position.y);
    [self addChild:hand1DisplayFrame z:zOrderPlayHandDetail name:@"hand1DisplayFrame"];
    
    CCSprite *hand2DisplayFrame = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"playingHand_frame.png"] ];
    hand2DisplayFrame.position = ccp(hand2DisplayBackground.position.x+hand2DisplayBackground.contentSize.width*0.02f,hand2DisplayBackground.position.y);
    hand2DisplayFrame.flipX = YES;
    [self addChild:hand2DisplayFrame z:zOrderPlayHandDetail name:@"hand2DisplayFrame"];
    
    //Hand Name Sprite
    CCSprite *hand1TextSprite = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"playingHand_text01.png"] ];
    hand1TextSprite.position = ccp(hand1DisplayBackground.position.x-hand1DisplayBackground.contentSize.width*0.28f,hand1DisplayBackground.position.y-hand1DisplayBackground.contentSize.height*0.625f);
    [self addChild:hand1TextSprite z:zOrderPlayHandDetail name:@"hand1TextSprite"];
    
    CCSprite *hand2TextSprite = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"playingHand_text02.png"] ];
    hand2TextSprite.position = ccp(hand2DisplayBackground.position.x+hand2DisplayBackground.contentSize.width*0.28f,hand2DisplayBackground.position.y-hand1DisplayBackground.contentSize.height*0.625f);
    [self addChild:hand2TextSprite z:zOrderPlayHandDetail name:@"hand2TextSprite"];
    
    
    CCLabelTTF *enableHandLabel = [CCLabelTTF labelWithString:@"The 2nd hand is\nnow disable" fontName:FONT_TRAJANPRO_BOLD fontSize:8];
    enableHandLabel.color = [CCColor colorWithCcColor3b:FONT_COLOR];
    enableHandLabel.position = ccp(hand2DisplayBackground.position.x+hand2DisplayBackground.contentSize.width*0.1f,hand2DisplayBackground.position.y+hand2DisplayBackground.contentSize.height*0.2f);
    [self addChild:enableHandLabel z:zOrderPlayHandDetail name:@"enableHandLabel"];
    [enableHandLabel setHorizontalAlignment:CCTextAlignmentCenter];
    
    
    
    CCButton *enableHand2Button = [CCButton buttonWithTitle:nil
                                                spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_enable.png"]
                                     highlightedSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_enable.png"]
                                        disabledSpriteFrame:nil];
    enableHand2Button.position = ccp(enableHandLabel.position.x,hand2DisplayBackground.position.y-hand2DisplayBackground.contentSize.height*0.2f);
    [self addChild:enableHand2Button z:zOrderPlayHandDetail name:@"enableHand2Button"];
    
    
    CCButton *disableHand2Button = [CCButton buttonWithTitle:nil
                                                 spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_disable.png"]
                                      highlightedSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_disable.png"]
                                         disabledSpriteFrame:nil];
    disableHand2Button.position = ccp(enableHandLabel.position.x,hand2DisplayBackground.position.y-hand2DisplayBackground.contentSize.height*0.2f);
    [self addChild:disableHand2Button z:zOrderPlayHandDetail name:@"disableHand2Button"];
    
    
    /* slot ของ card ที่แสดงผล*/
    //hand1
    for (int i = 0; i<3; i++) {
        CCSprite *slot = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"playingHand_cardBackdrop.png"]];
        slot.position = ccp(WINS.width*0.5f-((3.5f-i)*slot.contentSize.width*1.0f ), hand1DisplayBackground.position.y);
        [self addChild:slot z:zOrderPlayHandDetail name:[NSString stringWithFormat:@"slotHand%islot%i",0,i]];
        slot.visible = false;
        [self.allHandDisplayCardSlot setObject:slot forKey:slot.name];
    }
    //hand2
    for (int i = 0; i<3; i++) {
        CCSprite *slot = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"playingHand_cardBackdrop.png"]];
        slot.position = ccp(WINS.width*0.5f+((1.5f+i)*slot.contentSize.width*1.0f), hand1DisplayBackground.position.y);
        [self addChild:slot z:zOrderPlayHandDetail name:[NSString stringWithFormat:@"slotHand%islot%i",1,i]];
        slot.visible = false;
        [self.allHandDisplayCardSlot setObject:slot forKey:slot.name];
    }
    
    
    //กำหนดการกระทำเมื่อกดปุ่ม
    [enableHand2Button setBlock:^(id sender) {
        gameModel.playHandAmount = 2;
        CCButton *tempDisableHand2Button = (CCButton *)[self getChildByName:@"disableHand2Button" recursively:NO];
        CCButton *tempEnableHand2Button = (CCButton *)[self getChildByName:@"enableHand2Button" recursively:NO];
        CCLabelTTF *tempEnableHandLabel = (CCLabelTTF *)[self getChildByName:@"enableHandLabel" recursively:NO];
        CCSprite *tempHand2DisplayFrame = (CCSprite *)[self getChildByName:@"hand2DisplayFrame" recursively:NO];
        CCSprite *tempHand2TextSprite = (CCSprite *)[self getChildByName:@"hand2TextSprite" recursively:NO];
        
        tempDisableHand2Button.visible = YES;
        tempDisableHand2Button.enabled = YES;
        tempEnableHand2Button.visible = NO;
        tempEnableHand2Button.enabled = NO;
        [tempEnableHandLabel setString:@"The 2nd hand is\nnow enable"];
        tempHand2DisplayFrame.visible = YES;
        tempHand2TextSprite.visible = YES;
    }];
    
    [disableHand2Button setBlock:^(id sender){
        gameModel.playHandAmount = 1;
        CCButton *tempDisableHand2Button = (CCButton *)[self getChildByName:@"disableHand2Button" recursively:NO];
        CCButton *tempEnableHand2Button = (CCButton *)[self getChildByName:@"enableHand2Button" recursively:NO];
        CCLabelTTF *tempEnableHandLabel = (CCLabelTTF *)[self getChildByName:@"enableHandLabel" recursively:NO];
        CCSprite *tempHand2DisplayFrame = (CCSprite *)[self getChildByName:@"hand2DisplayFrame" recursively:NO];
        CCSprite *tempHand2TextSprite = (CCSprite *)[self getChildByName:@"hand2TextSprite" recursively:NO];
        tempDisableHand2Button.visible = NO;
        tempDisableHand2Button.enabled = NO;
        tempEnableHand2Button.visible = YES;
        tempEnableHand2Button.enabled = YES;
        [tempEnableHandLabel setString:@"The 2nd hand is\nnow disable"];
        hand2DisplayFrame.visible = NO;
        hand2TextSprite.visible = NO;
        tempHand2DisplayFrame.visible = NO;
        tempHand2TextSprite.visible = NO;
    }];
    
    int tempHand = gameModel.playHandAmount;
    // Visible or
    if (tempHand == 1) {
        hand2DisplayFrame.visible = NO;
        hand2TextSprite.visible = NO;
        disableHand2Button.visible = NO;
        disableHand2Button.enabled = NO;
        hand2DisplayFrame.visible = NO;
        hand2TextSprite.visible = NO;
    }else{
        [enableHandLabel setString:@"The 2nd hand is\nnow enable"];
        hand2DisplayFrame.visible = YES;
        hand2TextSprite.visible = YES;
        enableHand2Button.visible = NO;
        enableHand2Button.enabled = NO;
        hand2DisplayFrame.visible = YES;
        hand2TextSprite.visible = YES;
    }
}


-(void) removePlayerHandDetail{
    [self removeChildWithName:@"hand1DisplayBackground"];
    [self removeChildWithName:@"hand2DisplayBackground"];
    [self removeChildWithName:@"hand1DisplayFrame"];
    [self removeChildWithName:@"hand2DisplayFrame"];
    [self removeChildWithName:@"hand1TextSprite"];
    [self removeChildWithName:@"hand2TextSprite"];
    [self removeChildWithName:@"enableHandLabel"];
    [self removeChildWithName:@"enableHand2Button"];
    [self removeChildWithName:@"disableHand2Button"];
    int kCardSlot = 3;
    int kHandAmount = 2;
    for (int j = 0 ; j<kHandAmount; j++) {
        for (int i = 0; i<kCardSlot; i++) {
            [self removeChildWithName:[NSString stringWithFormat:@"slotHand%islot%i",j,i]];
        }
    }
    
}

-(void) setPlayerhandDetailEnable:(BOOL)enable{
    CCSprite *hand1DisplayBackground = (CCSprite *)[self getChildByName:@"hand1DisplayBackground" recursively:NO];
    CCSprite *hand2DisplayBackground = (CCSprite *)[self getChildByName:@"hand2DisplayBackground" recursively:NO];
    CCSprite *hand1DisplayFrame = (CCSprite *)[self getChildByName:@"hand1DisplayFrame" recursively:NO];
    CCSprite *hand2DisplayFrame = (CCSprite *)[self getChildByName:@"hand2DisplayFrame" recursively:NO];
    CCSprite *hand1TextSprite = (CCSprite *)[self getChildByName:@"hand1TextSprite" recursively:NO];
    CCSprite *hand2TextSprite = (CCSprite *)[self getChildByName:@"hand2TextSprite" recursively:NO];
    CCLabelTTF *enableHandLabel = (CCLabelTTF *)[self getChildByName:@"enableHandLabel" recursively:NO];
    CCButton *enableHand2Button = (CCButton *)[self getChildByName:@"enableHand2Button" recursively:NO];
    CCButton *disableHand2Button = (CCButton *)[self getChildByName:@"disableHand2Button" recursively:NO];
    
    hand1DisplayBackground.visible = enable;
    hand2DisplayBackground.visible = enable;
    hand1DisplayFrame.visible = enable;
    hand2DisplayFrame.visible = enable;
    hand1TextSprite.visible = enable;
    hand2TextSprite.visible = enable;
    enableHandLabel.visible = enable;
    
    enableHand2Button.visible = enable;
    enableHand2Button.enabled = enable;
    disableHand2Button.enabled = enable;
    disableHand2Button.visible = enable;
    
}

-(void) setDealerHandDetail{
    
    CCSprite *hand2DisplayFrame = (CCSprite *)[self getChildByName:@"hand2DisplayFrame" recursively:NO];
    CCSprite *hand2TextSprite = (CCSprite *)[self getChildByName:@"hand2TextSprite" recursively:NO];
    CCLabelTTF *enableHandLabel = (CCLabelTTF *)[self getChildByName:@"enableHandLabel" recursively:NO];
    CCButton *enableHand2Button = (CCButton *)[self getChildByName:@"enableHand2Button" recursively:NO];
    CCButton *disableHand2Button = (CCButton *)[self getChildByName:@"disableHand2Button" recursively:NO];
    
    hand2DisplayFrame.visible = NO;
    hand2TextSprite.visible = NO;
    enableHandLabel.visible = NO;
    
    enableHand2Button.visible = NO;
    enableHand2Button.enabled = NO;
    disableHand2Button.enabled = NO;
    disableHand2Button.visible = NO;
    
    
    for (int i = 0; i<3; i++) {
        CCSprite *hand1Slot = [self.allHandDisplayCardSlot objectForKey:[NSString stringWithFormat:@"slotHand%islot%i",0,i]];
        hand1Slot.visible = YES;
        
        CCSprite *hand2Slot = [self.allHandDisplayCardSlot objectForKey:[NSString stringWithFormat:@"slotHand%islot%i",1,i]];
        hand2Slot.visible = NO;
    }
}

//สั่ง เปิดปิด เมนูสำหรับเลือกมือ เมื่อเริ่มเล่น
-(void) setEnableSecondHandEnable:(BOOL)enable{
    CCLabelTTF *enableHandLabel = (CCLabelTTF *)[self getChildByName:@"enableHandLabel" recursively:NO];
    CCButton *enableHand2Button = (CCButton *)[self getChildByName:@"enableHand2Button" recursively:NO];
    CCButton *disableHand2Button = (CCButton *)[self getChildByName:@"disableHand2Button" recursively:NO];
    
    enableHandLabel.visible = enable;
    
    
    //ต้องปิด-เปิด slot ของ ไพ่
    
    for (int hand = 0; hand < gameModel.playHandAmount ; hand++) {
        for (int i = 0; i<3; i++) {
            CCSprite *slot = [self.allHandDisplayCardSlot objectForKey:[NSString stringWithFormat:@"slotHand%islot%i",hand,i]];
            slot.visible = !enable;
        }
    }
    
    if (gameModel.playHandAmount == 1) {
        //ถ้าเล่น 1 มือ ให้เปิดปุ่มสำหรับเปิด 2 มือ
        enableHand2Button.visible = enable;
        enableHand2Button.enabled = enable;
        for (int i = 0; i<3; i++) {
            CCSprite *slot = [self.allHandDisplayCardSlot objectForKey:[NSString stringWithFormat:@"slotHand%islot%i",1,i]];
            slot.visible = NO;
        }
    }else {
        //ถ้าเล่น 2 มือ ให้เปิดปุ่มสำหรับเล่น 1 มือ
        disableHand2Button.enabled = enable;
        disableHand2Button.visible = enable;
    }
    
    
    if (gameModel.currentPlayerStatus == PlayerStatusDealer) {
        enableHandLabel.visible = NO;
        enableHand2Button.visible = NO;
        enableHand2Button.enabled = NO;
        disableHand2Button.enabled = NO;
        disableHand2Button.visible = NO;
        for (int i = 0; i<3; i++) {
            CCSprite *slot = [self.allHandDisplayCardSlot objectForKey:[NSString stringWithFormat:@"slotHand%islot%i",1,i]];
            slot.visible = NO;
        }
    }
}
#pragma mark - Bet
-(void) initWaitingSetBetPopUp{
    CCSprite *popUpBackground = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"bg_popup.png"]];
    popUpBackground.position = ccp(WINS.width*0.5f, WINS.height*0.5f);
    [self addChild:popUpBackground z:zOrderMenu name:@"popUpBackground"];
    
    CCLabelTTF *waitingLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Waiting for player to set bet."]
                                                   fontName:FONT_TRAJANPRO_BOLD
                                                   fontSize:16];
    waitingLabel.color = [CCColor colorWithCcColor3b:FONT_COLOR];
    waitingLabel.position = ccp(WINS.width*0.5f, WINS.height*0.5f+popUpBackground.contentSize.height*0.25f);
    [self addChild:waitingLabel z:zOrderMenu name:@"waitingLabel"];
    
    
    [self initCountDownWithTime:15 withPosition:ccp(WINS.width*0.45f, WINS.height*0.5f)];
}
-(void) removeWaitingSetBetPopUp{
    [self removeChildWithName:@"popUpBackground"];
    [self removeChildWithName:@"waitingLabel"];
    [self removeTimer];
}


-(void) initSetBetMenu{
//    [self initSetBetMenu];
    NSInteger maxBet = gameModel.roomMaxBet;
    NSInteger minBet = gameModel.roomMinBet;
    
    currentBet = minBet;
    CCSprite *popUpBackground = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"bg_popup.png"]];
    popUpBackground.position = ccp(WINS.width*0.5f, WINS.height*0.5f);
    [self addChild:popUpBackground z:zOrderMenu name:@"popUpBackground"];
    
    CCLabelTTF *placeBetLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Place bet for hand %i",currentActiveHand]
                                                   fontName:FONT_TRAJANPRO_BOLD
                                                   fontSize:16];
    placeBetLabel.color = [CCColor colorWithCcColor3b:FONT_COLOR];
    placeBetLabel.position = ccp(WINS.width*0.5f, WINS.height*0.5f+popUpBackground.contentSize.height*0.25f);
    [self addChild:placeBetLabel z:zOrderMenu name:@"placeBetLabel"];
    
    CCLabelTTF *betLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"$%@",[PDHelperFunction getChipStringWithChip:currentBet]]
                                              fontName:FONT_TRAJANPRO_BOLD
                                              fontSize:22];
    betLabel.color = [CCColor colorWithCcColor3b:FONT_COLOR];
    betLabel.position = ccp(WINS.width*0.5f, WINS.height*0.5f);
    [self addChild:betLabel z:zOrderMenu name:@"betLabel"];
    
    CCButton *decreaseButton = [CCButton buttonWithTitle:nil
                                          spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_decrease.png"]
                               highlightedSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_decreaseC.png"]
                                     disabledSpriteFrame:nil];
    
    CCButton *increaseButton = [CCButton buttonWithTitle:nil
                                             spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_increase.png"]
                                  highlightedSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_increaseC.png"]
                                     disabledSpriteFrame:nil];
    
    CCButton *okButton = [CCButton buttonWithTitle:nil
                                       spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_ok.png"]
                            highlightedSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_okC.png"]
                               disabledSpriteFrame:nil];
    
    decreaseButton.position = ccp(WINS.width*0.25f,WINS.height*0.5f);
    increaseButton.position = ccp(WINS.width*0.75f,WINS.height*0.5f);
    okButton.position = ccp(WINS.width*0.5f,WINS.height*0.5f-popUpBackground.contentSize.height*0.25f);
    
    [self addChild:decreaseButton z:zOrderMenu name:@"decreaseButton"];
    [self addChild:increaseButton z:zOrderMenu name:@"increaseButton"];
    [self addChild:okButton z:zOrderMenu name:@"okButton"];
    
    [decreaseButton setBlock:^(id sender){
        currentBet -= 10;
        if (currentBet< minBet) {
            currentBet = minBet;
        }
        [betLabel setString:[NSString stringWithFormat:@"$%@",[PDHelperFunction getChipStringWithChip:currentBet]]];
    }];
    [increaseButton setBlock:^(id sender){
        currentBet += 10;
        if (currentBet > maxBet) {
            currentBet = maxBet;
        }
        [betLabel setString:[NSString stringWithFormat:@"$%@",[PDHelperFunction getChipStringWithChip:currentBet]]];
    }];
    [okButton setBlock:^(id sender){
        placeBet[currentActiveHand-1] = currentBet;
        currentActiveHand ++;
        [self removeSetBetMenu];
        [self removeTimer];
        if (currentActiveHand <= gameModel.playHandAmount) {
            [self initSetBetMenu];
        }else{
            currentActiveHand = 1;
            [gameModel sendBetHand1:placeBet[0] hand2:placeBet[1]];
            currentDecision = DecisionTypeNone;
            [self initLoadingNode];
        }
    }];
    [self initCountDownWithTime:5 withPosition:ccp(WINS.width*0.45f, WINS.height*0.5f-popUpBackground.contentSize.height*0.5f)];
}
-(void) removeSetBetMenu{
    [self removeChildWithName:@"popUpBackground"];
    [self removeChildWithName:@"placeBetLabel"];
    [self removeChildWithName:@"betLabel"];
    [self removeChildWithName:@"decreaseButton"];
    [self removeChildWithName:@"increaseButton"];
    [self removeChildWithName:@"okButton"];
}


-(void) drawPlayerBet{
    if (!isDrawBet) {
        if (gameModel.isHaveAllBetData && self.allUserDisplayUIArray.count > 0) {
            //เช็คว่ามีข้อมูล bet และ มีการวาดข้อมูลผู้เล่นแล้ว
            if (gameModel.isOnSkipAnimate) {
                if (gameModel.currentObserverProcessState < ServerStateSetBet) {
                    gameModel.currentObserverProcessState = ServerStateSetBet;
                }
            }
            
            for (int chair = 0; chair<kMaxPlayer; chair++) {
                if(self.currentChairOrderIndex.count > chair){
                    int dataIndex = [self.currentChairOrderIndex[chair] intValue];
                    
                    NSArray *playerInfo = [gameModel.allPlayerInfo objectAtIndex:dataIndex];
                    if (![playerInfo isEqual:[NSNull null]]) {
                        //                int chairIndexForShow = [self getChairIndexDisplay:chair];
                        int playHandAmount = [gameModel getPlayHandNum:dataIndex];
                        
                        for (int hand = 0; hand < playHandAmount; hand++) {
                            NSInteger bet = [gameModel getBetChair:dataIndex hand:hand];
                            if (bet>0) {
                                NSMutableArray *chipArray = [NSMutableArray array];
                                for (int chipAmount = 0; chipAmount<3; chipAmount++) {
                                    int randomChipType = (arc4random()%2)+ChipType10 ;
                                    PDChipNode *chip = [PDChipNode initChipWithType:randomChipType];
                                    
                                    //For Random Position
                                    float posX = (arc4random()%4 + 1)*0.1f;
                                    int temp = arc4random()%2;
                                    if (temp == 0) {
                                        posX *= -1;
                                    }
                                    float posY = (arc4random()%4 + 1)*0.1f;
                                    temp = arc4random()%2;
                                    if (temp == 0) {
                                        posY *= -1;
                                    }
                                    chip.position = [self getChipDefaultPosWithChairNumber:chair handNumber:hand allHandAmount:playHandAmount];
                                    chip.position = ccp(chip.position.x + (chip.contentSize.width*posX),chip.position.y + (chip.contentSize.height*posY));
                                    [self addChild:chip z:zOrderChipBetting];
                                    [chipArray addObject:chip];
                                    [self.allRemoveObjectArray addObject:chip];
                                }
                                [self.allPlayerChipDataDict setObject:chipArray forKey:[NSString stringWithFormat:@"chair_%ihand_%ichipNode",chair,hand]];
                            }
                        }
                    }
                }
            }
         isDrawBet = TRUE;
        }
    }
}


-(void) moveBetFromChair:(int)senderChair hand:(int)senderHand handAmount:(int)senderHandAmount toChair:(int)receiverChair hand:(int)receiverHand handAmount:(int)receiverHandAmount{
    NSArray *senderChipData = [self.allPlayerChipDataDict objectForKey:[NSString stringWithFormat:@"chair_%ihand_%ichipNode",senderChair,senderHand]];
    if (senderChipData) {
        //Lose
        for (int i = 0; i<senderChipData.count; i++) {
            PDChipNode *chip = (PDChipNode *)[senderChipData objectAtIndex:i];
            chip.zOrder = zOrderChipSending;
            CCActionDelay *delay = [CCActionDelay actionWithDuration:0.1f*i];
            CGPoint moveToPos = [self getChipDefaultPosWithChairNumber:receiverChair handNumber:receiverHand allHandAmount:receiverHandAmount];
            float distance = ccpDistance(chip.position, moveToPos);
            float moveDuration = distance *0.0075f;
            CCActionMoveTo *moveTo = [CCActionMoveTo actionWithDuration:moveDuration position:moveToPos];
            CCActionEaseOut *ease = [CCActionEaseOut actionWithAction:moveTo rate:2.0f];
            CCActionCallBlock *removeChip = [CCActionCallBlock actionWithBlock:^(void){
                [self removeChild:chip cleanup:YES];
            }];
            CCActionSequence *seq = [CCActionSequence actions:delay,ease,removeChip, nil];
            [chip runAction:seq];
        }
    }else{
        //Win
        DLog(@"self.allPlayerChipDataDict %@",self.allPlayerChipDataDict);
//        DLog(@"receiverChair %i receiverHand %i",receiverChair , receiverHand);
        NSArray *tempChipData = [self.allPlayerChipDataDict objectForKey:[NSString stringWithFormat:@"chair_%ihand_%ichipNode",receiverChair,receiverHand]];
        DLog(@"receiverChair %i receiverHand %i tempChipData %@",receiverChair,receiverHand,tempChipData);
        DLog(@"sender Chair %i",senderChair);
        for (int i = 0; i<tempChipData.count; i++) {
            PDChipNode *tempChip = (PDChipNode *)[tempChipData objectAtIndex:i];
            DLog(@"tempChip %@",tempChip);
            PDChipNode *chip;
            if (tempChip) {
                chip = [PDChipNode initChipWithType:tempChip.type];
            }else{
                ChipType randomChipType = arc4random()%2 + ChipType10;
                chip = [PDChipNode initChipWithType:randomChipType];
            }
            
            DLog(@"chip %@",chip);
            chip.position = [self getChipDefaultPosWithChairNumber:senderChair handNumber:senderHand allHandAmount:senderHandAmount];
            DLog(@"chip.position (%f,%f)",chip.position.x , chip.position.y);
            [self addChild:chip z:zOrderChipSending];
            
            CCActionDelay *delay = [CCActionDelay actionWithDuration:0.1f*i];
            CGPoint moveToPos = [self getChipDefaultPosWithChairNumber:receiverChair handNumber:receiverHand allHandAmount:receiverHandAmount];
            DLog(@"moveToPos (%f,%f)",moveToPos.x,moveToPos.y);
            float distance = ccpDistance(chip.position, moveToPos);
            float moveDuration = distance * 0.0075f;
            CCActionMoveTo *moveTo = [CCActionMoveTo actionWithDuration:moveDuration position:moveToPos];
            CCActionEaseOut *ease = [CCActionEaseOut actionWithAction:moveTo rate:2.0f];
            CCActionCallBlock *removeChip = [CCActionCallBlock actionWithBlock:^(void){
                [self removeChild:chip cleanup:YES];
            }];
            CCActionSequence *seq = [CCActionSequence actions:delay,ease,removeChip, nil];
            [chip runAction:seq];
        }
    }
}

#pragma mark - Cut Card
-(void) initWaitingSetCutCardPopUp{
    CCSprite *popUpBackground = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"bg_popup.png"]];
    popUpBackground.position = ccp(WINS.width*0.5f, WINS.height*0.5f);
    [self addChild:popUpBackground z:zOrderMenu name:@"popUpBackground"];
    
    CCLabelTTF *waitingLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Waiting for player to cut card."]
                                                  fontName:FONT_TRAJANPRO_BOLD
                                                  fontSize:16];
    waitingLabel.color = [CCColor colorWithCcColor3b:FONT_COLOR];
    waitingLabel.position = ccp(WINS.width*0.5f, WINS.height*0.5f+popUpBackground.contentSize.height*0.25f);
    [self addChild:waitingLabel z:zOrderMenu name:@"waitingLabel"];
    
    [self initCountDownWithTime:4 withPosition:ccp(WINS.width*0.45f, WINS.height*0.5f)];
}
-(void) removeWaitingSetCutCardPopUp{
    [self removeChildWithName:@"popUpBackground"];
    [self removeChildWithName:@"waitingLabel"];
}

-(void) initCutCardMenu{
    CCSprite *background = (CCSprite *)[self getChildByName:@"background" recursively:NO];
    self.userInteractionEnabled = YES;
    deckNode.userInteractionEnabled = YES;
    deckNode.scale = 1.0f;
    
    CCSprite *cutCardTextSprite = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"text_cut.png"]];
    cutCardTextSprite.position = ccp(WINS.width*0.5f,WINS.height*0.5f+background.contentSize.height*0.141f);
    [self addChild:cutCardTextSprite z:zOrderMenu name:@"cutCardTextSprite"];
    
    CCSprite *arrowSprite = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"draw_arrow.png"]];
    arrowSprite.position = ccp(WINS.width*0.5f, WINS.height*0.5f+background.contentSize.height*0.085f);
    [self addChild:arrowSprite z:zOrderMenu name:@"arrowSprite"];
    
    CCActionMoveBy *moveUp = [CCActionMoveBy actionWithDuration:0.6f position:ccp(0, arrowSprite.contentSize.height*0.25f)];
    CCActionMoveBy *moveDown = [CCActionMoveBy actionWithDuration:0.3f position:ccp(0, -arrowSprite.contentSize.height*0.25f)];
    CCActionSequence *seq = [CCActionSequence actions:moveUp,moveDown, nil];
    CCActionRepeatForever *repeateSeq = [CCActionRepeatForever actionWithAction:seq];
    [arrowSprite runAction:repeateSeq];
    
    [self initCountDownWithTime:5 withPosition:ccp(WINS.width*0.45f, WINS.height*0.5f-background.contentSize.height*0.1f)];
}

-(void) removeCutCardMenu{
    [self initLoadingNode];
    
    deckNode.scale = 0.5f;
    self.userInteractionEnabled =  NO;
    
    [self removeChildWithName:@"cutCardTextSprite"];
    [self removeChildWithName:@"arrowSprite"];
    [self removeTimer];
}

#pragma mark - Call Card
-(void) initCallCardMenu{
    [self removeCallCardMenu];
    
    CCSprite *background = (CCSprite *)[self getChildByName:@"background" recursively:NO];
    CardsRankType cardRank = [gameModel getCardRankTypeChair:gameModel.currentChairNumber hand:currentActiveHand-1 cardOnHandNumber:2];

    if (cardRank == CardsRankTypePok) {
        isCallCard[currentActiveHand-1] = NO;
        currentActiveHand ++;
        if (currentActiveHand > gameModel.playHandAmount) {
            currentDecision = DecisionTypeNone;
            [gameModel sendCallCardHand1:isCallCard[0] hand2:isCallCard[1]];
            [self initLoadingNode];
        }else{
            currentDecision = DecisionTypeCallCard;
            [self initCallCardMenu];
        }
    }else{
        deckNode.scale = 1.0f;
        [self initCountDownWithTime:5 withPosition:ccp(WINS.width*0.45f, WINS.height*0.5f-background.contentSize.height*0.132f)];
        CCSprite *callCardTextSprite = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"text_draw.png"]];
        callCardTextSprite.position = ccp(WINS.width*0.5f,WINS.height*0.5f+background.contentSize.height*0.141f);
        [self addChild:callCardTextSprite z:zOrderMenu name:@"callCardTextSprite"];
        
        CCButton *yesButton = [CCButton buttonWithTitle:nil
                                            spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_yes.png"]
                                 highlightedSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_yesC.png"]
                                    disabledSpriteFrame:nil];
        
        CCButton *noButton = [CCButton buttonWithTitle:nil
                                           spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_no.png"]
                                highlightedSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_noC.png"]
                                   disabledSpriteFrame:nil];
        
        yesButton.position = ccp(WINS.width*0.5f-yesButton.contentSize.width*0.6f, WINS.height*0.5f-background.contentSize.height*0.09f);
        noButton.position = ccp(WINS.width*0.5f+yesButton.contentSize.width*0.6f, WINS.height*0.5f-background.contentSize.height*0.09f);
        
        [self addChild:yesButton z:zOrderMenu name:@"yesButton"];
        [self addChild:noButton z:zOrderMenu name:@"noButton"];
        
        [yesButton setTarget:self selector:@selector(pressCallCardMenuButton:)];
        [noButton setTarget:self selector:@selector(pressCallCardMenuButton:)];
        
        CCSprite *arrowSprite = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"draw_arrow.png"]];
        [self addChild:arrowSprite z:zOrderMenu name:@"callCardArrowSprite"];
        if (currentActiveHand == 1) {
            arrowSprite.position = ccp(WINS.width*0.2f, WINS.height*0.5f-background.contentSize.height*0.26f);
        }else if (currentActiveHand == 2){
            arrowSprite.position = ccp(WINS.width*0.8f, WINS.height*0.5f-background.contentSize.height*0.26f);
        }
        CCActionMoveBy *moveUp = [CCActionMoveBy actionWithDuration:0.6f position:ccp(0, arrowSprite.contentSize.height*0.25f)];
        CCActionMoveBy *moveDown = [CCActionMoveBy actionWithDuration:0.3f position:ccp(0, -arrowSprite.contentSize.height*0.25f)];
        CCActionSequence *seq = [CCActionSequence actions:moveUp,moveDown, nil];
        CCActionRepeatForever *repeateSeq = [CCActionRepeatForever actionWithAction:seq];
        [arrowSprite runAction:repeateSeq];
        
        //ถ้ามีแต้มตำ่กว่า 5 แต้ม ต้องมีแต่ให้จั่ว
        int cardPoint = [gameModel getCardPointChair:gameModel.currentChairNumber hand:currentActiveHand-1 cardOnHandNumber:2];

        DLog(@"sumCardPoint %i",cardPoint);
        if (cardPoint <= 4) {
            callCardTextSprite.visible = false;
            CCSprite *popUpBackground = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"bg_popup.png"]];
            popUpBackground.scaleY = 0.5f;
            popUpBackground.position = ccp(WINS.width*0.5f, WINS.height*0.5f+popUpBackground.contentSize.height*popUpBackground.scaleY);
            [self addChild:popUpBackground z:zOrderMenu name:@"callCardPopUpBackground"];
            
            CCLabelTTF *warningLabel = [CCLabelTTF labelWithString:@"Your hand is less than four\nyou must call a card." fontName:FONT_TRAJANPRO_BOLD fontSize:16];
            warningLabel.horizontalAlignment = CCTextAlignmentCenter;
            warningLabel.position = ccp(WINS.width*0.5f,popUpBackground.position.y);
            [self addChild:warningLabel z:zOrderMenu name:@"callCardWarningLabel"];
            warningLabel.color = [CCColor colorWithCcColor3b:FONT_COLOR];
            noButton.visible = false;
            noButton.enabled = false;
            yesButton.position = ccp(WINS.width*0.5f, yesButton.position.y);
        }
    }
}
-(void) removeCallCardMenu{
    deckNode.scale = 0.5f;
    
    [self removeChildWithName:@"callCardTextSprite"];
    [self removeChildWithName:@"yesButton"];
    [self removeChildWithName:@"noButton"];
    [self removeChildWithName:@"callCardArrowSprite"];
    [self removeChildWithName:@"callCardWarningLabel"];
    [self removeChildWithName:@"callCardPopUpBackground"];
    [self removeTimer];
}

-(void) pressCallCardMenuButton:(id) sender{
    CCButton *button = (CCButton *)sender;
    if ([button.name isEqualToString:@"yesButton"]) {
        isCallCard[currentActiveHand-1] = YES;
    }else{
        isCallCard[currentActiveHand-1] = NO;
    }
    
    [self removeCallCardMenu];
    currentActiveHand ++;
    if (currentActiveHand > gameModel.playHandAmount) {
        currentDecision = DecisionTypeNone;
        [gameModel sendCallCardHand1:isCallCard[0] hand2:isCallCard[1]];
        [self initLoadingNode];
    }else{
        [self initCallCardMenu];
    }
}


#pragma mark - Handout Card
-(void) handOutCard{
    if (!isHandOutCard) {
        [deckNode stopAllActions];
        
        if (gameModel.isHaveCardData && self.allUserDisplayUIArray.count > 0) {
            float startScale = 0.5f;
            
            deckNode.scale = startScale;
            int actionCount = 0;
            DLog(@"self.playerInfo %@",gameModel.allPlayerInfo);
            int dealerDataIndex = gameModel.dealerChairNum;
            int dealerChairIndex = (int)[self.currentChairOrderIndex indexOfObject:[NSNumber numberWithInt:dealerDataIndex]];
            if (dealerChairIndex >= kMaxPlayer) {
                dealerChairIndex = 0;
            }
            DLog(@"dealerChairIndex %i",dealerChairIndex);
            //        NSArray *emptyChair = [gameModel.emptyChairNumberSet allObjects];
            int firstHandOutCardAmount = 2; //จำนวนไพ่ต่อมือที่แจกให้ในรอบแรก
            for (int cardIndex = 0; cardIndex < firstHandOutCardAmount; cardIndex++) {
                for (int chair = 0; chair<kMaxPlayer; chair++) {
                    int handOutChairNumber = dealerChairIndex + 1 + chair; //ลำดับของที่นั่งที่จะเริ่มแจกไพ่
                    if (handOutChairNumber >= kMaxPlayer) {
                        handOutChairNumber -= kMaxPlayer;
                    }
                    int dataIndex = [self.currentChairOrderIndex[handOutChairNumber] intValue];
                    NSArray *playerInfo = gameModel.allPlayerInfo[dataIndex];
                    DLog(@"playerInfo %@",playerInfo);
                    if (![playerInfo isEqual:[NSNull null]]) {
                        int playerHand = [gameModel getPlayHandNum:dataIndex];
                        for (int hand = 0; hand<playerHand; hand++) {
                            /* บอกรับข้อมูลของไพ่ที่ต้องแจกให้ผู้เล่น */
                            int cardDataNumber = [gameModel getCardChair:dataIndex hand:hand cardOnHand:cardIndex];
                            
                            CardNode *cardNode = [CardNode initCardBackWithCardNumber:cardDataNumber];
                            cardNode.scale = startScale;
                            cardNode.position = ccp(deckNode.position.x,deckNode.position.y+deckNode.contentSize.height*0.05f);
                            [self addChild:cardNode z:zOrderCard name:[NSString stringWithFormat:@"cardChair%ihand%icardIndex%i",handOutChairNumber,hand,cardIndex]];
                            
                            /* เก็บไพ่ไว้ใน Data Dict สำหรับใช้ตอนเปิดไพ่  */
                            [self.allPlayerCardDataDict setObject:cardNode forKey:cardNode.name];
                            
                            CGPoint moveToPos = [self getCardOriginPosWithChairNumber:handOutChairNumber handNumber:hand cardOnHandIndex:cardIndex allHandAmount:playerHand];
                            CCActionDelay *handOutCardDelay = [CCActionDelay actionWithDuration:0.5*actionCount];
                            CCActionMoveTo *moveToPlayerHand = [CCActionMoveTo actionWithDuration:0.5f position:moveToPos];
                            CCActionEaseOut *ease = [CCActionEaseOut actionWithAction:moveToPlayerHand rate:3.0f];
                            CCActionCallBlock *setToSlot = [CCActionCallBlock actionWithBlock:^{
                                if (gameModel.currentChairNumber == dataIndex && gameModel.currentPlayerStatus != PlayerStatusObserver) {
                                    CCSprite *slot = [self.allHandDisplayCardSlot objectForKey:[NSString stringWithFormat:@"slotHand%islot%i",hand,cardIndex]];
                                    [cardNode upToHand];
                                    cardNode.position = slot.position;
                                    cardNode.scale = 1.0f;
                                }
                            }];
                            CCActionSequence *moveCardSeq = [CCActionSequence actions:handOutCardDelay,ease,setToSlot, nil];
                            [cardNode runAction:moveCardSeq];
                            [self.allRemoveObjectArray addObject:cardNode];
                            actionCount++;
                        }
                    }
                }
            }
            CCActionDelay *actionDelay = [CCActionDelay actionWithDuration:0.5f*actionCount];
            CCActionCallBlock *callNextState = [CCActionCallBlock actionWithBlock:^{
                
                [self runSceneActionState:SceneActionStateShowPok];
            }];
            
            CCActionSequence *seq = [CCActionSequence actions:actionDelay,callNextState, nil];
            [self runAction:seq];
            isHandOutCard = true;
        }
    }else{
        [self initLoadingNode];
    }
}

-(void) handOutCardWithNoAnimate{
    if (!isHandOutCard) {
        [deckNode stopAllActions];
        if (gameModel.isHaveCardData && self.allUserDisplayUIArray.count > 0) {
            float startScale = 0.5f;
            if (gameModel.isOnSkipAnimate) {
                if (gameModel.currentObserverProcessState < ServerStateSetCutCard) {
                    gameModel.currentObserverProcessState = ServerStateSetCutCard;
                }
            }
            deckNode.scale = startScale;
            int dealerDataIndex = gameModel.dealerChairNum;
            int dealerChairIndex = (int)[self.currentChairOrderIndex indexOfObject:[NSNumber numberWithInt:dealerDataIndex]];
            DLog(@"dealerChairIndex %i",dealerChairIndex);
            //        NSArray *emptyChair = [gameModel.emptyChairNumberSet allObjects];
            int firstHandOutCardAmount = 2; //จำนวนไพ่ต่อมือที่แจกให้ในรอบแรก
            for (int cardIndex = 0; cardIndex < firstHandOutCardAmount; cardIndex++) {
                for (int chair = 0; chair<kMaxPlayer; chair++) {
                    int handOutChairNumber = dealerChairIndex + 1 + chair; //ลำดับของที่นั่งที่จะเริ่มแจกไพ่
                    if (handOutChairNumber >= kMaxPlayer) {
                        handOutChairNumber -= kMaxPlayer;
                    }
                    int dataIndex = [self.currentChairOrderIndex[handOutChairNumber] intValue];
                    NSArray *playerInfo = gameModel.allPlayerInfo[dataIndex];
                    DLog(@"playerInfo %@",playerInfo);
                    if (![playerInfo isEqual:[NSNull null]]) {
                        int playerHand = [gameModel getPlayHandNum:dataIndex];
                        for (int hand = 0; hand<playerHand; hand++) {
                            DLog(@"handOutChairNumber %i dataIndex%i handNum %i",handOutChairNumber,dataIndex,playerHand);
                            /* บอกรับข้อมูลของไพ่ที่ต้องแจกให้ผู้เล่น */
                            int cardDataNumber = [gameModel getCardChair:dataIndex hand:hand cardOnHand:cardIndex];
                            
                            DLog(@"handOutChairNumber %i dataIndex%i cardDataNumber %i",handOutChairNumber,dataIndex,cardDataNumber);
                            
                            CardNode *cardNode = [CardNode initCardBackWithCardNumber:cardDataNumber];
                            cardNode.scale = startScale;
                            CGPoint cardPos = [self getCardOriginPosWithChairNumber:handOutChairNumber handNumber:hand cardOnHandIndex:cardIndex allHandAmount:playerHand];
                            
                            cardNode.position = cardPos;
                            [self addChild:cardNode z:zOrderCard name:[NSString stringWithFormat:@"cardChair%ihand%icardIndex%i",handOutChairNumber,hand,cardIndex]];
                            
                            /* เก็บไพ่ไว้ใน Data Dict สำหรับใช้ตอนเปิดไพ่  */
                            [self.allPlayerCardDataDict setObject:cardNode forKey:cardNode.name];
                            if (gameModel.currentChairNumber == dataIndex && gameModel.currentPlayerStatus != PlayerStatusObserver) {
                                CCSprite *slot = [self.allHandDisplayCardSlot objectForKey:[NSString stringWithFormat:@"slotHand%islot%i",hand,cardIndex]];
                                [cardNode upToHand];
                                cardNode.position = slot.position;
                                cardNode.scale = 1.0f;
                            }
                            [self.allRemoveObjectArray addObject:cardNode];
                        }
                    }
                }
            }
            CCActionDelay *actionDelay = [CCActionDelay actionWithDuration:1.0f];
            CCActionCallBlock *callNextState = [CCActionCallBlock actionWithBlock:^{
                [self runSceneActionState:SceneActionStateShowPok];
            }];
            
            CCActionSequence *seq = [CCActionSequence actions:actionDelay,callNextState, nil];
            [self runAction:seq];
            isHandOutCard = true;
        }
    }else{
        [self initLoadingNode];
    }
        
}

-(void) handOutThirdCard{
    if (!isHandOutThirdCard) {
        [deckNode stopAllActions];
       
        DLog(@"handOutThirdCard");
        DLog(@"self.playerInfo %@",gameModel.allPlayerInfo);
        if (gameModel.isHaveCardData && self.allUserDisplayUIArray.count > 0) {
            float startScale = 0.5f;
            int actionCount = 0;
            int dealerDataIndex = gameModel.dealerChairNum;
            int dealerChairIndex = (int)[self.currentChairOrderIndex indexOfObject:[NSNumber numberWithInt:dealerDataIndex]];
            if (dealerChairIndex >= kMaxPlayer) {
                dealerChairIndex = 0;
            }
            DLog(@"dealerChairIndex %i",dealerChairIndex);
            int cardIndex = 2;
            
            for (int chair = 0; chair<kMaxPlayer; chair++) {
                int handOutChairNumber = dealerChairIndex + 1 + chair; //ลำดับของที่นั่งที่จะเริ่มแจกไพ่
                if (handOutChairNumber >= kMaxPlayer) {
                    handOutChairNumber -= kMaxPlayer;
                }
                int dataIndex = [self.currentChairOrderIndex[handOutChairNumber] intValue];
                NSArray *playerInfo = gameModel.allPlayerInfo[dataIndex];
                DLog(@"playerInfo %@",playerInfo);
                if (![playerInfo isEqual:[NSNull null]]) {
                    int playerHand = [gameModel getPlayHandNum:dataIndex];
                    for (int hand = 0; hand<playerHand; hand++) {
                        bool isCall = [gameModel getIsCallChair:dataIndex hand:hand];
                        if(isCall){
                            /* บอกรับข้อมูลของไพ่ที่ต้องแจกให้ผู้เล่น */
                            int cardDataNumber = [gameModel getCardChair:dataIndex hand:hand cardOnHand:cardIndex];
                            CardNode *cardNode = [CardNode initCardBackWithCardNumber:cardDataNumber];
                            cardNode.scale = startScale;
                            cardNode.position = ccp(deckNode.position.x,deckNode.position.y+deckNode.contentSize.height*0.05f);
                            [self addChild:cardNode z:zOrderCard name:[NSString stringWithFormat:@"cardChair%ihand%icardIndex%i",handOutChairNumber,hand,cardIndex]];
                            
                            /* เก็บไพ่ไว้ใน Data Dict สำหรับใช้ตอนเปิดไพ่  */
                            [self.allPlayerCardDataDict setObject:cardNode forKey:cardNode.name];
                            
                            CGPoint moveToPos = [self getCardOriginPosWithChairNumber:handOutChairNumber handNumber:hand cardOnHandIndex:cardIndex allHandAmount:playerHand];
                            CCActionDelay *handOutCardDelay = [CCActionDelay actionWithDuration:0.5*actionCount];
                            CCActionMoveTo *moveToPlayerHand = [CCActionMoveTo actionWithDuration:0.5f position:moveToPos];
                            CCActionEaseOut *ease = [CCActionEaseOut actionWithAction:moveToPlayerHand rate:3.0f];
                            CCActionCallBlock *setToSlot = [CCActionCallBlock actionWithBlock:^{
                                if (gameModel.currentChairNumber == dataIndex && gameModel.currentPlayerStatus != PlayerStatusObserver) {
                                    CCSprite *slot = [self.allHandDisplayCardSlot objectForKey:[NSString stringWithFormat:@"slotHand%islot%i",hand,cardIndex]];
                                    [cardNode upToHand];
                                    cardNode.position = slot.position;
                                    cardNode.scale = 1.0f;
                                }
                            }];
                            CCActionSequence *moveCardSeq = [CCActionSequence actions:handOutCardDelay,ease,setToSlot, nil];
                            [cardNode runAction:moveCardSeq];
                            [self.allRemoveObjectArray addObject:cardNode];
                            actionCount++;
                        }
                    }
                }
            }
            isHandOutThirdCard = TRUE;
        }
    }else{
        [self initLoadingNode];
    }
}

-(void) handOutThirdCardWithNoAnimate{
    if (!isHandOutThirdCard) {
        [deckNode stopAllActions];
        
        if (gameModel.isHaveAllCallCardData && self.allUserDisplayUIArray.count > 0) {
            isHandOutThirdCard = TRUE;
            DLog(@"handOutThirdCard");
            if (gameModel.isOnSkipAnimate) {
                if (gameModel.currentObserverProcessState < ServerStateSetCallCard) {
                    gameModel.currentObserverProcessState = ServerStateSetCallCard;
                }
            }
            
            float startScale = 0.5f;
            int dealerDataIndex = gameModel.dealerChairNum;
            int dealerChairIndex = (int)[self.currentChairOrderIndex indexOfObject:[NSNumber numberWithInt:dealerDataIndex]];
            DLog(@"dealerChairIndex %i",dealerChairIndex);
            int cardIndex = 2;
            
            for (int chair = 0; chair<kMaxPlayer; chair++) {
                int handOutChairNumber = dealerChairIndex + 1 + chair; //ลำดับของที่นั่งที่จะเริ่มแจกไพ่
                if (handOutChairNumber >= kMaxPlayer) {
                    handOutChairNumber -= kMaxPlayer;
                }
                int dataIndex = [self.currentChairOrderIndex[handOutChairNumber] intValue];
                NSArray *playerInfo = gameModel.allPlayerInfo[dataIndex];
                DLog(@"playerInfo %@",playerInfo);
                if (![playerInfo isEqual:[NSNull null]]) {
                    int playerHand = [gameModel getPlayHandNum:dataIndex];
                    for (int hand = 0; hand<playerHand; hand++) {
                        DLog(@"handOutChairNumber %i dataIndex%i handNum %i",handOutChairNumber,dataIndex,playerHand);
                        bool isCall = [gameModel getIsCallChair:dataIndex hand:hand];
                        if(isCall){
                            /* บอกรับข้อมูลของไพ่ที่ต้องแจกให้ผู้เล่น */
                            int cardDataNumber = [gameModel getCardChair:dataIndex hand:hand cardOnHand:cardIndex];
                            
                            DLog(@"handOutChairNumber %i dataIndex%i cardDataNumber %i",handOutChairNumber,dataIndex,cardDataNumber);
                            
                            CardNode *cardNode = [CardNode initCardBackWithCardNumber:cardDataNumber];
                            cardNode.scale = startScale;
                            CGPoint cardPos = [self getCardOriginPosWithChairNumber:handOutChairNumber handNumber:hand cardOnHandIndex:cardIndex allHandAmount:playerHand];
                            cardNode.position = cardPos;
                            [self addChild:cardNode z:zOrderCard name:[NSString stringWithFormat:@"cardChair%ihand%icardIndex%i",handOutChairNumber,hand,cardIndex]];
                            
                            /* เก็บไพ่ไว้ใน Data Dict สำหรับใช้ตอนเปิดไพ่  */
                            [self.allPlayerCardDataDict setObject:cardNode forKey:cardNode.name];
                            if (gameModel.currentChairNumber == dataIndex && gameModel.currentPlayerStatus != PlayerStatusObserver) {
                                CCSprite *slot = [self.allHandDisplayCardSlot objectForKey:[NSString stringWithFormat:@"slotHand%islot%i",hand,cardIndex]];
                                [cardNode upToHand];
                                cardNode.position = slot.position;
                                cardNode.scale = 1.0f;
                            }
                            [self.allRemoveObjectArray addObject:cardNode];
                        }
                    }
                }
            }
            isHandOutThirdCard = TRUE;
        }
    }
}

#pragma mark - Open Card
-(void) openPokCard{
    DLog(@"openPokCard");
    for (int chair = 0; chair<kMaxPlayer; chair++) {
        if (self.currentChairOrderIndex.count > chair) {
            int dataIndex = [self.currentChairOrderIndex[chair] intValue];
            NSArray *playerInfo = [gameModel.allPlayerInfo objectAtIndex:dataIndex];
            if (![playerInfo isEqual:[NSNull null]]) {
                int playHandAmount = [gameModel getPlayHandNum:dataIndex];
                for (int hand = 0; hand < playHandAmount; hand++) {
                    CardsRankType cardsRankType = [gameModel getCardRankTypeChair:dataIndex hand:hand cardOnHandNumber:2];
                    DLog(@"cardsRankType %i",cardsRankType);
                    if (cardsRankType == CardsRankTypePok) {
                        if (dataIndex == gameModel.dealerChairNum) {
                            isDealerPok = YES;
                            DLog(@"isDealerPok = YES!!");
                        }
                        [self openCardChair:chair handNumber:hand];
                        int cardPoint = [gameModel getCardPointChair:dataIndex hand:hand cardOnHandNumber:2];
                        CardEffectNodeType effectType = CardEffectNodeTypeNone;
                        DLog(@"cardPoint %i",cardPoint);
                        switch (cardPoint) {
                            case 8:{
                                effectType = CardEffectNodeTypePok8;
                            }
                                break;
                            case 9:{
                                effectType = CardEffectNodeTypePok9;
                            }
                                break;
                            default:
                                break;
                        }
                        [self showCardEffectWithChairNumber:chair handNumber:hand handAmount:playHandAmount cardEffectType:effectType];
                    }
                }
            }
        }
    }
}

-(void) openCardChair:(int)chairNumber handNumber:(int)handNumber{
    DLog(@"openCard chair %i hand %i",chairNumber,handNumber);
    float openCardDelay = 0.1f;
    for (int i = 0; i<3; i++) {
        NSString *key = [NSString stringWithFormat:@"cardChair%ihand%icardIndex%i",chairNumber,handNumber,i];
        
        CardNode *cardNode = (CardNode *)[self.allPlayerCardDataDict objectForKey:key];
        if (cardNode) {
            CCActionDelay *delay = [CCActionDelay actionWithDuration:openCardDelay*i];
            CCActionCallBlock *callOpen = [CCActionCallBlock actionWithBlock:^{
                if (!cardNode.isOpen) {
                    [cardNode openCard];
                }
            }];
            CCActionSequence *seq = [CCActionSequence actions:delay,callOpen, nil];
            [self runAction:seq];
        }
    }
}

#pragma mark - CardEffect
-(void) showCardEffectWithChairNumber:(int)chairNumber handNumber:(int)handNumber handAmount:(int)handAmount cardEffectType:(CardEffectNodeType)cardEffectType {
    CGPoint effectPos;
    float effectStartScale = 0.75f;
    switch (chairNumber) {
        case 0:{
            if (gameModel.currentPlayerStatus != PlayerStatusObserver) {
                CCSprite *slot = [self.allHandDisplayCardSlot objectForKey:[NSString stringWithFormat:@"slotHand%islot%i",handNumber,1]];
                effectPos = slot.position;
                effectStartScale = 1.1f;
            }else{
                effectPos = [self getCardOriginPosWithChairNumber:chairNumber handNumber:handNumber cardOnHandIndex:0 allHandAmount:handAmount];
            }
            
        }
            break;
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:{
            effectPos = [self getCardOriginPosWithChairNumber:chairNumber handNumber:handNumber cardOnHandIndex:0 allHandAmount:handAmount];
            
        }
            break;
        default:
            break;
    }
    
    PDCardEffectNode *effectNode = [PDCardEffectNode initCardEffectWithCardEffectNodeType:cardEffectType];
    effectNode.position = effectPos;
    effectNode.scale = effectStartScale;
    [self addChild:effectNode z:zOrderEffect];
    
    
}


#pragma mark - Game Result
-(void) showResult{
    // Step
    //เวียนไปที่ผู้เล่นแต่ละคน โดยเริ่มจากคนที่ถัดจากเจ้ามือ
    //open Card
    //Show Result
    //Move Bet
    if (!isShowResult ) {
        if (gameModel.isHaveMatchResultData && self.allUserDisplayUIArray.copy > 0) {
            if (gameModel.isOnSkipAnimate) {
                if (gameModel.currentObserverProcessState < ServerStateGetResult) {
                    gameModel.currentObserverProcessState = ServerStateGetResult;
                }
            }
            
            int actionCount = 0;
            
            int dealerDataIndex = gameModel.dealerChairNum;
            int dealerChairIndex = (int)[self.currentChairOrderIndex indexOfObject:[NSNumber numberWithInt:dealerDataIndex]];
            DLog(@"dealerChairIndex %i",dealerChairIndex);
            if (dealerChairIndex >= 0 && dealerChairIndex < kMaxPlayer) {
                //    NSArray *emptyChair = [gameModel.emptyChairNumberSet allObjects];
                for (int chair = 0; chair<kMaxPlayer; chair++) {
                    /*คำนวนหาตำแหน่งเก้าอี้ที่เริ่มต้น โดยเริ่มจากเก้าอี้เจ้ามือ*/
                    int handOutChairNumber = dealerChairIndex + chair; //ลำดับของที่นั่งที่จะเริ่มเปิดไพ่
                    if (handOutChairNumber >= kMaxPlayer) {
                        handOutChairNumber -= kMaxPlayer;
                    }
                    int dataIndex = [self.currentChairOrderIndex[handOutChairNumber] intValue];
                    NSArray *playerInfo = gameModel.allPlayerInfo[dataIndex];
                    if (![playerInfo isEqual:[NSNull null]]) {
                        int playerHand = [gameModel getPlayHandNum:dataIndex];
                        for (int hand = 0; hand < playerHand; hand++) {
                            ResultType resultType = [gameModel getResultTypeChair:dataIndex hand:hand];
                            
                            CCActionDelay *delay = [CCActionDelay actionWithDuration:actionCount * 2.2f];
                            CCActionCallBlock *openCard = [CCActionCallBlock actionWithBlock:^{
                                [self openCardChair:handOutChairNumber handNumber:hand];
                            }];
                            CCActionCallBlock *showResultEffect = [CCActionCallBlock actionWithBlock:^{
                                if (dataIndex != gameModel.dealerChairNum) {
                                    CardEffectNodeType *cardEffectNode;
                                    switch (resultType) {
                                        case ResultTypeWin:  cardEffectNode = CardEffecNodeResultWin;  break;
                                        case ResultTypeDraw: cardEffectNode = CardEffecNodeResultDraw; break;
                                        case ResultTypeLose: cardEffectNode = CardEffecNodeResultLose; break;
                                        default:
                                            break;
                                    }
                                    [self showCardEffectWithChairNumber:handOutChairNumber handNumber:hand handAmount:playerHand cardEffectType:cardEffectNode];
                                }
                            }];
                            CCActionCallBlock *moveBet = [CCActionCallBlock actionWithBlock:^{
                                switch (resultType) {
                                    case ResultTypeWin:{
                                        [self moveBetFromChair:dealerChairIndex hand:0 handAmount:1 toChair:handOutChairNumber hand:hand handAmount:playerHand];
                                    }
                                        break;
                                    case ResultTypeLose:{
                                        [self moveBetFromChair:handOutChairNumber hand:hand handAmount:playerHand toChair:dealerChairIndex hand:0 handAmount:1];
                                    }
                                        break;
                                    default:
                                        break;
                                }
                            }];
                            CCActionSequence *seq = [CCActionSequence actions:delay,
                                                     openCard,
                                                     [CCActionDelay actionWithDuration:0.5f],
                                                     showResultEffect,
                                                     [CCActionDelay actionWithDuration:1.0f],
                                                     moveBet,
                                                     nil];
                            [self runAction:seq];
                            if (handOutChairNumber != dealerChairIndex) {
                                actionCount ++;
                            }
                        }
                    }
                }
                float delayTime = 3.0f*actionCount;
                CCActionDelay *allDelay = [CCActionDelay actionWithDuration:delayTime];
                CCActionCallBlock *callNextState = [CCActionCallBlock actionWithBlock:^{
                    //Update เงินของผู้เล่นที่มุมขวาบนของจอ
                    if (gameModel.currentPlayerStatus != PlayerStatusObserver) {
                        [gameModel requestUpdatePlayerChip];
                    }
                    [self runSceneActionState:SceneActionStateClearTable];
                    [self initLoadingNode];
                }];
                CCActionSequence *mainSeq = [CCActionSequence actions:allDelay,callNextState, nil];
                [self runAction:mainSeq];
                
                isShowResult = true;
            }
        }
    }
}

#pragma mark - Countdown decision timer
-(void) initCountDownWithTime:(float)time withPosition:(CGPoint)pos{
    countDownTick = time;
    countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateCountDown) userInfo:nil repeats:YES];
    CountDownTimerNode *countDownTimeNode = [CountDownTimerNode initCountDownTimerWithTime:countDownTick];
    countDownTimeNode.position = pos;
    [self addChild:countDownTimeNode z:zOrderMenu name:@"countDownTimeNode"];
}
-(void) updateCountDown{
    countDownTick -= 1.0f;
    CountDownTimerNode *countDownTimeNode = (CountDownTimerNode *)[self getChildByName:@"countDownTimeNode" recursively:NO];
    if (countDownTick > 0) {
        [countDownTimeNode decreaseTime];
    }else{
        [self removeTimer];
        switch (currentDecision) {
            case DecisionTypeSetHand:{
                
            }
                break;
            case DecisionTypeSetBet:{
                switch (gameModel.currentPlayerStatus) {
                    case PlayerStatusDealer:
                        [self removeSetBetMenu];
                        [self removeWaitingSetBetPopUp];
                        break;
                    case PlayerStatusPlayer:{
                        [self removeSetBetMenu];
                        [self removeWaitingSetBetPopUp];
                    }
                        break;
                    case PlayerStatusObserver:{
                    }
                        break;
                    default:
                        break;
                }
                
                placeBet[currentActiveHand-1] = gameModel.roomMinBet;
                currentActiveHand ++;
                if (currentActiveHand <= gameModel.playHandAmount) {
                    [self initSetBetMenu];
                }else{
                    currentActiveHand = 1;
                    [gameModel sendBetHand1:placeBet[0] hand2:placeBet[1]];
                    currentDecision = DecisionTypeNone;
                    [self initLoadingNode];
                }
            }
                break;
            case DecisionTypeCutCard:{
                switch (gameModel.currentPlayerStatus) {
                    case PlayerStatusDealer:
                        [self removeCutCardMenu];
                        [self removeWaitingSetCutCardPopUp];
                        [gameModel sendCutCard:NO];
                        currentDecision = DecisionTypeNone;
                        [self initLoadingNode];
                        break;
                    case PlayerStatusPlayer:{
                        [self removeCutCardMenu];
                        [self removeWaitingSetCutCardPopUp];
                        [gameModel sendCutCard:NO];
                        currentDecision = DecisionTypeNone;
                        [self initLoadingNode];
                    }
                        break;
                    case PlayerStatusObserver:{
                    }
                        break;
                    default:
                        break;
                }
            }
                break;
            case DecisionTypeCallCard:{
                [self removeCallCardMenu];
                isCallCard[currentActiveHand-1] = NO;
                int cardPoint = [gameModel getCardPointChair:gameModel.currentChairNumber hand:currentActiveHand-1 cardOnHandNumber:2];
                if (cardPoint <= 4) {
                    isCallCard[currentActiveHand-1] = YES;
                }
                currentActiveHand ++;
                if (currentActiveHand <= gameModel.playHandAmount) {
//                    [self initCallCardMenu];
                }else{
                    currentActiveHand = 1;
                    [gameModel sendCallCardHand1:isCallCard[0] hand2:isCallCard[1]];
                    currentDecision = DecisionTypeNone;
                    [self initLoadingNode];
                }
            }
                break;
                
            default:
                break;
        }
    }
}

-(void)removeTimer{
    [self removeChildWithName:@"countDownTimeNode"];
    if (countdownTimer) {
        [countdownTimer invalidate];
        countdownTimer = nil;
    }
}

#pragma mark - Request Dealer

-(BOOL) canRequestDealer{
    if (gameModel.currentPlayerStatus == PlayerStatusPlayer && isSetHandComplete) {
        if (shareGame.chip >= [BetProcess getMinChipForPlayAsDealerWithRoomMaxBet:gameModel.roomMaxBet]) {
            return YES;
        }
    }
    return NO;
}
-(void) initRequestDealerButton{
    [self removeRequestDealerButton];
    CCSprite *popUpBackground = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"bg_popup.png"]];
    popUpBackground.position = ccp(WINS.width*0.5f,WINS.height*0.5f);
    [self addChild:popUpBackground z:zOrderMenu name:@"popUpBackground"];
    
    CCLabelTTF *waitingLabel = [CCLabelTTF labelWithString:@"Waiting for dealer start...." fontName:FONT_TRAJANPRO_BOLD fontSize:14];
    waitingLabel.horizontalAlignment = CCTextAlignmentCenter;
    waitingLabel.color = [CCColor colorWithCcColor3b:FONT_COLOR];
    waitingLabel.position = ccp(WINS.width*0.5f, WINS.height*0.5f+popUpBackground.contentSize.height*0.25f);
    [self addChild:waitingLabel z:zOrderMenu name:@"waitingLabel"];
    
    if (!gameModel.isHaveDealer) {
        [waitingLabel setString:@"This room is no dealer."];
    }
    
    if ([self canRequestDealer]) {
        CCLabelTTF *requestDealerLabel = [CCLabelTTF labelWithString:@"You can send a request to\nbe the dealer." fontName:FONT_TRAJANPRO_BOLD fontSize:14];
        requestDealerLabel.horizontalAlignment = CCTextAlignmentCenter;
        requestDealerLabel.color = [CCColor colorWithCcColor3b:FONT_COLOR];
        requestDealerLabel.position = ccp(WINS.width*0.5f, WINS.height*0.5f);
        [self addChild:requestDealerLabel z:zOrderMenu name:@"requestDealerLabel"];
        
        CCButton *requestDealerButton = [CCButton buttonWithTitle:nil
                                                      spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_request.png"]
                                           highlightedSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_requestC.png"] disabledSpriteFrame:nil];
        requestDealerButton.position = ccp(WINS.width*0.5f,WINS.height*0.5f-popUpBackground.contentSize.height*0.25f);
        [self addChild:requestDealerButton z:zOrderMenu name:@"requestDealerButton"];
        [requestDealerButton setBlock:^(id sender){
            isOnSendRequestDealer = YES;
            [gameModel requestDealer];
            [self removeRequestDealerButton];
        }];
    }else{
        if (!gameModel.isHaveDealer) {
            CCLabelTTF *requestDealerLabel = [CCLabelTTF labelWithString:@"Your chip not enough to request dealer\nPlease join in other room." fontName:FONT_TRAJANPRO_BOLD fontSize:14];
            requestDealerLabel.horizontalAlignment = CCTextAlignmentCenter;
            requestDealerLabel.color = [CCColor colorWithCcColor3b:FONT_COLOR];
            requestDealerLabel.position = ccp(WINS.width*0.5f, WINS.height*0.5f);
            [self addChild:requestDealerLabel z:zOrderMenu name:@"requestDealerLabel"];
        }
    }
}


-(void) removeRequestDealerButton{
    [self removeChildWithName:@"popUpBackground"];
    [self removeChildWithName:@"waitingLabel"];
    [self removeChildWithName:@"requestDealerLabel"];
    [self removeChildWithName:@"requestDealerButton"];
}

-(void) initGetRequestDealerPopUpWithRequestData:(NSDictionary *)requestData{
    DLog(@"initGetRequestDealerPopUpWithRequestData");
    [self removeStartGameButton];
    [self removeAIButton];
    
    if (requestData && !isRequestDealerPopUpOn) {
        NSString *userId = [requestData objectForKey:@"user_id"];
        if (![userId isEqualToString:shareGame.userId]) {
            isRequestDealerPopUpOn = true;
            CCSprite *popUpBackground = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"bg_popup.png"]];
            popUpBackground.position = ccp(WINS.width*0.5f,WINS.height*0.5f);
            [self addChild:popUpBackground z:zOrderMenu name:@"popUpBackground"];
            
            NSString *requestDisplayName = [requestData objectForKey:@"displayname"];
            NSString *requestString = [NSString stringWithFormat:@"Player %@\nWould like to be the dealer",requestDisplayName];
            CCLabelTTF *getRequestDealerLabel = [CCLabelTTF labelWithString:requestString fontName:FONT_TRAJANPRO_BOLD fontSize:14];
            getRequestDealerLabel.horizontalAlignment = CCTextAlignmentCenter;
            getRequestDealerLabel.color = [CCColor colorWithCcColor3b:FONT_COLOR];
            getRequestDealerLabel.position = ccp(WINS.width*0.5f, WINS.height*0.5f);
            [self addChild:getRequestDealerLabel z:zOrderMenu name:@"getRequestDealerLabel"];
            
            CCButton *allowButton = [CCButton buttonWithTitle:nil
                                                  spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_allow.png"]
                                       highlightedSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_allowC.png"] disabledSpriteFrame:nil];
            
            CCButton *declineButton = [CCButton buttonWithTitle:nil
                                                    spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_decline.png"]
                                         highlightedSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_declineC.png"]
                                            disabledSpriteFrame:nil];
            
            allowButton.position = ccp(WINS.width*0.5f-popUpBackground.contentSize.width*0.25f,WINS.height*0.5f-popUpBackground.contentSize.height*0.25f);
            [self addChild:allowButton z:zOrderMenu name:@"allowButton"];
            [allowButton setBlock:^(id sender){
                isRequestDealerPopUpOn = false;
                [gameModel allowRequestDealer];
                [self removeGetRequestDealerPopUp];
            }];
            
            declineButton.position = ccp(WINS.width*0.5f+popUpBackground.contentSize.width*0.25f,WINS.height*0.5f-popUpBackground.contentSize.height*0.25f);
            [self addChild:declineButton z:zOrderMenu name:@"declineButton"];
            [declineButton setBlock:^(id sender){
                isRequestDealerPopUpOn = false;
                [gameModel declineRequestDealer];
                [self removeGetRequestDealerPopUp];
            }];
        }
    }
}
-(void) removeGetRequestDealerPopUp{
    [self removeChildWithName:@"popUpBackground"];
    [self removeChildWithName:@"getRequestDealerLabel"];
    [self removeChildWithName:@"allowButton"];
    [self removeChildWithName:@"declineButton"];
    
    isRequestDealerPopUpOn = false;
}

#pragma mark - Init Alert PopUp
-(void) initAlertPopUpWithString:(NSString *)alertString popUpName:(NSString *)popUpName{
    PDPopUpNode *alertPopUp = [PDPopUpNode initPopUpNodeWithTarget:self popUpSize:CGSizeMake(WINS.width*0.75f, WINS.height*0.3f)];
    alertPopUp.position = ccp(WINS.width*0.5f, WINS.height*0.5f);
    CCLabelTTF *alert = [CCLabelTTF labelWithString:alertString
                                           fontName:FONT_TRAJANPRO_BOLD
                                           fontSize:16 dimensions:CGSizeMake(WINS.width*0.7f, WINS.height*0.25f)];
    alert.position = ccp(0, -alert.contentSize.height*0.3f);
    alert.anchorPoint = ccp(0.5f, 0.5f);
    alert.color = [CCColor colorWithCcColor3b:FONT_COLOR];
    alert.horizontalAlignment = CCTextAlignmentCenter;
    [alertPopUp addChild:alert];
    [self addChild:alertPopUp z:zOrderPopUp name:popUpName];
}


-(void) initPlayerProfilePopUpWithData:(NSDictionary *)playerData{
    DLog(@"playerData %@",playerData);
    CCSprite *background = (CCSprite *)[self getChildByName:@"background" recursively:NO];
    PDPopUpNode *playerProfilePopUp = [PDPopUpNode initPopUpNodeWithTarget:self popUpSize:CGSizeMake(WINS.width*0.8f, background.contentSize.height*0.45f)];
    playerProfilePopUp.position = ccp(WINS.width*0.5f, WINS.height*0.5f);
    [self addChild:playerProfilePopUp z:zOrderPopUp name:@"playerProfilePopUp"];
    
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"Player Info" fontName:FONT_TRAJANPRO_BOLD fontSize:18];
    label.color = [CCColor colorWithCcColor3b:FONT_COLOR];
    label.anchorPoint = ccp(0.0f, 0.5f);
    label.position = ccp(-playerProfilePopUp.contentSize.width*0.45f, playerProfilePopUp.contentSize.height*0.5f-label.contentSize.height*1.1f);
    [playerProfilePopUp addChild:label];
    
    CCSprite *lineSprite = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"popup_underline.png"] ];
    lineSprite.anchorPoint = ccp(0.0f, 0.5f);
    lineSprite.position = ccp(label.position.x,label.position.y-label.contentSize.height*0.6f);
    [playerProfilePopUp addChild:lineSprite];
    
    CCSprite *playerPic = [PDHelperFunction GetSpriteWithURL:[playerData objectForKey:@"pic"]];
    playerPic.position = ccp(0, playerProfilePopUp.contentSize.height*0.18f);
    [playerProfilePopUp addChild:playerPic];
    
    
    NSString *playerName = [playerData objectForKey:@"displayname"];
    if (playerData == nil) {
        playerName = @"Unknown";
    }
    CCLabelTTF *playerDisplayNameLabel = [CCLabelTTF labelWithString:playerName fontName:FONT_TRAJANPRO_BOLD fontSize:14 dimensions:CGSizeMake(playerProfilePopUp.contentSize.width*0.8f, playerProfilePopUp.contentSize.height*0.2f)];
    playerDisplayNameLabel.color = [CCColor colorWithCcColor3b:FONT_COLOR];
    playerDisplayNameLabel.horizontalAlignment = CCTextAlignmentCenter;
    playerDisplayNameLabel.position = ccp(0, -playerProfilePopUp.contentSize.height*0.1f);
    [playerProfilePopUp addChild:playerDisplayNameLabel z:zOrderPopUp name:@"displayNameLabel"];

    NSInteger chip = [[playerData objectForKey:@"chips"]integerValue];
    NSString *chipString = [NSString stringWithFormat:@"$%@",[PDHelperFunction getChipStringWithChip:chip]];
    
    CCLabelTTF *playerChipLabel = [CCLabelTTF labelWithString:chipString fontName:FONT_TRAJANPRO_BOLD fontSize:22];
    playerChipLabel.color = [CCColor colorWithCcColor3b:FONT_COLOR];
    playerChipLabel.anchorPoint = ccp(0.5f, 0.5f);
    playerChipLabel.position = ccp(0, -playerProfilePopUp.contentSize.height*0.125f);
    [playerProfilePopUp addChild:playerChipLabel z:zOrderPopUp name:@"playerChipLabel"];
    
    int fontSize = 16;
    
    float scorePosY[3];
    scorePosY[0] = -playerProfilePopUp.contentSize.height*0.2f;
    scorePosY[1] = -playerProfilePopUp.contentSize.height*0.275f;
    scorePosY[2] = -playerProfilePopUp.contentSize.height*0.35f;
    
    CCLabelTTF *winLabel = [CCLabelTTF labelWithString:@"Win" fontName:FONT_TRAJANPRO_BOLD fontSize:fontSize];
    winLabel.color = [CCColor colorWithCcColor3b:FONT_COLOR];
    winLabel.anchorPoint = ccp(0.0f, 0.5f);
    winLabel.position = ccp(-playerProfilePopUp.contentSize.width*0.25f, scorePosY[0]);
    [playerProfilePopUp addChild:winLabel z:zOrderPopUp name:@"winLabel"];
    
    CCLabelTTF *drawLabel = [CCLabelTTF labelWithString:@"Draw" fontName:FONT_TRAJANPRO_BOLD fontSize:fontSize];
    drawLabel.color = [CCColor colorWithCcColor3b:FONT_COLOR];
    drawLabel.anchorPoint = ccp(0.0f, 0.5f);
    drawLabel.position = ccp(winLabel.position.x, scorePosY[1]);
    [playerProfilePopUp addChild:drawLabel z:zOrderPopUp name:@"drawLabel"];
    
    CCLabelTTF *loseLabel = [CCLabelTTF labelWithString:@"Lose" fontName:FONT_TRAJANPRO_BOLD fontSize:fontSize];
    loseLabel.color = [CCColor colorWithCcColor3b:FONT_COLOR];
    loseLabel.anchorPoint = ccp(0.0f, 0.5f);
    loseLabel.position = ccp(winLabel.position.x, scorePosY[2]);
    [playerProfilePopUp addChild:loseLabel z:zOrderPopUp name:@"winLabel"];
    
    
    
    int wins = [[playerData objectForKey:@"wins"]intValue];
    int loses = [[playerData objectForKey:@"loses"]intValue];
    int draws = [[playerData objectForKey:@"draws"]intValue];
    
    CCLabelTTF *winAmountLabel = [CCLabelTTF labelWithString:[PDHelperFunction getChipStringWithChip:wins] fontName:FONT_TRAJANPRO_BOLD fontSize:fontSize];
    winAmountLabel.color = [CCColor colorWithCcColor3b:FONT_COLOR];
    winAmountLabel.anchorPoint = ccp(1.0f, 0.5f);
    winAmountLabel.position = ccp(playerProfilePopUp.contentSize.width*0.1f, scorePosY[0]);
    [playerProfilePopUp addChild:winAmountLabel z:zOrderPopUp name:@"winAmountLabel"];
    
    CCLabelTTF *drawAmountLabel = [CCLabelTTF labelWithString:[PDHelperFunction getChipStringWithChip:draws] fontName:FONT_TRAJANPRO_BOLD fontSize:fontSize];
    drawAmountLabel.color = [CCColor colorWithCcColor3b:FONT_COLOR];
    drawAmountLabel.anchorPoint = ccp(1.0f, 0.5f);
    drawAmountLabel.position = ccp(winAmountLabel.position.x, scorePosY[1]);
    [playerProfilePopUp addChild:drawAmountLabel z:zOrderPopUp name:@"drawAmountLabel"];
    
    CCLabelTTF *loseAmountLabel = [CCLabelTTF labelWithString:[PDHelperFunction getChipStringWithChip:loses] fontName:FONT_TRAJANPRO_BOLD fontSize:fontSize];
    loseAmountLabel.color = [CCColor colorWithCcColor3b:FONT_COLOR];
    loseAmountLabel.anchorPoint = ccp(1.0f, 0.5f);
    loseAmountLabel.position = ccp(winAmountLabel.position.x, scorePosY[2]);
    [playerProfilePopUp addChild:loseAmountLabel z:zOrderPopUp name:@"loseAmountLabel"];
    
    for (int i = 0; i<3; i++) {
        CCLabelTTF *timesLabel = [CCLabelTTF labelWithString:@"Times" fontName:FONT_TRAJANPRO_BOLD fontSize:fontSize-2];
        timesLabel.color = [CCColor colorWithCcColor3b:FONT_COLOR];
        timesLabel.anchorPoint = ccp(0.0f, 0.5f);
        timesLabel.position = ccp(playerProfilePopUp.contentSize.width*0.15f, scorePosY[i]);
        [playerProfilePopUp addChild:timesLabel z:zOrderPopUp name:[NSString stringWithFormat:@"timesLable%i",i]];
    }
    
    //getProfile
    /*
    NSString *displayName;
    CCSprite *displayPic;
    int chip;
    int wins;
    int loses;
    int draws;
    */
}

#pragma mark - Update
-(void) update:(CCTime)delta{
    [gameModel update:delta];
    
}

#pragma mark - Enable Button
-(void) setStartButtonEnable:(BOOL)enable{
    
}

#pragma mark - Press Button
-(void) pressQuitButton:(id)sender{
    [gameModel quitRoom];
    /*
    CCButton *quitButton = (CCButton *)sender;
    PDLobbySceneType sceneType = [quitButton.name intValue];
    [self goToLobbySceneWithLobbySceneType:sceneType];
     */
}


-(void) pressQuitChairButton:(id)sender{
    [gameModel requestQuitChair];
    [self removeAIButton];
    
    [self setQuitChairButtonEnable:NO];
    [self initSitButton];
    
    [self drawPlayerDisplay];
}

#pragma mark - Process Data

-(void) processCurrentChairOrderData{
    [self.currentChairOrderIndex removeAllObjects];
    for (int i = 0; i<kMaxPlayer; i++) {
        int chairIndex = gameModel.currentChairNumber + i;
        if (chairIndex >= kMaxPlayer) {
            chairIndex = chairIndex - kMaxPlayer;
        }
        [self.currentChairOrderIndex addObject:[NSNumber numberWithInt:chairIndex]];
    }
//    DLog(@"self.currentChairOrderIndex %@",self.currentChairOrderIndex);
}

-(int) getChairIndexDisplay:(int)chairNumber{
    //เนื่องจากตำแหน่งการนั่งของผู้เล่น จะอยู่ด้านล่างของจอเสมอ จึงต้องปรับตำแหน่งการแสดงผลของผู้เล่นและสิ่งต่างๆให้สัมพันธ์กับตำแหน่งผู้เล่น
    int chairIndexForShow = chairNumber - gameModel.currentChairNumber;
    if (chairIndexForShow < 0) {
        chairIndexForShow += 6;
    }
    return chairIndexForShow;
}
-(CGPoint) getChairPos:(int) chairNumber{
    CCSprite *chair = [self.chairSpriteArray objectAtIndex:chairNumber];
    return chair.position;
}

-(CGPoint) getChipDefaultPosWithChairNumber:(int)chairNumber handNumber:(int)handNumber allHandAmount:(int)allHandAmount{
    CCSprite *chair = [self.chairSpriteArray objectAtIndex:chairNumber];
    CGPoint pos;
    float x,y;
    x = y = 0.0f;

    switch (chairNumber) {
        case 0:{
            x = chair.position.x + ((1+handNumber-((allHandAmount+1) *0.5f))*chair.contentSize.width*0.35f);
            y = chair.position.y + chair.contentSize.height*0.5f;
        }
            break;
        case 1:
        case 2:{
            x = chair.position.x - chair.contentSize.width*0.5f;
            y = chair.position.y + (1+handNumber-((allHandAmount+1) *0.5f))*chair.contentSize.width*0.3f;
        }
            break;
        case 3:{
            x = chair.position.x + ((1+handNumber-((allHandAmount+1) *0.5f))*chair.contentSize.width*0.35f * - 1);
            y = chair.position.y - chair.contentSize.height*0.46f;
        }
            break;
        case 4:
        case 5:{
            x = chair.position.x + chair.contentSize.width*0.5f;
            y = chair.position.y + ((1+handNumber-((allHandAmount+1) *0.5f))*chair.contentSize.width*0.3f * -1 );
        }
            break;
        default:
            break;
    }
    pos = ccp(x , y);
    return pos;
}
-(CGPoint) getCardOriginPosWithChairNumber:(int)chairNumber handNumber:(int)handNumber cardOnHandIndex:(int)cardOnHandIndex allHandAmount:(int)allHandAmount{
    int maxCardOnHand   = 3;
    CCSprite *chair = [self.chairSpriteArray objectAtIndex:chairNumber];
    CGPoint pos;
    float x,y;
    x = y = 0.0f;
    
    switch (chairNumber) {
        case 0:{
            x = chair.position.x + ((1+handNumber-((allHandAmount+1) *0.25f))*chair.contentSize.width*0.45f);
            y = chair.position.y + chair.contentSize.height*0.5f;
            x = x + ((cardOnHandIndex - (maxCardOnHand + 1))*chair.contentSize.width*0.11f);
        }
            break;
        case 1:
        case 2:{
            x = chair.position.x - chair.contentSize.width*0.13f;
            y = chair.position.y + (1+handNumber-((allHandAmount+1) *0.45f))*chair.contentSize.width*0.3f;
            
            x = x + ((cardOnHandIndex - (maxCardOnHand + 1))*chair.contentSize.width*0.11f) ;
        }
            break;
        case 3:{
            x = chair.position.x + ((1+handNumber-((allHandAmount+1) *0.25f))*chair.contentSize.width*0.45f * - 1);
            y = chair.position.y - chair.contentSize.height*0.46f;
            
            
            x = x + ((cardOnHandIndex - (maxCardOnHand + 1))*chair.contentSize.width*0.11f * -1) ;
        }
            break;
        case 4:
        case 5:{
            x = chair.position.x + chair.contentSize.width*0.87f;
            y = chair.position.y + ((1+handNumber-((allHandAmount+1) *0.55f))*chair.contentSize.width*0.3f * -1 );
            
            x = x + ((cardOnHandIndex - (maxCardOnHand + 1))*chair.contentSize.width*0.11f) ;
        }
            break;
        default:
            break;
    }
    pos = ccp(x , y);
    return pos;
}
#pragma mark - Touch
-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
//    [deckNode runAnimationShuffle];
}

-(void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    CGPoint touchPos = [touch locationInNode:self];
    CGRect checkRect = CGRectMake(deckNode.position.x-deckNode.contentSize.width*0.5f, deckNode.position.y-deckNode.contentSize.height*0.5f, deckNode.contentSize.width, deckNode.contentSize.height);
    BOOL isContain = CGRectContainsPoint(checkRect, touchPos);
    if (isContain) {
        // ส่งผลว่าต้องการตัดไพ่
        // As a result, you want to cut the cards
        [gameModel sendCutCard:YES];
        [self removeCutCardMenu];
    }
}

#pragma mark - Clear Data

-(void) resetValueToDefault{
    DLog(@"resetValueToDefault");
    placeBet[0] = 0;
    placeBet[1] = 0;
    
    isCutCard = false;
    
    isCallCard[0] = 0;
    isCallCard[1] = 0;
    
    isAnimateCutCard = false;
    isAnimateShuffleCard = false;
    isDrawBet = false;
    isHandOutCard = false;
    isHandOutThirdCard = false;
    isShowResult = false;
    
    
    
    isRequestDealerPopUpOn = NO;
    isDealerPressStartGame = NO;
    
    isDealerPok = NO;
    [self.allPlayerCardDataDict removeAllObjects];
    
    switch (gameModel.currentPlayerStatus) {
        case PlayerStatusDealer:{
            currentActiveHand = 1;
        }
            break;
        case PlayerStatusPlayer:{
            isOnSendRequestDealer = FALSE;
        }
            break;
        case PlayerStatusObserver:{
            
        }
            break;
        default:
            break;
    }
}

-(void) clearTable{
    [self removeWaitingSetBetPopUp];
    [self removeWaitingSetCutCardPopUp];
    [self removeCutCardMenu];
    [self removeSetBetMenu];
    [self removeCallCardMenu];
    for (CCNode *node in self.allRemoveObjectArray) {
//        [node removeAllChildrenWithCleanup:YES];
//        [node stopAllActions];
        [node removeFromParentAndCleanup:YES];
    }
    [self.allRemoveObjectArray removeAllObjects];
    /*
    [self.allPlayerCardDataDict removeAllObjects];
    [self.allPlayerChipDataDict removeAllObjects];
     */
}

//ใช้สำหรับไม่ต้องคอยพิมพ์เช็คว่ามี child หรือไม่ทุกครั้งที่ต้องการ remove child
-(void) removeChildWithName:(NSString *)childName{

    if ([self getChildByName:childName recursively:NO]) {
        [self removeChildByName:childName cleanup:YES];
    }
}

#pragma mark - Change Scene
-(void) goToLobbySceneWithLobbySceneType:(PDLobbySceneType)sceneType{
    [[CCDirector sharedDirector]replaceScene:[PDLobbyScene sceneWithLobbySceneType:sceneType] withTransition:[CCTransition transitionFadeWithDuration:0.5f]];
}


#pragma mark - PDGameModelDelegate

-(void) actionCompleteCallbackWithActionType:(CallbackActionType)actionType data:(NSDictionary *)data{
    switch (actionType) {
        case CallbackActionTypeEnterChairComplete:{
            DLog(@"CallbackActionTypeEnterChairComplete");
            [self removePreparing];
            [self setQuitChairButtonEnable:YES];
            [self removeObserverModeWindow];
            if (gameModel.currentPlayerStatus == PlayerStatusPlayer) {
                isOnSendRequestDealer = false;
            }
            
            if (gameModel.currentPlayerStatus == PlayerStatusPlayer && gameModel.enterChairStatus == EnterChairStatusComplete) {
                [self initSetHandMenu];
            }
        }
            break;
        case CallbackActionTypeQuitChairComplete:{
            DLog(@"CallbackActionTypeQuitChairComplete");
            [self removeRequestDealerButton];
            [self removePlayerHandDetail];
            [self removeSetHandMenu];
            isSetHandComplete = false;
            [self setQuitChairButtonEnable:NO];
            [self removeStartGameButton];
        }
            break;
        case CallbackActionTypeUpdatePlayerOnChairData:{
            
            if (currentActionState == SceneActionStateWaitingForStart) {
                [self removePreparing];
                [self removeLoadingNode];
                [self processCurrentChairOrderData];
                [self drawPlayerDisplay];
                DLog(@"gameModel.currentPlayerStatus %i",gameModel.currentPlayerStatus);
                switch (gameModel.currentPlayerStatus) {
                    case PlayerStatusDealer:{
                        [self setDealerHandDetail];
                        if (gameModel.emptyChairNumberSet.count <= 4 && !isDealerPressStartGame) {
                            if (!isRequestDealerPopUpOn) {
                                [self initStartGameButton];
                            }
                        }else{
                            [self removeStartGameButton];
                        }
                        if (!isRequestDealerPopUpOn) {
                            [self initAIButton];
                        }
                    }
                        break;
                    case PlayerStatusPlayer:{
                        [self removeStartGameButton];
                        if (!isOnSendRequestDealer && isSetHandComplete && gameModel.enterChairStatus == EnterChairStatusComplete)  {
                            [self setEnableSecondHandEnable:YES];
                            [self initRequestDealerButton];
                        }else if (isOnSendRequestDealer && !gameModel.isHaveDealer){
                            [self initRequestDealerButton];
                        }
                    }
                        break;
                    case PlayerStatusObserver:{
                        [self removeStartGameButton];
                        [self initObserverModeWindow];
                        DLog(@"gameModel.isOnSkipAnimate %i",gameModel.isOnSkipAnimate);
                        if (!gameModel.isOnSkipAnimate) {
                            [self removePreparing];
                            [self initSitButton];
                        }else{
                            [self removePreparing];
                        }
                    }
                        break;
                        
                    default:
                        break;
                }
                
            }else{
                [self removeStartGameButton];
                [self removeSitButton];
                DLog(@"currentActionState != SceneActionStateWaitingForStart");
                DLog(@"gameModel.currentServerState %i",gameModel.currentServerState);
                if (gameModel.currentServerState == ServerStateWaitingForStart) {
                    currentActionState = SceneActionStateWaitingForStart;
                }
                
                
                switch (gameModel.currentPlayerStatus) {
                    case PlayerStatusDealer:{
                        
                    }
                        break;
                    case PlayerStatusPlayer:{
                        
                    }
                        break;
                    case PlayerStatusObserver:{
                        if (isComeToSceneFirstTime) {
                            isComeToSceneFirstTime = NO;
                            [self removePreparing];
                            [self removeSitButton];
                            [self processCurrentChairOrderData];
                            [self initObserverModeWindow];
                            [self drawPlayerDisplay];
                            
                            //เผื่อกรณีหลุดจาก dealer/player to observer
                            [self removeStartGameButton];
                            [self removeRequestDealerButton];
                            
                            [gameModel requestGetAllBetData];
                        }
                    }
                        break;
                    default:
                        break;
                }
            }
        }
            break;
        case CallbackActionTypeGameStart:{
            [self.allPlayerChipDataDict  removeAllObjects];
            [self initLoadingNode];
//            [self setQuitButtonEnable:NO];
            switch (gameModel.currentPlayerStatus) {
                case PlayerStatusDealer:{
                    [self setDealerHandDetail];
                    [self removeGetRequestDealerPopUp];
                    [self setQuitButtonEnable:NO];
                    [self setQuitChairButtonEnable:NO];
                }
                    break;
                case PlayerStatusPlayer:{
                    [self setEnableSecondHandEnable:NO];
                    [self setQuitButtonEnable:NO];
                    [self setQuitChairButtonEnable:NO];
                    [self removeRequestDealerButton];
                }
                    break;
                case PlayerStatusObserver:{
                    //แจ้งว่าให้รอจนกว่าจะจบรอบการเล่นนี้
                    [self removeSitButton];
                    DLog(@"PlayerStatusObserver CallbackActionTypeGameStart");
                    
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case CallbackActionTypeSetBetComplete:{
            
        }
            break;
        case CallbackActionTypeGetAllBetComplete:{
            
        }
            break;
        case CallbackActionTypeSetCutCardComplete:{
            
        }
            break;
        case CallbackActionTypeGetAllCutCardComplete:{
            
            
        }
            break;
        case CallbackActionTypeSetCallCardComplete:{
            
        }
            break;
        case CallbackActionTypeGetAllCallCardComplete:{
            
           
            
        }
            break;
        case CallbackActionTypeGetGameResultComplete:{
        }
            break;
        case CallbackActionTypeUpdateStateTimer:{
            
        }
            break;
        case CallbackActionTypeChangeState:{
            
        }
            break;
        case CallbackActionTypeQuitRoom:{
            [self goToLobbySceneWithLobbySceneType:comeFromLobbySceneType];
        }
            break;
        case CallbackActionTypeGetRequestDealer:{
            if (gameModel.currentServerState == ServerStateWaitingForStart) {
                
                [self initGetRequestDealerPopUpWithRequestData:data];
            }
        }
            break;
        case CallbackActionTypeSetIsDealer:{
            [self removeRequestDealerButton];
        }
            break;
        case CallbackActionTypeChangeFromDealerToPlayer:{
            isSetHandComplete = FALSE;
            [self initSetHandMenu];
            [self removeStartGameButton];
            [self removeAIButton];
        }
            break;
        case CallbackActionTypeChangeFromPlayerToDealer:{
            isSetHandComplete = TRUE;
            gameModel.playHandAmount = 1;
            currentActiveHand = 1;
            
            
            [self setDealerHandDetail];
        }
            
        case CallbackActionTypeGetPlayerInfo:{
            if (isOnRequestPlayerInfo) {
                isOnRequestPlayerInfo = false;
                [self initPlayerProfilePopUpWithData:data];
            }
        }
            break;
        case CallbackActionTypeUpdatePlayerChip:{
            CCLabelTTF *playerChipLabel = (CCLabelTTF*)[self getChildByName:@"playerChipLabel" recursively:NO];
            [playerChipLabel setString:[NSString stringWithFormat:@"$%@",[PDHelperFunction getChipStringWithChip:shareGame.chip]]];
                                
        }
            break;
            
        default:
            break;
    }
}
-(void) actionFailureCallbackWithActionType:(CallbackActionType)actiontype failureString:(NSString *)failureString{
    switch (actiontype) {
        case CallbackActionTypeEnterChairComplete:{
            [self initAlertPopUpWithString:@"The game has already started.\nPlease waiting until game end." popUpName:@"alertPopUp"];
        }
            break;
            
        default:
            break;
    }
}


-(void) getDataCompleteWithDataType:(GetDataType)dataType{
    switch (dataType) {
        case GetDataTypeAllBet:{
            [self removeLoadingNode];
            switch (gameModel.currentPlayerStatus) {
                case PlayerStatusDealer:{
                    [self runSceneActionState:SceneActionStateDrawBet];
                }
                    break;
                case PlayerStatusPlayer:{
                    [self runSceneActionState:SceneActionStateDrawBet];
                }
                    break;
                case PlayerStatusObserver:{
                    if (gameModel.isOnSkipAnimate) {
                        currentActionState = SceneActionStateDrawBet;
                        [self drawPlayerBet];
                    }else{
                        [self removeSitButton];
                        [self runSceneActionState:SceneActionStateDrawBet];
                    }
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case GetDataTypeAllCardData:{
            
        }
            break;
        case GetDataTypeAllCutCard:{
            [self removeLoadingNode];
            switch (gameModel.currentPlayerStatus) {
                case PlayerStatusDealer:{
                    [self runSceneActionState:SceneActionStateCutCard];
                }
                    break;
                case PlayerStatusPlayer:{
                    [self runSceneActionState:SceneActionStateCutCard];
                }
                    break;
                case PlayerStatusObserver:{
                    if (gameModel.currentServerState >= ServerStateSetCutCard) {
                        if (gameModel.isOnSkipAnimate) {
                            currentActionState = SceneActionStateCutCard;
//                            [self handOutCardWithNoAnimate];
                        }else{
                            [self runSceneActionState:SceneActionStateCutCard];
                        }
                    }
                    
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case GetDataTypeAllCallThirdCard:{
            [self removeLoadingNode];
            switch (gameModel.currentPlayerStatus) {
                case PlayerStatusDealer:{
                    [self handOutCardWithNoAnimate];
                    [self runSceneActionState:SceneActionStateHandOutThirdCard];
                }
                    break;
                case PlayerStatusPlayer:{
                    [self handOutCardWithNoAnimate];
                    [self runSceneActionState:SceneActionStateHandOutThirdCard];
                }
                    break;
                case PlayerStatusObserver:{
                    [self handOutCardWithNoAnimate];
                    if (gameModel.currentServerState >= ServerStateSetCallCard) {
                        if (gameModel.isOnSkipAnimate) {
                            if (!(isDealerPok || [gameModel isAllGamblerPok])) {
                                currentActionState = SceneActionStateHandOutThirdCard;
                                [self handOutThirdCardWithNoAnimate];
                            }
                            
                        }else{
                            [self runSceneActionState:SceneActionStateHandOutThirdCard];
                        }
                    }
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case GetDataTypeAllResult:{
            [self removeLoadingNode];
            CCActionDelay *delay = [CCActionDelay actionWithDuration:2.0f];
            CCActionCallFunc *callShowResult = [CCActionCallFunc actionWithTarget:self selector:@selector(showResult)];
            CCActionSequence *actionSeq = [CCActionSequence actions:delay,callShowResult, nil];
            
            switch (gameModel.currentPlayerStatus) {
                case PlayerStatusDealer:{
                    
                    [self runAction:actionSeq];
                }
                    break;
                case PlayerStatusPlayer:{
                    [self runAction:actionSeq];
                }
                    break;
                case PlayerStatusObserver:{
                    [self drawPlayerBet];
                    [self handOutCardWithNoAnimate];
                    if (currentActionState >= SceneActionStateHandOutThirdCard) {
                        if (!(isDealerPok || gameModel.isAllGamblerPok)) {
                            [self handOutThirdCardWithNoAnimate];
                        }
                    }
                    [self runAction:actionSeq];
                }
                    break;
                    
                default:
                    break;
            }
        }
        default:
            break;
    }
}


-(void) observerModeLoadDataCompleteCallbackWithDataType:(GetDataType)dataType{
    DLog(@"observerModeLoadDataCompleteCallbackWithDataType dataType %i",dataType);
    switch (dataType) {
        case GetDataTypeRoomState:{
            [self processCurrentChairOrderData];
            [self drawPlayerDisplay];
            
            [gameModel requestGetAllBetData];
            [gameModel requestGetAllCardData];
            /*
            if (isOnSkipAnimate && gameModel.currentObserverProcessState > ServerStateSetBet) {
                [gameModel requestGetAllBetData];
                [gameModel requestGetAllCardData];
            }
             */
        }
            break;
        case GetDataTypePlayerInfo:{
            
        }
            break;
        case GetDataTypeAllBet:{
            [self drawPlayerBet];
            if (gameModel.isOnSkipAnimate && gameModel.currentObserverProcessState > ServerStateSetCutCard) {
               
                [gameModel requestGetAllCutCardData];
            }else{
                gameModel.isOnSkipAnimate = false;
            }
        }
            break;
        case GetDataTypeAllCardData:{
            if (gameModel.currentObserverProcessState > ServerStateSetCutCard) {
                [self handOutCardWithNoAnimate];
            }
        }
            break;
        case GetDataTypeAllCutCard:{
            if (gameModel.isOnSkipAnimate && gameModel.currentObserverProcessState > ServerStateSetCallCard) {
                [gameModel requestGetAllCallcardData];
            }
        }
            break;
        case GetDataTypeAllCallThirdCard:{
            if (gameModel.isOnSkipAnimate && gameModel.currentObserverProcessState > ServerStateSetCallCard) {
                [gameModel requestGetMatchResult];
            }
        }
            break;
        case GetDataTypeAllResult:{
            [self showResult];
        }
            break;
        default:
            break;
    }
}

-(void) connectionTimeOutCallbackWithDetailString:(NSString *)detailString{
    isConnectionTimeOut = true;
    [self stopAllActions];
    [self initAlertPopUpWithString:detailString popUpName:@"timeOutPopUp"];
}

-(void) roomNotActiveCallbackWithDetailString:(NSString *)detailString{
    [self stopAllActions];
    [self initAlertPopUpWithString:detailString popUpName:@"roomNotActivePopUp"];
}


-(void) serverChangeStateCallback:(ServerState)serverState{
    DLog(@"serverChangeStateCallback");
    switch (serverState) {
        case ServerStateWaitingForStart:{
            //เคลียร์ table ซํ้าอีกที
            [self clearTable];
            [self setQuitButtonEnable:YES];
            [self removeLoadingNode];
            switch (gameModel.currentPlayerStatus) {
                case PlayerStatusDealer:{
                    [self setQuitChairButtonEnable:YES];
                }
                    break;
                case PlayerStatusPlayer:{
                    [self setQuitChairButtonEnable:YES];
                }
                    break;
                case PlayerStatusObserver:{
                    [self initSitButton];
                    isComeToSceneFirstTime = NO;
                }
                    break;
                default:
                    break;
                    
            }
            currentActionState = SceneActionStateWaitingForStart;
            [self resetValueToDefault];
            break;
        case ServerStateStart:{
            currentActionState = SceneActionStateStartPlay;
            [self initLoadingNode];
            switch (gameModel.currentPlayerStatus) {
                case PlayerStatusDealer:{
                    [self drawPlayerDisplay];
                    [self setQuitButtonEnable:NO];
                    [self setQuitChairButtonEnable:NO];
                    [self removeAIButton];
                    
                    gameModel.playHandAmount = 1;
                }
                    break;
                case PlayerStatusPlayer:{
                    [self drawPlayerDisplay];
                    [self setQuitButtonEnable:NO];
                    [self setQuitChairButtonEnable:NO];
                    if (!isSetHandComplete) {
                        [self removeSetHandMenu];
                        isSetHandComplete = YES;
                        gameModel.playHandAmount = 1;
                        [self removePlayerHandDetail];
                        [self initPlayerHandDetail];
                        [self setEnableSecondHandEnable:NO];
                    }
                    [self removeRequestDealerButton];
                }
                    break;
                case PlayerStatusObserver:{
                    [self removeSitButton];
                    [self initObserverModeWindow];
                }
                    break;
                default:
                    break;
            }
            
        }
            break;
        case ServerStateSetBet:{
            switch (gameModel.currentPlayerStatus) {
                case PlayerStatusDealer:{
                    [self runSceneActionState:SceneActionStateSetBet];
                }
                    break;
                case PlayerStatusPlayer:{
                    [self runSceneActionState:SceneActionStateSetBet];
                }
                    break;
                case PlayerStatusObserver:{
                    if (gameModel.currentObserverProcessState == ServerStateSetBet) {
                        [self runSceneActionState:SceneActionStateSetBet];
                    }
                }
                    break;
                default:
                    break;
            }
            
        }
            break;
        case ServerStateSetCutCard:{
            switch (gameModel.currentPlayerStatus) {
                case PlayerStatusDealer:{
                    [self runSceneActionState:SceneActionStateCutCard];
                }
                    break;
                case PlayerStatusPlayer:{
                    [self runSceneActionState:SceneActionStateCutCard];
                }
                    break;
                case PlayerStatusObserver:{
                    if (gameModel.currentObserverProcessState == SceneActionStateCutCard) {
                        [self runSceneActionState:SceneActionStateCutCard];
                    }
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case ServerStateSetCallCard:{
            
        }
            break;
        case ServerStatePrepareForNewGame:{
            
        }
            break;
        default:
            break;
        }
    }
}

#pragma mark - DeckNodeCallBack
-(void) shuffleAnimateCompleteCallback{
    //ถามว่าต้องการตัดไพ่หรือไม่
    [self runSceneActionState:SceneActionStateSetCutCard];
}

-(void) cutTheCardCompleteCallback{
    //แจกไพ่
    [self removeWaitingSetCutCardPopUp];
    [self removeCutCardMenu];
    [self runSceneActionState:SceneActionStateHandOutCard];
}

#pragma mark - PDPopUpNodeCallback
-(void) pressCloseButtonCallback:(id)sender{
    PDPopUpNode *popUp = (PDPopUpNode *)sender;
    if ([popUp.name isEqualToString:@"playerProfilePopUp"]) {
        [self setPlayerInfoButtonEnable:YES];
    }else if ([popUp.name isEqualToString:@"timeOutPopUp"]){
        [self stopAllActions];
        [self goToLobbySceneWithLobbySceneType:comeFromLobbySceneType];
    }else if ([popUp.name isEqualToString:@"roomNotActivePopUp"]){
        [gameModel quitRoom];
    }
}
@end
