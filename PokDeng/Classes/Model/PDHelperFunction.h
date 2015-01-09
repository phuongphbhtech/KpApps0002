//
//  PDHelperFunction.h
//  PokDeng
//
//  Created by Sarunporn Pisutwimol on 5/20/2557 BE.
//  Copyright (c) 2557 Sarunporn Pisutwimol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum{
    TREF=0,     //ดอกจิก
    DIAMOND,    //ข้าวหลามตัด
    HEART,      //โพธิ์แดง (หัวใจ)
    SPADE,      //โพธิ์ดำ
}suitType;

@interface PDHelperFunction : CCNode

//Sprite From URL
+(CCSprite *)GetSpriteWithURL:(NSString*)_url;
+(BOOL) getIsGameDisplayPic:(NSString*)_url;
//Card
+(int)getCardPointWithCardNum:(int)_cardNum;
+(suitType)getCardSuitTypeWithCardNum:(int)_cardNum;
+(int)getCardNumWithCardNumber:(int)_cardNum;
+(float) getScreenHeight;
+(int) getAvatarIndexWithAvatarPicName:(NSString *)picName;


//String Process
+(NSString *)getChipStringWithChip:(NSInteger)chip;
@end
