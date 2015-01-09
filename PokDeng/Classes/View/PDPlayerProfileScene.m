//
//  PDPlayerProfileScene.m
//  PokDeng
//
//  Created by Sarunporn Pisutwimol on 5/14/2557 BE.
//  Copyright 2557 Sarunporn Pisutwimol. All rights reserved.
//

#import "PDPlayerProfileScene.h"

typedef enum {
    zOrderBackground = 0,
    zOrderDisplayPic,
    zOrderDisplayFrame,
    zOrderDataLabel,
    zOrderMenu,
    zOrderPopUp,
}zOrder;

@interface PDPlayerProfileScene (){
    PDShareConnection *shareConnection;
    PDGameSingleton *shareGame;
    
    int currentSelectAvatarIndex; //ลำดับของภาพอวาต้าร์ที่เลือกในปัจจุบัน
    int selectAvatarIndex;          // ลำดับของภาพอวาต้าร์ที่อยู่ระหว่างการเลือกเปลี่ยน
}
-(id) initSceneFromLobbySceneType:(PDLobbySceneType)sceneType;


-(void) initBackground;
-(void) initPlayerProfile;
-(void) initEditProfileMenu;
-(void) initBackButtonToSceneType:(PDLobbySceneType)sceneType;
-(void) initAlertPopUpWithString:(NSString *)alertString;
-(void) initChangeDisplayPicPopUp;
-(void) initChangeDisplayName;

-(void) refreshPlayerDataWithData:(NSDictionary *)data;

-(void) pressBackButton:(id)sender;
-(void) pressEditMenuButton:(id)sender;
-(void) pressAvatarButton:(id)sender;
-(void) pressAvatarSaveChange;

-(void) setEnableMenu:(BOOL)enable;

-(void) loadSpritesheet;
-(void) removeSpritesheet;

-(void) cleanMemory;

-(void) goToLobbySceneType:(PDLobbySceneType)sceneType;

@end

@implementation PDPlayerProfileScene
+(CCScene *)scene{
    return [[self alloc]initSceneFromLobbySceneType:PDLobbySceneTypePlay];
}
+(CCScene *)sceneFromLobbySceneType:(PDLobbySceneType)sceneType{
    return [[self alloc]initSceneFromLobbySceneType:sceneType];
}

-(id) initSceneFromLobbySceneType:(PDLobbySceneType)sceneType{
    if ((self = [super init])) {
        
        shareConnection = [PDShareConnection shareInstance];
        shareConnection.delegate = self;
        
        shareGame = [PDGameSingleton shareInstance];
        
        [shareConnection requestGetPlayerProfileWithUserId:shareGame.userId];
        
        [self loadSpritesheet];
        [self initBackground];
        [self initPlayerProfile];
        [self initBackButtonToSceneType:sceneType];
        
        switch (shareGame.loginType) {
            case LoginTypeGuess:{
                currentSelectAvatarIndex = [PDHelperFunction getAvatarIndexWithAvatarPicName:shareGame.displayPicture];
                [self initEditProfileMenu];
                DLog(@"currentSelectAvatarIndex %i",currentSelectAvatarIndex);
            }
                break;
            default:
                break;
        }
    }
    return self;
}


-(void) initBackground{
    CCSprite *background = [CCSprite spriteWithImageNamed: @"playerProfileSceneBG.jpg"];
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
}


