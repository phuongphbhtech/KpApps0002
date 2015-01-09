//
//  SMScrollView.h
//  Smash
//
//  Created by Sarunporn Pisutwimol on 4/2/2557 BE.
//  Copyright 2557 Sarunporn Pisutwimol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "cocos2d-ui.h"

/* เป็น CCScrollView เพื่อความสามารถในการระบุขอบเขตที่จะแสดงผลได้ */
@interface SMScrollView : CCScrollView {
    
}

@property (nonatomic , assign) CGRect cropRect;
@end
