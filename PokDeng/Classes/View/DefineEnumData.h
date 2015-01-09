//
//  DefineEnumData.h
//  PokDeng
//
//  Created by Sarunporn Pisutwimol on 5/27/2557 BE.
//  Copyright (c) 2557 Sarunporn Pisutwimol. All rights reserved.
//

#define kMaxPlayer          6
#define kDefaultRefreshGetTimeLimitRate  3.0f

#define kDefaultWaitingForRoomStartRefreshRate 3.0f

typedef enum {
    ServerStateWaitingForStart = 0,
    ServerStateStart,               //1
    ServerStateSetBet,              //2
    ServerStateSetCutCard,          //3
    ServerStateSetCallCard,         //4
    ServerStateGetResult,           //5
    ServerStatePrepareForNewGame,
}ServerState;

typedef enum {
    StateStatusWaitingForNextState = 0,         //รอเข้าสู่ state ใหม่
    StateStatusRequestGetTimeLimit,             //ขอ TimeLimit
    StateStatusCountdownTimeLimit,              //นับถอยหลังเวลาของแต่ละ state
    StateStatusCountDownForRefreshTimeLimit,    //เป็นช่วงนับถอยหลังเพื่อขอ Timelimit อีกครั้งเพราะยังไม่เข้าสู่ state ใหม่
    StateStatusActiveTimeLimitEndAction,        //ทำ Action หลังจบการนับถอยหลัง
    StateStatusEnd,
}StateStatus;

typedef enum {
    GetDataTypeRoomState = 1,
    GetDataTypePlayerInfo,
    GetDataTypeAllCardData,
    GetDataTypeAllBet,
    GetDataTypeAllCutCard,
    GetDataTypeAllCallThirdCard,
    GetDataTypeAllResult,
}GetDataType;

typedef enum {
    PlayerStatusNone = 0, //สถานเมื่อยังไม่ได้เข้าร่วมในห้อง
    PlayerStatusDealer,
    PlayerStatusPlayer,
    PlayerStatusObserver,
}PlayerStatus;

typedef enum {
    EnterChairStatusNone = 0,
    EnterChairStatusSearchingChair,
    EnterChairStatusSendingRequest,
    EnterChairStatusComplete,
    EnterChairStatusWaitingForNextGame,
}EnterChairStatus;

typedef enum {
    CardRankTypeNone = 0,
    CardRankType8,
    CardRankType9,
}CardRankType;

typedef enum {
    CardsRankTypeNone = 0,
    CardsRankTypeValue,         //1
    CardsRankTypeColor,         //2
    CardsRankType3Border,       //3
    CardsRankTypeRunning,       //4
    CardsRankTypeTripple,       //5
    CardsRankTypeRunningRoyal,  //6
    CardsRankTypePok,           //7

}CardsRankType;

typedef enum {
    PokType8 = 1,
    PokType9,
}PokType;

typedef enum {
    ResultTypeLose = 0,
    ResultTypeDraw,
    ResultTypeWin,
}ResultType;


typedef enum {
    CallbackActionTypeEnterChairComplete,
    CallbackActionTypeQuitChairComplete,
    
    CallbackActionTypeUpdatePlayerOnChairData,
    CallbackActionTypeGameStart,
    CallbackActionTypeSetBetComplete,
    CallbackActionTypeGetAllBetComplete,
    CallbackActionTypeSetCutCardComplete,
    CallbackActionTypeGetAllCutCardComplete,
    CallbackActionTypeSetCallCardComplete,
    CallbackActionTypeGetAllCallCardComplete,
    CallbackActionTypeGetGameResultComplete,
    CallbackActionTypeUpdateStateTimer,
    CallbackActionTypeChangeState,
    
    CallbackActionTypeQuitRoom,
    CallbackActionTypeAddAi,
    CallbackActionTypeRemoveAi,
    CallbackActionTypeGetPlayerInfo,
    
    CallbackActionTypeUpdatePlayerChip,
    
    CallbackActionTypeGetRequestDealer,
    CallbackActionTypeSetRequestDealerUncomplete,
    CallbackActionTypeSetIsDealer,
    
    CallbackActionTypeChangeFromDealerToPlayer,
    CallbackActionTypeChangeFromPlayerToDealer,
    
    CallbackActionTypeConnectionTimeOut,
    
}CallbackActionType;

typedef enum {
    PlayerJoinStateNone,                            //ไม่ได้ทำอะไร
    PlayerJoinStateWaitingForEnterChair,            //รอส่งคำร้องขอนั่งเก้าอี้
    PlayerJoinStateSendingRequestForEnterChair,     //อยู่ระหว่างส่งคำร้องขอนั่งเก้าอี้
    PlayerJoinStateWaitingForNextGame,              //สถานะนั่งเก้าอี้ แต่ยังไม่สามารถเข้าร่วมเกมในรอบนั้นได้
    PlayerJoinStateJoinComplete                     //นั่งเก้าอี้เรียบร้อย พร้อมเล่น
    
}PlayerJoinState;
