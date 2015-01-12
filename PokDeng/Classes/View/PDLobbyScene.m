//
//  PDLobbyScene.m
//  PokDeng
//
//  Created by Sarunporn Pisutwimol on 5/14/2557 BE.
//  Copyright 2557 Sarunporn Pisutwimol. All rights reserved.
//

#import "PDLobbyScene.h"
#import "PDPlayerProfileScene.h"
#import "PDPlayScene.h"


typedef enum {
    zOrderBackground = 0,
    zOrderMenu,
    zOrderPopUp,
}zOrder;


@interface PDLobbyScene (){
    PDGameSingleton *shareGame;
    PDShareConnection *shareConnection;
    PDLobbySceneType currentLobbyType;
    FBConnect *fbConnect;
    
    bool isQuickJoin;
    bool isSendQuickAgain;   //ถ้ามีข้อมูลอยู่ในห้องก่อนหน้านี้ จะไม่สามารถ join ห้องได้ ต้องสั่ง quit ก่อน แล้วเข้าไปใหม่
    NSString *currentRequestJoinRoomId;
    
    NSInteger currentSelectMinBet;
    NSInteger currentSelectMaxBet;
    
    NSTimer *fbFriendRefreshTimeInterval;
    
    PDLoadingNode *loadingNode;

}
@property (nonatomic , retain) NSMutableArray *roomData;
@property (nonatomic , retain) NSArray *fbFrindsListArray;
@property (nonatomic , retain) NSMutableArray *fbFrindsListObjectsArray;

-(id) initWithLobbySceneType:(PDLobbySceneType)sceneType;

-(void) initUI;
-(void) initBackground;
-(void) initPlayerProfile;
-(void) initPlayMenu;
-(void) initTapMenu;
-(void) initGetMoreChipButton;
-(void) initFBLoginMenu;
-(void) initFriendListMenu;
-(void) clearFBFriendsList;

-(void) initJoinRoomBetSelectPopUp;
-(void) initGetMoreChipPopUp;

-(void) initAlertPopUpWithString:(NSString *)alertString;
-(void) initLoadingNode;

-(void) refreshPlayerProfileWithData:(NSDictionary *)playerData;
-(void) refreshFBFriendData;
-(void) refreshFBFriendList;

-(void) pressQuickJoinButton;
-(void) pressJoinRoomButton;
-(void) pressCreateRoomButton;
-(void) pressPlayerInfoButton;
-(void) pressInAppPurchaseButton;
-(void) pressTapPlayButton;
-(void) pressTapFBFriendButton;
-(void) pressFBLoginButton;
-(void) setMenuEnable:(BOOL)enable;

// SpriteSheet
-(void) loadSpritesheet;
-(void) removeSpritesheet;

// Memory
-(void) cleanMemory;

-(void) goToPlayerProfileScene;
-(void) goToPlayScene;
-(void) goToLobbySceneWithLobbySceneType:(PDLobbySceneType)sceneType;
@end

@implementation PDLobbyScene

+(CCScene *)scene{
    return [[self alloc]initWithLobbySceneType:PDLobbySceneTypePlay];
}

+(CCScene *)sceneWithLobbySceneType:(PDLobbySceneType)sceneType{
    return [[self alloc]initWithLobbySceneType:sceneType];
}


-(id) initWithLobbySceneType:(PDLobbySceneType)sceneType{
    if ((self = [super init])) {
        shareGame = [PDGameSingleton shareInstance];
        shareConnection = [PDShareConnection shareInstance];
        shareConnection.delegate = self;
        
        
        
        currentLobbyType = sceneType;
        self.fbFrindsListObjectsArray = [NSMutableArray array];
        [shareConnection requestGetPlayerProfileWithUserId:shareGame.userId];
        
        self.roomData = [NSMutableArray array];
        
        [self loadSpritesheet];
        [self initUI];
        
        DLog(@"shareGame.loginType %i",shareGame.loginType);
        if (shareGame.loginType == LoginTypeFacebook && currentLobbyType == PDLobbySceneTypeFBFriend) {
            DLog(@"shareGame.loginType == LoginTypeFacebook && currentLobbyType == PDLobbySceneTypeFBFriend");
            fbConnect = [FBConnect initFBConnectWithTarget:self];
            fbFriendRefreshTimeInterval = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(refreshFBFriendData) userInfo:nil repeats:YES];
            
            
        }
        
    }
    return self;
}

-(void) onEnterTransitionDidFinish{
    [super onEnterTransitionDidFinish];
    
    
}

-(void) onExitTransitionDidStart{
    if (fbFriendRefreshTimeInterval) {
        [fbFriendRefreshTimeInterval invalidate];
    }
    [self removeSpritesheet];
    [super onExitTransitionDidStart];
}

