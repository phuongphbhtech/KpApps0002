//
//  PDGameSingle.m
//  PokDeng
//
//  Created by Sarunporn Pisutwimol on 5/18/2557 BE.
//  Copyright (c) 2557 Sarunporn Pisutwimol. All rights reserved.
//

#import "PDGameSingleton.h"

@implementation PDGameSingleton
+(instancetype) shareInstance{
    static PDGameSingleton *shareInstance;
    @synchronized(self){
        if (!shareInstance) {
            shareInstance = [[self alloc]init];
        }
    }
    return shareInstance;
}

-(id) init{
    if ((self = [super init])) {
        self.userId = @"0";
        self.username = @"username";
        self.displayName = @"DisplayName";
        self.displayPicture = @"";
        self.loginType = LoginTypeGuess;
        self.chip = 0;
        self.joinRoomType = JoinRoomTypeNone;
    }
    return self;
}
@end