-(void) initPlayerProfile{
    CCSprite *background = (CCSprite *)[self getChildByName:@"background" recursively:NO];
    CCSprite *displayFrame = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"frame_playerProfile.png"]];
    displayFrame.position = ccp(WINS.width*0.5f, WINS.height*0.5f+background.contentSize.height*0.24f);
    [self addChild:displayFrame z:zOrderDisplayFrame name:@"displayFrame"];
    
    CCLabelTTF *playerDisplayNameLabel = [CCLabelTTF labelWithString:@"" fontName:FONT_TRAJANPRO_BOLD fontSize:20];
    playerDisplayNameLabel.color = [CCColor colorWithCcColor3b:FONT_COLOR];
    playerDisplayNameLabel.position = ccp(WINS.width*0.5f, WINS.height*0.5f+background.contentSize.height*0.12f);
    [self addChild:playerDisplayNameLabel z:zOrderDataLabel name:@"displayNameLabel"];
    

    CCLabelTTF *playerChipLabel = [CCLabelTTF labelWithString:@"" fontName:FONT_TRAJANPRO_BOLD fontSize:20];
    playerChipLabel.color = [CCColor colorWithCcColor3b:FONT_COLOR];
    playerChipLabel.anchorPoint = ccp(0.0f, 0.5f);
    playerChipLabel.position = ccp(WINS.width*0.24f, WINS.height*0.5f-background.contentSize.height*0.06f);
    [self addChild:playerChipLabel z:zOrderDataLabel name:@"playerChipLabel"];
    
    int fontSize = 16;
    
    float scorePosY[3];
    scorePosY[0] = WINS.height*0.5f-background.contentSize.height*0.2f;
    scorePosY[1] = WINS.height*0.5f-background.contentSize.height*0.245f;
    scorePosY[2] = WINS.height*0.5f-background.contentSize.height*0.29f;
    
    CCLabelTTF *winLabel = [CCLabelTTF labelWithString:@"Win" fontName:FONT_TRAJANPRO_BOLD fontSize:fontSize];
    winLabel.color = [CCColor colorWithCcColor3b:FONT_COLOR];
    winLabel.anchorPoint = ccp(0.0f, 0.5f);
    winLabel.position = ccp(WINS.width*0.24f, scorePosY[0]);
    [self addChild:winLabel z:zOrderDataLabel name:@"winLabel"];
    
    CCLabelTTF *drawLabel = [CCLabelTTF labelWithString:@"Draw" fontName:FONT_TRAJANPRO_BOLD fontSize:fontSize];
    drawLabel.color = [CCColor colorWithCcColor3b:FONT_COLOR];
    drawLabel.anchorPoint = ccp(0.0f, 0.5f);
    drawLabel.position = ccp(WINS.width*0.24f, scorePosY[1]);
    [self addChild:drawLabel z:zOrderDataLabel name:@"drawLabel"];
    
    CCLabelTTF *loseLabel = [CCLabelTTF labelWithString:@"Lose" fontName:FONT_TRAJANPRO_BOLD fontSize:fontSize];
    loseLabel.color = [CCColor colorWithCcColor3b:FONT_COLOR];
    loseLabel.anchorPoint = ccp(0.0f, 0.5f);
    loseLabel.position = ccp(WINS.width*0.24f, scorePosY[2]);
    [self addChild:loseLabel z:zOrderDataLabel name:@"winLabel"];
    
    CCLabelTTF *winAmountLabel = [CCLabelTTF labelWithString:@"" fontName:FONT_TRAJANPRO_BOLD fontSize:fontSize];
    winAmountLabel.color = [CCColor colorWithCcColor3b:FONT_COLOR];
    winAmountLabel.anchorPoint = ccp(1.0f, 0.5f);
    winAmountLabel.position = ccp(WINS.width*0.6875f, scorePosY[0]);
    [self addChild:winAmountLabel z:zOrderDataLabel name:@"winAmountLabel"];
    
    CCLabelTTF *drawAmountLabel = [CCLabelTTF labelWithString:@"" fontName:FONT_TRAJANPRO_BOLD fontSize:fontSize];
    drawAmountLabel.color = [CCColor colorWithCcColor3b:FONT_COLOR];
    drawAmountLabel.anchorPoint = ccp(1.0f, 0.5f);
    drawAmountLabel.position = ccp(WINS.width*0.6875f, scorePosY[1]);
    [self addChild:drawAmountLabel z:zOrderDataLabel name:@"drawAmountLabel"];
    
    CCLabelTTF *loseAmountLabel = [CCLabelTTF labelWithString:@"" fontName:FONT_TRAJANPRO_BOLD fontSize:fontSize];
    loseAmountLabel.color = [CCColor colorWithCcColor3b:FONT_COLOR];
    loseAmountLabel.anchorPoint = ccp(1.0f, 0.5f);
    loseAmountLabel.position = ccp(WINS.width*0.6875f, scorePosY[2]);
    [self addChild:loseAmountLabel z:zOrderDataLabel name:@"loseAmountLabel"];
    
    for (int i = 0; i<3; i++) {
        CCLabelTTF *timesLabel = [CCLabelTTF labelWithString:@"Times" fontName:FONT_TRAJANPRO_BOLD fontSize:fontSize-2];
        timesLabel.color = [CCColor colorWithCcColor3b:FONT_COLOR];
        timesLabel.anchorPoint = ccp(0.0f, 0.5f);
        timesLabel.position = ccp(WINS.width*0.70f, scorePosY[i]);
        [self addChild:timesLabel z:zOrderDataLabel name:[NSString stringWithFormat:@"timesLable%i",i]];
    }
}

