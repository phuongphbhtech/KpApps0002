//
//  PDFBFriendDataNode.h
//  PokDeng
//
//  Created by Sarunporn Pisutwimol on 5/24/2557 BE.
//  Copyright 2557 Sarunporn Pisutwimol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "PDFBFriendDataObject.h"
#import "cocos2d-ui.h"
#import "PDHelperFunction.h"

@protocol PDFBFriendDataNodeCallback <NSObject>

-(void) pressJoinRoomButtonCallbackWithRoomId:(NSString *)roomId;

@end

@interface PDFBFriendDataNode : CCNode {
    
}
@property (nonatomic , weak) id<PDFBFriendDataNodeCallback> delegate;
+(id) initFBFriendDataNodeWithTarget:(id<PDFBFriendDataNodeCallback>)target WithDataObject:(PDFBFriendDataObject *)dataObject ;
@end
