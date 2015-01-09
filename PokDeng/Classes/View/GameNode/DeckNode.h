//
//  DeckNode.h
//  PokDeng_Alpha4
//
//  Created by Sarunporn Pisutwimol on 10/31/2556 BE.
//  Copyright (c) 2556 Sarunporn Pisutwimol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CardNode.h"
#import "CCAnimation.h"

@class DeckNode;
@protocol DeckNodeCallback <NSObject>

-(void)shuffleAnimateCompleteCallback;
-(void)cutTheCardCompleteCallback;

@end
//DeckNode เป็นเหมือน view ของ Deck สามารถ Run Animation ต่างๆได้
@interface DeckNode : CCNode{
    id<DeckNodeCallback> delegate;
}

+(instancetype)initDeckWithTarget:(id<DeckNodeCallback>)target;

-(void)setTarget:(id<DeckNodeCallback>)target;

-(void)runAnimationShuffle;
-(void)runAnimationCutTheCard;
-(void)runAnimationCutTheCardWithCardNumber:(int)_cardNumber;


@end