-(void) initUI{
    [self initBackground];
    [self initPlayerProfile];
    [self initGetMoreChipButton];
    [self initTapMenu];
    DLog(@"initWithLobbySceneType %i",currentLobbyType);
    switch (currentLobbyType) {
        case PDLobbySceneTypePlay:{
            [self initPlayMenu];
        }
            break;
        case PDLobbySceneTypeFBFriend:{
            switch (shareGame.loginType) {
                case LoginTypeFacebook:{
                    DLog(@"requestGetFBFriendListWithUserId")
                    [shareConnection requestGetFBFriendListWithUserId:shareGame.userId];
                    [self initLoadingNode];
//                    [self initFriendListMenu];
                }
                    break;
                case LoginTypeGuess:{
                    [self initFBLoginMenu];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
}
-(void) initBackground{
    CCSprite *background = [CCSprite spriteWithImageNamed:@"roomSelectBG.jpg"];
    background.positionType = CCPositionTypeNormalized;
    background.position = ccp(0.5f,0.5f);
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
}

-(void) initPlayerProfile{
    CCSprite *background = (CCSprite *)[self getChildByName:@"background" recursively:NO];
    CCLabelTTF *playerNameLabel = [CCLabelTTF labelWithString:shareGame.displayName fontName:FONT_TRAJANPRO_BOLD fontSize:20];
    [playerNameLabel setDimensions:CGSizeMake(WINS.width*0.7f, playerNameLabel.contentSize.height*1.5f)];

    playerNameLabel.color = [CCColor colorWithCcColor3b:FONT_COLOR];
    playerNameLabel.anchorPoint = ccp(0, 0.5f);
    playerNameLabel.positionType = CCPositionTypePoints;
    playerNameLabel.position = ccp(WINS.width*0.24f, WINS.height*0.5f+background.contentSize.height*0.375f*background.scale);
    [self addChild:playerNameLabel z:zOrderMenu name:@"playerNameLabel"];
    
    CCLabelTTF *playerChipLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"$%@",[PDHelperFunction getChipStringWithChip:shareGame.chip]] fontName:FONT_TRAJANPRO_BOLD fontSize:24];
    playerChipLabel.color = [CCColor colorWithCcColor3b:FONT_COLOR];
    playerChipLabel.anchorPoint = ccp(0, 0.5f);
    playerChipLabel.positionType = CCPositionTypePoints;
    playerChipLabel.position = ccp(WINS.width*0.24f, WINS.height*0.5f+background.contentSize.height*0.315f*background.scale);
    [self addChild:playerChipLabel z:zOrderMenu name:@"playerChipLabel"];
    
    CCButton *playerDisplayPicFrameButton = [CCButton buttonWithTitle:nil spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"frameUser.png"]];
    playerDisplayPicFrameButton.position = ccp(WINS.width*0.12f,WINS.height*0.5f+background.contentSize.height*0.345f*background.scale);
    [self addChild:playerDisplayPicFrameButton z:zOrderMenu name:@"playerDisplayPicFrameButton"];
    [playerDisplayPicFrameButton setTarget:self selector:@selector(pressPlayerInfoButton)];
}

-(void) initPlayMenu{
    DLog(@"initPlayMenu");
    CCButton *quickJoinButton = [CCButton buttonWithTitle:nil
                                              spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"tabPlay_QuickJoin.png"]
                                 highlightedSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"tabPlay_QuickJoinC.png"] disabledSpriteFrame:nil];
    
    CCButton *joinRoomButton = [CCButton buttonWithTitle:nil
                                             spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"tabPlay_JoinRoom.png"]
                                  highlightedSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"tabPlay_JoinRoomC.png"] disabledSpriteFrame:nil];
    
    CCButton *createRoomButton = [CCButton buttonWithTitle:nil
                                               spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"tabPlay_CreateRoom.png"]
                                    highlightedSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"tabPlay_CreateRoomC.png"] disabledSpriteFrame:nil];
    
    quickJoinButton.positionType = CCPositionTypeNormalized;
    joinRoomButton.positionType = CCPositionTypeNormalized;
    createRoomButton.positionType = CCPositionTypeNormalized;
    
    quickJoinButton.position = ccp(0.5f, 0.5f);
    joinRoomButton.position = ccp(0.5f, 0.35f);
    createRoomButton.position = ccp(0.5f, 0.2f);
    
    [self addChild:quickJoinButton z:zOrderMenu name:@"quickJoinButton"];
    [self addChild:joinRoomButton z:zOrderMenu name:@"joinRoomButton"];
    [self addChild:createRoomButton z:zOrderMenu name:@"createRoomButton"];
    
    
    [quickJoinButton setTarget:self selector:@selector(pressQuickJoinButton)];
    [joinRoomButton setTarget:self selector:@selector(pressJoinRoomButton)];
    [createRoomButton setTarget:self selector:@selector(pressCreateRoomButton)];
}

-(void) initTapMenu{
    CCSprite *background = (CCSprite *)[self getChildByName:@"background" recursively:NO];
    
    CCButton *tapFBFriendButton = [CCButton buttonWithTitle:nil
                                                spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"button_FB.png"]
                                     highlightedSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"button_FB.png"] disabledSpriteFrame:nil];
