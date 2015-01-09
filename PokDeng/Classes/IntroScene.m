//
//  IntroScene.m
//  PokDeng
//
//  Created by Sarunporn Pisutwimol on 5/23/2557 BE.
//  Copyright Sarunporn Pisutwimol 2557. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "IntroScene.h"
#import "HelloWorldScene.h"

// -----------------------------------------------------------------------
#pragma mark - IntroScene
// -----------------------------------------------------------------------

@implementation IntroScene

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (IntroScene *)scene
{
	return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    int maxCapacity = 6;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:maxCapacity];
    for (int i = 0; i<maxCapacity; i++) {

        [array addObject:[NSNull null]];
    }
    NSArray *testData = @[@"data1",@"data2"];
    [array setObject:testData atIndexedSubscript:2];

    DLog(@"array %@",array);

    for (int i = 0; i<array.count; i++) {
        NSArray *getArray = [array objectAtIndex:i];
        if (![getArray  isEqual:[NSNull null]]) {
            DLog(@"data %@",getArray);
        }else{
            DLog(@"data at index %i is null",i);
        }
        
    }
    
    //Use for get font name
    /*
     for (NSString* family in [UIFont familyNames])
     {
     NSLog(@"%@", family);
     
     for (NSString* name in [UIFont fontNamesForFamilyName: family])
     {
     NSLog(@"  %@", name);
     }
     }
     */
    // done
	return self;
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)onSpinningClicked:(id)sender
{
    // start spinning scene with transition
    [[CCDirector sharedDirector] replaceScene:[HelloWorldScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:1.0f]];
}

// -----------------------------------------------------------------------
@end
