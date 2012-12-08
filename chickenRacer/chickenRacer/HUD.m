//
//  HUD.m
//  chickenRacer
//
//  Created by Alex Gievsky on 08.12.12.
//  Copyright (c) 2012 spotGames. All rights reserved.
//

#import "HUD.h"

@interface HUD ()

@end

@implementation HUD

- (void) dealloc
{
    [super dealloc];
}

- (id) init
{
    if(self = [super init])
    {
//        goForwardBtn = [CCMenuItemImage itemWithNormalImage: @"goForwardBtn.png"
//                                              selectedImage: @"goForwardBtnOn.png"
//                                                     target: self
//                                                   selector: @selector(goForward)];
//        
//        goBackwarddBtn = [CCMenuItemImage itemWithNormalImage: @"goBackwardBtn.png"
//                                                selectedImage: @"goBackwardBtnOn.png"
//                                                       target: self
//                                                     selector: @selector(goBackward)];
//
//        transmissionMenu = [CCMenu menuWithItems: goForwardBtn, goBackwarddBtn, nil];
//        
//        [transmissionMenu alignItemsHorizontallyWithPadding: 10];
//        
//        transmissionMenu.position = ccp(970, 26);
//        
//        [self addChild: transmissionMenu];
        
        pointsLabel = [CCLabelBMFont labelWithString: @"" fntFile: @"bip_big.fnt"];
        pointsLabel.anchorPoint = ccp(1, 0.5);
        pointsLabel.position = ccp(1010, 740);
        
        [self addChild: pointsLabel];
        
        timeLabel = [CCLabelBMFont labelWithString: @"" fntFile: @"bip_big.fnt"];
        timeLabel.anchorPoint = ccp(1, 0.5);
        timeLabel.position = ccp(1010, 710);
        
        [self addChild: timeLabel];
    }

    return self;
}

- (void) setPoints: (NSInteger) points
{
    pointsLabel.string = [NSString stringWithFormat: @"points: %i", points];
}

- (void) setTime: (NSInteger) seconds
{
    NSString *time = nil;
    
    NSInteger minutes = seconds / 60;
    NSInteger restSeconds = seconds % 60;
    
    NSString *minutesStr = minutes > 10 ? [NSString stringWithFormat: @"%i", minutes] : [NSString stringWithFormat: @"0%i", minutes];
    NSString *secondsStr = restSeconds > 10 ? [NSString stringWithFormat: @"%i", restSeconds] : [NSString stringWithFormat: @"0%i", restSeconds];
    
    timeLabel.string = [NSString stringWithFormat: @"time: %@:%@", minutesStr, secondsStr];
}


//- (void) goForward
//{
//    CCLOG(@"going forward");
//}
//
//- (void) goBackward
//{
//    CCLOG(@"going backward");
//}

@end