//    tapFBFriendButton.positionType = CCPositionTypeNormalized;
    tapFBFriendButton.position = ccp(WINS.width*0.7, WINS.height*0.5f+background.contentSize.height*0.235f*background.scale);
    
    [self addChild:tapFBFriendButton z:zOrderMenu name:@"tapFBFriendButton"];
    [tapFBFriendButton setTarget:self selector:@selector(pressTapFBFriendButton)];
    
    
    CCButton *tapPlayButton = [CCButton buttonWithTitle:nil
                                            spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"button_Play.png"]
                                 highlightedSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"button_Play.png"] disabledSpriteFrame:nil];
//    tapPlayButton.positionType = CCPositionTypeNormalized;
    tapPlayButton.position = ccp(WINS.width*0.295, WINS.height*0.5f+background.contentSize.height*0.235f*background.scale);
    
    [self addChild:tapPlayButton z:zOrderMenu name:@"tapPlayButton"];
    [tapPlayButton setTarget:self selector:@selector(pressTapPlayButton)];
    
    CCSprite *selectionLineSprite = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName: @"selectionLine.png"]];
    [self addChild:selectionLineSprite z:zOrderMenu name:@"selectionLineSprite"];
    
    CCSprite *selecttionArrowSprite = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"selectionArrow.png"]];
    [self addChild:selecttionArrowSprite z:zOrderMenu name:@"selecttionArrowSprite"];
    
    switch (currentLobbyType) {
        case PDLobbySceneTypePlay:{
            tapPlayButton.enabled = NO;
            selectionLineSprite.position = ccp(tapPlayButton.position.x , tapPlayButton.position.y - tapPlayButton.contentSize.height*0.6f);
            selecttionArrowSprite.position = ccp(tapPlayButton.position.x , WINS.height*0.5f + background.contentSize.height*0.1925f);
        }
            break;
        case PDLobbySceneTypeFBFriend:{
            tapFBFriendButton.enabled = NO;
            selectionLineSprite.position = ccp(tapFBFriendButton.position.x , tapFBFriendButton.position.y - tapPlayButton.contentSize.height*0.6f);
            selecttionArrowSprite.position = ccp(tapFBFriendButton.position.x , WINS.height*0.5f + background.contentSize.height*0.1925f);
        }
            break;
        default:
            break;
    }
}
-(void) initGetMoreChipButton{
    CCSprite *background = (CCSprite *)[self getChildByName:@"background" recursively:NO];
    
    CCButton *getMoreChipButton = [CCButton buttonWithTitle:nil
                                                spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"button_AddCoin.png"]
                                     highlightedSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"button_AddCoinC.png"] disabledSpriteFrame:nil];
    getMoreChipButton.position = ccp(WINS.width*0.885, WINS.height*0.5f+background.contentSize.height*0.32f*background.scale);
    [self addChild:getMoreChipButton z:zOrderMenu name:@"getMoreChipButton"];
    [getMoreChipButton setTarget:self selector:@selector(pressInAppPurchaseButton)];
    
}


-(void) initFBLoginMenu{
    CCSprite *background = (CCSprite *)[self getChildByName:@"background" recursively:NO];
    NSString *guessLoginWarningString = @"You are currently\nplaying as a guess";
    CCLabelTTF *guessLoginWarningLabel = [CCLabelTTF labelWithString:guessLoginWarningString fontName:FONT_TRAJANPRO_BOLD fontSize:20];
    guessLoginWarningLabel.position = ccp(WINS.width*0.5f,WINS.height*0.5f-background.contentSize.height*0.011f*background.scale);
    guessLoginWarningLabel.color = [CCColor colorWithCcColor3b:FONT_COLOR];
    [self addChild:guessLoginWarningLabel z:zOrderMenu name:@"guessLoginWarningLabel"];
    
    if(IS_OPEN_FB){
        CCButton *fbLoginButton = [CCButton buttonWithTitle:nil
                                                spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"tabFriend_FBlogin.png"]
                                     highlightedSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"tabFriend_FBloginC.png"]
                                        disabledSpriteFrame:nil];
        fbLoginButton.position = ccp(WINS.width*0.5f, WINS.height*0.5f-background.contentSize.height*0.125f);
        [fbLoginButton setTarget:self selector:@selector(pressFBLoginButton)];
        [self addChild:fbLoginButton z:zOrderMenu name:@"fbLoginButton"];
    }
}

-(void) initFriendListMenu{
    
    if (loadingNode) {
        [loadingNode removeFromParentAndCleanup:YES];
    }
    
    CCSprite *background = (CCSprite *)[self getChildByName:@"background" recursively:NO];
    DLog(@"initFriendListMenu");
    
    if ([self getChildByName:@"layoutBox" recursively:NO]) {
        [self removeChildByName:@"layoutBox" cleanup:YES];
    }
    
    if (currentLobbyType == PDLobbySceneTypeFBFriend) {
        CCLayoutBox *layoutBox = [[CCLayoutBox alloc]init];
        layoutBox.anchorPoint = ccp(0.5f, 1.0f);
        layoutBox.spacing = 10.0f;
        layoutBox.direction = CCLayoutBoxDirectionVertical;
        [layoutBox setName:@"layoutBox"];
        
        CGSize size = CGSizeMake(0, 0);
        int drawDataNum = MIN(5, (int)self.fbFrindsListObjectsArray.count );
        for (int i = 0; i<drawDataNum; i++) {
            PDFBFriendDataObject *dataObject = [self.fbFrindsListObjectsArray objectAtIndex:i];
            PDFBFriendDataNode *fbFriendNode = [PDFBFriendDataNode initFBFriendDataNodeWithTarget:self WithDataObject:dataObject];
            
            size = CGSizeMake(MAX(size.width, fbFriendNode.contentSize.width), MAX(size.height, fbFriendNode.contentSize.height));
            [layoutBox addChild:fbFriendNode];
        }
        /* ตำแหน่งเมื่อ add บน self */
        layoutBox.position = ccp(WINS.width*0.875f, WINS.height*0.5f+background.contentSize.height*0.2f);
        
        [self addChild:layoutBox z:zOrderMenu];
    }
}

