//
//  GameGapLayer.m
//  cocos-gap-iPad
//
//  Created by Drew Mayer on 8/17/10.
//  Copyright 2010 Drew Mayer. All rights reserved.
//

// Import the interfaces
#import "GameGapLayer.h"

// HelloWorld implementation
@implementation GameGapLayer

@synthesize _gameGap;


+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
		
	// return the scene
	return scene;
	
}

-(void)nextFrame:(ccTime)dt
{
	[_gameGap nextFrame:dt];
}

// on "init" you need to initialize your instance
-(id) init
{
	if ( (self=[super init] ))
	{
		self.isTouchEnabled = YES;
		
	}
	
	
	return self;
	
}

// Link to example with accelerometer... although maybe not needed as phonegap provides?
// http://www.google.com/codesearch/p?hl=en#PWa7F9gP7VU/trunk/tests/samples/HelloEvents.m&q=touchestest%20package:http://cocos2d-iphone%5C.googlecode%5C.com&d=0


// This callback will be called because 'isTouchesEnabled' is YES.
// Possible events:
//   * ccTouchesBegan
//   * ccTouchesMoved
//   * ccTouchesEnded
//   * cctouchesCancelled
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[_gameGap ccTouchesBegan:touches withEvent:event];
}

//- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
//- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[_gameGap ccTouchesEnded:touches withEvent:event];
}


// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}


@end
