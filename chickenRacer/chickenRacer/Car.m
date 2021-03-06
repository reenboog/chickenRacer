
#import "Car.h"
#import "Config.h"

@implementation Car

@synthesize canMakeStep;
@synthesize direction;

@synthesize gameDelegate;

- (void) dealloc
{
    [super dealloc];
}

- (id) init
{
    if(self = [super init])
    {
        sprite = [CCSprite spriteWithFile: @"car0.png"];
        
        [self addChild: sprite];
        {
//        [sprite runAction:
//                        [CCRepeatForever actionWithAction:
//                                                        [CCSequence actions:
//                                                                        [CCScaleTo actionWithDuration: 0.1 scale: 1.05],
//                                                                        [CCDelayTime actionWithDuration: 0.05],
//                                                                        [CCScaleTo actionWithDuration: 0.1 scale: 1.0],
//                                                                        nil
//                                                        ]
//                        ]
//        ];
        }
        
        [self reset];
        
        [self setContentSize: sprite.boundingBox.size];
    }
    
    return self;
}

- (void) reset
{
    direction = ccp(0, 1);
    sprite.rotation = 0;
    
    canMakeStep = YES;
}

- (void) setInitialDirection: (NSString *) dir
{
    CGPoint pt;
    
    if([dir isEqualToString: @"right"])
    {
        pt = ccp(1, 0);
    }
    else if([dir isEqualToString: @"left"])
    {
        pt = ccp(-1, 0);
    }
    else if([dir isEqualToString: @"up"])
    {
        pt = ccp(0, 1);
    }
    else if([dir isEqualToString: @"down"])
    {
        pt = ccp(0, -1);
    }
    
    direction = pt;
    float angle = 0;
    
    if(pt.x == 1 && pt.y == 0)
    {
        angle = 90;
    }
    else if(pt.x == 0 && pt.y == -1)
    {
        angle = 180;
    }
    else if(pt.x == -1 && pt.y == 0)
    {
        angle = -90;
    }
    else if(pt.x == 0 && pt.y == 1)
    {
        angle = 0;
    }
    
    sprite.rotation = angle;
    
    CCLOG(@"direction: %f,%f", direction.x, direction.y);
    CCLOG(@"initial rotation: %f", sprite.rotation);
    
    //orthogonal = ccpRotateByAngle(orthogonal, ccp(0, 0), angle);
    
}

- (CGPoint) makeStep
{
    CCLOG(@"step");
    
    CGPoint delta = ccpMult(direction, kStep);
    CGPoint pos = ccpAdd(self.position, delta);
    
    [self runAction:
                    [CCSequence actions:
                                    [CCEaseBackOut actionWithAction:
                                                                    [CCMoveBy actionWithDuration: 0.2 position: delta]
                                    ],
                                    [CCCallFunc actionWithTarget: self.gameDelegate selector: @selector(checkState)],
                                    nil
                    ]
    ];
    
    return pos;
}

- (BOOL) canMakeStep
{
    return [self numberOfRunningActions] == 0;//canMakeStep;
}

- (void) turnByAngle: (float) angle
{
    canMakeStep = NO;
    
    direction = ccpRotateByAngle(direction, ccp(0, 0), CC_DEGREES_TO_RADIANS(-angle));

    float a = CC_DEGREES_TO_RADIANS(sprite.rotation + angle);
//    float x = direction.x * cosf(a) - direction.y * sinf(a);
//    float y = direction.x * sinf(a) + direction.y * cosf(a);
    
    [sprite runAction:
                    [CCSequence actions:
                                        [CCRotateBy actionWithDuration: 0.2 angle: angle],
                                        [CCCallBlock actionWithBlock:
                                                                    ^{
                                                                        canMakeStep = YES;
                                                                     }
                                        ],
                                        nil
                    ]
    ];
    
    CCLOG(@"point: %f, %f", direction.x, direction.y);
}

- (void) turnRight
{
    CCLOG(@"turning right.");
    [self turnByAngle: 90];
}

- (void) turnLeft
{
    CCLOG(@"turning lef.");
    [self turnByAngle: -90];
}

- (void) turnAround
{
    CCLOG(@"turning around.");
    [self turnByAngle: -180];
}

- (void) turnToDirection: (CGPoint) dir
{
    CCLOG(@"turning by direction: %f, %f", dir.x, dir.y);
    
    float angle = atan2f(dir.y, dir.x) - atan2(direction.y, direction.x);
    angle = CC_RADIANS_TO_DEGREES(angle);
    
    if(fabs(angle) > 180)
    {
        angle = 360 - angle;
        angle *= - 1;
    }
    
    //angle = atan2f(1, 1);

    CCLOG(@"resulting angle: %f", angle);
    
    [self turnByAngle: -angle];
}

@end