-(void) initJoinRoomBetSelectPopUp{
    PDPopUpNode *popUpNode = [PDPopUpNode initPopUpNodeWithTarget:self popUpSize:CGSizeMake(288, 188)];
    popUpNode.userInteractionEnabled = YES;
    popUpNode.position = ccp(WINS.width*0.5f,WINS.height*0.5f);
    [self addChild:popUpNode z:zOrderPopUp name:@"setBetPopUp"];
    
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"Select bet rate" fontName:FONT_TRAJANPRO_BOLD fontSize:20];
    label.color = [CCColor colorWithCcColor3b:FONT_COLOR];
    label.anchorPoint = ccp(0.0f, 0.5f);
    label.position = ccp(-popUpNode.contentSize.width*0.45f, popUpNode.contentSize.height*0.5f-label.contentSize.height);
    [popUpNode addChild:label];
    
    CCSprite *lineSprite = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"popup_underline.png"] ];
    lineSprite.anchorPoint = ccp(0.0f, 0.5f);
    lineSprite.position = ccp(label.position.x,label.position.y-label.contentSize.height*0.6f);
    [popUpNode addChild:lineSprite];
    
    
    CCSlideControl *betSlideControl = [CCSlideControl initCCSlideControlWithTarget:self knotSpriteName:@"popup_scrollThumb.png" barSpriteName:@"popup_scrollTrack.png"];
    betSlideControl.position = ccp(-betSlideControl.contentSize.width*0.5f, -betSlideControl.contentSize.height*0.5f+popUpNode.contentSize.height*0.2f);
    [popUpNode addChild:betSlideControl];
    
    int block = [betSlideControl getBlock];
    NSArray *getBetData = [betSlideControl.betList objectAtIndex:block];
//    NSLog(@"getBetData %@",getBetData);
    
    currentSelectMaxBet = [getBetData[1]integerValue];
    currentSelectMinBet = [getBetData[3]integerValue];
    
    CCLabelTTF *betValueLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@ - %@",getBetData[2],getBetData[0]]
                                                   fontName:FONT_TRAJANPRO_BOLD fontSize:20];
    betValueLabel.color = [CCColor colorWithCcColor3b:FONT_COLOR];
    betValueLabel.position = ccp(0, -popUpNode.contentSize.height*0.05f);
    [popUpNode addChild:betValueLabel z:0 name:@"betValueLabel"];
    
    
    CCLabelTTF *betDescription = [CCLabelTTF labelWithString:@"Min/Max buy in" fontName:FONT_TRAJANPRO_BOLD fontSize:14];
    betDescription.color = [CCColor colorWithCcColor3b:FONT_COLOR];
    betDescription.anchorPoint = ccp(0.5f, 0.5f);
    betDescription.position = ccp(0, -popUpNode.contentSize.height*0.2f);
    [popUpNode addChild:betDescription];
    
    CCButton *joinRoomButton = [CCButton buttonWithTitle:nil
                                             spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"popup_buttonJoin.png"]
                                  highlightedSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"popup_buttonJoinC.png"]
                                     disabledSpriteFrame:nil];
    joinRoomButton.position = ccp(0, -popUpNode.contentSize.height*0.5f+joinRoomButton.contentSize.height*0.7f);
    [popUpNode addChild:joinRoomButton z:0 name:@"joinRoomButton"];
    
    [joinRoomButton setBlock:^(id sender){

        if ([self getChildByName:@"setBetPopUp" recursively:NO]) {
            [self removeChildByName:@"setBetPopUp" cleanup:YES];
        }
        [shareConnection requestGetAllRoomsDataByBetWithUserId:shareGame.userId minbet:currentSelectMinBet maxbet:currentSelectMaxBet];
        [self setMenuEnable:YES];
    }];
}

