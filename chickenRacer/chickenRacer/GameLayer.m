
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
    [stars release];
    [crossers release];
    
    [hud release];
    [car release];
    
    [super dealloc];
}

// 
-(id) init
{
	if((self=[super init]))
    {
        stars = [[NSMutableArray alloc] init];
        crossers = [[NSMutableArray alloc] init];
        
        [self initCar];
        [self initHUD];
        
        [self loadLevel: currentLevel];
        
        self.isTouchEnabled = YES;
        
        [self schedule: @selector(onTimer:) interval: 1];
        [self scheduleUpdate];
    }
	
	return self;
}

- (void) reset
{
    car.position = ccp(0, 0);
    [car stopAllActions];
    
    points = 0;
    [hud setPoints: points];
    
    time = 0;
    [hud setTime: time];
    
    for(CCNode *node in stars)
    {
        [self removeChild: node cleanup:NO];
    }
    
    [stars removeAllObjects];
    
    for(CCNode *node in crossers)
    {
        [self removeChild: node cleanup: NO];
    }
    
    [crossers removeAllObjects];
    
    [self removeChildByTag: kMap cleanup: NO];
}

- (void) update: (ccTime) dt
{
    //check collisions

    //stars
    NSMutableArray *starsToRemove = [NSMutableArray array];
    
    for(CCNode *star in stars)
    {
        if(CGRectContainsPoint([star boundingBox], car.position))
        {
            [self applyScore: 10];
            
            [star removeFromParentAndCleanup: NO];
            
            [starsToRemove addObject: star];
        }
    }
    
    for(CCNode *star in starsToRemove)
    {
        [stars removeObject: star];
    }
    
    //crossers
    
    for(CCNode *crosser in crossers)
    {
        if(ccpDistance(car.position, crosser.position) < 20)
        {
            [self applyScore: -10];
            
            //[star removeFromParentAndCleanup: YES];
            
            //[starsToRemove addObject: star];
        }
    }
    
    //finish?
    
    if(CGRectContainsPoint(finishRect, car.position))
    {
        CCLOG(@"finish");
        
        //load next level
        [self loadLevel: currentLevel + 1];
    }
}

- (void) applyScore: (NSInteger) score
{
    points += score;
    [hud setPoints: points];
}

- (void) onTimer: (ccTime) dt
{
    time += 1;
    
    [hud setTime: time];
}

#pragma mark - Level stuff

- (CGPoint) tileCoordForPosition: (CGPoint) position
{
    int x = position.x / map.tileSize.width;
    int y = ((map.mapSize.height * map.tileSize.height) - position.y) / map.tileSize.height;

    return ccp(x, y);
}

- (CGPoint) positionFromTileCoord: (CGPoint) tileIndex
{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    int x = kTileSize * tileIndex.x + kTileSize / 2;
    int y =  screenSize.height - kTileSize * tileIndex.y - kTileSize / 2;
    
    return ccp(x, y);
}


- (void) loadLevel: (NSInteger) level
{
    [self reset];
    
    map = [CCTMXTiledMap tiledMapWithTMXFile: [NSString stringWithFormat: @"level%i.tmx" , level]];
    
    if(!map)
    {
        CCLOG(@"no such map file: %@", [NSString stringWithFormat: @"level%i.tmx", level]);
        
        return;
    }
    
    map.tag = kMap;
    
    [self addChild: map z: zMap];
    
    [self loadTurns];
    [self loadCrossers];
    [self loadStars];
    [self loadRoad];
    
    [self placeCar];
    
    //get finish rect
    
    CCTMXObjectGroup *objects = [map objectGroupNamed: @"objects"];
    NSAssert(objects != nil, @"'Objects' object group not found");
    
    NSMutableDictionary *finishRectDict = [objects objectNamed: @"finish"];
    NSAssert(finishRectDict != nil, @"SpawnPoint object not found");
    
    int x = [[finishRectDict valueForKey: @"x"] intValue];
    int y = [[finishRectDict valueForKey: @"y"] intValue];
    int w = [[finishRectDict valueForKey: @"width"] intValue];
    int h = [[finishRectDict valueForKey: @"height"] intValue];
    
    finishRect = CGRectMake(x, y, w, h);
    
    currentLevel = level;
}

- (void) loadRoad
{
    road = [map layerNamed: @"road"];
}

