
#import "cocos2d.h"
#import "Common.h"

@interface Car: CCNode
{
    CCSprite *sprite;
    CGPoint direction;
    BOOL canMakeStep;
    
    id<MapDelegate> gameDelegate;
}

@property (nonatomic, readonly, getter = canMakeStep) BOOL canMakeStep;
@property (nonatomic, readonly) CGPoint direction;

@property (nonatomic, assign) id<MapDelegate> gameDelegate;

- (void) reset;
- (CGPoint) makeStep;
- (void) setInitialDirection: (NSString *) direction;

- (void) turnRight;
- (void) turnLeft;
- (void) turnAround;

- (void) turnToDirection: (CGPoint) dir;


@end
