package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	
	public class StdButtonMC extends MovieClip {
		
		
		public function StdButtonMC() {
			
			//prevents the text to be in the way of the mouse
			btnText.mouseEnabled = false;
			
			addEventListener(MouseEvent.MOUSE_OVER,mouseOver);
		}
		
		public function mouseOver(_event:Event) {
			
			//new sound plays with specific volume
			new Flag().play().soundTransform = SoundManager.getSoundTransform(0.5);
		}
	}
	
}
