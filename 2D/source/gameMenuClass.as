package  {
	
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.*;
	
	//dynamic class
	public dynamic class gameMenuClass extends MovieClip {
		
		
		//state everything with "this" or otherwise it doesnt work when loaded
		public function gameMenuClass() {
			this.btnStart.btnText.text = "START";
			this.btnHighscore.btnText.text = "HIGHSCORE";
		}
	}
	
}
