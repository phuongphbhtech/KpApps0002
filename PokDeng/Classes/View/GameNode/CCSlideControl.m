//
//  CCSlideControl.m
//  PokDeng
//
//  Created by Sarunporn Pisutwimol on 5/22/2557 BE.
//  Copyright 2557 Sarunporn Pisutwimol. All rights reserved.
//

#define kValueBlock             17
#import "CCSlideControl.h"
@interface CCSlideControl(){
    CCSprite *barSprite;
    CCSprite *knotSprite;
    
    CCSprite *touchSprite;
    
    float minBlockDis;
}
-(id) initInstanceWithTarget:(id<CCSlideControlDelegate>)target knotSpriteName:(NSString *)knotSpriteName barSpriteName:(NSString *)barSpriteName;

@end

@implementation CCSlideControl
+(id)initCCSlideControlWithTarget:(id<CCSlideControlDelegate>)target knotSpriteName:(NSString *)knotSpriteName barSpriteName:(NSString *)barSpriteName{
    return [[self alloc]initInstanceWithTarget:target knotSpriteName:knotSpriteName barSpriteName:barSpriteName];
}
-(id) initInstanceWithTarget:(id<CCSlideControlDelegate>)target knotSpriteName:(NSString *)knotSpriteName barSpriteName:(NSString *)barSpriteName{
    if ((self = [super init])) {
        self.delegate = target;
        NSString *path = [[NSBundle mainBundle]pathForResource:@"betList" ofType:@"plist"];
        self.betList = [NSArray arrayWithContentsOfFile:path];
        
        self.userInteractionEnabled = YES;
        barSprite = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:barSpriteName] ];
        barSprite.position = ccp(barSprite.contentSize.width*0.5f, barSprite.contentSize.height*0.5f);
        [self addChild:barSprite ];
        
        knotSprite = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:knotSpriteName] ];
        knotSprite.position = barSprite.position;
        [self addChild:knotSprite];
        
        self.contentSize = CGSizeMake(barSprite.contentSize.width, knotSprite.contentSize.height*1.5f);
        
        minBlockDis = barSprite.contentSize.width / (self.betList.count-1);
    }
    return self;
}
-(void) setBarValueMax:(NSInteger)max min:(NSInteger)min{
    self.maxBar = max;
    self.minBar = min;
    
}
-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    CGPoint touchPos = [touch locationInNode:self];
    DLog(@"touchPos %f , %f",touchPos.x,touchPos.y);
    CGRect rect = CGRectMake(knotSprite.position.x - knotSprite.contentSize.width*1.0f, knotSprite.position.y-knotSprite.contentSize.height*1.0f, knotSprite.contentSize.width*2.0f, knotSprite.contentSize.height*2.0f);
    BOOL isContainPoint = CGRectContainsPoint(rect, touchPos);
    if (isContainPoint) {
        touchSprite = knotSprite;
    }
}

-(void) touchMoved:(UITouch *)touch withEvent:(UIEvent *)event{
    
    if (touchSprite) {
        float minimumPos = barSprite.position.x - (barSprite.contentSize.width*0.4f);
        float maximunPos = barSprite.position.x + (barSprite.contentSize.width*0.4f);
        
        if (touchSprite == knotSprite) {
            CGPoint touchPos = [touch locationInNode:self];
            if (touchPos.x < minimumPos) {
                touchPos.x = minimumPos;
            }
            if (touchPos.x > maximunPos) {
                touchPos.x = maximunPos;
            }
            touchSprite.position = ccp(touchPos.x, touchSprite.position.y);
            [self.delegate CCSlideControlCurrentBlock:[self getBlockNumbWithKnotPosition:touchSprite.position] slider:self];
        }
    }
}

-(void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    touchSprite = nil;
}

-(int) getBlockNumbWithKnotPosition:(CGPoint)position{
    int block = position.x / minBlockDis;
//    block += (int)(self.betList.count/2);
    return block;
}

-(int) getBlock{
    int block = knotSprite.position.x / minBlockDis;
    return block;
}
@end
