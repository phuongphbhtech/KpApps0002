//
//  PDTitleScene.h
//  PokDeng
//
//  Created by Sarunporn Pisutwimol on 5/14/2557 BE.
//  Copyright 2557 Sarunporn Pisutwimol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "cocos2d-ui.h"
#import "PDShareConnection.h"
#import "PDGameSingleton.h"
#import "FBConnect.h"
#import "PDPopUpNode.h"

#import "PDFBFriendDataNode.h"
#import "PDLoadingNode.h"

#include "TargetConditionals.h"


@interface PDTitleScene : CCScene <PDShareConnectionDelegate , FBConnectDelegate , PDPopUpNodeDelegate>{
    
}

+(CCScene *)scene;
@end
