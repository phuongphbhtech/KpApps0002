//
//  BetProcess.m
//  PokDengFunctionTest
//
//  Created by Sarunporn Pisutwimol on 12/23/2556 BE.
//  Copyright (c) 2556 Sarunporn Pisutwimol. All rights reserved.
//

#import "BetProcess.h"

@implementation BetProcess

+(NSInteger)getMaxBetWithChip:(NSInteger)chip{
    NSInteger max = chip / ((6*2)*5);
    return max;
}
+(NSInteger)getMinBetWithChip:(NSInteger)chip{
    NSInteger max = [self getMaxBetWithChip:chip];
    NSInteger min = (int)(max*0.1f);
    return min;
}

+(NSInteger)getMinChipForPlayAsDealerWithRoomMaxBet:(NSInteger)roomMaxBet{
    return roomMaxBet * 10;
}
@end