-(void) initBackButtonToSceneType:(PDLobbySceneType)sceneType{
    CCSprite *background = (CCSprite *)[self getChildByName:@"background" recursively:NO];
    CCButton *backButton = [CCButton buttonWithTitle:nil
                                         spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_back.png"]
                              highlightedSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_backC.png"]
                                 disabledSpriteFrame:nil];
    
//    backButton.positionType = CCPositionTypeNormalized;
    backButton.position = ccp(backButton.contentSize.width*0.55f,WINS.height*0.5f+background.contentSize.height*0.39f);
    
    if ([PDHelperFunction getScreenHeight] <= 960) {
        
        backButton.position = ccp(backButton.contentSize.width*0.55f,WINS.height-backButton.contentSize.height*0.6f);
    }
    
    [self addChild:backButton z:zOrderMenu name:@"backButton"];
    [backButton setTarget:self selector:@selector(pressBackButton:)];
    
    [backButton setName:[NSString stringWithFormat:@"%i",sceneType]];
}


-(void) initEditProfileMenu{
    CCSprite *background = (CCSprite *)[self getChildByName:@"background" recursively:NO];
    CCButton *editDisplayPicNameButton = [CCButton buttonWithTitle:nil
                                                    spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_editAvatar.png"]
                                         highlightedSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_editAvatarC.png"]
                                            disabledSpriteFrame:nil];
    CCButton *editDisplayNameButton = [CCButton buttonWithTitle:nil
                                                       spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_editName.png"]
                                            highlightedSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_editNameC.png"]
                                               disabledSpriteFrame:nil];
    editDisplayPicNameButton.position = ccp(WINS.width*0.5f-editDisplayPicNameButton.contentSize.width*0.6f, WINS.height*0.5f+background.contentSize.height*0.06f);
    editDisplayNameButton.position = ccp(WINS.width*0.5f+editDisplayPicNameButton.contentSize.width*0.6f, WINS.height*0.5f+background.contentSize.height*0.06f);
    
//    editDisplayPicNameButton.position = ccp(WINS.width*0.5f, editDisplayPicNameButton.position.y);
    [self addChild:editDisplayPicNameButton z:zOrderMenu name:@"editDisplayPicNameButton"];
    [self addChild:editDisplayNameButton z:zOrderMenu name:@"editDisplayNameButton"];
    
    [editDisplayPicNameButton setTarget:self selector:@selector(pressEditMenuButton:)];
    [editDisplayNameButton setTarget:self selector:@selector(pressEditMenuButton:)];
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

-(void) initChangeDisplayPicPopUp{
    CCSprite *background = (CCSprite *)[self getChildByName:@"background" recursively:NO];
    PDPopUpNode *changeDisplayPopUp = [PDPopUpNode initPopUpNodeWithTarget:self popUpSize:CGSizeMake(WINS.width*0.75f, background.contentSize.height*0.4f)];
    changeDisplayPopUp.position = ccp(WINS.width*0.5f, WINS.height*0.5f);
    [self addChild:changeDisplayPopUp z:zOrderPopUp name:@"changeDisplayPopUp"];
    
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"Choose Avatar" fontName:FONT_TRAJANPRO_BOLD fontSize:18];
    label.color = [CCColor colorWithCcColor3b:FONT_COLOR];
    label.anchorPoint = ccp(0.0f, 0.5f);
    label.position = ccp(-changeDisplayPopUp.contentSize.width*0.45f, changeDisplayPopUp.contentSize.height*0.5f-label.contentSize.height*1.1f);
    [changeDisplayPopUp addChild:label];
    
    CCSprite *lineSprite = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"popup_underline.png"] ];
    lineSprite.anchorPoint = ccp(0.0f, 0.5f);
    lineSprite.position = ccp(label.position.x,label.position.y-label.contentSize.height*0.6f);
    [changeDisplayPopUp addChild:lineSprite];
    
    //Display Amount = 6
    int displayAmount = 6;
    int rowCount = 0;
    int colomnCount = 0;
    for (int i = 0; i<displayAmount; i++) {
        if (colomnCount > 2) {
            rowCount++;
            colomnCount = 0;
        }
        NSString *spriteName = [NSString stringWithFormat:@"basic%.2d_icon.png",i+1];
        CCButton *avatarButton = [CCButton buttonWithTitle:@""
                                               spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteName]
                                    highlightedSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteName]
                                       disabledSpriteFrame:nil];
        avatarButton.position = ccp(-changeDisplayPopUp.contentSize.width*0.29f + (avatarButton.contentSize.width*(colomnCount)*1.2f), + changeDisplayPopUp.contentSize.height*0.2f - (avatarButton.contentSize.height*rowCount*1.1f));
        [changeDisplayPopUp addChild:avatarButton z:0 name:[NSString stringWithFormat:@"%i",i]];
        [avatarButton setTarget:self selector:@selector(pressAvatarButton:)];
        
        if (i == currentSelectAvatarIndex) {
            //เป็น avatar ที่กำลังเลือกใช้
            CCSprite *frame = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"frame_choosing.png"]];
            frame.position = avatarButton.position;
            [changeDisplayPopUp addChild:frame z:0 name:@"avatarSelectedFrame"];
        }
        
        colomnCount ++;
    }
    
    CCButton *saveChangeButton = [CCButton buttonWithTitle:nil
                                               spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_save.png"]
                                    highlightedSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_saveC.png"] disabledSpriteFrame:nil];
    saveChangeButton.position = ccp(0, -changeDisplayPopUp.contentSize.height*0.5f+saveChangeButton.contentSize.height);
    [saveChangeButton setTarget:self selector:@selector(pressAvatarSaveChange)];
    [changeDisplayPopUp addChild:saveChangeButton];
    
}
-(void) initChangeDisplayName{
    CCLabelTTF *displayNameLabel = (CCLabelTTF *)[self getChildByName:@"displayNameLabel" recursively:NO];
    displayNameLabel.visible = FALSE;
    UIColor *color = [[UIColor alloc]initWithRed:255 green:255 blue:255 alpha:0];
    if ([PDHelperFunction getScreenHeight]>960) {
        self.displayNameTextfield = [[UITextField alloc]initWithFrame:CGRectMake(WINS.width*0.125f, WINS.height*0.36f, WINS.width*0.75f, WINS.height*0.05f)];
    }else{
        self.displayNameTextfield = [[UITextField alloc]initWithFrame:CGRectMake(WINS.width*0.125f, WINS.height*0.33f, WINS.width*0.75f, WINS.height*0.05f)];
    }
    
    
    CCColor *textColor = [CCColor colorWithCcColor3b:FONT_COLOR];
    
    self.displayNameTextfield.textColor = [UIColor colorWithRed:textColor.ccColor4f.r green:textColor.ccColor4f.g blue:textColor.ccColor4f.b alpha:1.0f];
    self.displayNameTextfield.font = [UIFont fontWithName:FONT_TRAJANPRO_BOLD size:20];
    self.displayNameTextfield.textAlignment = NSTextAlignmentCenter;
    
    [self.displayNameTextfield setBackgroundColor:color];
    //        [self.usernameTextField setKeyboardType:UIKeyboardTypeAlphabet];
    self.displayNameTextfield.placeholder = shareGame.displayName;
    [self.displayNameTextfield setAutocorrectionType:UITextAutocorrectionTypeNo];
    self.displayNameTextfield.delegate = self;
    [[CCDirector sharedDirector].view addSubview:self.displayNameTextfield];
    [self.displayNameTextfield becomeFirstResponder];
}

