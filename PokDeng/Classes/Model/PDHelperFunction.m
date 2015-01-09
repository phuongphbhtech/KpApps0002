//
//  PDHelperFunction.m
//  PokDeng
//
//  Created by Sarunporn Pisutwimol on 5/20/2557 BE.
//  Copyright (c) 2557 Sarunporn Pisutwimol. All rights reserved.
//

#import "PDHelperFunction.h"

#define DEFALUT_SPRITE_NAME                 @"basic04.png"
#define DEFAULT_PIC_INDEX                   3
#define kCardNumPerSuit                     13



@implementation PDHelperFunction
+(CCSprite *)GetSpriteWithURL:(NSString*)_url{
    NSURL *imgUrl = [NSURL URLWithString:_url];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imgUrl]];
    CCSprite *sprite;
    if ([image isEqual:[NSNull null]] || image == NULL || image == nil) {
        if ([_url rangeOfString:@"basic"].location == NSNotFound ) {
            sprite = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:DEFALUT_SPRITE_NAME]];
        }else{
            sprite = [CCSprite spriteWithImageNamed:_url];
        }
        
    }else{
        sprite = [CCSprite spriteWithCGImage:image.CGImage key:_url];
    }
    
    return sprite;
}

+(BOOL) getIsGameDisplayPic:(NSString*)_url{
    NSURL *imgUrl = [NSURL URLWithString:_url];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imgUrl]];
    if (image != nil) {
        return NO;
    }else{
        return YES;
    }
}
//Card
+(int)getCardPointWithCardNum:(int)_cardNum{
    int cardPoint = [self getCardNumWithCardNumber:_cardNum];
    if (cardPoint > 10) {
        cardPoint = 10;
    }
    return cardPoint;
}
+(suitType)getCardSuitTypeWithCardNum:(int)_cardNum{
    suitType type;
    if (_cardNum <= 13) {
        type = TREF;
    }else if (_cardNum >=14 && _cardNum <= 26){
        type = DIAMOND;
    }else if (_cardNum >=28 && _cardNum <= 40){
        type = HEART;
    }else if (_cardNum >= 41){
        type = SPADE;
    }
    return type;
}
+(int)getCardNumWithCardNumber:(int)_cardNum{
    int cardNum = _cardNum %kCardNumPerSuit;
    if (cardNum == 0) {
        cardNum = kCardNumPerSuit;
    }
    return cardNum;
}

+(float) getScreenHeight{
    return WINS.height*[[CCDirector sharedDirector]contentScaleFactor];
}

+(int) getAvatarIndexWithAvatarPicName:(NSString *)picName{
    if (!([picName rangeOfString:@"basic"].location == NSNotFound)) {
        NSString *indexString = [picName substringWithRange:NSMakeRange(5, 2)];
        int index = [indexString intValue];
        return index-1;
    }
    return DEFAULT_PIC_INDEX; //return ค่า avatar ลำดับที่ 3 ที่เป็นอันให้ใช้เริ่มต้น
}

#pragma mark - String Process
+(NSString *)getChipStringWithChip:(NSInteger)chip{
    NSMutableString *string = [NSMutableString stringWithFormat:@"%i",(int)chip];
    NSInteger processIndex = string.length;
    
    if (processIndex > 3) {
        while (processIndex-3 > 0) {
            processIndex -= 3;
            [string insertString:@"," atIndex:processIndex];
        }
    }
    return string;
}
@end
