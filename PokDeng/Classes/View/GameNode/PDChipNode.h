//
//  PDChipNode.h
//  PokDeng
//
//  Created by Sarunporn Pisutwimol on 5/21/2557 BE.
//  Copyright 2557 Sarunporn Pisutwimol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum {
    ChipType10  = 10,
    ChipType50,
    ChipType100,
    ChipType500,
}ChipType;

@interface PDChipNode : CCNode {
    
}
@property (nonatomic , assign)ChipType type;
+(id)initChipWithType:(ChipType)_chipType;
-(void)removeChip;
@end
