//
//  BetProcess.h
//  PokDengFunctionTest
//
//  Created by Sarunporn Pisutwimol on 12/23/2556 BE.
//  Copyright (c) 2556 Sarunporn Pisutwimol. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BetProcess : NSObject{

}


+(NSInteger)getMaxBetWithChip:(NSInteger)chip;
+(NSInteger)getMinBetWithChip:(NSInteger)chip;
+(NSInteger)getMinChipForPlayAsDealerWithRoomMaxBet:(NSInteger)roomMaxBet;
@end
