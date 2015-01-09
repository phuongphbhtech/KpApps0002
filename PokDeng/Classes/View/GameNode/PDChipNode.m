//
//  PDChipNode.m
//  PokDeng
//
//  Created by Sarunporn Pisutwimol on 5/21/2557 BE.
//  Copyright 2557 Sarunporn Pisutwimol. All rights reserved.
//

#import "PDChipNode.h"
@interface PDChipNode()
-(id)initWithType:(ChipType)_chipType;

@end

@implementation PDChipNode
+(id)initChipWithType:(ChipType)_chipType{
    return [[self alloc]initWithType:_chipType];
}

-(id)initWithType:(ChipType)_chipType{
    if ((self = [super init])) {
        self.type = _chipType;
        NSString *chipSpriteName;
        switch (_chipType) {
            case ChipType10:{
                chipSpriteName = [NSString stringWithFormat:@"chip10.png"];
            }
                break;
            case ChipType50:{
                chipSpriteName = [NSString stringWithFormat:@"chip50.png"];
            }
                break;
            case ChipType100:{
                chipSpriteName = [NSString stringWithFormat:@"chip100.png"];
            }
                break;
            case ChipType500:{
                chipSpriteName = [NSString stringWithFormat:@"chip500.png"];
            }
                break;
                
            default:
                break;
        }
        CCSprite *chipSprite = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:chipSpriteName]];
        [self addChild:chipSprite z:0 name:@"chip"];
        
        self.contentSize = CGSizeMake(chipSprite.contentSize.width, chipSprite.contentSize.height);
    }
    return self;
}

-(void)removeChip{
    CCSprite *chip = (CCSprite *)[self getChildByName:@"chip" recursively:NO];
    CCActionFadeOut *fadeOut = [CCActionFadeOut actionWithDuration:0.5f];
    CCActionCallBlock *callblock = [CCActionCallBlock actionWithBlock:^(void){
        [self removeChild:chip cleanup:YES];
        [self removeFromParentAndCleanup:YES];
    }];
    CCActionSequence *seq = [CCActionSequence actions:fadeOut,callblock, nil];
    
    [chip runAction:seq];
}
@end
