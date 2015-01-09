//
//  PDPlayScreen.h
//  PokDeng
//
//  Created by Sarunporn Pisutwimol on 5/14/2557 BE.
//  Copyright 2557 Sarunporn Pisutwimol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "cocos2d-ui.h"
//#import "PDGameModel.h"
#import "PDLobbyScene.h"
#import "PDCardEffectNode.h"
#import "DeckNode.h"
#import "PDChipNode.h"

#import "CountDownTimerNode.h"
#import "PDPopUpNode.h"

#import "PDGameModel2.h"
#import "PDLoadingNode.h"


typedef enum {
    SceneActionStateNone = 0,
    SceneActionStateWaitingForStart,        //สารมารถ เพิ่มลด ai , ขอเป็นเจ้ามือ , เพิ่มจำนวนมือที่เล่นได้
    SceneActionStateStartPlay,              //เริ่มต้นเล่น เมื่อเข้าสู่ state นี้ จะไม่สามารถเลือกจำนวนมือ หรือ ขอเป็นเจ้ามือได้
    SceneActionStateSetBet,                 //ผู้เล่นเลือกจำนวนเบ็ตที่ต้องการ
    SceneActionStateDrawBet,                //แสดงผล bet
    SceneActionStateShuffleCard,            //แสดงอนิเมทสับไพ่
    SceneActionStateSetCutCard,             //เลือกว่าต้องการตัดไพ่หรือไม่โดยการแตะที่กองไพ่
    SceneActionStateCutCard,                //แสดงอนิเมทตัดไพ่
    SceneActionStateHandOutCard,            //แจกไพ่
    SceneActionStateShowPok,                //เปิดไพ่ป๊อก
    SceneActionStateSetCallCard,            //เลือกว่าจะจั่วไพ่หรือไม่
    SceneActionStateHandOutThirdCard,       //แจกไพ่ใบที่สาม
    SceneActionStateCheckResult,            //ตรวจผลไพ่ และ แสดงอนิเมทผลการเล่น
    SceneActionStateClearTable,             //clear โต๊ะ รวบไพ่กลับมาตรงกลาง clear chip
    
}SceneActionState;

@interface PDPlayScene: CCScene <PDGameModelDelegate , DeckNodeCallback , PDPopUpNodeDelegate>{
//    PDGameModel *gameModel;
    PDGameModel2 *gameModel;
    PDGameSingleton *shareGame;
    
    PDLobbySceneType comeFromLobbySceneType;

//    BOOL isSkipAnimate;
    SceneActionState currentActionState;
    bool isConnectionTimeOut;
}

+(CCScene *)scene;
+(CCScene *)sceneFromLobbySceneType:(PDLobbySceneType)sceneType;
@end
