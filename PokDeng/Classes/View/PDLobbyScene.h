//
//  PDLobbyScene.h
//  PokDeng
//
//  Created by Sarunporn Pisutwimol on 5/14/2557 BE.
//  Copyright 2557 Sarunporn Pisutwimol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "cocos2d-ui.h"
#import "CCTextureCache.h"
#import "PDShareConnection.h"
#import "PDGameSingleton.h"
#import "FBConnect.h"

#import "PDRoomDataObject.h"

#import "BetProcess.h"
#import "PDHelperFunction.h"

#import "PDPopUpNode.h"
#import "CCSlideControl.h"
#import "PDFBFriendDataObject.h"
#import "PDFBFriendDataNode.h"
#import "SMScrollView.h"

#import "PDLoadingNode.h"

typedef enum {
    PDLobbySceneTypePlay = 1,
    PDLobbySceneTypeFBFriend = 2,
    
}PDLobbySceneType;
@interface PDLobbyScene : CCScene <PDShareConnectionDelegate , FBConnectDelegate , PDPopUpNodeDelegate , CCSlideControlDelegate , PDFBFriendDataNodeCallback>{
    
}
+(CCScene *)scene;
+(CCScene *)sceneWithLobbySceneType:(PDLobbySceneType)sceneType;
@end
