//
//  LosCocosGap.m
//  cocos-gap-iPad
//
//  Created by Drew Mayer on 8/24/10.
//  Copyright 2010 Drew Mayer. All rights reserved.
//

/*
 
 Here are the TODO items:
 
 * Listen for touch events and pass through to elementFromPoint via javascript. ( event ? )
   * Figure out if should pass reference to gamegap or super to be able to write javascript.
 * Create a draw text method.
 * Make a set transparent method.
 * Make a prefetch texture call / preload.
 * Make a set orientation call -- or just integrate latest Cocos that supports orientations....
 * Create the dealloc method....
 * Create predone ccanimations / movements across screen with cocos2d
 * Try on a real device......
 * Create multiple demos
    * Create a simple "Driver" app that moves a sprite around.... shoot then delete something
    * The existing bounce around demo.
    * A demo with javascript box2d.
 * How to pause / resume game.
   This is here: http://www.google.com/codesearch/p?hl=en#PWa7F9gP7VU/trunk/tests/TouchesTest/TouchesDemoAppDelegate.m&q=touchestest%20package:http://cocos2d-iphone%5C.googlecode%5C.com&sa=N&cd=1&ct=rc
 * Document.
 * Upload somewhere.

 */




#import "GameGap.h"
#import "GameGapLayer.h"
#import "InvokedUrlCommand.h"
#import "PhoneGapDelegate.h"



@implementation GameGap


/* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 
 initAndDisplayGameView
 
 Arguments:
	width
	height
 */


- (void)initAndDisplayGameView:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options; 
{
	NSUInteger count = [arguments count];
	if ( count < 2 ) return;
	
	_width = [[ arguments objectAtIndex:0] intValue]; 
	_height = [[ arguments objectAtIndex:1] intValue]; 
	
	if( ! [CCDirector setDirectorType:CCDirectorTypeDisplayLink] ) {
		[CCDirector setDirectorType:CCDirectorTypeDefault];
	}
	
	// Use RGBA_8888 buffers
	// Default is: RGB_565 buffers
	[[CCDirector sharedDirector] setPixelFormat:kPixelFormatRGBA8888];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
	[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA4444];
	
	// before creating any layer, set the landscape mode
	//[[CCDirector sharedDirector] setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
	[[CCDirector sharedDirector] setAnimationInterval:1.0/60];
	//[[CCDirector sharedDirector] setDisplayFPS:YES];
	
	// create an openGL view inside a window
	[[CCDirector sharedDirector] attachInView:self.webView.superview];
	
	_scene = [GameGapLayer scene];
	
	// 'layer' is an autorelease object.
	layer = [GameGapLayer node];
	
	// add layer as a child to scene
	[_scene addChild: layer];
	
	layer->_gameGap = self;
	
	[[CCDirector sharedDirector] runWithScene: _scene];
	

	// ---------------------------------------
	
	// Try running with a timer
	//[NSTimer scheduledTimerWithTimeInterval:.005f
	//								 target:self
	//							     selector:@selector(updateTimer:)
	//							     userInfo:nil
	//								 repeats:YES];	
	
	
	// -------------------------------------

}


/* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 
 startGameCallback
 -Cocos2d callback
 
 */

- (void)startGameCallback:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
{
	[layer schedule:@selector(nextFrame:)];		
}



/* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 
 stopGameCallback
 -Cocos2d callback
 
 */


- (void)stopGameCallback:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
{
		
}


/* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 
 nextFrame
  -Cocos2d callback
  
 */


-(void)nextFrame:(ccTime)dt
{

	NSString *jsString = [NSString stringWithFormat:@"GameGap_NextFrame(%4.6f)", dt];
	//NSLog(@"Str: %@", jsString);
	
	NSString *theURL = [super.webView stringByEvaluatingJavaScriptFromString:jsString];
	NSURL *drainURL = [NSURL URLWithString:theURL];
	
	//NSLog(@"Drain URL: %@", drainURL);
	
	InvokedUrlCommand* iucDrain = [[InvokedUrlCommand newFromUrl:drainURL] autorelease];
	
	PhoneGapDelegate *appDelegate = (PhoneGapDelegate *)[[UIApplication sharedApplication] delegate];	
	
	[appDelegate execute:iucDrain];
	
}

						  

/* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 
	createSprite
 
	Arguments:
      -spriteKey
      -width
      -height
      -initial image
 
 */

