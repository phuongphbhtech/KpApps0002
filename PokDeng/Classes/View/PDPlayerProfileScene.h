//
//  PDPlayerProfileScene.h
//  PokDeng
//
//  Created by Sarunporn Pisutwimol on 5/14/2557 BE.
//  Copyright 2557 Sarunporn Pisutwimol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "cocos2d-ui.h"
#import "PDLobbyScene.h"

#import "PDShareConnection.h"
#import "PDGameSingleton.h"

@interface PDPlayerProfileScene : CCScene <PDShareConnectionDelegate , PDPopUpNodeDelegate , UITextFieldDelegate>{
    
}
@property (nonatomic , retain)UITextField *displayNameTextfield;
+(CCScene *)scene;
+(CCScene *)sceneFromLobbySceneType:(PDLobbySceneType)sceneType;
@end
