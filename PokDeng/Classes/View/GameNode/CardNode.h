//
//  CardNode.h
//  PokDeng_Alpha4
//
//  Created by Sarunporn Pisutwimol on 10/31/2556 BE.
//  Copyright (c) 2556 Sarunporn Pisutwimol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CardNode : CCNode{
    
}
@property (nonatomic , assign) int cardNumber;
@property (nonatomic , assign) bool isOpen;
+(id)initCardBack;
+(id)initCardFrontWithType:(int)_type WithCardNumber:(int)_cardNumber; //cardType 1-4 , cardNumber 1-13;
+(id)initCardFrontWithCardNumber:(int)_cardNumber; //cardNumber 1-52;

+(id)initCardBackWithCardNumber:(int)_cardNumber;

-(void)openCard;
-(void) upToHand;
@end