#pragma mark - Refresh

-(void) refreshPlayerDataWithData:(NSDictionary *)data{
    DLog(@"data %@",data);
    if([self getChildByName:@"displayPic" recursively:NO]){
        [self removeChildByName:@"displayPic" cleanup:YES];
    }
    CCSprite *displayFrame = (CCSprite *)[self getChildByName:@"displayFrame" recursively:NO];
    CCSprite *displayPic = [PDHelperFunction GetSpriteWithURL:[data objectForKey:@"pic"]];
    displayPic.position = displayFrame.position;
    
    if (displayPic.contentSize.width > displayFrame.contentSize.width) {
        float delta = displayPic.contentSize.width - displayFrame.contentSize.width;
        displayPic.scale = (displayPic.contentSize.width-delta) / displayPic.contentSize.width;
        displayPic.scale -= 0.1f;
    }else if (displayPic.contentSize.height > displayFrame.contentSize.height){
        float delta = displayPic.contentSize.height - displayFrame.contentSize.height;
        displayPic.scale = (displayPic.contentSize.height-delta) / displayPic.contentSize.height;
        displayPic.scale -= 0.1f;
    }
    [self addChild:displayPic z:zOrderDisplayPic name:@"displayPic"];
    
    CCLabelTTF *playerDisplayName = (CCLabelTTF *)[self getChildByName:@"displayNameLabel" recursively:NO];
    [playerDisplayName setString:[data objectForKey:@"displayname"]];
    
    CCLabelTTF *playerChip = (CCLabelTTF *)[self getChildByName:@"playerChipLabel" recursively:NO];
    NSInteger chip = [[data objectForKey:@"chips"]integerValue];
    [playerChip setString:[NSString stringWithFormat:@"$%@",[PDHelperFunction getChipStringWithChip:chip]]];
    
    CCLabelTTF *winAmountLabel = (CCLabelTTF *)[self getChildByName:@"winAmountLabel" recursively:NO];
    CCLabelTTF *drawAmountLabel = (CCLabelTTF *)[self getChildByName:@"drawAmountLabel" recursively:NO];
    CCLabelTTF *loseAmountLabel = (CCLabelTTF *)[self getChildByName:@"loseAmountLabel" recursively:NO];
    
    NSInteger win = [[data objectForKey:@"wins"]integerValue];
    NSInteger draw = [[data objectForKey:@"draws"]integerValue];
    NSInteger lose = [[data objectForKey:@"loses"]integerValue];
    
    [winAmountLabel setString:[NSString stringWithFormat:@"%@",[PDHelperFunction getChipStringWithChip:win]]];
    [drawAmountLabel setString:[NSString stringWithFormat:@"%@",[PDHelperFunction getChipStringWithChip:draw]]];
    [loseAmountLabel setString:[NSString stringWithFormat:@"%@",[PDHelperFunction getChipStringWithChip:lose]]];
    
}

