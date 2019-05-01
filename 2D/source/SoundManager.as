package {
	import flash.media.SoundTransform;

	public class SoundManager {


		
		public static var overallVolume: Number;
		

		public static function getSoundTransform(volume:Number): SoundTransform {
			
			var myTransform = new SoundTransform();
			
			myTransform.volume = volume;
			
			return myTransform;
		}



	}

}