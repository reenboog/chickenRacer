
#import "cocos2d.h"
#import "Common.h"

@class Car;
@class HUD;

// HelloWorldLayer
@interface GameLayer : CCLayer <MapDelegate>
{
    HUD *hud;
    
    Car *car;
    
    CCTMXTiledMap *map;
    CCTMXLayer *turns;
    CCTMXLayer *road;

    CCTMXLayer *crossersLayer;
    NSMutableArray *crossers;

    CCTMXLayer *starsLayer;
    NSMutableArray *stars;
        
    int points;
    int time;
    
    int currentLevel;
    
    CGRect finishRect;
    
    CGPoint carPrevLocation;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

- (void) reset;

- (void) initCar;
- (void) initHUD;

- (void) applyScore: (NSInteger) score;

- (void) makeStep;

- (void) loadLevel: (NSInteger) level;
- (void) loadTurns;
- (void) loadCrossers;

- (void) checkState;

@end
