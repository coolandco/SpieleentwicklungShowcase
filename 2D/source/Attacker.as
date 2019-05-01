package {
	import flash.display.MovieClip;
	import flash.events.Event;

	public class Attacker extends MovementClass {


		//set the possibillity
		public function Attacker() {
			//so the attacker "glide" into and out of the stage
			super.STAGE_MIN = -50
			super.STAGE_WITH = 1100
			
			super.x = STAGE_WITH;

			super.y = Math.random() * ((super.MAX_Y - super.MIN_Y)) + super.MIN_Y;

			//let the attacker walk left
			super.moveKey("left");

			//we will be telled when we reach the left side
			addEventListener("reachedLeftSide", reachedLeftSide);

		}


		public function reachedLeftSide(_event: Event) {
			//remove all references, so the garbage collector destroys this attacker
			mainGameClass.attackers.splice(mainGameClass.attackers.indexOf(this), 1);
			destroy();
			removeEventListener("reachedLeftSide", reachedLeftSide);


			//Minus one live
			mainGameClass.LIVES--;

		}

		public function destroy() {
			HierarchyManager.removeDisplayable(this);
			super.onDestroy();
		}

	}

}