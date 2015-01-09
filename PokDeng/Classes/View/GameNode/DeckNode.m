//
//  DeckNode.m
//  PokDeng_Alpha4
//
//  Created by Sarunporn Pisutwimol on 10/31/2556 BE.
//  Copyright (c) 2556 Sarunporn Pisutwimol. All rights reserved.
//

#import "DeckNode.h"
typedef enum {
    tagDeckNodeMainDeckCardNode = 5000,
}tagDeckNode;

@interface DeckNode(){
    
}
@property (nonatomic , retain) CCSprite *cardForShuffle;
@property (nonatomic , retain) NSMutableArray *shuffleAnimateFrame;
@property (nonatomic , retain) NSMutableArray *cutCardsObjectArray;

-(instancetype)initDeckInstanceWithTarget:(id<DeckNodeCallback>)target;
-(void)initAnimateFrame;

#pragma mark Shuffle Action
-(void)shuffleFinish;

@end

@implementation DeckNode
@synthesize shuffleAnimateFrame;
+(instancetype)initDeckWithTarget:(id<DeckNodeCallback>)target{
    return [[self alloc]initDeckInstanceWithTarget:target];
}
-(instancetype)initDeckInstanceWithTarget:(id<DeckNodeCallback>)target
{
    self = [super init];
    if (self) {
        delegate = target;
        self.cutCardsObjectArray = [NSMutableArray array];
        
        CCNode *mainDeckNode = [CCNode node];
        mainDeckNode.position = CGPointZero;
        
        [self addChild:mainDeckNode z:0 name:@"mainDeckNode"];
        for (int i = 0; i<6; i++) {
            CardNode *card = [CardNode initCardBack];
            card.position = ccp(0, card.contentSize.height*0.07f*i);
            [mainDeckNode addChild:card];
        }
        
        //init Animate Frame;
        [self initAnimateFrame];

        
        
    }
    return self;
}
-(void)setTarget:(id<DeckNodeCallback>)target{
    delegate = target;
    
}
-(void)initAnimateFrame{
    self.cardForShuffle = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"cardShuffling01.png"]];
    self.cardForShuffle.visible = false;
    [self addChild:self.cardForShuffle];
    self.cardForShuffle.visible = false;
    self.shuffleAnimateFrame = [[NSMutableArray alloc]init];
    for (int i = 1 ; i<=10; i++) {
        NSString *frameName = [NSString stringWithFormat:@"cardShuffling%.2d.png",i];
        
        [self.shuffleAnimateFrame addObject:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:frameName ]];
    }
    
    self.contentSize = CGSizeMake(self.cardForShuffle.contentSize.width, self.cardForShuffle.contentSize.height);
}


#pragma mark Shuffle Action
-(void)runAnimationShuffle{
    CCNode *mainNode = (CCNode *)[self getChildByName:@"mainDeckNode" recursively:NO];
    mainNode.visible = false;
    self.cardForShuffle.visible = true;
    self.cardForShuffle.scale = 1.0f;
    self.cardForShuffle.position = ccp(self.cardForShuffle.position.x, self.cardForShuffle.position.y-self.cardForShuffle.contentSize.height*0.05f);
    
    CCAnimation *shuffleAnimation = [CCAnimation animationWithSpriteFrames:self.shuffleAnimateFrame delay:0.05f];
    CCActionAnimate *lshuffleAnimate = [CCActionAnimate actionWithAnimation:shuffleAnimation];
    CCActionRepeat *repeatShuffle = [CCActionRepeat actionWithAction:lshuffleAnimate times:5];
    CCActionCallFunc *callShuffleFinish = [CCActionCallFunc actionWithTarget:self selector:@selector(shuffleFinish)];
//    CCActionCallFunc *callback    = [CCActionCallFunc actionWithTarget:delegate selector:@selector(shuffleAnimateCompleteCallback)];
    CCActionSequence *seq = [CCActionSequence actions:repeatShuffle,callShuffleFinish , nil];
    
    //ไม่แน่ใจว่า ต้องใช้ self เรียก callShuffleFinish อย่างเดียวหรือเปล่า
    [self.cardForShuffle runAction:seq];
}
-(void)shuffleFinish{
    CCNode *mainNode = (CCNode *)[self getChildByName:@"mainDeckNode" recursively:NO];
    mainNode.visible = true;
    self.cardForShuffle.visible = false;
    [delegate shuffleAnimateCompleteCallback];
}

-(void)runAnimationCutTheCard{
    [self runAnimationCutTheCardWithCardNumber:3];
}

-(void)runAnimationCutTheCardWithCardNumber:(int)_cardNumber{
    int actionCount = 0;
    int cutCardCount = _cardNumber;
    float duration = 0.1f;
    for (int i = 0; i<cutCardCount; i++) {
        CCActionDelay *delay = [CCActionDelay actionWithDuration:duration*actionCount];
        CCActionCallBlock *actionBlock = [CCActionCallBlock actionWithBlock:^(void){
            CardNode *card = [CardNode initCardBack];
            card.position = ccp(0, card.contentSize.height*0.35f);
            [self addChild:card];
            [self.cutCardsObjectArray addObject:card];
            
            CCActionMoveBy *moveRight = [CCActionMoveBy actionWithDuration:0.25f position:ccp(card.contentSize.width*1.2f,0)];
            CCActionCallBlock *reZOrder = [CCActionCallBlock actionWithBlock:^(void){
                card.zOrder = -1;
            }];
            CCActionMoveBy *moveLeft = [CCActionMoveBy actionWithDuration:0.25f position:ccp(-card.contentSize.width*1.2f,0)];
            CCActionCallBlock *animateFinish = [CCActionCallBlock actionWithBlock:^(void){
                [self removeChild:card];
                
                //                [delegate cutTheCardCompleteCallback];
            }];
            CCActionSequence *seq = [CCActionSequence actions:moveRight,reZOrder,moveLeft,animateFinish, nil];
            [card runAction:seq];
        }];
        CCActionSequence *seq2 = [CCActionSequence actions:delay,actionBlock, nil];
        [self runAction:seq2];
        actionCount ++;
    }
    
    CCActionCallFunc *actionFinishCallBack = [CCActionCallFunc actionWithTarget:delegate selector:@selector(cutTheCardCompleteCallback)];
    CCActionDelay *delay3 = [CCActionDelay actionWithDuration:(duration*actionCount)+1.0f];
    CCActionCallBlock *removeCutCardsAllObject = [CCActionCallBlock actionWithBlock:^(void){
        [self.cutCardsObjectArray removeAllObjects];
    }];
    CCActionSequence *seq3 = [CCActionSequence actions:delay3,removeCutCardsAllObject,actionFinishCallBack, nil];
    [self runAction:seq3];
}

-(void) stopAllActions{
    [super stopAllActions];
    if ([self.cardForShuffle numberOfRunningActions] != 0) {
        [self.cardForShuffle stopAllActions];
    }
    self.cardForShuffle.visible = false;
    
    for (CardNode *card in self.cutCardsObjectArray) {
        [self removeChild:card cleanup:YES];
    }
    
    [self.cutCardsObjectArray removeAllObjects];
}
@end
