//
//  LosCocosGap.h
//  cocos-gap-iPad
//
//  Created by Drew Mayer on 8/24/10.
//  Copyright 2010 Drew Mayer. All rights reserved.
//

#import "PhoneGapCommand.h" 

#import "cocos2d.h"
@class GameGapLayer;

@interface GameGap : PhoneGapCommand  {

	CCScene* _scene;
	GameGapLayer *layer;
	NSMutableDictionary* _sprites;
	int _width;
	int _height;

}

- (void)initAndDisplayGameView:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options; 
- (void)setGameDisplayTransparent:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)createSprite:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)setSpriteImage:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)setSpriteZOrder:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)setPositions:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)deleteSprite:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

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
