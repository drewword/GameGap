//
//  LosCocosGap.m
//  cocos-gap-iPad
//
//  Created by Drew Mayer on 8/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
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




@interface MyPoint : NSObject
{
	float x;
	float y;
}
@property (nonatomic) float x;
@property (nonatomic) float y;
@end
@implementation MyPoint
@synthesize x;
@synthesize y;
@end



@implementation GameGap


/* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 
 initAndDisplayGameView
 
 Arguments:
	width
	height
 */


- (void)initGameView:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options; 
{
	NSUInteger count = [arguments count];
	if ( count < 2 ) return;

	if ( _scene == nil ) 
	{
	
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
		[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
		//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA4444];
	
		// before creating any layer, set the landscape mode
		//[[CCDirector sharedDirector] setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
		[[CCDirector sharedDirector] setAnimationInterval:1.0/60];
		//[[CCDirector sharedDirector] setDisplayFPS:YES];
	
		_scene = [GameGapLayer scene];
		
		// 'layer' is an autorelease object.
		layer = [GameGapLayer node];
		
		// add layer as a child to scene
		[_scene addChild: layer];
		
		layer->_gameGap = self;

		[[CCDirector sharedDirector] runWithScene: _scene];
		
		_touchPointsToRects = [[NSMutableDictionary alloc] initWithCapacity:10];
		

		[self.webView.superview setMultipleTouchEnabled: YES];
		
		
	}

	[[CCDirector sharedDirector] attachInView:self.webView.superview];
	[[CCDirector sharedDirector] resume];
	
	[self.webView.superview bringSubviewToFront:webView];
	
}


-(void)displayGameView:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options
{
	//[[CCDirector sharedDirector] attachInView:self.webView.superview];
	//[[CCDirector sharedDirector] attachInView:self.webView.superview];
	//[[CCDirector sharedDirector] resume];
	
	[self.webView.superview sendSubviewToBack:webView];
}


/* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 
 hideGameView
 
 */

- (void)hideGameView:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	//[self clearSprites];
	//[[CCDirector sharedDirector] stopAnimation];
	//[[CCDirector sharedDirector] dealloc];

	[self.webView.superview bringSubviewToFront:webView];
	
	//[[[CCDirector sharedDirector] openGLView] removeFromSuperview];
	
}



/* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 
 setBackgroundTilemap
 www/tilemap.tmx
 
 */


- (void)setBackgroundTilemap:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	NSUInteger count = [arguments count];
	if ( count < 1 ) return;
	
	NSString *spriteImage = [arguments objectAtIndex:0];
	spriteImage = [@"www/" stringByAppendingString:spriteImage];

	_tileMap = [CCTMXTiledMap tiledMapWithTMXFile:spriteImage];
	_background = [_tileMap layerNamed:@"Background"];
	[_scene addChild:_tileMap z:-1];
	
 	[_background setPosition:ccp(0,0)];
	
}


/* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 
 startGameCallback
 -Cocos2d callback
 
 */

- (void)startGameCallback:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
{
	
	[super writeJavascript:@"var e = document.createEvent('Events'); e.initEvent(\'gameGapTimerStart\');document.dispatchEvent(e);"];

	// make sure we dont run multiple timers
	[layer unschedule:@selector(nextFrame:)];
	
	
	[layer schedule:@selector(nextFrame:)];	
	
	
	// THIS IS Needed in the case if we are going to support on resume + 
	// active, etc.  Otherwise, lets avoid it.
	// on resume
	//[[CCDirector sharedDirector] stopAnimation];
	//[[CCDirector sharedDirector] resume];
	//[[CCDirector sharedDirector] startAnimation];
	
	
	
	// OLD STUFF
	//[[SimpleAudioEngine sharedEngine] init];

}



/* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 
 stopGameCallback
 -Cocos2d callback
 
 */


- (void)stopGameCallback:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
{
	// NOTE: Could also use pause and resume.
	[layer unschedule:@selector(nextFrame:)];
	
	//[[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
	
}


/* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 
 nextFrame
  -Cocos2d callback
  
 */


