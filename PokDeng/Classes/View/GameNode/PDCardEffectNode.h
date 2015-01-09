//
//  PDCardEffectNode.h
//  PokDeng
//
//  Created by Sarunporn Pisutwimol on 5/21/2557 BE.
//  Copyright 2557 Sarunporn Pisutwimol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum{
    CardEffectNodeTypeNone = 0,
    
    CardEffectNodeTypePok8,
    CardEffectNodeTypePok9,
    
    
    CardEffecNodeResultWin,
    CardEffecNodeResultDraw,
    CardEffecNodeResultLose,
}CardEffectNodeType;


@interface PDCardEffectNode : CCNode {
    
}
+(id) initCardEffectWithCardEffectNodeType:(CardEffectNodeType )cardEffectNodeType;

@end
