package {

	import flash.display.MovieClip;

	/**

	each movie Clip, that uses this class has to have some requirements for this to work.
	Requirements:
	-to have an Animation called "idle"
	-the last frame of an Animation has to call "routine()"
	-to switch to an new animation use changeCurrentAnimationState
	-if you want to make shure one specific animation runs trought completely then set it with "setAnimationThatMustFinish"
	
	*/

	public class AnimationStateManager extends MovieClip {

		public var DEFAULT_ANIMATION: String = "idle";


		//ATTRIBUTES
		private var currentAnim: String = DEFAULT_ANIMATION; //set default

		private var animationThatMustFinish = ""; //empty string
		private var isPlayingATMF = false;

		//will be called onApplicationStart
		public function AnimationStateManager() {
			//gives the parent MovieClip - movement class this animationstate manager
			//animation state changes will be given to this class from it
			MovementClass(parent).setTarget(this);
		}

		protected function doInit(){

		}
		

		//ROUTINE
		//takes care of the current animationstates, so they keep playing
		protected function routine() {
			
			//ATMF finished after gone through a ATMF, set isPlayingATMF false
			if (isPlayingATMF == true)
				isPlayingATMF = false;


			//as long as we dont change the current animation, keep the
			//current animation playing
			jumpToAnimation(currentAnim);
		}


		//FUNCTIONS PRIVATE
		private function jumpToAnimation(animationToPlay: String) {
			//TODO: if there is no animation to with the name "animationToPlay" then play "DEFAULT_ANIMATION"
			if (animationToPlay != null)
				gotoAndPlay(animationToPlay);
		}


		//FUNCTIONS PUBLIC
		//this has to take care of the state changes of animations
		public function changeCurrentAnimationState(newAnimation: String) {


			//if if animation changes not, return;
			if (newAnimation == currentAnim)
				return;

			//if it wants to jump but is not jumping
			else if (newAnimation == animationThatMustFinish && !isPlayingATMF ) {
				//do not change "currentAnimation" cause we want to play
				//ATMF just once
				isPlayingATMF = true;
				jumpToAnimation(animationThatMustFinish); //go to ATMF
			} else if (currentAnim != newAnimation) { //if there is any other change
				
				//double changing ATMF would put "ATMF in "currentAnimation""
				//so check for that too
				if (newAnimation != animationThatMustFinish) 
					currentAnim = newAnimation;
				
				//but char shall finnish with jump befor switching to new animation
				//so only switch suddenly if char is not jumping
				if (!isPlayingATMF) 
					jumpToAnimation(newAnimation);
			}

		}


		public function setAnimationThatMustFinish(toSet_animationThatMustFinish: String) {
			animationThatMustFinish = toSet_animationThatMustFinish;
		}


		public function getCurrAnim(): String {
			return currentAnim;
		}


	}

}