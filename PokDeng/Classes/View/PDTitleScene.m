//
//  PDTitleScene.m
//  PokDeng
//
//  Created by Sarunporn Pisutwimol on 5/14/2557 BE.
//  Copyright 2557 Sarunporn Pisutwimol. All rights reserved.
//

#import "PDTitleScene.h"
#import "PDLobbyScene.h"


#define KEY_PLAY_AS_GUESS_USERNAME_DATA                   @"play_as_guess_username"

typedef enum {
    zOrderBackground,
    zOrderTitle,
    zOrderMenu,
    zOrderPopUp,
}zOrder;

@interface PDTitleScene (){
    PDGameSingleton *shareGame;
    PDShareConnection *shareConnection;
    FBConnect *fbConnect;
    NSString *deviceId;
    
    PDLoadingNode *loadingNode;
}
// Init UI
-(void) initBackground;
-(void) initTitle;
-(void) initLoginMenu;
-(void) initLoadingNode;
-(void) removeLoadingNode;
// Press Button
-(void) pressLoginAsGuessButton;
-(void) pressFBLoginButton;

// Enable Button
-(void) setMainMenuButtonEnable:(BOOL)enable;

// Save / Load Data
-(NSString *) loadPlayAsGuessUsernameData;  //ทำการโหลดข้อมูล Username ในโหมดการเล่นแบบ Guess ว่ามีหรือยัง
-(void) savePlayAsGuessUsernameData;   //Save ข้อมูล Username ในโหมดการเล่นแบบ Guess

// SpriteSheet
-(void) loadSpritesheet;
-(void) removeSpritesheet;

// Memory
-(void) cleanMemory;
// Change Scene
-(void) goToLobbyScene;
@end

@implementation PDTitleScene
+(CCScene *)scene{
    return [[self alloc]init];
}

-(id) init{
    if ((self = [super init])) {
        shareGame = [PDGameSingleton shareInstance];
        
        shareConnection = [PDShareConnection shareInstance];
        shareConnection.delegate = self;
        
        UIDevice *device = [UIDevice currentDevice];
        
        deviceId = [NSString stringWithFormat:@"%@",[device.identifierForVendor UUIDString]];
        NSLog(@"deviceID %@",deviceId);
        //Init UI
        [self loadSpritesheet];
        [self initBackground];
        [self initTitle];
        [self initLoginMenu];
        
        
    }
    return self;
}


-(void) initBackground{
    CCSprite *background = [CCSprite spriteWithImageNamed:@"titleSceneBG.jpg"];
    background.anchorPoint = ccp(0.5f, 0.5f);
    background.position = ccp(WINS.width*0.5f, WINS.height*0.5f );
    
    if ([PDHelperFunction getScreenHeight] <= 960) {
        background.position = ccp(WINS.width*0.5f, background.contentSize.height*0.42f );
    }
    [self addChild:background z:zOrderBackground name:@"background"];
}
-(void) initTitle{
    CCSprite *background = (CCSprite *)[self getChildByName:@"background" recursively:NO];
    
    CCSprite *titleShadowSprite = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"logo_shadow.png"]];
    [self addChild:titleShadowSprite];
    titleShadowSprite.position = ccp(WINS.width*0.5f, background.contentSize.height*0.55f);
    if ([PDHelperFunction getScreenHeight] <= 960) {
        titleShadowSprite.position = ccp(WINS.width*0.5f, background.contentSize.height*0.48f);
    }
    
    CCSprite *titleSprite = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"logo.png"]];
    [self addChild:titleSprite];
    titleSprite.position = titleShadowSprite.position;
    
    
}
-(void) initLoginMenu{
    CCSprite *background = (CCSprite *)[self getChildByName:@"background" recursively:NO];
    
    CCButton *loginAsGuessButton = [CCButton buttonWithTitle:nil
                                                 spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_loginGuest.png"]
                                      highlightedSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_loginGuestC.png"]
                                         disabledSpriteFrame:nil];
    loginAsGuessButton.position = ccp(WINS.width*0.5f, background.contentSize.height*0.325f);
    [loginAsGuessButton setTarget:self selector:@selector(pressLoginAsGuessButton)];
    [self addChild:loginAsGuessButton z:zOrderMenu name:@"loginAsGuessButton"];
    
    if (IS_OPEN_FB) {
        CCButton *loginFacebookButton = [CCButton buttonWithTitle:nil
                                                      spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_loginFB.png"]
                                           highlightedSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_loginFBC.png"]
                                              disabledSpriteFrame:nil];
        loginFacebookButton.position = ccp(WINS.width*0.5f, background.contentSize.height*0.235f);
        [loginFacebookButton setTarget:self selector:@selector(pressFBLoginButton)];
        [self addChild:loginFacebookButton z:zOrderMenu name:@"loginFacebookButton"];
        if ([PDHelperFunction getScreenHeight] <= 960) {
            loginFacebookButton.position = ccp(WINS.width*0.5f, background.contentSize.height*0.16f);
        }
        
    }
    
    if ([PDHelperFunction getScreenHeight] <= 960) {
        loginAsGuessButton.position = ccp(WINS.width*0.5f, background.contentSize.height*0.25f);
    }
}

