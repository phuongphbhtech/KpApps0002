//
//  PDPopUpNode.h
//  PokDeng
//
//  Created by Sarunporn Pisutwimol on 5/22/2557 BE.
//  Copyright 2557 Sarunporn Pisutwimol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "cocos2d-ui.h"


@protocol PDPopUpNodeDelegate <NSObject>

-(void) pressCloseButtonCallback:(id)sender;

@end
@interface PDPopUpNode : CCNode {
    
}
@property (nonatomic , weak) id<PDPopUpNodeDelegate> delegate;
+(id) initPopUpNodeWithTarget:(id <PDPopUpNodeDelegate>) target popUpSize:(CGSize)size;
@end
