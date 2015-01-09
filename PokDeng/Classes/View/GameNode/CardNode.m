//
//  CardNode.m
//  PokDeng_Alpha4
//
//  Created by Sarunporn Pisutwimol on 10/31/2556 BE.
//  Copyright (c) 2556 Sarunporn Pisutwimol. All rights reserved.
//

#import "CardNode.h"
#define tagCardNodeSprite             1000
#define kCardSpriteScale                1.0f
@interface CardNode(){
    CCSprite *backCardTemp;
}

-(id)initBack;
-(id)initFrontWithType:(int)_type WithCardNumber:(int)_cardNumber;
-(id)initFrontWithCardNumber:(int)_cardNumber;
-(id)initBackWithCardNumber:(int)_cardNumber;

@end

@implementation CardNode
@synthesize cardNumber;
@synthesize isOpen;

+(id)initCardBack{
    return [[self alloc]initBack];
}
+(id)initCardFrontWithType:(int)_type WithCardNumber:(int)_cardNumber{
    return [[self alloc]initFrontWithType:_type WithCardNumber:_cardNumber];
}

+(id)initCardFrontWithCardNumber:(int)_cardNumber{
    return [[self alloc]initFrontWithCardNumber:_cardNumber];
}

+(id)initCardBackWithCardNumber:(int)_cardNumber{
    return [[self alloc]initBackWithCardNumber:_cardNumber];
}

-(id)initBack{
    if ((self = [super init])) {
        CCSprite *backCard = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"card_back.png"]];
        backCard.scale = kCardSpriteScale;
        backCard.position = CGPointZero;
        [self addChild:backCard];
        self.isOpen = false;
        self.contentSize = CGSizeMake(backCard.contentSize.width, backCard.contentSize.width);
        
    }
    return self;
}
-(id)initFrontWithType:(int)_type WithCardNumber:(int)_cardNumber{
    if ((self = [super init])) {
        
    }
    return self;
}
-(id)initFrontWithCardNumber:(int)_cardNumber{
    if ((self = [super init])) {
        NSString *spriteFrameName = [NSString stringWithFormat:@"c%.2d.png",_cardNumber];
        DLog(@"card frame name %@",spriteFrameName);
        CCSprite *card = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteFrameName]];
        card.scale = kCardSpriteScale;
        card.position = CGPointZero;
        [self addChild:card];
        
        self.isOpen = true;
        self.contentSize = CGSizeMake(card.contentSize.width, card.contentSize.width);
    }
    return self;
}

-(id)initBackWithCardNumber:(int)_cardNumber{
    if ((self = [super init])) {
        backCardTemp = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"card_back.png"]];
        backCardTemp.scale = kCardSpriteScale;
        backCardTemp.position = CGPointZero;
        [self addChild:backCardTemp ];
        self.cardNumber = _cardNumber;
        self.isOpen = false;
        self.contentSize = CGSizeMake(backCardTemp.contentSize.width, backCardTemp.contentSize.width);
    }
    return self;
}

-(void)openCard{
    [backCardTemp setSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:[NSString stringWithFormat:@"c%.2d.png",self.cardNumber]]];
    CCActionJumpBy *jump = [CCActionJumpBy actionWithDuration:0.25f position:ccp(0,0) height:backCardTemp.contentSize.height*0.2f jumps:1];
    [backCardTemp runAction:jump];
    self.isOpen = true;
    
}
-(void) upToHand{
    [backCardTemp setSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:[NSString stringWithFormat:@"c%.2d.png",self.cardNumber]]];
    self.isOpen = true;
}
@end
