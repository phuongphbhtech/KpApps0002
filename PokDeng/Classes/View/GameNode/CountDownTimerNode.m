//
//  CountDownTimerNode.m
//  PokDeng_Beta
//
//  Created by Sarunporn Pisutwimol on 12/3/2556 BE.
//  Copyright 2556 Sarunporn Pisutwimol. All rights reserved.
//

#import "CountDownTimerNode.h"
typedef enum {
    tagCountDownTimerNodeCounterSpriteStart = 1000,
    
}tagCountDownTimerNode;
@interface CountDownTimerNode(){
    int time;
}
-(id)initWithTime:(int)_time;
@end

@implementation CountDownTimerNode
+(id)initCountDownTimerWithTime:(int)_time{
    return [[self alloc]initWithTime:_time];
}

-(id)initWithTime:(int)_time{
    if ((self = [super init])) {
        time = _time;
        int column = 0;
        int row = 0;
        
        for (int i = 0; i<time; i++) {
            CCSprite *sprite = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"counter_ball.png"]];
            sprite.position = ccp(sprite.contentSize.width * column , -sprite.contentSize.height*row);
            [self addChild:sprite z:0 name:[NSString stringWithFormat:@"counter_ball%i",i]];
            column ++;
            if (column > 4) {
                row ++;
                column = 0;
            }
        }
        CCSprite *sprite = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"counter_ball.png"]];
        self.contentSize = CGSizeMake(sprite.contentSize.width*4, sprite.contentSize.height*row);
    }
    return self;
}
-(void)decreaseTime{
    time--;
    [self removeChildByName:[NSString stringWithFormat:@"counter_ball%i",time] cleanup:YES];
}
@end
