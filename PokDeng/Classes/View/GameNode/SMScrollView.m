//
//  SMScrollView.m
//  Smash
//
//  Created by Sarunporn Pisutwimol on 4/2/2557 BE.
//  Copyright 2557 Sarunporn Pisutwimol. All rights reserved.
//

#import "SMScrollView.h"


@implementation SMScrollView


-(id) initWithContentNode:(CCNode *)contentNode{
    if ((self = [super initWithContentNode:contentNode])) {
    }
    return self;
}
-(void) visit{
    
    glEnable(GL_SCISSOR_TEST);
    
    CGPoint origin = [self convertToWorldSpaceAR:self.cropRect.origin];
    CGPoint topRight = [self convertToWorldSpaceAR:ccpAdd(self.cropRect.origin, ccp(self.cropRect.size.width, self.cropRect.size.height))];
    CGRect scissorRect = CGRectMake(origin.x, origin.y, topRight.x-origin.x, topRight.y-origin.y);
    glScissor((GLint) scissorRect.origin.x, (GLint) scissorRect.origin.y,
              (GLint) scissorRect.size.width, (GLint) scissorRect.size.height);
    [super visit];
    glDisable(GL_SCISSOR_TEST);
}
@end
