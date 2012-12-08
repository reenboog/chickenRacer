
#import "cocos2d.h"

@interface HUD: CCLayer
{
    //CCMenu *transmissionMenu;
    //CCMenuItemImage *goForwardBtn;
    //CCMenuItemImage *goBackwarddBtn;
    CCLabelBMFont *pointsLabel;
    CCLabelBMFont *timeLabel;
}

- (void) goForward;
- (void) goBackward;

- (void) setPoints: (NSInteger) points;
- (void) setTime: (NSInteger) seconds;

@end
