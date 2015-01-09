//
//  PDPopUpNode.m
//  PokDeng
//
//  Created by Sarunporn Pisutwimol on 5/22/2557 BE.
//  Copyright 2557 Sarunporn Pisutwimol. All rights reserved.
//

#import "PDPopUpNode.h"

@interface PDPopUpNode()
@property (nonatomic , retain) CCSprite9Slice *sprite9slice;

-(id) initPopUpNodeInstanceWithTarget:(id <PDPopUpNodeDelegate>) target popUpSize:(CGSize)size;
-(void) pressCloseButton;
@end
@implementation PDPopUpNode
+(id) initPopUpNodeWithTarget:(id <PDPopUpNodeDelegate>) target popUpSize:(CGSize)size{
    return [[self alloc]initPopUpNodeInstanceWithTarget:target popUpSize:size];
}

-(id) initPopUpNodeInstanceWithTarget:(id<PDPopUpNodeDelegate>)target popUpSize:(CGSize)size{
    if ((self = [super init])) {
        self.delegate = target;
        
        self.sprite9slice = [[CCSprite9Slice alloc]initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"popup_textbox.png"]];
        [self.sprite9slice setContentSize:size];
        
        self.sprite9slice.position = CGPointZero;
        [self addChild:self.sprite9slice];
        
        CCButton *closeButton = [CCButton buttonWithTitle:nil
                                              spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"popup_buttonClose.png"]
                                   highlightedSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"popup_buttonCloseC.png"]
                                      disabledSpriteFrame:nil];
        closeButton.position = ccp(size.width*0.5f-closeButton.contentSize.width*0.5f, size.height*0.5f-closeButton.contentSize.height*0.5f);
        [self addChild:closeButton];
        [closeButton setTarget:self selector:@selector(pressCloseButton)];
        
        [self setContentSize:size];
    }
    return self;
}

-(void) pressCloseButton{
    DLog(@"pressCloseButton");
    if ([self.delegate respondsToSelector:@selector(pressCloseButtonCallback:)]) {
        [self.delegate pressCloseButtonCallback:self];
    }
    
    self.delegate = nil;
    [self removeAllChildrenWithCleanup:YES];
    [self removeFromParentAndCleanup:YES];
}
@end
