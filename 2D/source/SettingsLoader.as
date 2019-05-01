package {
	import flash.net.URLVariables;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLLoader;
	import flash.events.*;
	import flash.utils.*;
	import flash.display.Sprite;
	import flash.concurrent.*;
	import flash.system.Worker;
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;

	public class SettingsLoader {
		
		//is static
		public static var xmlFile: XML;
		public static var settingsLoaded : Boolean = false;
		
		
		private var eventTopTarget : MovieClip;
		
		//the event, that the xml is loaded will be dispached to the eventTopTarget
		public function SettingsLoader(_eventTopTarget:MovieClip){
			
			eventTopTarget = _eventTopTarget;
			
			
			loadSettings();
		}
		
		
		// Load settings
		public function loadSettings() {
			var oLoader = new URLLoader();
			var oUrl: URLRequest = new URLRequest("Settings.xml");
			oLoader.addEventListener(Event.COMPLETE, loadSettingsComplete);
			oLoader.load(oUrl);
			
			//eventTopTarget.addEventListener("loadSettingsCompleted",bla);
			
		}

		//when completed
		public function loadSettingsComplete(_oEvent: Event) {			
			//use Data
			xmlFile = new XML(_oEvent.currentTarget.data);
			
			//and send event out, so others can ask for data
			eventTopTarget.dispatchEvent(new Event("loadSettingsCompleted",true));
			
			//set indicator for settings loaded true
			settingsLoaded = true;
			
		}		
	
		
		//any constructor who listenes to the loadSettingsCompleted event can get
		//a value for the regarding class
		//the class should name itself and the property it wants, to get an return
		public static function getValue(_name: String, _class: String) : Number {
			
			
			//xmlFile.child(_class).child(_name).@Value;
			//every class should be unique and evere property of a class, too
			return xmlFile.child(_class).child(_name).@Value;
		}

	}

}