-(void) initLoadingNode{
    if (loadingNode == nil) {
        DLog(@"loadingNode");
        loadingNode = [PDLoadingNode initLoadingNode];
        loadingNode.position = ccp(WINS.width*0.5f, WINS.height*0.25f);
        [self addChild:loadingNode z:zOrderPopUp];
    }
}
-(void) removeLoadingNode{
    [loadingNode stopAllActions];
    [loadingNode removeFromParentAndCleanup:YES];
    loadingNode = nil;
}
-(void) initAlertPopUpWithString:(NSString *)alertString{
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

#pragma mark - Active Button
-(void) pressLoginAsGuessButton{
    [self setMainMenuButtonEnable:NO];
    [self initLoadingNode];
    
#if (TARGET_IPHONE_SIMULATOR)
    [shareConnection requestGetNewGuessUserWithDeviceId:deviceId];
#else
    shareGame.username = [self loadPlayAsGuessUsernameData];
    if (shareGame.username == nil) {
        DLog(@"username == nil");
        [shareConnection requestGetNewGuessUserWithDeviceId:deviceId];
        [shareConnection requestGetNewGuessUserWithDeviceId:@"7E77A428-BF25-49B1-9355-863ED453AC65"];
    }else{
        DLog(@"username != nil");
//        [shareConnection requestLoginWithUsername:shareGame.username password:deviceId];
        [shareConnection requestLoginWithUsername:@"Tester 001" password:@"7E77A428-BF25-49B1-9355-863ED453AC65"];
    }
#endif
    
}


#pragma mark - Enable Button
-(void) setMainMenuButtonEnable:(BOOL)enable{
    CCButton *loginAsGuessButton = (CCButton *)[self getChildByName:@"loginAsGuessButton" recursively:NO];
    
    loginAsGuessButton.visible = enable;
    loginAsGuessButton.enabled = enable;
    
    if (IS_OPEN_FB) {
        CCButton *loginFacebookButton = (CCButton *)[self getChildByName:@"loginFacebookButton" recursively:NO];
        loginFacebookButton.visible = enable;
        loginFacebookButton.enabled = enable;
    }
    
}

-(void) pressFBLoginButton{
    [self setMainMenuButtonEnable:NO];
    [self initLoadingNode];

    fbConnect = [FBConnect initFBConnectWithTarget:self];
    [fbConnect login];
}
#pragma mark - Save / Load Data
-(NSString *) loadPlayAsGuessUsernameData{
    NSString *guessUsername = [[NSUserDefaults standardUserDefaults]objectForKey:KEY_PLAY_AS_GUESS_USERNAME_DATA];
    return guessUsername;
}
-(void) savePlayAsGuessUsernameData{
    [[NSUserDefaults standardUserDefaults]setObject:shareGame.username forKey:KEY_PLAY_AS_GUESS_USERNAME_DATA];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

#pragma mark - SpriteSheet
-(void) loadSpritesheet{
    [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:@"TitleSceneSpritesheet.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:@"JoinRoomBetPopUpSpritesheet.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:@"RoomSelectionSpritesheet.plist"];
}
-(void) removeSpritesheet{
    [[CCSpriteFrameCache sharedSpriteFrameCache]removeSpriteFramesFromFile:@"TitleSceneSpritesheet.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache]removeSpriteFramesFromFile:@"JoinRoomBetPopUpSpritesheet.plist"];
//    [[CCSpriteFrameCache sharedSpriteFrameCache]removeSpriteFramesFromFile:@""];
}

#pragma mark - Memory
-(void) cleanMemory{
    if (loadingNode) {
        [loadingNode removeFromParentAndCleanup:YES];
    }
    [self removeAllChildrenWithCleanup:YES];
    
    [self removeSpritesheet];
}

#pragma mark - Change Scene

-(void) goToLobbyScene{
    [self cleanMemory];
    shareConnection.delegate = nil;
    [fbConnect setTarget:nil];
    [[CCDirector sharedDirector] replaceScene:[PDLobbyScene sceneWithLobbySceneType:PDLobbySceneTypePlay] withTransition:[CCTransition transitionFadeWithDuration:0.5f]];
}

#pragma mark - PDShareConnectionDelegate
-(void) requestCompleteWithRequestType:(RequestConnectionType)requestType data:(NSDictionary *)data{
    NSDictionary *gotData;
    if (data != nil) {
        gotData = [data objectForKey:@"data"];
    }
    switch (requestType) {
        case RequestConnectionTypeGetNewGuessUser:{
            NSString *gotUsername = [gotData objectForKey:@"username"];
            if (gotUsername != nil) {
                shareGame.username = gotUsername;
                DLog(@"username = %@",shareGame.username);
                [self savePlayAsGuessUsernameData];
//                [shareConnection requestLoginWithUsername:shareGame.username password:deviceId];
                [shareConnection requestLoginWithUsername:@"Tester 001" password:@"7E77A428-BF25-49B1-9355-863ED453AC65"];
            }
        }
            break;
        case RequestConnectionTypeLogin:{
            shareGame.loginType = LoginTypeGuess;
            NSString *gotUserId = [gotData objectForKey:@"user_id"];
            if (gotUserId != nil) {
                shareGame.userId = gotUserId;
                DLog(@"userId %@",shareGame.userId);
                [self goToLobbyScene];
            }
        }
            break;
        case RequestConnectionTypeFBLogin:{
            shareGame.loginType = LoginTypeFacebook;
            NSString *gotUserId = [gotData objectForKey:@"user_id"];
            if (gotUserId != nil) {
                shareGame.userId = gotUserId;
                DLog(@"userId %@",shareGame.userId);
                [self goToLobbyScene];
            }
        }
            break;
        default:
            break;
    }
}

-(void) requestFailWithRequestType:(RequestConnectionType)requestType error:(NSError *)error{
    DLog(@"requestFailure :%@",error.localizedDescription)
    
    switch (error.code) {
            case NSURLErrorTimedOut:
        case NSURLErrorNotConnectedToInternet:
        case NSURLErrorNetworkConnectionLost:
        case NSURLErrorSecureConnectionFailed:
            [self setMainMenuButtonEnable:NO];
            [self initAlertPopUpWithString:error.localizedDescription];
            [self removeLoadingNode];
            break;
            
        default:
            break;
    }
    
    switch (requestType) {
        case RequestConnectionTypeGetNewGuessUser:{
            
        }
            break;
        case RequestConnectionTypeLogin:{
            
        }
            break;
        default:
            break;
    }
}

-(void) requestFailWithConnectionError:(RequestConnectionType)requestType errorString:(NSString *)errorString{
//    [self initAlertPopUpWithString:errorString];
    switch (requestType) {
        case RequestConnectionTypeLogin:{
            
        }
            break;
            
        default:
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
-(void) facebookRequestErrorCallback:(NSString *)errorString{
    [self initAlertPopUpWithString:errorString];
    [self removeLoadingNode];
}
-(void) pressCloseButtonCallback:(id)sender{
    [self setMainMenuButtonEnable:YES];
}
@end
