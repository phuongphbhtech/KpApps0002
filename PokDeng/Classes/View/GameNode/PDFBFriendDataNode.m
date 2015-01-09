//
//  PDFBFriendDataNode.m
//  PokDeng
//
//  Created by Sarunporn Pisutwimol on 5/24/2557 BE.
//  Copyright 2557 Sarunporn Pisutwimol. All rights reserved.
//

#import "PDFBFriendDataNode.h"
typedef enum {
    zOrderBackground = 0,
    zOrderData,
    zOrderDisplayPic,
    zOrderDisplayPicFrame,
    zOrderButton,
}zOrder;
@interface PDFBFriendDataNode()
-(id) initFBFriendDataNodeInstanceWithTarget:(id<PDFBFriendDataNodeCallback>)target WithDataObject:(PDFBFriendDataObject *)dataObject;

@end

@implementation PDFBFriendDataNode
+(id) initFBFriendDataNodeWithTarget:(id<PDFBFriendDataNodeCallback>)target WithDataObject:(PDFBFriendDataObject *)dataObject{
    return [[self alloc]initFBFriendDataNodeInstanceWithTarget:target WithDataObject:dataObject];
}

-(id) initFBFriendDataNodeInstanceWithTarget:(id<PDFBFriendDataNodeCallback>)target WithDataObject:(PDFBFriendDataObject *)dataObject{
    if ((self = [super init])) {
        self.delegate = target;
        CCSprite *friendBG = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"tabFriend_BG.png"]];
        [self addChild:friendBG];
        
        CCLabelTTF *friendName = [CCLabelTTF labelWithString:dataObject.username fontName:FONT_TRAJANPRO_BOLD fontSize:14 dimensions:CGSizeMake(friendBG.contentSize.width*0.7f, friendBG.contentSize.height*0.5f)];

        friendName.color = [CCColor colorWithCcColor3b:FONT_COLOR];
        [self addChild:friendName];
        
        CCSprite *frame;
        CCSprite *statusPic;
        if (dataObject.isOnline) {
            frame = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"tabFriend_FrameGold.png"]];
            
            if (dataObject.isPlaying) {
                statusPic = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"tabFriend_StatusIngame.png"]];
                
                CCButton *joinButton = [CCButton buttonWithTitle:nil
                                                     spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"tabFriend_JoinGame.png"]
                                          highlightedSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"tabFriend_JoinGameC.png"]
                                             disabledSpriteFrame:nil];
                joinButton.position = ccp(friendBG.contentSize.width*0.3f, -friendBG.contentSize.height*0.2f);
                [self addChild:joinButton];
                [joinButton setBlock:^(id sender){
                    if ([self.delegate respondsToSelector:@selector(pressJoinRoomButtonCallbackWithRoomId:)]) {
                        [self.delegate pressJoinRoomButtonCallbackWithRoomId:dataObject.roomId];
                    }
                }];
            }else{
                
                statusPic = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"tabFriend_StatusOnline.png"]];
            }
        }else{
            //OffLine
            frame = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"tabFriend_FrameSilver.png"]];
            
            statusPic = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"tabFriend_StatusOffline.png"]];
        }
        
        frame.position = ccp(-friendBG.contentSize.width*0.5f+frame.contentSize.width*0.55f, 0);
        
        friendName.anchorPoint = ccp(0, 1.0f);
        friendName.position = ccp(frame.position.x + frame.contentSize.width*0.6f, friendBG.contentSize.height*0.4f);
        
        statusPic.anchorPoint = ccp(0.0f, 0.5f);
        statusPic.position = ccp(frame.position.x + frame.contentSize.width*0.6f  , -friendBG.contentSize.height*0.2f);
        
        [self addChild:frame z:zOrderDisplayPicFrame];
        [self addChild:statusPic];
        CCSprite *displayPic = [PDHelperFunction GetSpriteWithURL:dataObject.displayPic];
        displayPic.position = frame.position;
        

        if (displayPic.contentSize.width > frame.contentSize.width) {
            float delta = displayPic.contentSize.width - frame.contentSize.width;
            displayPic.scale = ( displayPic.contentSize.width - delta ) / displayPic.contentSize.width;
            
        }else if (displayPic.contentSize.height > frame.contentSize.height) {
            float delta = displayPic.contentSize.height - frame.contentSize.height;
            displayPic.scale = ( displayPic.contentSize.height - delta ) / displayPic.contentSize.height;
        }
        displayPic.scale -= 0.05f;
        [self addChild:displayPic z:zOrderDisplayPic];
        
        self.contentSize = friendBG.contentSize;
    }
    return self;
}
@end
