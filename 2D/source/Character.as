package {

	import flash.display.MovieClip;
	import flash.events.Event;


	public class Character extends MovementClass {

		public var MAX_X_SPEED_CHAR: Number = 5;
		public var MAX_Y_SPEED_CHAR: Number = 3;

		//Maximum cats in the magazine
		public var MAX_CATS_IN_MAGAZINE: Number = 7;
		public var START_X: Number = 200;
		public var START_Y: Number = 450;


		//character starts with 1 cats in the magazine
		private var pussyPuffer: int = 1;

		//this is the Cat that the Character will throw
		public var attachedCat: Cat;

		public function Character() {
			this.scaleX = 0.815; //special scale
			this.scaleY = 0.815;

			super.MAX_X_SPEED = MAX_X_SPEED_CHAR;
			super.MAX_Y_SPEED = MAX_Y_SPEED_CHAR;

			this.x = START_X;
			this.y = START_Y;

			//give our hitbox to the movementclass
			//WARNING: hardcode
			super.setHitbox(hitbox);

			//we have  main game routine
			this.addEventListener(Event.ENTER_FRAME, update2);
		}

		override public function loadValues(_event: Event = null) {
			super.loadValues();
			//Movement speed
			MAX_X_SPEED_CHAR = SettingsLoader.getValue("MAX_X_SPEED_CHAR", "Character");
			MAX_Y_SPEED_CHAR = SettingsLoader.getValue("MAX_Y_SPEED_CHAR", "Character");
			pussyPuffer = SettingsLoader.getValue("pussyPuffer", "Character");

			//refresh super values
			super.MAX_X_SPEED = MAX_X_SPEED_CHAR;
			super.MAX_Y_SPEED = MAX_Y_SPEED_CHAR;
		}


		public function update2(_event: Event) {
			if (attachedCat == null && hasCatsInMagazine()) {

				//change animation names
				if (super.walkingAnimationName != "walkingCat") { //only if neccesary
					super.walkingAnimationName = "walkingCat";
					super.idleAnimationName = "idleCat";
					super.walkInPressedDirection(); //update aniamtion
				}

				//spawns a cat attached to this character
				attachedCat = new Cat(this);

				//gives the mainGameClass this cat
				//mainGameClass.flyingCat = attachedCat;

				//because we have a cat attached, remove one from the pussy puffer
				removeCatFromMagazine();
			}
		}



		//adds a cat to the magazine
		public function addCatToMagazine(): Boolean {
			pussyPuffer += 1;

			//if to many cats in magazine, reduce it
			if (pussyPuffer > MAX_CATS_IN_MAGAZINE) {
				pussyPuffer = MAX_CATS_IN_MAGAZINE;
				return false;
			} else
				return true;
		}

		public function hasCatsInMagazine(): Boolean {
			if (pussyPuffer > 0)
				return true;
			else
				return false;
		}

		public function removeCatFromMagazine() {
			pussyPuffer -= 1;

			//so we dont get less than 0 cats in the magazine
			if (pussyPuffer < 0)
				pussyPuffer = 0;
		}

		public function getCatsinMagazine(): Number {
			return pussyPuffer;
		}

		public function unAttachCat() {
			attachedCat = null;

			//change animations to the animations without cat
			super.walkingAnimationName = "walking";
			super.idleAnimationName = "idle";
			//update animation
			walkInPressedDirection();
		}

		public function destroy() {
			HierarchyManager.removeDisplayable(this);
			//remove the attached cat
			if (attachedCat)
				attachedCat.destroy();

			super.onDestroy();
		}


		//to override a super function, use this.
		//even if the function is called on an super Class this will be called first
		override function moveKey(_direction: String) {
			switch (_direction) {
				case "shoot":
					//send event
					dispatchEvent(new Event("characterShoots", true)); //goes to the maingameclass
					break;
				default:
					super.moveKey(_direction);
					break;
			}


		}

		override function stopKey(_direction: String) {
			switch (_direction) {
				case "shoot":
					//do nothing, especially not the default action
					break;
				default:
					super.stopKey(_direction);
					break;
			}

		}

	}
}