package {
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.events.*;
	import flash.display.Stage;
	import flash.sampler.NewObjectSample;

	public class HierarchyManager extends MovieClip{ 

		//displayables array, for sorting
		public static var displayables: Array = new Array();
		private static var toRemove: Array = new Array();



		public function HierarchyManager() {
			//adds this Movie Clip to the Sorting List
			displayables.push(this);
		}


		public static function update(_event: Event) {

			//sort all my objects in the array for the y position
			//reverse for correct order
			displayables.sortOn("y", Array.NUMERIC);
			displayables.reverse();

			//get the stage where the displayable objects are attached, as Movie clip
			//WARNING: hardcode
			var myStage: MovieClip = MovieClip(_event.target);


			for (var i: int = 0; i < displayables.length; ++i) {

				//removes child to clear stage
				if (myStage.contains(displayables[i]))
					myStage.removeChild(displayables[i]);

			}

			//after everything has been removed from the stage, its the right time to remove 
			//stuff from the displayables, so they dont get displayed anymore
			for each(var _toRemove in toRemove) {
				displayables.splice(displayables.indexOf(_toRemove), 1);

			}
			//reset array
			toRemove = new Array();
			//trace(toRemove);


			//get the insert position AFTER displayables have been removed
			//WARNING: hardcode
			var insertPosition: Number = myStage.getChildIndex(myStage.insertPosition);

			//add the displayables to stage again
			for (var j: int = 0; j < displayables.length; ++j) {
				//adds the child in right order to stage
				myStage.addChildAt(displayables[j], insertPosition);
			}

		}

		public static function removeDisplayable(_toRemove: HierarchyManager) {
			//we cannot guaranty that this function will not be called twice with the same object.
			//(bc. something collides in two frames, but has not been removed yet)
			//to prevent removing wanted stuff, check if returned value == -1
			if (toRemove.indexOf(_toRemove) == -1)
				toRemove.push(_toRemove);
		}



	}

}