-(void) pressBackButton:(id)sender{
    CCButton *backButton = (CCButton *)sender;
    PDLobbySceneType sceneType = [[backButton name]intValue];
    [self goToLobbySceneType:sceneType];
}

-(void) pressEditMenuButton:(id)sender{
    CCButton *button = (CCButton *)sender;
    if ([button.name isEqualToString:@"editDisplayPicNameButton"]) {
        [self setEnableMenu:NO];
        [self initChangeDisplayPicPopUp];
    }else if ([button.name isEqualToString:@"editDisplayNameButton"]) {
        [self setEnableMenu:NO];
        [self initChangeDisplayName];
    }
}

-(void) pressAvatarButton:(id)sender{
    CCButton *button = (CCButton *)sender;
    int avatarIndex = [button.name intValue];
    
    selectAvatarIndex = avatarIndex;
    
    PDPopUpNode *changeDisplayPopUp = (PDPopUpNode *)[self getChildByName:@"changeDisplayPopUp" recursively:NO];
    CCSprite *avatarSelectedFrame = (CCSprite *)[changeDisplayPopUp getChildByName:@"avatarSelectedFrame" recursively:NO];
    avatarSelectedFrame.position = button.position;
}

-(void) pressAvatarSaveChange{
    currentSelectAvatarIndex = selectAvatarIndex;
    NSString *pictureName = [NSString stringWithFormat:@"basic%.2d.png",currentSelectAvatarIndex+1];
    [shareConnection requestSetPlayerDisplayPictureNameWithUserId:shareGame.userId displayPictureName:pictureName];
    //Refresh Avatar
    CCSprite *displayPic = (CCSprite *)[self getChildByName:@"displayPic" recursively:NO];
    [displayPic setSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:pictureName]];
    if ([self getChildByName:@"changeDisplayPopUp" recursively:NO]) {
        [self removeChildByName:@"changeDisplayPopUp" cleanup:YES];
    }
    [self setEnableMenu:YES];
}

-(void) setEnableMenu:(BOOL)enable{
    CCButton *editDisplayPicNameButton = (CCButton *)[self getChildByName:@"editDisplayPicNameButton" recursively:NO];
    CCButton *editDisplayNameButton = (CCButton *)[self getChildByName:@"editDisplayNameButton" recursively:NO];
    CCButton *backButton = (CCButton *)[self getChildByName:@"backButton" recursively:NO];
    
    editDisplayPicNameButton.enabled = enable;
    editDisplayNameButton.enabled = enable;
    backButton.enabled = enable;
}