-(void) initGetMoreChipPopUp{
    
    CCSprite *background = (CCSprite *)[self getChildByName:@"background" recursively:NO];
    PDPopUpNode *popUpNode = [PDPopUpNode initPopUpNodeWithTarget:self popUpSize:CGSizeMake(WINS.width*0.9f, background.contentSize.height*0.35f)];
    popUpNode.userInteractionEnabled = YES;
    popUpNode.position = ccp(WINS.width*0.5f,WINS.height*0.5f);
    [self addChild:popUpNode z:zOrderPopUp name:@"buyChipsPopUp"];
    
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"Buy Chips" fontName:FONT_TRAJANPRO_BOLD fontSize:20];
    label.color = [CCColor colorWithCcColor3b:FONT_COLOR];
    label.anchorPoint = ccp(0.0f, 0.5f);
    label.position = ccp(-popUpNode.contentSize.width*0.45f, popUpNode.contentSize.height*0.5f-label.contentSize.height);
    [popUpNode addChild:label];
    
    CCSprite *lineSprite = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"popup_underline.png"] ];
    lineSprite.anchorPoint = ccp(0.0f, 0.5f);
    lineSprite.position = ccp(label.position.x,label.position.y-label.contentSize.height*0.6f);
    [popUpNode addChild:lineSprite];
    
    int row = 0;
    int column = 0;
    for (int i = 0; i<8 ; i++) {
        if (column >= 4) {
            row++;
            column = 0;
        }
        
        CCButton *chipButton = [CCButton buttonWithTitle:nil
                                             spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"popup_shopIcon.png"]
                                  highlightedSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"popup_shopIcon.png"]
                                     disabledSpriteFrame:nil];
        chipButton.position = ccp(- popUpNode.contentSize.width*0.35f + chipButton.contentSize.width*1.15f * (column), popUpNode.contentSize.height*0.12f - (chipButton.contentSize.height*1.1f*(row)));
        [popUpNode addChild:chipButton];
        column ++;
    }
    
}

-(void) initAlertPopUpWithString:(NSString *)alertString{
    [self setMenuEnable:NO];
    
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
    [self addChild:alertPopUp z:zOrderPopUp name:@"alertPopUp"];
}

-(void) initLoadingNode{
    if (loadingNode == nil) {
        DLog(@"loadingNode");
        loadingNode = [PDLoadingNode initLoadingNode];
        loadingNode.position = ccp(WINS.width*0.5f, WINS.height*0.4f);
        [self addChild:loadingNode z:zOrderPopUp];
    }
}

#pragma mark - Refresh
-(void) refreshPlayerProfileWithData:(NSDictionary *)playerData{
    
    shareGame.displayName = [playerData objectForKey:@"displayname"];
    shareGame.chip = [[playerData objectForKey:@"chips"]integerValue];
    shareGame.displayPicture = [playerData objectForKey:@"pic"];
    
    CCLabelTTF *playerNameLabel = (CCLabelTTF *)[self getChildByName:@"playerNameLabel" recursively:NO];
    CCLabelTTF *playerChipLabel = (CCLabelTTF *)[self getChildByName:@"playerChipLabel" recursively:NO];
    CCButton *playerDisplayPicFrameButton = (CCButton *)[self getChildByName:@"playerDisplayPicFrameButton" recursively:NO];
    
    
    CCSprite *playerProfileDisplayPic;
    if (shareGame.loginType == LoginTypeFacebook) {
        playerProfileDisplayPic = [PDHelperFunction GetSpriteWithURL:[playerData objectForKey:@"pic"]];
    }else{
        playerProfileDisplayPic = [PDHelperFunction GetSpriteWithURL:[playerData objectForKey:@"pic"]];
    }
    
    playerProfileDisplayPic.position = playerDisplayPicFrameButton.position;
    [self addChild:playerProfileDisplayPic z:zOrderMenu name:@"playerProfileDisplayPic"];
    
    if (playerProfileDisplayPic.contentSize.width > playerDisplayPicFrameButton.contentSize.width ) {
        float delta = playerProfileDisplayPic.contentSize.width - playerDisplayPicFrameButton.contentSize.width;
        playerProfileDisplayPic.scale = (playerProfileDisplayPic.contentSize.width - delta)/playerProfileDisplayPic.contentSize.width;
    }else if (playerProfileDisplayPic.contentSize.height > playerDisplayPicFrameButton.contentSize.height){
        float delta = playerProfileDisplayPic.contentSize.height - playerDisplayPicFrameButton.contentSize.height;
        playerProfileDisplayPic.scale = (playerProfileDisplayPic.contentSize.height - delta)/playerProfileDisplayPic.contentSize.height;
    }
    playerProfileDisplayPic.scale -= 0.1f;
    
    playerNameLabel.string = shareGame.displayName;
    playerChipLabel.string = [NSString stringWithFormat:@"$%@",[PDHelperFunction getChipStringWithChip:shareGame.chip]];
    
}

-(void) refreshFBFriendData{
    if (shareGame.loginType == LoginTypeFacebook) {
        /*Init Loading Node*/
        [self initLoadingNode];
        
        
        [shareConnection requestGetFBFriendListWithUserId:shareGame.userId];
    }
}

