//
//  PDLoadingNode.m
//  PokDeng
//
//  Created by Sarunporn Pisutwimol on 5/26/2557 BE.
//  Copyright 2557 Sarunporn Pisutwimol. All rights reserved.
//

#import "PDLoadingNode.h"
@interface PDLoadingNode(){
    NSTimer *timer;
    CCLabelTTF *loadingLabel;
    
    int loopCount;
}
-(id)initLoadingNodeInstance;
-(void) updateLoadingLabel;
@end

@implementation PDLoadingNode
+(id) initLoadingNode{
    return [[self alloc]initLoadingNodeInstance];
}
-(id)initLoadingNodeInstance{
    if ((self = [super init])) {
        loopCount = 0;
        loadingLabel = [CCLabelTTF labelWithString:@"Processing\nPlease wait" fontName:FONT_TRAJANPRO_BOLD fontSize:18];
        loadingLabel.color = [CCColor colorWithCcColor3b:FONT_COLOR];
        
        loadingLabel.horizontalAlignment = CCTextAlignmentCenter;
        loadingLabel.verticalAlignment = CCTextAlignmentCenter;
        loadingLabel.position = CGPointZero;
        
        CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithCcColor4b:ccc4(100, 100, 100, 100)] width:loadingLabel.contentSize.width*1.2f height:loadingLabel.contentSize.height*1.2f];
        background.anchorPoint = ccp(0.5f,0.5f);
        background.position = CGPointZero;
        [self addChild:background];
        
        [self addChild:loadingLabel];
        
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateLoadingLabel) userInfo:nil repeats:YES];
        
        self.contentSize = CGSizeMake(loadingLabel.contentSize.width, loadingLabel.contentSize.height);
    }
    return self;
}

-(void) updateLoadingLabel{
    loopCount ++;
    if (loopCount > 3) {
        loopCount = 0;
    }
    NSString *string = @"";
    switch (loopCount) {
        case 0:{
            string = @"Processing\nPlease wait";
        }
            break;
        case 1:{
            string = @"Processing\nPlease wait.";
        }
            break;
        case 2:{
            string = @"Processing\nPlease wait..";
        }
            break;
        case 3:{
            string = @"Processing\nPlease wait...";
        }
            break;
    }
    [loadingLabel setString:string];
}

-(void) stopAllActions{
    [super stopAllActions];
    [timer invalidate];
    timer = nil;
}


@end
