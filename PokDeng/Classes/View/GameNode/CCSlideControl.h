//
//  CCSlideControl.h
//  PokDeng
//
//  Created by Sarunporn Pisutwimol on 5/22/2557 BE.
//  Copyright 2557 Sarunporn Pisutwimol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@protocol CCSlideControlDelegate <NSObject>

-(void) CCSlideControlCurrentBlock:(int)block slider:(id)sender;

@end
@interface CCSlideControl : CCNode {
    
}
@property (nonatomic , retain) id <CCSlideControlDelegate> delegate;
@property (nonatomic , assign) NSInteger maxBar;
@property (nonatomic , assign) NSInteger minBar;

+(id)initCCSlideControlWithTarget:(id<CCSlideControlDelegate>)target knotSpriteName:(NSString *)knotSpriteName barSpriteName:(NSString *)barSpriteName;
-(void) setBarValueMax:(NSInteger)max min:(NSInteger)min;
-(int) getBlock;

@property (nonatomic , retain) NSArray *betList;
@end