-(void) refreshFBFriendList{
    if (self.fbFrindsListObjectsArray.count > 0) {
        [self.fbFrindsListObjectsArray removeAllObjects];
    }
    if (self.fbFrindsListArray.count > 0) {
        for (int i = 0; i<self.fbFrindsListArray.count; i++) {
            NSDictionary *fbFriendData = [NSDictionary dictionaryWithDictionary:[self.fbFrindsListArray objectAtIndex:i]];
            PDFBFriendDataObject *fbfriend = [[PDFBFriendDataObject alloc]init];
            fbfriend.username = [fbFriendData objectForKey:@"username"];
            fbfriend.roomId = [fbFriendData objectForKey:@"room_id"];
            fbfriend.displayPic = [fbFriendData objectForKey:@"pic"];
            fbfriend.isOnline = [[fbFriendData objectForKey:@"is_online"]boolValue];
            fbfriend.isPlaying = [[fbFriendData objectForKey:@"is_playing"]boolValue];
            [self.fbFrindsListObjectsArray addObject:fbfriend];
        }
        [self initFriendListMenu];
    }
}

-(void) clearFBFriendsList{
    
}

#pragma mark - Press Button
-(void) pressQuickJoinButton{
    [self setMenuEnable:NO];
    isQuickJoin = TRUE;
    shareGame.joinRoomType = JoinRoomTypeQuickJoin;
    [shareConnection requestGetAllRoomsDataByBetWithUserId:shareGame.userId minbet:1 maxbet:shareGame.chip];
    
}
-(void) pressJoinRoomButton{
    [self setMenuEnable:NO];
    [self initJoinRoomBetSelectPopUp];
//    [self goToPlayScene];
}
-(void) pressCreateRoomButton{
    [self setMenuEnable:NO];
    shareGame.joinRoomType = JoinRoomTypeServer;
    NSInteger maxBet = [BetProcess getMaxBetWithChip:shareGame.chip];
    NSInteger minBet = [BetProcess getMinBetWithChip:shareGame.chip];
//    [shareConnection requestCreateRoomWithUserId:shareGame.userId roomSize:6 minbet:minBet maxbet:maxBet];
    [shareConnection requestCreateRoomWithUserId:@"101" roomSize:6 minbet:200 maxbet:10000];
    
//    [self goToPlayScene];
}
-(void) pressPlayerInfoButton{
    [self goToPlayerProfileScene];
}
-(void) pressInAppPurchaseButton{
    [self setMenuEnable:NO];
    [self initGetMoreChipPopUp];
}
-(void) pressTapPlayButton{
    [self goToLobbySceneWithLobbySceneType:PDLobbySceneTypePlay];
}
-(void) pressTapFBFriendButton{
    [self goToLobbySceneWithLobbySceneType:PDLobbySceneTypeFBFriend];
}
-(void) pressFBLoginButton{
    fbConnect = [FBConnect initFBConnectWithTarget:self];
    [fbConnect login];
}

#pragma mark - Enable Menu
-(void) setMenuEnable:(BOOL)enable{
    CCButton *quickJoinButton = (CCButton *)[self getChildByName:@"quickJoinButton" recursively:NO];
    CCButton *joinRoomButton = (CCButton *)[self getChildByName:@"joinRoomButton" recursively:NO];
    CCButton *createRoomButton = (CCButton *)[self getChildByName:@"createRoomButton" recursively:NO];
    CCButton *playerDisplayPicFrameButton = (CCButton *)[self getChildByName:@"playerDisplayPicFrameButton" recursively:NO];
    CCButton *getMoreChipButton = (CCButton *)[self getChildByName:@"getMoreChipButton" recursively:NO];
    
    
    quickJoinButton.enabled = enable;
    joinRoomButton.enabled = enable;
    createRoomButton.enabled = enable;
    playerDisplayPicFrameButton.enabled = enable;
    getMoreChipButton.enabled = enable;
    
    switch (currentLobbyType) {
        case PDLobbySceneTypePlay:{
            CCButton *tapFBFriendButton = (CCButton *)[self getChildByName:@"tapFBFriendButton" recursively:NO];
            tapFBFriendButton.enabled = enable;
        }
            break;
        case PDLobbySceneTypeFBFriend:{
            CCButton *tapPlayButton = (CCButton *)[self getChildByName:@"tapPlayButton" recursively:NO];
            tapPlayButton.enabled = enable;
        }
            break;
        default:
            break;
    }
}
#pragma mark - SpriteSheet
-(void) loadSpritesheet{
    [[CCTextureCache sharedTextureCache]addImage:@"roomSelectBG.jpg"];
    [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:@"RoomSelectionSpritesheet.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:@"JoinRoomBetPopUpSpritesheet.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:@"PlayerProfileSceneSpritesheet.plist"];
}
-(void) removeSpritesheet{
    [[CCTextureCache sharedTextureCache]removeUnusedTextures];
//    [[CCSpriteFrameCache sharedSpriteFrameCache]removeSpriteFramesFromFile:@"RoomSelectionSpritesheet.plist"];
//    [[CCSpriteFrameCache sharedSpriteFrameCache]removeSpriteFramesFromFile:@"JoinRoomBetPopUpSpritesheet.plist"];
//    [[CCSpriteFrameCache sharedSpriteFrameCache]removeSpriteFramesFromFile:@"PlayerProfileSceneSpritesheet.plist"];
}

#pragma mark - Memory
-(void) cleanMemory{
    [self removeAllChildrenWithCleanup:YES];
    [self removeSpritesheet];
}

#pragma mark - Change Scene

