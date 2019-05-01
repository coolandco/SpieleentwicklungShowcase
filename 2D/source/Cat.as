package {

	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;


	public class Cat extends MovementClass {
		
		public var MAX_X_SPEED_CAT: Number = 10;

		public var startPoint: MovieClip;
		public var isFlying: Boolean = false;


		//There are two kinds of cats, one that sits ant waits till the character collects it
		//the other one flying till it reaches the right side or hits an Attacker
		public function Cat(_startPoint: MovieClip = null) {
			//give our hitbox to the movementclass
			//WARNING: hardcode
			super.setHitbox(hitbox);
			//so the cat "glides" into and out of the stage
			super.STAGE_MIN = -50;
			super.STAGE_WITH = 1100;


			if (_startPoint == null) {
				//this will be a ground cat
				//mainGameClass.cats.push(this);//already done in mainClass

				//Spawn somewhere on the left Side of the stage, so the character can collect it.
				this.y = MIN_Y + (Math.random() * (MAX_Y - MIN_Y));
				this.x = nominalRandom(500); //left side
			} else {
				startPoint = _startPoint;

				//attatch cat to the _startPoint, character is about to throw it
				addEventListener(Event.ENTER_FRAME, update2);
				addEventListener("reachedRightSide", reachedRightSide);
				super.MAX_X_SPEED = MAX_X_SPEED_CAT;
			}
		}
		
		override public function loadValues(_event: Event = null) {
			super.loadValues();
			MAX_X_SPEED_CAT = SettingsLoader.getValue("MAX_X_SPEED_CAT", "Cat");
			
			//refresh values
			super.MAX_X_SPEED = MAX_X_SPEED_CAT;
		}

		public function update2(_event: Event) {
			//keep the cat attached to the defender
			//move the inner cat to the top right of the start point with absolute values
			//"outer" cat has still same y value
			this.y = startPoint.y -4 ;// so we r behind the character
			
			InnerCat_mc.y = -90;
			hitbox.y = InnerCat_mc.y;
			
			
			this.x =startPoint.x;
			
			InnerCat_mc.x = +20;
			hitbox.x = InnerCat_mc.x;

		}

		public function destroy() {
			HierarchyManager.removeDisplayable(this);
			super.onDestroy();
		}

		//cat will only reach right side, when flying
		public function reachedRightSide(_event: Event) {
			isFlying = false;
			//remove all references, so the garbage collector destroys this cat
			if (mainGameClass.flyingCats.indexOf(this) >= 0)
				mainGameClass.flyingCats.splice(mainGameClass.flyingCats.indexOf(this), 1);

			destroy();
			removeEventListener(Event.ENTER_FRAME, update_rotate);
			removeEventListener("reachedRightSide", reachedRightSide);
		}

		public function startFlying() {
			//we shot the cat, so its not attached anymore
			//remove attatchement
			removeEventListener(Event.ENTER_FRAME, update2);
			if (mainGameClass.defender.attachedCat == this) {
				mainGameClass.defender.unAttachCat();
			}

			//tell the main class
			isFlying = true;
			mainGameClass.flyingCats.push(this);
			
			//Play sound
			new cat1().play(100).soundTransform = SoundManager.getSoundTransform(0.1);
			
			//start moving the cat
			super.moveKey("right");

			//we want it also to rotate
			addEventListener(Event.ENTER_FRAME, update_rotate);
		}
		

		public function update_rotate(_event: Event) {
			//360° 1 second
			//WARNING: hardcode
			InnerCat_mc.rotation += 15;
		}
	}

}