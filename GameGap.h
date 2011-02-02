//
//  LosCocosGap.h
//  cocos-gap-iPad
//
//  Created by Drew Mayer on 8/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PhoneGapCommand.h" 
#import "cocos2d.h"
#import "SimpleAudioEngine.h"

/*
 public static int MOVE_SPRITE = 0;
 public static int SET_SPRITE_IMAGE = 1;
 public static int CREATE_SPRITE = 2;
 
 public static int PLAY_EFFECT = 3;
 public static int PLAY_BACKGROUND_MUSIC = 4;
 public static int STOP_BACKGROUND_MUSIC = 5; 
 public static int RESUME_BACKGROUND_MUSIC = 6;
 
 public static int PAUSE_BACKGROUND_MUSIC = 7;
 public static int DELETE_SPRITE = 8;
 public static int DELETE_ALL_SPRITES_AND_STOP_CALLBACK = 9;
 */

#define MOVE_SPRITE 0
#define SET_SPRITE_IMAGE 1

#define CREATE_SPRITE 2
#define PLAY_EFFECT 3

#define PLAY_BACKGROUND_MUSIC 4
#define STOP_BACKGROUND_MUSIC 5
#define RESUME_BACKGROUND_MUSIC 6

#define PAUSE_BACKGROUND_MUSIC 7
#define DELETE_SPRITE 8
#define DELETE_SPRITE_AND_STOP_ENGINE 9

#define COMMAND_PARAM_SEPARATOR @":"
#define COMMAND_SEPARATOR @"|"

@class GameGapLayer;

@interface GameGap : PhoneGapCommand  {

	CCScene* _scene;
	GameGapLayer *layer;
	NSMutableDictionary* _sprites;
	NSMutableDictionary* _touchPointsToRects;

	CCTMXTiledMap *_tileMap;	
	CCTMXLayer *_background;
	
	int _width;
	int _height;

}

- (void)initGameView:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)displayGameView:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)hideGameView:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options; 
- (void)setGameDisplayTransparent:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)preloadSpriteImage:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)createSprite:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)createMultipleSprites:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)setSpriteImage:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)setSpriteZOrder:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)setBackgroundTilemap:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)setPositions:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)deleteSprite:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)deleteMultipleSprites:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)startGameCallback:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;;
- (void)stopGameCallback:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;;

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)updateTimer:(NSTimer *)theTimer;

-(void)nextFrame:(ccTime)dt;

- (void)clearSprites;


@end
