//
//  PDFBFriendDataObject.h
//  PokDeng
//
//  Created by Sarunporn Pisutwimol on 5/24/2557 BE.
//  Copyright (c) 2557 Sarunporn Pisutwimol. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDFBFriendDataObject : NSObject
@property (nonatomic , retain) NSString *username;
@property (nonatomic , retain) NSString *roomId;
@property (nonatomic , retain) NSString *displayPic;
@property (nonatomic , retain) NSString *userId;
@property (nonatomic , assign) bool isOnline;
@property (nonatomic , assign) bool isPlaying;
@end
