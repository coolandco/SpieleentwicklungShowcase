package  {
	
	public class scoreItem {
		
		
		public var p_name:String = "";
		public var p_score:Number= 0;

		public function scoreItem(_p_name : String = "", _p_score : String = "0") {
			p_name = _p_name;
			
			p_score = Number(_p_score); //parse score
		}

	}
	
}
