//
//  GameGapLayer.h
//  cocos-gap-iPad
//
//  Created by Drew Mayer on 8/17/10.
//  Copyright 2010 Drew Mayer. All rights reserved.
//

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "GameGap.h"

@class GameGap;

// GameGapLayer Layer
@interface GameGapLayer : CCLayer
{
	@public
	GameGap* _gameGap;
}

// returns a Scene that contains the GameGapLayer as the only child
+(id) scene;

-(void)nextFrame:(ccTime)dt;

@property(nonatomic,assign)GameGap* _gameGap;


@end