-(void)nextFrame:(ccTime)dt
{
	// Commands will come in with a number + the arguments.  First need to split the
	// commands up.
	
	NSString *jsString = [NSString stringWithFormat:@"GameGap_NextFrame(%4.8f)", dt];
	NSString *jsCommandData = [super.webView stringByEvaluatingJavaScriptFromString:jsString];
	
	if ( jsCommandData == nil ) return;
	
	//NSLog(@"Str: %@", jsCommandData);

	NSArray *commands = [jsCommandData componentsSeparatedByString:COMMAND_SEPARATOR];
	if ( commands == nil ) return;

	BOOL bDeleteAllAndHalt = FALSE;
	
	for (NSString *command in commands) 
	{
		//NSLog(@"Command: %@", command );
		if ( command == nil ) continue;
		NSArray *commandPieces = [command componentsSeparatedByString:COMMAND_PARAM_SEPARATOR];
		if ( commandPieces == nil ) continue;
		
		int pieceslen = [commandPieces count];
		if ( pieceslen == 0 ) continue;
		int command = [[commandPieces objectAtIndex:0] intValue];

		pieceslen -= 2; // 1 for nil at end, 1 for the actual command (MOVE_SPRITE)
		// We have a command, run it.
		switch (command) 
		{
			case MOVE_SPRITE:
			{
				// The signature for the command is
				// -spriteName
				// -xpos
				// -ypos 
				//  with as many repeating scenarios as that...
				NSMutableArray *pgCommand = [[NSMutableArray alloc] initWithCapacity:20];
				for ( int pc = 1; pc < pieceslen; pc += 3 )
				{
					NSString *spriteName = [commandPieces objectAtIndex:pc];
					int xpos = [[commandPieces objectAtIndex:pc + 1] intValue];
					int ypos = [[commandPieces objectAtIndex:pc + 2] intValue]; 
					//NSLog(@"move spritZ %@ %i %i", spriteName, xpos, ypos);
					
					[pgCommand addObject:spriteName];
					[pgCommand addObject:[NSNumber numberWithInteger:xpos]];
					[pgCommand addObject:[NSNumber numberWithInteger:ypos]];
				}
				
				// Call out to move the sprite.
				[self setPositions:pgCommand withDict:nil];
				[pgCommand release];
				break;
			}
			case SET_SPRITE_IMAGE:
			{
				NSString *spriteName = [commandPieces objectAtIndex:1];
				NSString *imageName = [commandPieces objectAtIndex:2];
				NSMutableArray *pgCommand = [[NSMutableArray alloc] initWithObjects:
											 spriteName, imageName, nil];
				
				[self setSpriteImage:pgCommand withDict:nil];
				[pgCommand release];
				
				break;
			}
			case CREATE_SPRITE:
			{
				NSString *spriteKey = [commandPieces objectAtIndex:1];
				NSString *width = [commandPieces objectAtIndex:2]; //[[commandPieces objectAtIndex:2] intValue];
				NSString *height = [commandPieces objectAtIndex:3]; //[[commandPieces objectAtIndex:3] intValue];
				NSString *imageName = [commandPieces objectAtIndex:4];
				
				NSMutableArray *pgCommand = [[NSMutableArray alloc] initWithObjects:
											  spriteKey, width, height, imageName, nil ];
				[self createSprite:pgCommand withDict:nil];
				[pgCommand release];
				
				break;
			}
			case PLAY_EFFECT:
			{
				NSString *sound = [commandPieces objectAtIndex:1];
				sound = [@"www/" stringByAppendingString:sound];

				[[SimpleAudioEngine sharedEngine] playEffect:sound];
				break;
			}
			case PLAY_BACKGROUND_MUSIC:
			{
				NSString *sound = [commandPieces objectAtIndex:1];
				sound = [@"www/" stringByAppendingString:sound];
				
				[[SimpleAudioEngine sharedEngine] playBackgroundMusic:sound];
				break;
			}
			case STOP_BACKGROUND_MUSIC:
			{
				[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
				break;
			}
			case PAUSE_BACKGROUND_MUSIC:
			{
				[[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
				break;
			}
			case RESUME_BACKGROUND_MUSIC:
			{
				[[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
				break;
			}
			case DELETE_SPRITE:
			{
				NSString *spriteKey = [commandPieces objectAtIndex:1];
				CCSprite* spriteToRemove = [_sprites objectForKey:spriteKey];
				if ( spriteToRemove != nil )
				{
					[_sprites removeObjectForKey:spriteToRemove];
					[_scene removeChild:spriteToRemove cleanup:YES];
				}
				break;
			}
			case DELETE_SPRITE_AND_STOP_ENGINE:
			{
				bDeleteAllAndHalt = TRUE; // Go ahead and do everything else first
				break;
			}
			default:
			{
				break;
			}	
		}
		
		if ( bDeleteAllAndHalt )
		{
			NSEnumerator* myIterator = [_sprites objectEnumerator];
			id anObject;
			while( anObject = [myIterator nextObject])
			{
				[_scene removeChild:(CCNode*)anObject cleanup:YES];
			}	
			[_sprites removeAllObjects];
			[layer unschedule:@selector(nextFrame:)];
		}
		
	}
	

	
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

	if ( spriteImage == nil ) {
		return;
	}
	if ( [spriteImage length] == 0 ) {
		return;
	}
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
	
	//NSLog(@"Created sprite key '%@' with image: '%@'", spriteKey, spriteImage);
	
	[_sprites setObject:newSprite forKey:spriteKey];
	
	[_scene addChild:newSprite];
	
	
}

/* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 
 createMultipleSprites
 
 Arguments:
 -spriteKey
 -width
 -height
 -initial image
 
 */

- (void)createMultipleSprites:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	NSUInteger count = [arguments count];
	if ( count == 0 ) return;

	// Split apart and call createSprite
	NSString *jsCommandData = [arguments objectAtIndex:0];

	NSArray *spriteData = [jsCommandData componentsSeparatedByString:COMMAND_SEPARATOR];
	if ( spriteData == nil ) return;
	
	for (NSString *data in spriteData) 
	{
		//NSLog(@"Command: %@", command );
		
		NSArray *spritePieces = [data componentsSeparatedByString:COMMAND_PARAM_SEPARATOR];
		int pieceslen = [spritePieces count];
		if ( pieceslen == 0 ) continue;
		
		NSString *spriteKey = [spritePieces objectAtIndex:0];
		NSString *width = [spritePieces objectAtIndex:1];
		NSString *height = [spritePieces objectAtIndex:2];
		NSString *x = [spritePieces objectAtIndex:3];
		NSString *y = [spritePieces objectAtIndex:4];
		NSString *spriteImage = [spritePieces objectAtIndex:5];
		
		NSMutableArray *pgCommand = [[NSMutableArray alloc] initWithObjects:
									 spriteKey, width, height, spriteImage, nil];
		
		[self createSprite:pgCommand withDict:nil];
		[pgCommand release];
		
		pgCommand = [[NSMutableArray alloc] initWithObjects:
							 spriteKey, x,y, nil];
		
		[self setPositions:pgCommand withDict:nil];
		[pgCommand release];
		

	}
	
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
 
 setSpriteImage
 
 Arguments:
 -spriteKey
 -spriteImage
 
 */

- (void)preloadSpriteImage:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	NSUInteger count = [arguments count];
	if ( count < 1 ) return;
	
	NSString *spriteImage = [arguments objectAtIndex:0];
	
	[[CCTextureCache sharedTextureCache] addImage:spriteImage];
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
	
	//NSLog(@"Set Z order for sprite '%@'", spriteKey);
	
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
	//NSLog(@"Delete sprite '%@'", spritKey);
	
	CCSprite* spriteToRemove = [_sprites objectForKey:spritKey];
	if ( spriteToRemove == nil ) return;
	[_sprites removeObjectForKey:spriteToRemove];
	[_scene removeChild:spriteToRemove cleanup:YES];
}

- (void)deleteMultipleSprites:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	NSUInteger count = [arguments count];
	if ( count < 1 ) return;
	NSString *jsCommandData = [arguments objectAtIndex:0];
	
	NSArray *spriteData = [jsCommandData componentsSeparatedByString:COMMAND_SEPARATOR];
	if ( spriteData == nil ) return;
	
	for (NSString *data in spriteData) 
	{
		NSMutableArray *pgCommand = [[NSMutableArray alloc] initWithObjects:
									 data, nil];
		
		[self deleteSprite:pgCommand withDict:nil];
		[pgCommand release];
		
	}
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

		//NSLog(@"move sprite %@ %i %i", spritKey, x, y);
		
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
 
 setGameDisplayTransparent
 
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
	
	//UITouch *touch = [touches anyObject]; // grab a single touch.
	NSSet *allTouches = [event allTouches];  // <--this gets all the current touches
	
	if( allTouches ) // touch 
	{
		for (UITouch *touch in allTouches) 
		{ 
			if ( touch.phase != UITouchPhaseBegan ) {
				continue;
			}
			
			// IMPORTANT:
			// The touches are always in "portrait" coordinates. You need to convert them to your current orientation
			CGPoint location = [touch locationInView: [touch view]];
			
			// -------------------------------
			//NSValue *originalPoint = [NSValue valueWithCGPoint:CGPointMake(location.x, location.y)];			
			MyPoint *originalPoint = [[MyPoint alloc] init];
			originalPoint.x = location.x;
			originalPoint.y = location.y;
			NSString *touchPtrStr = [NSString stringWithFormat:@"0x%08x", touch];
			
			[_touchPointsToRects setValue:originalPoint forKey:touchPtrStr];
			//[_touchPointsToRects setObject:originalPoint forKey:touch];
			// -------------------------------
			
			// Store the points to get them for mouse up.
			CGPoint convertedPoint = [[CCDirector sharedDirector] convertToGL:location];

			//NSLog(@"touch began:%@ %2f",touchPtrStr, location.x);
			
			NSString *jsString = [NSString stringWithFormat:@"var elem = document.elementFromPoint (%i,%i);"
								  "var evt = document.createEvent(\"MouseEvents\");"
								  "evt.initMouseEvent(\"mousedown\", true, true, window,"
								  "0, %i, %i, %i, %i, false, false, false, false, 0, null);"
								  "elem.dispatchEvent(evt);"		, 
								  (int)convertedPoint.x, (int)(_height - convertedPoint.y),
								  (int)convertedPoint.x, (int)(_height - convertedPoint.y),
								  (int)convertedPoint.x, (int)(_height - convertedPoint.y)]; 
			
			//NSLog(@"%@",jsString);
			[super writeJavascript:jsString];
			
		}		
		
	}
	
}




- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//UITouch *touch = [touches anyObject]; // grab a single touch.
	NSSet *allTouches = [event allTouches];  // <--this gets all the current touches
	
	if( allTouches ) // touch 
	{
		for (UITouch *touch in allTouches) 
		{
			if ( touch.phase != UITouchPhaseEnded ) {
				continue;
			}
			CGPoint location = [touch locationInView: [touch view]];
			
			// -------------------------------
			NSString *touchPtrStr = [NSString stringWithFormat:@"0x%08x", touch];
			
			MyPoint *thePoint = [_touchPointsToRects objectForKey:touchPtrStr];
			if ( thePoint != nil ) {
				location.x = thePoint.x;
				location.y = thePoint.y;
				[_touchPointsToRects removeObjectForKey:touchPtrStr];
				[thePoint release];
			}
			
			//NSValue *val = [_touchPointsToRects objectForKey:touch];
			//CGPoint location = [val CGPointValue];
			// -------------------------------
			
			// IMPORTANT:
			// The touches are always in "portrait" coordinates. You need to convert them to your current orientation
			CGPoint convertedPoint = [[CCDirector sharedDirector] convertToGL:location];

			int convertedX = convertedPoint.x;
			int convertedY = _height - convertedPoint.y;

			//NSLog(@"touch end: %@ %2f",touchPtrStr, location.x);
			
			/*
			if ( convertedX < 0 ) convertedX = 4;
			if ( convertedY < 0 ) convertedY = 4;
			if ( convertedX > _width ) convertedX = _width - 4;
			if ( convertedY > _height ) convertedY = _height - 4;
			 */
			
			NSString *jsString = [NSString stringWithFormat:@"var elem = document.elementFromPoint (%i,%i);"
								"var evt = document.createEvent(\"MouseEvents\");"
								"evt.initMouseEvent(\"mouseup\", true, true, window,"
												"0, %i, %i, %i, %i, false, false, false, false, 0, null);"
							    "elem.dispatchEvent(evt);"		, 
								 convertedX , convertedY,
								convertedX , convertedY,
								convertedX , convertedY,
								convertedX , convertedY]; 
		
			//NSLog(@"%@",jsString);
			[super writeJavascript:jsString];
		}
	}
	
}


- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	//UITouch *touch = [touches anyObject]; // grab a single touch.
	NSSet *allTouches = [event allTouches];  // <--this gets all the current touches
	
	if( allTouches ) // touch 
	{
		for (UITouch *touch in allTouches) 
		{ 
			CGPoint location = [touch locationInView: [touch view]];

			
			// -------------------------------
			NSString *touchPtrStr = [NSString stringWithFormat:@"0x%08x", touch];
			MyPoint *thePoint = [_touchPointsToRects objectForKey:touchPtrStr];
			if ( thePoint != nil ) {
				location.x = thePoint.x;
				location.y = thePoint.y;
				[_touchPointsToRects removeObjectForKey:touchPtrStr];
				[thePoint release];
			}
			// -------------------------------
			
			// IMPORTANT:
			// The touches are always in "portrait" coordinates. You need to convert them to your current orientation
			CGPoint convertedPoint = [[CCDirector sharedDirector] convertToGL:location];
			
			int convertedX = convertedPoint.x;
			int convertedY = _height - convertedPoint.y;
			
			if ( convertedX < 0 ) convertedX = 4;
			if ( convertedY < 0 ) convertedY = 4;
			if ( convertedX > _width ) convertedX = _width - 4;
			if ( convertedY > _height ) convertedY = _height - 4;
			
			
			NSString *jsString = [NSString stringWithFormat:@"var elem = document.elementFromPoint (%i,%i);"
								  "var evt = document.createEvent(\"MouseEvents\");"
								  "evt.initMouseEvent(\"mouseup\", true, true, window,"
								  "0, %i, %i, %i, %i, false, false, false, false, 0, null);"
								  "elem.dispatchEvent(evt);"		, 
								  convertedX, convertedY,
								  convertedX, convertedY,
								  convertedX, convertedY,
								  convertedX, convertedY]; 
			
			//NSLog(@"%@",jsString);
			[super writeJavascript:jsString];
		}
	}
	
}




- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	//UITouch *touch = [touches anyObject]; // grab a single touch.
	
	/*
	 
	// NOTE:  Touches moved can be re-enabled if desired.
	// My thought is that it may be expensive, constantly calling
	// into the web view.
	 
	NSSet *allTouches = [event allTouches];  // <--this gets all the current touches
	
	if( allTouches ) // touch 
	{
		for (UITouch *touch in allTouches) 
		{ 
			//CGPoint location = [touch locationInView: [touch view]];
			CGPoint location = [touch locationInView: [touch view]];
			
			// IMPORTANT:
			// The touches are always in "portrait" coordinates. You need to convert them to your current orientation
			CGPoint convertedPoint = [[CCDirector sharedDirector] convertToGL:location];
			
			
			NSString *jsString = [NSString stringWithFormat:@"var elem = document.elementFromPoint (%i,%i);"
								  "var evt = document.createEvent(\"MouseEvents\");"
								  "evt.initMouseEvent(\"mousemove\", true, true, window,"
								  "0, %i, %i, %i, %i, false, false, false, false, 0, null);"
								  "elem.dispatchEvent(evt);"		, 
								  (int)convertedPoint.x, (int)(_height - convertedPoint.y),
								  (int)convertedPoint.x, (int)(_height - convertedPoint.y),
								  (int)convertedPoint.x, (int)(_height - convertedPoint.y),
								  (int)convertedPoint.x, (int)(_height - convertedPoint.y)]; 
			
			//NSLog(@"%@",jsString);
			[super writeJavascript:jsString];
		}
	}
	*/
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
	
	[_touchPointsToRects release];
	
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
	if ( _tileMap != nil ) {
		[_tileMap release];
	}
	if ( _background != nil ) {
		[_background release];
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

