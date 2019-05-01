package  {
	
	import flash.display.MovieClip;
	
	
	public class CatSmallIcon extends HierarchyManager {
		
		
		public function CatSmallIcon() {
			// constructor code
		}
		
		public function destroy(){
			
			HierarchyManager.removeDisplayable(this);
		}
	}
	
}