- (void) placeCar
{
    CCTMXObjectGroup *objects = [map objectGroupNamed: @"objects"];
    NSAssert(objects != nil, @"'Objects' object group not found");

    NSMutableDictionary *spawnPoint = [objects objectNamed: @"spawnPoint"];
    NSAssert(spawnPoint != nil, @"SpawnPoint object not found");

    int x = [[spawnPoint valueForKey: @"x"] intValue];
    int y = [[spawnPoint valueForKey: @"y"] intValue];
    
    car.position = ccp(x, y);
    carPrevLocation = car.position;
    
    NSString *initialDirection = [spawnPoint valueForKey: @"direction"];
    
    [car setInitialDirection: initialDirection];
}

- (void) loadTurns
{
    turns = [map layerNamed: @"turns"];
}

- (void) loadCrossers
{
    crossersLayer = [map layerNamed: @"crosses"];
    crossersLayer.visible = NO;
    
    //parse tiles and make crossers
    for(int i = 0; i < map.mapSize.height; ++i)
    {
        for(int j = 0; j < map.mapSize.width; ++j)
        {
            CGPoint tileIndex = ccp(j, i);
            
            //CGPoint tileCoord = [self tileCoordForPosition: tileIndex];
            int tileGid = [crossersLayer tileGIDAt: tileIndex];
            
            if(tileGid)
            {
                NSDictionary *properties = [map propertiesForGID: tileGid];
                if(properties)
                {
                    NSString *type = [properties valueForKey: @"type"];

                    CCNode *crosser = [self crosserByType: type];
                    crosser.position = [self positionFromTileCoord: tileIndex];
                    
                    [self addChild: crosser z: zCrosser];
                    
                    [crossers addObject: crosser];
                }
            }

        }
    }
}

- (void) loadStars
{
    starsLayer = [map layerNamed: @"stars"];
    starsLayer.visible = NO;
    
    for(int i = 0; i < map.mapSize.height; ++i)
    {
        for(int j = 0; j < map.mapSize.width; ++j)
        {
            CGPoint tileIndex = ccp(j, i);
            
            //CGPoint tileCoord = [self tileCoordForPosition: tileIndex];
//            int tileGid = [stars tileGIDAt: tileIndex];
//            
//            if(tileGid)
//            {
//                NSDictionary *properties = [map propertiesForGID: tileGid];
//                if(properties)
//                {
//                    NSString *type = [properties valueForKey: @"type"];
//                    
//                    CCNode *crosser = [self crosserByType: type];
//                    crosser.position = [self positionFromTileCoord: tileIndex];
//                    
//                    [self addChild: crosser z: zCrosser];
//                }
//            }
            
            CCNode *tile = [starsLayer tileAt: tileIndex];
            
            if(tile)
            {
                CCSprite *star = [CCSprite spriteWithFile: @"star.png"];
                star.position = [self positionFromTileCoord: tileIndex];
                
                [self addChild: star z: zStar];
                
                [stars addObject: star];
                
                [star runAction:
                                [CCRepeatForever actionWithAction:
                                                                [CCSequence actions:
                                                                                    [CCScaleTo actionWithDuration: 0.3 scaleX: 1.2 scaleY: 0.8],
                                                                                    [CCScaleTo actionWithDuration: 0.6 scaleX: 0.8 scaleY: 1.2],
                                                                                    [CCScaleTo actionWithDuration: 0.3 scaleX: 1 scaleY: 1],
                                                                                    nil
                                                                ]
                                ]
                ];
            }
            
        }
    }

}

