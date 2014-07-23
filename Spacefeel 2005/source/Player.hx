package ;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxObject;
import flixel.util.FlxPoint;
import flixel.util.FlxColorUtil;
/**
SOMETHING WRONG WITH SETFACINGFROMSIMPLEVEOCITY
LEFT, LEFTUP, UP
LEFT GOOD
LEFTUP GOOD
WHEN RELEASE LEFT IT FLIPS TO RIGHT, RELEASE UP POPS TO UP* @author ...
 */
class Player extends FlxSprite
{
	
	//private var sqr:FlxSprite;
	private var _runSpeed:Int;
	private var _previouslyMoving:Bool;
	private var _currentlyMoving:Bool;
	private var _previousFacing:Int;
	
	//private static var UP:Int = FlxObject.UP;
	//private static var DOWN:Int = FlxObject.DOWN;
	//private static var LEFT:Int = FlxObject.LEFT;
	//private static var RIGHT:Int = FlxObject.RIGHT;


	public function new(X:Int, Y:Int) 
	{
		super(X, Y);
		loadGraphic("assets/images/tinycharacter.png", true, 32, 32);
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);	
		setFacingFlip(FlxObject.UP, false, false);		
		setFacingFlip(FlxObject.DOWN, false, false);		

		
		animation.add("idleDown", [0]);
		animation.add("idleUp", [1]);
		animation.add("idleRight", [2]);

		animation.add("walkDown", [0, 3, 0, 6], 10, true);
		animation.add("walkRight", [2, 5, 2, 8], 10, true);
		animation.add("walkUp", [1, 4, 1, 7], 10, true);	
		
		//basic player physics
		_runSpeed = 50;
		maxVelocity.x = _runSpeed;
		maxVelocity.y = _runSpeed;
		
		_previouslyMoving = false;
		_previousFacing = FlxObject.DOWN;
		this.facing = FlxObject.DOWN;
	}
	
	override public function update():Void 
	{
		
		_previouslyMoving = !(velocity.x == 0 && velocity.y == 0);
		_previousFacing = this.facing;
		
		//movement
		velocity.x = velocity.y = 0;

		if (FlxG.keys.anyPressed(["up", "w"])) {
			velocity.y -= _runSpeed;
		} else if (FlxG.keys.anyPressed(["down", "s"])) {
			velocity.y += _runSpeed;
		} 
		
		if (FlxG.keys.anyPressed(["left", "a"])) {
		    velocity.x -= _runSpeed;
		} else if (FlxG.keys.anyPressed(["right", "d"])) {
			velocity.x += _runSpeed;
		} 
		
		_currentlyMoving = !(velocity.x == 0 && velocity.y == 0);
		
		
		
		//FACNG
		var reanimateFlag = false;
		if (!_previouslyMoving) {
			if (FlxG.keys.anyPressed(["up", "w"])) {
				this.facing = FlxObject.UP;
			} else if (FlxG.keys.anyPressed(["down", "s"])) {
				this.facing = FlxObject.DOWN;
			} else if (FlxG.keys.anyPressed(["left", "a"])) {
				this.facing = FlxObject.LEFT;
			} else if (FlxG.keys.anyPressed(["right", "d"])) {
				this.facing = FlxObject.RIGHT;
			}
			//trace("Not previously moving, new facing is " + facingToString());
		} else if (_currentlyMoving && !verifyFacingFromCurrentVelocity()) {
			trace("current facing is invalid based off of velocity");
			reanimateFlag = true;
			if (!setSimpleFacingFromVelocity()) {
				trace("flipping facing");
				flipFacingSingleAxis();
			}
		}
		
		//ANIMATION
		if (!_previouslyMoving || reanimateFlag) {
			if(_currentlyMoving){
				switch this.facing {
					case FlxObject.UP:    animation.play("walkUp");
					case FlxObject.DOWN:  animation.play("walkDown");
					case FlxObject.LEFT, 
					     FlxObject.RIGHT: animation.play("walkRight");
					default: idle();
				}
			} else {
				idle();
			}
		}
		super.update();
	}
	
	private function idle():Void {
		switch this.facing {
			case FlxObject.UP:
				animation.play("idleUp");
			case FlxObject.DOWN:
				animation.play("idleDown");
			case FlxObject.RIGHT, FlxObject.LEFT:
				animation.play("idleRight");
			default: return;
		}
	}
	/**
	 * If there is currently only motion in one direction, this method sets the facing of the player to the direction that matches the current 2d velocity. 
	 * @return true if there is only velocity in one axis and facing was set, false if there is velocity on both axes
	 */
	private function setSimpleFacingFromVelocity():Bool {
		trace("attempting to set facing based on 1d velocity");
		
		if (velocity.x == 0 && velocity.y > 0) {
			this.facing = FlxObject.DOWN;
			trace("Setting facing to DOWN"); 
		} else if (velocity.x == 0 && velocity.y < 0) {
			this.facing = FlxObject.UP;
			trace("Setting facing to UP"); 
		} else if (velocity.y == 0 && velocity.x > 0) {
			this.facing = FlxObject.RIGHT;
			trace("Setting facing to RIGHT"); 
		} else if (velocity.y == 0 && velocity.x < 0) {
			this.facing = FlxObject.LEFT;
			trace("Setting facing to LEFT"); 
		} else {
			trace("Velocity is in two dimensions");
			return false;
		}
		trace("Velocity was 1d, set facing");
		return true;
		
	}
	
	/**
	 * Makes sure that the current facing is valid for the current velocity, (ie If facing is up, makes sure that we are moving up [could also be diagonally up, doesn't matter])
	 * @return true if the facing is valid for the velocity and false if it is invalid
	 */
	private function verifyFacingFromCurrentVelocity():Bool {
		switch this.facing {
			case FlxObject.UP: return (this.velocity.y < 0);
			case FlxObject.DOWN: return (this.velocity.y > 0);
			case FlxObject.LEFT: return (this.velocity.x < 0);
			case FlxObject.RIGHT: return (this.velocity.x > 0);
			default: return false;
		}
	}
	
	private function flipFacingSingleAxis():Void {
		switch this.facing {
			case FlxObject.UP: this.facing = FlxObject.DOWN;
			case FlxObject.DOWN: this.facing = FlxObject.UP;
			case FlxObject.LEFT: this.facing = FlxObject.RIGHT;
			case FlxObject.RIGHT: this.facing = FlxObject.LEFT;
			default: return;
		}
	}
	
	private function facingToString():String {
		switch this.facing {
			case FlxObject.UP: return "UP";
			case FlxObject.DOWN: return "DOWN";
			case FlxObject.LEFT: return "LEFT";
			case FlxObject.RIGHT: return "RIGHT";
			default: return "ERROR";
		}
	}

}