-(void) goToPlayerProfileScene{
    shareConnection.delegate = nil;
    [self cleanMemory];
    [[CCDirector sharedDirector]replaceScene:[PDPlayerProfileScene scene] withTransition:[CCTransition transitionFadeWithDuration:0.5f]];
}

-(void) goToPlayScene{
    shareConnection.delegate = nil;
    [self cleanMemory];
    [[CCDirector sharedDirector]replaceScene:[PDPlayScene scene] withTransition:[CCTransition transitionFadeWithDuration:0.5f]];
}

-(void) goToLobbySceneWithLobbySceneType:(PDLobbySceneType)sceneType{
    shareConnection.delegate = nil;
    [self cleanMemory];
    [[CCDirector sharedDirector]replaceScene:[PDLobbyScene sceneWithLobbySceneType:sceneType]];
}


#pragma mark - PDShareConnection Delegate
-(void) requestCompleteWithRequestType:(RequestConnectionType)requestType data:(NSDictionary *)data{
    NSDictionary *gotData;
    if (data != nil && ![data isEqual:[NSNull null]]) {
        gotData = [data objectForKey:@"data"];
    }
    DLog(@"gotData %@",gotData);
    switch (requestType) {
        case RequestConnectionTypeJoinRoom:{
            if (shareGame.joinRoomType == JoinRoomTypeServer) {
                [shareConnection requestEnterChairWithUserId:shareGame.userId chairOrder:0];
            }else{
                if (isQuickJoin) {
                    shareGame.joinRoomType = JoinRoomTypeQuickJoin;
                }else{
                    shareGame.joinRoomType = JoinRoomTypeNormalJoin;
                }
                [self goToPlayScene];
            }
        }
            break;
        case RequestConnectionTypeCreateRoom:{
            if (gotData) {
                NSString *roomId = [gotData objectForKey:@"room_id"];
//                [shareConnection requestJoinRoomWithUserId:shareGame.userId roomId:roomId];
                [shareConnection requestJoinRoomWithUserId:@"101" roomId:@"111"];
            }
        }
            break;
        case RequestConnectionTypeEnterChair:{
            [self goToPlayScene];
        }
            break;
        case RequestConnectionTypeGetFBFriendList:{
            DLog(@"fb got data %@",gotData);
            self.fbFrindsListArray = [NSArray arrayWithArray:[data objectForKey:@"data"]];
            [self refreshFBFriendList];
//            self.fbFrindsListArray = [NSArray arrayWithArray:[gotData objectForKey:data]];
//            NSLog(@"self.fbFrindsListArray %@",self.fbFrindsListArray);
        }
            break;
        case RequestConnectionTypeGetPlayerProfile:{
            NSDictionary *playerProfile = [[data objectForKey:@"data"]objectAtIndex:0];
//            NSDictionary *playerProfileDict = @{@"chips": [playerProfile objectForKey:@"chips"],
//                                                @"displayname":[playerProfile objectForKey:@"displayname"],
//                                                @"pic":[playerProfile objectForKey:@"pic"]
//                                                };
            NSDictionary *playerProfileDict = @{@"chips": @"555",
                                                @"displayname":@"Tester 001",
                                                @"pic": @""
                                                };
            
            [self refreshPlayerProfileWithData:playerProfileDict];
        }
            break;
        case RequestConnectionTypeGetAllRoomDataByBet:{
            //เลือกห้องที่มีเก้าอี้ว่าง
            NSArray *dataArray = [NSArray arrayWithArray:[data objectForKey:@"data"]];
            DLog(@"dataArray %@",dataArray);
            DLog(@"self.roomData %@",self.roomData);
            for (int i = 0; i<dataArray.count; i++) {
                int playerAmount = [[dataArray[i] objectForKey:@"player_amount"]intValue];
                int isDeleted = [[dataArray[i] objectForKey:@"is_deleted"]boolValue];
                NSString *dealerName = [dataArray[i] objectForKey:@"dealer"];
                if (playerAmount < 6 && playerAmount > 0 && !isDeleted && ![dealerName isEqualToString:@""]) {
                    PDRoomDataObject *roomDataObject = [[PDRoomDataObject alloc]init];
                    roomDataObject.roomId = [dataArray[i]objectForKey:@"id"];
                    roomDataObject.isDeleted = [[dataArray[i] objectForKey:@"is_deleted"]boolValue];
                    roomDataObject.isStarted = [[dataArray[i] objectForKey:@"is_started"]boolValue];
                    roomDataObject.maxBet = [[dataArray[i] objectForKey:@"max_bet"]intValue];
                    roomDataObject.minBet = [[dataArray[i] objectForKey:@"min_bet"]intValue];
                    roomDataObject.playerAmount = [[dataArray[i] objectForKey:@"player_amount"]intValue];
                    roomDataObject.roomState = [[dataArray[i] objectForKey:@"state"]intValue];
                    
                    [self.roomData addObject:roomDataObject];
                }
            }
            DLog(@"self.roomData %@",self.roomData);
            if (self.roomData.count == 0) {
                [self initAlertPopUpWithString:@"There is no room available."];
                
            }else{
                int randomRoomIndex = arc4random() % self.roomData.count;
                DLog(@"randomRoomIndex %i",randomRoomIndex);
                PDRoomDataObject *firstFoundRoom = [self.roomData objectAtIndex:randomRoomIndex];
                currentRequestJoinRoomId = [NSString stringWithString:firstFoundRoom.roomId];
                
//                [shareConnection requestJoinRoomWithUserId:shareGame.userId roomId:firstFoundRoom.roomId];
                
                [shareConnection requestJoinRoomWithUserId:@"101" roomId:@"102"];
            }
        }
            break;
        case RequestConnectionTypeFBLogin:{
            shareGame.loginType = LoginTypeFacebook;
            NSString *gotUserId = [gotData objectForKey:@"user_id"];
            if (gotUserId != nil) {
                shareGame.userId = gotUserId;
                [self goToLobbySceneWithLobbySceneType:PDLobbySceneTypeFBFriend];
                
            }
        }
            break;
        case RequestConnectionTypeQuitRoom:{
            if (isQuickJoin && currentRequestJoinRoomId) {
//                [shareConnection requestJoinRoomWithUserId:shareGame.userId roomId:currentRequestJoinRoomId];
                
                [shareConnection requestJoinRoomWithUserId:@"101" roomId:@"103"];
            }
        }
            break;
        default:
            break;
    }
}

