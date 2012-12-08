
#import "GameLayer.h"
#import "Car.h"
#import "HUD.h"
#import "Common.h"

#pragma mark - GameLayer

// HelloWorldLayer implementation
@implementation GameLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameLayer *layer = [GameLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (void) dealloc
{
    [car release];
    
    [super dealloc];
}

// 
-(id) init
{
	if((self=[super init]))
    {

		//CGSize size = [[CCDirector sharedDirector] winSize];
        
        [self initCar];
        [self initHUD];
        
        self.isTouchEnabled = YES;
    }
	
	return self;
}

#pragma mark - Touches

-(void) registerWithTouchDispatcher
{
	[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate: self priority: 0 swallowsTouches:YES];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self makeStep];
    
    return YES;
}

#pragma mark - Car

- (void) initCar
{
    car = [[Car alloc] init];
    
    [self addChild: car z: ZCar];
    
    car.position = ccp(300, 300);
    
    [car setInitialDirection: ccp(0, 1)];
}

- (void) makeStep
{
    static int i = 0;
    if(car.canMakeStep)
    {
        [car makeStep];
        
        
        if(i % 2 == 0)
        {
            [car turnLeft];
        }
        else if(i % 3 == 0)
        {
            [car turnRight];
        }
        else
        {
            [car turnAround];
        }
        i++;
    }
}

#pragma mark - HUD

- (void) initHUD
{
    hud = [[HUD alloc] init];
    
    [self addChild: hud z: zHUD];
}

@end