- (void)createSprite:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	NSUInteger count = [arguments count];
	if ( count < 4 ) return;
	
	NSString *spriteKey = [arguments objectAtIndex:0];
	int width = [[ arguments objectAtIndex:1] intValue]; 
	int height = [[ arguments objectAtIndex:2] intValue]; 
	NSString *spriteImage = [arguments objectAtIndex:3];
	
	if (_sprites == nil) {
		_sprites = [[NSMutableDictionary alloc] initWithCapacity:10];
	}
	
	spriteImage = [@"www/" stringByAppendingString:spriteImage];

	CCSprite *newSprite = [CCSprite spriteWithFile:spriteImage rect:CGRectMake(0,0,width,height)];
	if ( newSprite == nil ) {
		NSLog(@"COULD NOT CREATE SPRITE key '%@' with image: '%@'", spriteKey, spriteImage);
		return;
	}
	newSprite.position = ccp(-100, -100);
	
	NSLog(@"Created sprite key '%@' with image: '%@'", spriteKey, spriteImage);
	
	[_sprites setObject:newSprite forKey:spriteKey];
	
	[_scene addChild:newSprite];
	
	
}


/* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 
 setSpriteImage
 
 Arguments:
 -spriteKey
 -spriteImage
 
 */

- (void)setSpriteImage:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	NSUInteger count = [arguments count];
	if ( count < 2 ) return;
	
	NSString *spriteKey = [arguments objectAtIndex:0];
	NSString *spriteImage = [arguments objectAtIndex:1];
	
	CCSprite* spriteToChange = [_sprites objectForKey:spriteKey];

	if ( spriteToChange == nil ) return;

	// addImage of text cache will either add a new image, or return if its there
	// www/red_button.png
	spriteImage = [@"www/" stringByAppendingString:spriteImage];
	[spriteToChange setTexture:[[CCTextureCache sharedTextureCache] addImage:spriteImage]];

}



/* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 
 setSpriteZOrder
 
 Arguments:
 -spriteKey
 -zOrder
 
 */

- (void)setSpriteZOrder:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	NSUInteger count = [arguments count];
	if ( count < 2 ) return;
	
	NSString *spriteKey = [arguments objectAtIndex:0];
	int zOrder = [[ arguments objectAtIndex:1] intValue]; 
	
	CCSprite* spriteToMove = [_sprites objectForKey:spriteKey];
	
	if ( spriteToMove == nil ) return;
	
	[_scene reorderChild:spriteToMove z:zOrder];
	
	NSLog(@"Set Z order for sprite '%@'", spriteKey);
	
}

/* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 
 deleteSprite
 
 Arguments:
 -spriteKey
 
 */


- (void)deleteSprite:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	NSUInteger count = [arguments count];
	if ( count < 1 ) return;
	NSString *spritKey = [arguments objectAtIndex:0];
	CCSprite* spriteToRemove = [_sprites objectForKey:spritKey];
	if ( spriteToRemove == nil ) return;
	[_sprites removeObjectForKey:spriteToRemove];
	[_scene removeChild:spriteToRemove cleanup:YES];
}


/* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 
 setPositions
 
 Arguments:
 -spriteKey
 -xPosition
 -yPosition
 
 */


- (void)setPositions:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	NSUInteger count = [arguments count];
	if ( count < 3 ) return;
	if ( count % 3 != 0 ) return;
	
	for ( int n = 0; n < count; n ++ )
	{
		NSString *spritKey = [arguments objectAtIndex:n];
		n++;
		int x = [[ arguments objectAtIndex:n] intValue]; 
		n++;
		int y = [[ arguments objectAtIndex:n] intValue]; 

		y = _height - y;
		CCSprite* spriteToMove = [_sprites objectForKey:spritKey];
		if ( spriteToMove == nil ) continue;

		// Need to compensate because HTML is anchor point top left
		// where cocos2d is in the middle....
		int compensateX = spriteToMove.contentSize.width / 2;
		int compensateY = spriteToMove.contentSize.height / 2;
		
		// Move the sprite.
		spriteToMove.position = ccp(x + compensateX , y - compensateY);
	}
	
}



/* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 
 setPositions
 
 Arguments:
 -spriteKey
 -xPosition
 -yPosition
 
 */

- (void)setGameDisplayTransparent:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	// This makes it so you can see the webview underneath.
	// This of course will probably make it slower ....
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	[CCDirector sharedDirector].openGLView.backgroundColor = [UIColor clearColor];
	
}



/* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 
	Touch Events forwarded from Cocos Layer
 
 */


- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	
	if( touch ) 
	{
		CGPoint location = [touch locationInView: [touch view]];
		// IMPORTANT:
		// The touches are always in "portrait" coordinates. You need to convert them to your current orientation
		CGPoint convertedPoint = [[CCDirector sharedDirector] convertToGL:location];
		
		
		NSString *jsString = [NSString stringWithFormat:@"var elem = document.elementFromPoint (%i,%i);"
							  "var evt = document.createEvent(\"MouseEvents\");"
							  "evt.initMouseEvent(\"mousedown\", true, true, window,"
							  "0, 0, 0, 0, 0, false, false, false, false, 0, null);"
							  "elem.dispatchEvent(evt);"		, 
							  (int)convertedPoint.x, (int)(_height - convertedPoint.y)]; 
		
		//NSLog(@"%@",jsString);
		[super writeJavascript:jsString];
	}
}


- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	
}

- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	
	if( touch ) 
	{
		CGPoint location = [touch locationInView: [touch view]];
		// IMPORTANT:
		// The touches are always in "portrait" coordinates. You need to convert them to your current orientation
		CGPoint convertedPoint = [[CCDirector sharedDirector] convertToGL:location];

							 
		NSString *jsString = [NSString stringWithFormat:@"var elem = document.elementFromPoint (%i,%i);"
								"var evt = document.createEvent(\"MouseEvents\");"
								"evt.initMouseEvent(\"mouseup\", true, true, window,"
												"0, 0, 0, 0, 0, false, false, false, false, 0, null);"
							    "elem.dispatchEvent(evt);"		, 
							 (int)convertedPoint.x, (int)(_height - convertedPoint.y)]; 
		
		//NSLog(@"%@",jsString);
		[super writeJavascript:jsString];
	}
	
}



- (void)updateTimer:(NSTimer *)theTimer
{
}



- (void) clearCaches
{
	[self clearSprites];
	
	[super clearCaches];
}

- (void) dealloc
{
	[self clearSprites];
	[_scene release];
	_scene = nil;
	[super dealloc];
}

- (void)clearSprites
{
	if ( _sprites != nil )
	{
		NSEnumerator* myIterator = [_sprites objectEnumerator];
		id anObject;
		
		while( anObject = [myIterator nextObject])
		{
			[_scene removeChild:(CCNode*)anObject cleanup:YES];
		}	
		
		[_sprites removeAllObjects];
		[_sprites release];
		_sprites = nil;
	}	
	
}

@end


/*
	RANDOM HOWTOS:
 
 [sprite setRotation: (float) CC_RADIANS_TO_DEGREES( -body->a )];
 
 
 //[[CCDirector sharedDirector] add];
 
 //[self.webView removeFromSuperview];
 
 
 //NSUInteger argc = [arguments count];  
 //int total = 0;  
 //for(int n = 0; n < argc; n++)  
 //{  
 //    total += [[ arguments objectAtIndex:n] intValue];  
 //}  
 //NSString* retStr = [ NSString stringWithFormat:@"alert(\"%d\");",total];  
 //[ webView stringByEvaluatingJavaScriptFromString:retStr ];  
 //	[webView stringByEvaluatingJavaScriptFromString:@"var e = document.createEvent('Events'); e.initEvent(\'deviceawake\');document.dispatchEvent(e);"];
 
 
 // DT is the time since the last frame..... this equates to our same time diff we were
 // trying to do in other games ........
 // 800 * dt means 800 pixels a second.
 
 -(void)nextFrame:(ccTime)dt 
 {
 //player.position = ccp(player.position.x + (500 * dt) , player.position.y);
 //player.position = ccp(player.position.x + 1 , player.position.y);
 
 //if ( player.position.x > 600 ) {
 //	player.position = ccp( -40, player.position.y);
 //}
 
 }
 
 
 //CGSize winSize = [[CCDirector sharedDirector] winSize];
 
 //player = [CCSprite spriteWithFile:@"block_blank.png" rect:CGRectMake(0,0,45,40)];
 //player.position = ccp(player.contentSize.width / 2, winSize.height/2);
 
 //[_layer addChild:player];
 
 // THIS Works for setting the texture / image, but it seems to flicker in
 // the simulator for this.
 //CCTexture2D *texture = [[CCTexture2D alloc]initWithImage:[UIImage imageNamed:@"www/red_button.png"]];
 //[player setTexture:texture];
 
 // THIS WORKS for setting the scale too!
 //[player setScaleX:2];
 //[player setScaleY:2];	
 

 // THIS Seems to work.......for removing things..
 // commenting out for now.
 //[[CCDirector sharedDirector] stopAnimation];
 //[[[CCDirector sharedDirector] openGLView] removeFromSuperview];
 
 
 
 
 */