-(void) requestFailWithRequestType:(RequestConnectionType)requestType error:(NSError *)error{
    if (error.code == NSURLErrorTimedOut || error.code == NSURLErrorNetworkConnectionLost || error.code == NSURLErrorSecureConnectionFailed) {
        [self setMenuEnable:NO];
        [self initAlertPopUpWithString:error.localizedDescription];
    }
    switch (requestType) {
        case RequestConnectionTypeJoinRoom:{
            
        }
            break;
        case RequestConnectionTypeCreateRoom:{
            
        }
            break;
        case RequestConnectionTypeGetFBFriendList:{
        }
            break;
        case RequestConnectionTypeGetPlayerProfile:{
            
        }
            break;
            
        default:
            break;
    }
}

-(void) requestFailWithConnectionError:(RequestConnectionType)requestType errorString:(NSString *)errorString{
    DLog(@"requestFailWithNoDataWithRequestType");
    switch (requestType) {
        case RequestConnectionTypeGetAllRoomDataByBet:{
           [self initAlertPopUpWithString:@"There is no room available."];
        }
            break;
        case RequestConnectionTypeJoinRoom:{
//            [shareConnection requestQuitRoomWithUserId:shareGame.userId];
            [shareConnection requestQuitRoomWithUserId:@"101"];
        }
            break;
        case RequestConnectionTypeCreateRoom:{
             [self initAlertPopUpWithString:errorString];
//            [shareConnection requestQuitRoomWithUserId:shareGame.userId];
            [shareConnection requestQuitRoomWithUserId:@"101"];
        }
            break;
        default:
//            [self initAlertPopUpWithString:errorString];
            break;
    }
}

#pragma mark - FBConnect Callback
-(void) loginWithFBCompleteWithUserData:(NSDictionary *)data{
//    NSLog(@"data %@",data);
    NSString *token = [data objectForKey:@"token"];
    NSString *email = [data objectForKey:@"email"];
//    [shareConnection requestFBLoginWithToken:token email:email];
    [shareConnection requestFBLoginWithToken:@"6a0a3ac39064ee69a7cbec66749be8b8" email:@"nhok3by_kut3@yahoo.com.vn"];

}

-(void) loginWithFBFailWithError:(NSError *)error{
    
}

-(void) logoutWithFBComplete{
    
}

-(void) logoutWithFBFail{
    
}

#pragma mark - PDPopUpNodeDelegate
-(void) pressCloseButtonCallback:(id)sender{
    [self setMenuEnable:YES];
}

#pragma mark - CCSlideControl
-(void) CCSlideControlCurrentBlock:(int)block slider:(id)sender{
    DLog(@"Block %i",block);
    
    CCSlideControl *slider = (CCSlideControl *)sender;
    NSArray *getBetData = slider.betList[block];
//    NSLog(@"dataArray %@",getBetData);
    
    PDPopUpNode *popUpNode = (PDPopUpNode *)[self getChildByName:@"setBetPopUp" recursively:NO];
    CCLabelTTF *betValueLabel = (CCLabelTTF *)[popUpNode getChildByName:@"betValueLabel" recursively:NO];
    [betValueLabel setString:[NSString stringWithFormat:@"%@ - %@",getBetData[2],getBetData[0]]];
    
    currentSelectMaxBet = [getBetData[1]integerValue];
    currentSelectMinBet = [getBetData[3]integerValue];
}

#pragma mark - 
-(void) pressJoinRoomButtonCallbackWithRoomId:(NSString *)roomId{
    shareGame.joinRoomType = JoinRoomTypeNormalJoin;
//    [shareConnection requestJoinRoomWithUserId:shareGame.userId roomId:roomId];
    [shareConnection requestJoinRoomWithUserId:@"101" roomId:@"111"];
}
@end
