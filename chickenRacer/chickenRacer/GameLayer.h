
#import "cocos2d.h"

@class Car;
@class HUD;

// HelloWorldLayer
@interface GameLayer : CCLayer
{
    HUD *hud;
    
    Car *car;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

- (void) initCar;
- (void) initHUD;

- (void) makeStep;

@end
