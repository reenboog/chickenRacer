
#import "cocos2d.h"

@interface Car: CCNode
{
    CCSprite *sprite;
    CGPoint direction;
    BOOL canMakeStep;
}

@property (nonatomic, readonly, getter = canMakeStep) BOOL canMakeStep;
@property (nonatomic, readonly) CGPoint direction;

- (void) reset;
- (void) makeStep;
- (void) setInitialDirection: (CGPoint) pt;

- (void) turnRight;
- (void) turnLeft;
- (void) turnAround;


@end
