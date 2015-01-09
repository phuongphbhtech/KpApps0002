//
//  PDRoomDataObject.h
//  PokDeng
//
//  Created by Sarunporn Pisutwimol on 5/18/2557 BE.
//  Copyright (c) 2557 Sarunporn Pisutwimol. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDRoomDataObject : NSObject

@property (nonatomic , retain) NSString *roomId;
@property (nonatomic , assign) BOOL isDeleted;
@property (nonatomic , assign) BOOL isStarted;
@property (nonatomic , assign) long int minBet;
@property (nonatomic , assign) long int maxBet;
@property (nonatomic , assign) int playerAmount;
@property (nonatomic , assign) int roomState;
@end
