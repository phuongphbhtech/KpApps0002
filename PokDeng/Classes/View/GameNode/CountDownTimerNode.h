//
//  CountDownTimerNode.h
//  PokDeng_Beta
//
//  Created by Sarunporn Pisutwimol on 12/3/2556 BE.
//  Copyright 2556 Sarunporn Pisutwimol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CountDownTimerNode : CCNode {
    
}
+(id)initCountDownTimerWithTime:(int)_time;
-(void)decreaseTime;
@end
