//
//  PDGameSingle.h
//  PokDeng
//
//  Created by Sarunporn Pisutwimol on 5/18/2557 BE.
//  Copyright (c) 2557 Sarunporn Pisutwimol. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    LoginTypeFacebook,
    LoginTypeGuess,
}LoginType;

typedef enum {
    JoinRoomTypeNone = 0,
    JoinRoomTypeServer,
    JoinRoomTypeQuickJoin,
    JoinRoomTypeNormalJoin,
}JoinRoomType;

@interface PDGameSingleton : NSObject

@property (nonatomic) NSString *userId;
@property (nonatomic) NSString *username;
@property (nonatomic) NSString *displayName;
@property (nonatomic) NSString *displayPicture;
@property (nonatomic) NSInteger chip;
@property (nonatomic , assign) LoginType loginType;

@property (nonatomic , assign) JoinRoomType joinRoomType;
@property (nonatomic , assign) int currentSelectAvatarPicIndex;

+(instancetype) shareInstance;
@end