-(void) loadSpritesheet{
    [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:@"PlayerProfileSceneSpritesheet.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:@"JoinRoomBetPopUpSpritesheet.plist"];
}
-(void) removeSpritesheet{
    [[CCSpriteFrameCache sharedSpriteFrameCache]removeSpriteFramesFromFile:@"PlayerProfileSceneSpritesheet.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache]removeSpriteFramesFromFile:@"JoinRoomBetPopUpSpritesheet.plist"];
    
}

-(void) cleanMemory{
    [self removeAllChildrenWithCleanup:YES];
    [self removeSpritesheet];
    [[CCTextureCache sharedTextureCache]removeAllTextures];
}
#pragma mark - Change Scene
-(void) goToLobbySceneType:(PDLobbySceneType)sceneType{
    shareConnection.delegate = nil;
    [self cleanMemory];
    [[CCDirector sharedDirector]replaceScene:[PDLobbyScene sceneWithLobbySceneType:sceneType] withTransition:[CCTransition transitionFadeWithDuration:0.5f]];
}

#pragma mark UITextField Callback
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    //เมื่อกด เข้า TextField
    //    NSLog(@"textFieldShouldBeginEditing");
    textField.textColor  = [UIColor colorWithRed:0 green:0 blue:0 alpha:255];
//    inUseTextField = textField;
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    //เมื่อกดปุ่ม clear แต่ปุ่ม clear อยู่ไหนไม่รู้
    //    NSLog(@"textFieldShouldClear");
    textField.textColor = [UIColor colorWithRed:100 green:100 blue:100 alpha:50];
    if ([textField isEqual:self.displayNameTextfield]) {

    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    //เมื่อกด เข้า TextField
    //    NSLog(@"textFieldDidBeginEditing");
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    //เมื่อกด Return , เปลี่ยนช่อง
    //    NSLog(@"textFieldDidEndEditing");
    //ตรวจ ค่าของแต่ละบล็อก
    [self setEnableMenu:YES];
    if ([textField isEqual:self.displayNameTextfield]) {
        shareGame.displayName = self.displayNameTextfield.text;
        [shareConnection requestSetPlayerDisplayNameWithUserId:shareGame.userId displayName:shareGame.displayName];
        
        CCLabelTTF *displayNameLabel = (CCLabelTTF *)[self getChildByName:@"displayNameLabel" recursively:NO];
        [displayNameLabel setString:shareGame.displayName];
        displayNameLabel.visible = true;
        [self.displayNameTextfield removeFromSuperview];
    }
    
    //ถ้าค่า บล็อก username + password != nil ทำการโปรเซส
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    //เมื่อกด Return
    //    NSLog(@"textFieldShouldReturn");
    [textField resignFirstResponder];
    // Call Process
    
    if ([textField isEqual:self.displayNameTextfield]) {
        shareGame.displayName = self.displayNameTextfield.text;
        [shareConnection requestSetPlayerDisplayNameWithUserId:shareGame.userId displayName:shareGame.displayName];
        
        
        CCLabelTTF *displayNameLabel = (CCLabelTTF *)[self getChildByName:@"displayNameLabel" recursively:NO];
        [displayNameLabel setString:shareGame.displayName];
        displayNameLabel.visible = true;
        
        [self.displayNameTextfield removeFromSuperview];
        [self setEnableMenu:YES];
    }
    return YES;
}


#pragma mark - PDShareConnectionDelegate
-(void) requestCompleteWithRequestType:(RequestConnectionType)requestType data:(NSDictionary *)data{
    switch (requestType) {
        case RequestConnectionTypeSetPlayerDisplayName:{
            
        }
            break;
        case RequestConnectionTypeSetPlayerDisplayPictureName:{
            
        }
            break;
        case RequestConnectionTypeGetPlayerProfile:{
            NSDictionary *playerData = [[data objectForKey:@"data"]objectAtIndex:0];
            [self refreshPlayerDataWithData:playerData];
            
        }
            break;
            
        default:
            break;
    }
}
-(void) requestFailWithRequestType:(RequestConnectionType)requestType error:(NSError *)error{
    
    if (error.code == NSURLErrorTimedOut || error.code == NSURLErrorNetworkConnectionLost || error.code == NSURLErrorSecureConnectionFailed) {
        [self setEnableMenu: NO];
        [self initAlertPopUpWithString:error.localizedDescription];
    }
    switch (requestType) {
        case RequestConnectionTypeSetPlayerDisplayName:{
            
        }
            break;
        case RequestConnectionTypeSetPlayerDisplayPictureName:{
            
        }
            break;
            
        default:
            break;
    }
}


-(void) requestFailWithConnectionError:(RequestConnectionType)requestType errorString:(NSString *)errorString{
//    [self initAlertPopUpWithString:errorString];
}

#pragma mark - PDPopUpNodeDelegate
-(void) pressCloseButtonCallback:(id)sender{
    [self setEnableMenu:YES];
}
@end
