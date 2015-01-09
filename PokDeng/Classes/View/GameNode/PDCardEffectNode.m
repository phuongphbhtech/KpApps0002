//
//  PDCardEffectNode.m
//  PokDeng
//
//  Created by Sarunporn Pisutwimol on 5/21/2557 BE.
//  Copyright 2557 Sarunporn Pisutwimol. All rights reserved.
//

#import "PDCardEffectNode.h"

@interface PDCardEffectNode ()
-(id) initWithEffectNoedType:(CardEffectNodeType)cardEffectNodeType;
@end

@implementation PDCardEffectNode
+(id) initCardEffectWithCardEffectNodeType:(CardEffectNodeType )cardEffectNodeType{
    return [[self alloc]initWithEffectNoedType:cardEffectNodeType];
}


-(id) initWithEffectNoedType:(CardEffectNodeType)cardEffectNodeType{
    if ((self = [super init])) {
        NSString *spriteName;
        switch (cardEffectNodeType) {
            case CardEffectNodeTypeNone:{
            }
                break;
            case CardEffectNodeTypePok8:{
                spriteName = [NSString stringWithFormat:@"pok8.png"];
            }
                break;
            case CardEffectNodeTypePok9:{
                spriteName = [NSString stringWithFormat:@"pok9.png"];
            }
                break;
            case CardEffecNodeResultWin:{
                spriteName = [NSString stringWithFormat:@"result_win.png"];
            }
                break;
            case CardEffecNodeResultDraw:{
                spriteName = [NSString stringWithFormat:@"result_draw.png"];
            }
                break;
            case CardEffecNodeResultLose:{
                spriteName = [NSString stringWithFormat:@"result_lose.png"];
            }
                break;
        }
        CCSprite *effectSprite = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteName]];
        effectSprite.position = CGPointZero;
        
        self.contentSize = CGSizeMake(effectSprite.contentSize.width, effectSprite.contentSize.height);
        [self addChild:effectSprite];
        [effectSprite runAction:[self getEffectAction]];
    }
    return self;
}

-(CCAction*)getEffectAction{
    CCActionJumpBy *jump = [CCActionJumpBy actionWithDuration:0.5f position:ccp(0,0) height:self.contentSize.height*0.75f jumps:1];
    CCActionFadeOut *fadeOut = [CCActionFadeOut actionWithDuration:0.25f];
    CCActionCallBlock *remove = [CCActionCallBlock actionWithBlock:^(void){
        [self stopAllActions];
        [self.parent removeChild:self];
    }];
    CCActionSequence *seq = [CCActionSequence actions:jump,fadeOut,remove, nil];
    return seq;
}
@end