- (CCNode *) crosserByType: (NSString *) type
{
    CCNode *node = nil;
    
    CGPoint delta;
    
    if([type isEqualToString: @"vt"])
    {
        node = [CCSprite spriteWithFile: @"crosser0.png"];
        delta = ccp(0, -2 * kTileSize);
        
        [node runAction:
                        [CCRepeatForever actionWithAction:
                                            [CCSequence actions:
                                                        [CCEaseBackInOut actionWithAction:
                                                                                    [CCMoveBy actionWithDuration: 0.2
                                                                                                        position: delta]
                                                        ],
                                                        [CCDelayTime actionWithDuration: 0.4],
                                                        [CCEaseBackInOut actionWithAction:
                                                                                    [CCMoveBy actionWithDuration: 0.2
                                                                                                        position: ccpMult(delta, -1)]
                                                        ],
                                                        [CCDelayTime actionWithDuration: 1],
                                                        nil
                                            ]
                        ]
        ];
    }
    else if([type isEqualToString: @"vb"])
    {
        node = [CCSprite spriteWithFile: @"crosser1.png"];
        delta = ccp(0, 2 * kTileSize);
        
        [node runAction:
                        [CCRepeatForever actionWithAction:
                                            [CCSequence actions:
                                                        [CCEaseBackInOut actionWithAction:
                                                                                    [CCMoveBy actionWithDuration: 0.2
                                                                                                        position: delta]
                                                        ],
                                                        [CCDelayTime actionWithDuration: 0.4],
                                                        [CCEaseBackInOut actionWithAction:
                                                                                    [CCMoveBy actionWithDuration: 0.2
                                                                                                        position: ccpMult(delta, -1)]
                                                        ],
                                                        [CCDelayTime actionWithDuration: 1],
                                                        nil
                                            ]
                        ]
        ];
    }
    else if([type isEqualToString: @"hl"])
    {
        node = [CCSprite spriteWithFile: @"crosser2.png"];
        delta = ccp(2 * kTileSize, 0);
        
        [node runAction:
                        [CCRepeatForever actionWithAction:
                                            [CCSequence actions:
                                                        [CCEaseBackInOut actionWithAction:
                                                                                    [CCMoveBy actionWithDuration: 0.2
                                                                                                        position: delta]
                                                        ],
                                                        [CCDelayTime actionWithDuration: 0.4],
                                                        [CCEaseBackInOut actionWithAction:
                                                                                    [CCMoveBy actionWithDuration: 0.2
                                                                                                        position: ccpMult(delta, -1)]
                                                        ],
                                                        [CCDelayTime actionWithDuration: 1],
                                                        nil
                                            ]
                        ]
        ];
    }
    else if([type isEqualToString: @"hr"])
    {
        node = [CCSprite spriteWithFile: @"crosser3.png"];
        delta = ccp(-2 * kTileSize, 0);
        
        [node runAction:
                        [CCRepeatForever actionWithAction:
                                            [CCSequence actions:
                                                        [CCEaseBackInOut actionWithAction:
                                                                                    [CCMoveBy actionWithDuration: 0.2
                                                                                                        position: delta]
                                                        ],
                                                        [CCDelayTime actionWithDuration: 0.4],
                                                        [CCEaseBackInOut actionWithAction:
                                                                                    [CCMoveBy actionWithDuration: 0.2
                                                                                                        position: ccpMult(delta, -1)]
                                                        ],
                                                        [CCDelayTime actionWithDuration: 1],
                                                        nil
                                            ]
                        ]
        ];
    }
    
    
    return node;
}

#pragma mark - Touches

-(void) registerWithTouchDispatcher
{
	[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate: self priority: 0 swallowsTouches:YES];
    
    //CCTMXLayer
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
    car.gameDelegate = self;
    
    [self addChild: car z: ZCar];
}

- (void) makeStep
{
    if(car.canMakeStep)
    {
        carPrevLocation = car.position;

        [car makeStep];
        
    }
}

- (void) checkState
{
    //is it a turn?
    
    CGPoint tileIndex = [self tileCoordForPosition: car.position];
    
    CCNode *turn = [turns tileAt: tileIndex];
    
    if(turn)
    {
        
        CCLOG(@"turning");
        
        NSMutableArray *adjacentNodes = [NSMutableArray array];
        
        CCNode *tile = nil;
        CCNode *prevTile = [road tileAt: [self tileCoordForPosition: carPrevLocation]];
        
        if((tile = [self getAdjacentNodeAtX: tileIndex.x + 1 andY: tileIndex.y]))
        {
            [adjacentNodes addObject: tile];
        }
        
        tile = nil;
        
        if((tile = [self getAdjacentNodeAtX: tileIndex.x andY: tileIndex.y - 1]))
        {
            [adjacentNodes addObject: tile];
        }
        
        tile = nil;
        
        if((tile = [self getAdjacentNodeAtX: tileIndex.x - 1 andY: tileIndex.y]))
        {
            [adjacentNodes addObject: tile];
        }
        
        tile = nil;
        
        if((tile = [self getAdjacentNodeAtX: tileIndex.x andY: tileIndex.y + 1]))
        {
            [adjacentNodes addObject: tile];
        }
        
        if([adjacentNodes count] > 1)
        {
            [adjacentNodes removeObject: prevTile];
        }

        CCNode *anyTile = [adjacentNodes objectAtIndex: 0];
        CCNode *currentTile = [road tileAt: tileIndex];
        
        CGPoint dir = ccpNormalize(ccpSub(anyTile.position, currentTile.position));
        
        [car turnToDirection: dir];
    }

}

- (CCNode *) getAdjacentNodeAtX: (NSInteger) x andY: (NSInteger) y
{
    int mapWidth = map.mapSize.width;
    int mapHeigt = map.mapSize.height;
    
    if(x >= 0 && x < mapWidth && y >= 0 && y < mapHeigt)
    {
        return [road tileAt: ccp(x, y)];
    }
    
    return nil;
}

#pragma mark - HUD

- (void) initHUD
{
    hud = [[HUD alloc] init];
    
    [self addChild: hud z: zHUD];
}

@end