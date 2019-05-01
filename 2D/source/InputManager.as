package {

	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.display.MovieClip;
	import flash.display.DisplayObjectContainer;
	import flash.display.DisplayObject;
	import flash.display.Stage;

	public class InputManager {


		//TODO: some Target for those events + fill that target
		private var CURRENT_TARGET: MovieClip;

		//this is the states of the buttons pressed
		private var keyUp_isPressed: Boolean = false;
		private var keyDown_isPressed: Boolean = false;
		private var keyLeft_isPressed: Boolean = false;
		private var keyRight_isPressed: Boolean = false;
		private var keyShoot_isPressed: Boolean = false;

		private var keyUp_isPressed_oldState: Boolean = false;
		private var keyDown_isPressed_oldState: Boolean = false;
		private var keyLeft_isPressed_oldState: Boolean = false;
		private var keyRight_isPressed_oldState: Boolean = false;
		private var keyShoot_isPressed_oldState: Boolean = false;


		public function InputManager(inputTarget : MovieClip, s : Stage) {
			
			//set the keyboard target
			CURRENT_TARGET = inputTarget;
			
			//listener for keys
			s.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			s.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

		}
		
		public function doReset(inputTarget : MovieClip, s : Stage) {
			//remove old listener
			s.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			s.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
			
			//TODO: double code
			//set the keyboard target
			CURRENT_TARGET = inputTarget;
			
			//listener for keys
			s.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			s.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

		}


		//only sends a moveKey if state of a key is changed
		//TODO: Find a more generic way. But consider, its just 5 keys for control, so this should be fine
		private function checkState() {
			if (keyUp_isPressed != keyUp_isPressed_oldState) {
				if (keyUp_isPressed) moveKey("up");
				else stopKey("up");

				keyUp_isPressed_oldState = keyUp_isPressed; //take over new state
			}
			if (keyDown_isPressed != keyDown_isPressed_oldState) {
				if (keyDown_isPressed) moveKey("down");
				else stopKey("down");

				keyDown_isPressed_oldState = keyDown_isPressed;
			}
			if (keyLeft_isPressed != keyLeft_isPressed_oldState) {
				if (keyLeft_isPressed) moveKey("left");
				else stopKey("left");

				keyLeft_isPressed_oldState = keyLeft_isPressed;
			}
			if (keyRight_isPressed != keyRight_isPressed_oldState) {
				if (keyRight_isPressed) moveKey("right");
				else stopKey("right");

				keyRight_isPressed_oldState = keyRight_isPressed;
			}
			if (keyShoot_isPressed != keyShoot_isPressed_oldState) {
				if (keyShoot_isPressed) moveKey("shoot");
				else stopKey("shoot");

				keyShoot_isPressed_oldState = keyShoot_isPressed;
			}

		}


		private function onKeyPress(_event: KeyboardEvent) {

			switch (_event.keyCode) {
				case Keyboard.UP:
				case Keyboard.W:
					keyUp_isPressed = true;
					break;
				case Keyboard.DOWN:
				case Keyboard.S:
					keyDown_isPressed = true;
					break;
				case Keyboard.LEFT:
				case Keyboard.A:
					keyLeft_isPressed = true;
					break;
				case Keyboard.RIGHT:
				case Keyboard.D:
					keyRight_isPressed = true;
					break;
				case Keyboard.SPACE:
					keyShoot_isPressed = true;
					break;
			}

			checkState(); //check state in the end
		}

		private function onKeyRelease(_event: KeyboardEvent) {

			switch (_event.keyCode) {
				case Keyboard.UP:
				case Keyboard.W:
					keyUp_isPressed = false;
					break;
				case Keyboard.DOWN:
				case Keyboard.S:
					keyDown_isPressed = false;
					break;
				case Keyboard.LEFT:
				case Keyboard.A:
					keyLeft_isPressed = false;
					break;
				case Keyboard.RIGHT:
				case Keyboard.D:
					keyRight_isPressed = false;
					break;
				case Keyboard.SPACE:
					keyShoot_isPressed = false;
					break;
			}

			checkState(); //check states

		}


		private function moveKey(key: String) {
			//TODO: am I always allowed to sent those orders?
			CURRENT_TARGET.moveKey(key);
		}

		private function stopKey(key: String) {
			CURRENT_TARGET.stopKey(key);
		}
		
		public function destroy(s:Stage){
			//tidy up for the garbage collector
			
			CURRENT_TARGET = null;
			
			s.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			s.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

	}

}