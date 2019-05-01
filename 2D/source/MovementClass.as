package {

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;


	/**
	this "class" does the movement of the an object and gives the 
	animation State Manager the movement changes.
	
	NOTE: an inner object should have an AnimationStateManager attached and call the setTarget methode
	NOTE: the class, attached to the MovieClip should give this class its Hitbox MovieClip
	
	*/
	public class MovementClass extends HierarchyManager {

		public var MAX_X_SPEED: Number = 4; //maximum speed
		public var MAX_Y_SPEED: Number = 2; //maximum speed

		//there is a max Y value
		public var MAX_Y: Number = 550;
		public var MIN_Y: Number = 350;

		public var STAGE_MIN: Number = 0;
		public var STAGE_WITH: Number = 1024;




		private var currentY: Number = 50;

		private var x_speed: Number = 0;
		private var y_speed: Number = 0;


		//TODO: Fill maybe better
		private var hitboxMC: MovieClip;

		//so this will be compared in the collide function
		//only if a given MovementClass.y is withhin this number it will collide
		public static var HIT_PRECISION_RANGE: Number = 20;

		//target for the animation orders to be dispatched
		protected var animationTarget: AnimationStateManager;
		protected var walkingAnimationName: String = "walking";
		protected var idleAnimationName: String = "idle";


		//shows the curent states for left, right, up and down movement
		public var left_isPressed: Boolean = false;
		public var right_isPressed: Boolean = false;
		public var up_isPressed: Boolean = false;
		public var down_isPressed: Boolean = false;


		public function MovementClass() {

			//update will be called every frame
			this.addEventListener(Event.ENTER_FRAME, update);

			//we want to load the values from the stored file

			//stage.addEventListener("loadSettingsCompleted", loadValues);
			if (SettingsLoader.settingsLoaded) {


				//get the values directly, settings have been loaded
				loadValues();
				//trace("settings loaded directly");
			} else {
				//WARNING: hardcode
				if(parent)
					parent.addEventListener("loadSettingsCompleted", loadValues);
				//trace("Listener started");
			}

		}

		public function loadValues(_event: Event = null) {
			//Movement speed
			MAX_X_SPEED = SettingsLoader.getValue("MAX_X_SPEED", "MovementClass");
			MAX_Y_SPEED = SettingsLoader.getValue("MAX_Y_SPEED", "MovementClass");
		}


		public function setTarget(target: AnimationStateManager) {
			//wil be set from the InnerAnimation Class in its constructor
			animationTarget = target;

			//now we are guaranteed, that we have an AnimationStateManager

			animationTarget.changeCurrentAnimationState("idle");
		}

		//will be set from the outer class, a child of this class
		protected function setHitbox(_hitbox: Hitbox) {
			hitboxMC = _hitbox;
		}

		public function getHitbox(): MovieClip {
			return hitboxMC;
		}

		//safety late init
		public function doInit() {
			trace("didInit");
			stop();
		}


		//called every frame because of event listener
		function update(_event: Event) {

			//this is the Movement stuff
			doMovement();

		}



		function doMovement() {

			//x_speed Rules
			this.x += x_speed;

			if (x_speed != 0) {
				if (this.x < STAGE_MIN) {
					this.x = STAGE_MIN;
					dispatchEvent(new Event("reachedLeftSide", true));
				}


				if (this.x > STAGE_WITH) {
					this.x = STAGE_WITH; //stage.stageWidth;
					dispatchEvent(new Event("reachedRightSide", true));
				}

			}



			//y_speed
			this.y += y_speed;

			if (y_speed != 0) {
				if (this.y < MIN_Y)
					this.y = MIN_Y;

				if (this.y > MAX_Y)
					this.y = MAX_Y;

			}
		}

		public function isWalking(): Boolean {
			if (left_isPressed || right_isPressed || up_isPressed || down_isPressed)
				return true;
			else
				return false;
		}

		public function walkInPressedDirection() {

			if (left_isPressed) {
				moveKey("left");
			} else if (right_isPressed) {
				moveKey("right");
			} else if (up_isPressed) {
				moveKey("up");
			} else if (down_isPressed) {
				moveKey("down");
			} else {
				stopKey("updateAnimation"); //Bit slushish solution far the idleCat animation, just update animation
			}

		}



		//manages movement of this
		function moveKey(_direction: String) {

			//trace("habe move befehl für: " + _direction);

			switch (_direction) {
				case "up":
					up_isPressed = true;
					y_speed = -MAX_Y_SPEED;
					animationTarget.changeCurrentAnimationState(walkingAnimationName);
					break;
				case "down":
					down_isPressed = true;
					y_speed = +MAX_Y_SPEED;
					animationTarget.changeCurrentAnimationState(walkingAnimationName);
					break;
				case "left":
					left_isPressed = true;
					x_speed = -MAX_X_SPEED;
					animationTarget.changeCurrentAnimationState(walkingAnimationName);
					break;
				case "right":
					right_isPressed = true;
					x_speed = +MAX_X_SPEED;
					animationTarget.changeCurrentAnimationState(walkingAnimationName);
					break;
			}
		}

		function stopKey(_direction: String) {

			//trace("habe stop befehl für: " + _direction);

			switch (_direction) {
				case "up":
					up_isPressed = false;
					//handle up key, bc. other Key could be still pressed
					animationTarget.changeCurrentAnimationState(idleAnimationName);
					y_speed = 0;
					if (isWalking())
						walkInPressedDirection(); //walk in the still pressed direction

					break;
				case "down":
					down_isPressed = false;
					//handle up key, bc. other Key could be still pressed
					animationTarget.changeCurrentAnimationState(idleAnimationName);
					y_speed = 0;
					if (isWalking())
						walkInPressedDirection(); //walk in the still pressed direction

					break;
				case "left":
					left_isPressed = false;
					//handle up key, bc. other Key could be still pressed
					animationTarget.changeCurrentAnimationState(idleAnimationName);
					x_speed = 0;
					if (isWalking())
						walkInPressedDirection(); //walk in the still pressed direction

					break;
				case "right":
					right_isPressed = false;
					//handle up key, bc. other Key could be still pressed
					animationTarget.changeCurrentAnimationState(idleAnimationName);
					x_speed = 0;
					if (isWalking())
						walkInPressedDirection(); //walk in the still pressed direction

					break;
				case "updateAnimation":
					animationTarget.changeCurrentAnimationState(idleAnimationName);
					break;
				default:
					x_speed = 0;
					y_speed = 0;
					animationTarget.changeCurrentAnimationState(idleAnimationName);
					break;
			}



		}

		public function isColliding(otherMC: MovementClass): Boolean {

			//only if both are withhin HIT_PRECISION_RANGE
			if (otherMC.y - HIT_PRECISION_RANGE < this.y && otherMC.y + HIT_PRECISION_RANGE > this.y) {

				//and they are colliding

				if (this.getHitbox().hitTestObject(otherMC.getHitbox()))
					return true;
			}

			//otherwise false
			return false;
		}

		/**
			call this on the lifes end of an Movementobject
		*/
		protected function onDestroy() {
			stopKey("stop");
			removeEventListener(Event.ENTER_FRAME, update);
				
			if(parent && parent.hasEventListener("loadSettingsCompleted")){
				parent.removeEventListener("loadSettingsCompleted",loadValues);
			}
			
			animationTarget = null;//loosen connection for garbage collector
		}


		/**
		//get a random number with bellcurveishish precition
		*/
		public static function nominalRandom(maxRange: Number): Number {


			var a = Math.random() * (maxRange + 1);
			a = a * a;
			var b = Math.random() * (maxRange + 1);
			b = b * b;
			var c = Math.random() * (maxRange + 1);
			c = c * c;
			var d = Math.random() * (maxRange + 1);
			d = d * d;

			var r = Math.round((a + b + c + d) / 4);

			r = Math.sqrt(r);

			return r;
		}



	}

}