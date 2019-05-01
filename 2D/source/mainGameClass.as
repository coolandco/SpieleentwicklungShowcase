package {

	import flash.display.MovieClip;
	import flash.events.*;
	import flash.utils.*;
	import flash.net.*
		import flash.display.*;
	import flash.net.URLRequest;
	import flash.display.Loader;
	import flash.system.System;
	import flash.media.SoundTransform;
	import flash.media.SoundChannel;



	public class mainGameClass extends MovieClip {

		//Input manager for the Keybord Input
		private var inputManager: InputManager;

		private var menu: gameMenuClass;
		private var playerName: String = "";


		//collider sources
		public static var attackers: Array = new Array();
		public static var cats: Array = new Array();
		public static var flyingCats: Array = new Array();

		public static var defender: Character;


		public var score: Number = 0;
		public static var LIVES: Number = 3; //dirty static
		public var startTime: Number = 0;
		public var lastTimeScoreUpdate: int = 0;

		public var DIFFICULTYSETTING1: Number = 2;
		public var DIFFICULTYSETTING2: Number = 1;


		public var SCORE_PTS_CAT: Number = 5;
		public var SCORE_PTS_PER_1_SEC: Number = 1;

		public static var STARTMESSAGE = "Die Mauer ist noch nicht gebaut. Deswegen müssen andere Methoden benutzt werden, um das Weiße Haus zu verteidigen.\n" +
			"Steuere den Verteidiger mit den Pfeiltasten, sammel Katzen ein und wirf sie mit der Leertaste, um das Weiße Haus vor" +
			" den Angreifern zu schützen.";
		public static var ENDMESSAGE_KILLEDBYMEXICAN = "Du wurdest von einem Angreifer geschlagen!\nDas Weiße Haus konnte nicht verteidigt werden.";
		public static var ENDMESSAGE_MEXICANCONQUERES = "Die Angreifer haben das Weiße Haus gestürmt.\nDu hast verloren!";

		public var menuMusic: SoundChannel;




		public var pussyPufferHUD_cats: Array = new Array();
		public var pussyPufferHUD_X_start: Number = 430;
		public var pussyPufferHUD_Y: Number = 554.4;


		public function mainGameClass() {
			//WARNING: hardcode
			//set startmessage
			DTF_MessageEnd.visible = true;
			DTF_MessageEnd.text = STARTMESSAGE;
			//we dont want to see that on the first run
			DTF_ScoreEnd.visible = false;
			STF_ScoreEnd.visible = false;
			STF_NameEnd.visible = false;
			DTF_NameEnd.visible = false;
			HUD_ScoreUmrandung.visible = false;
			highscoreDisplay.visible = false;
			highscoreStatic.visible = false;

			//initializes the Settings Loading system
			new SettingsLoader(this);


			//we want to update all the display objects in HierarchyManager, every Frame.
			this.addEventListener(Event.ENTER_FRAME, HierarchyManager.update);

			//Settings
			if (SettingsLoader.settingsLoaded) {


				//get the values directly, settings have been loaded
				loadValues();
				//trace("settings loaded directly");
			} else {
				addEventListener("loadSettingsCompleted", loadValues);
				//trace("Listener started");
			}

			//load the menu
			loadMenu();

		}

		public function loadValues(_event: Event = null) {
			//Movement speed
			LIVES = SettingsLoader.getValue("LIVES", "mainGameClass");
			DIFFICULTYSETTING1 = SettingsLoader.getValue("DIFFICULTYSETTING1", "mainGameClass");
			DIFFICULTYSETTING2 = SettingsLoader.getValue("DIFFICULTYSETTING2", "mainGameClass");
		}

		//load the gameMenuClass
		public function loadMenu() {
			var oLoader = new Loader();
			var oUrl: URLRequest = new URLRequest("gameMenu.swf");
			oLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, menuLoaded, false, 0, true); //weak reference for garbage collector
			oLoader.load(oUrl);
		}

		public function menuLoaded(_event: Event) {

			//WARNING: hardcode
			sichtschutz.visible = true;

			//add menu to the stage and set it to the correct position
			menu = gameMenuClass(this.addChild(_event.target.content));
			menu.x = 0;
			menu.y = 350;

			//sound
			menuMusic = new cockroach_loop().play(0,999);
			menuMusic.soundTransform = SoundManager.getSoundTransform(0.2);

			//WARNING: hardcode
			//add a listener to start the game
			menu.btnStart.addEventListener(MouseEvent.CLICK, clickedStartGame);
			menu.btnHighscore.addEventListener(MouseEvent.CLICK, doHighscore);
		}

		public function clickedStartGame(_event: Event) {
			//WARNING: hardcode
			sichtschutz.visible = false;

			DTF_MessageEnd.visible = false;
			DTF_ScoreEnd.visible = false;
			STF_ScoreEnd.visible = false;
			STF_NameEnd.visible = false;
			DTF_NameEnd.visible = false;
			HUD_ScoreUmrandung.visible = false;
			highscoreDisplay.visible = false;
			highscoreStatic.visible = false;

			//WARNING: hardcode
			//give the main class the player name
			playerName = menu.tfPlayerName.text;
			
			//sound end
			menuMusic.stop();

			// away whith the menu
			this.removeChild(menu);

			startGame();
		}

		public function startGame() {
			//we have  main game routine, so start it
			this.addEventListener(Event.ENTER_FRAME, update);

			this.addEventListener("characterShoots", characterShoots);

			//put an defender on stage
			defender = new Character();


			//give the reference of our controllable character and the stage to the input Manager,
			//so it can controll and gets the keyboard input of the Stage
			//WARNING: hardcode
			inputManager = new InputManager(defender, stage);


			//set the start time
			startTime = getTimer();

		}

		/*
		this is the main game logic
		*/
		public function update(_event: Event) {
			//spawn cats and attackers

			//confusing generating of cats and attackers
			//basicly "(1-e^-(x/3)) *5"
			//type in google and look up

			var willBeTwo: Number = (((getTimer() - startTime) * 0.001) * (DIFFICULTYSETTING1 / 60)); //this variable will be two after 1/2 minutes if difficultySetting1 = 2

			var timeFactor: Number = ((1 - Math.pow(Math.E, -(willBeTwo / 3))) * 5) + 1;
			//trace("Time factor " + timeFactor);

			var probDefender: Number = (Math.random() * (cats.length + defender.getCatsinMagazine())) / (timeFactor);
			//trace("Probability Cat: " + probDefender + "amount cats" + cats.length);

			//push new cat
			if (probDefender < 0.03 * DIFFICULTYSETTING2) {
				cats.push(new Cat());
			}

			var probAttacker: Number = (Math.random() * attackers.length) / (timeFactor * ((cats.length / 5) + 1))

			//trace("Probability Attacker: " + probAttacker + "amount attackers" + attackers.length);
			//new attacker
			if (probAttacker < 0.015 * DIFFICULTYSETTING2) {
				attackers.push(new Mexican());
			}

			//======================================================================================
			//manage pussyPuffer and Character Magazine showing in HUD

			//more cats in mag, than in the hud
			if (defender.getCatsinMagazine() > pussyPufferHUD_cats.length) {
				var catSmall: CatSmallIcon = new CatSmallIcon();
				pussyPufferHUD_cats.push(catSmall); //add one
				catSmall.y = pussyPufferHUD_Y; //set this once, it will stay the same

			} else if (defender.getCatsinMagazine() < pussyPufferHUD_cats.length) { //less cats in mag, than in hud
				CatSmallIcon(pussyPufferHUD_cats.pop()).destroy(); //remove one from array and destroy it
			}

			//now give them proper x Values
			for (var i: int = 0; i < pussyPufferHUD_cats.length; i++) {
				var currentCat: MovieClip = MovieClip(pussyPufferHUD_cats[i]);

				currentCat.x = pussyPufferHUD_X_start + (i * (currentCat.width + 5));
			}

			//======================================================================================
			//collide flyingCats --> Attacker
			for each(var mc in attackers) {
				var attacker: Attacker = Attacker(mc); //cast

				//collide every cat with this specific attacker
				var collidedFlyingCat_MC: MovieClip = collideArray(attacker, flyingCats);
				if (collidedFlyingCat_MC) {

					//cast MovieClip to Cat
					var collidedFlyingCat: Cat = Cat(collidedFlyingCat_MC);

					//remove from our arrays
					if (attackers.indexOf(attacker) >= 0)
						attackers.splice(attackers.indexOf(attacker), 1);
					if (flyingCats.indexOf(collidedFlyingCat) >= 0)
						flyingCats.splice(flyingCats.indexOf(collidedFlyingCat), 1);

					//destroy from stage
					collidedFlyingCat.destroy();
					attacker.destroy();


				}
			}

			//======================================================================================
			//collide defender --> Cats
			//let the cats on the ground collide with the defender
			var collidedCat_MC: MovieClip = collideArray(defender, cats);
			if (collidedCat_MC) {

				//cast MovieClip to Cat
				var collidedCat: Cat = Cat(collidedCat_MC);

				//shold remove this specific collided cat from the array
				if (cats.indexOf(collidedCat) >= 0)
					cats.splice(cats.indexOf(collidedCat), 1);

				//add one cat to the magazine
				//if magazine full, add to score, because it will be rewarded
				if (!defender.addCatToMagazine()) {
					//TODO: Different sound
					score += SCORE_PTS_CAT; //points per cat for score
					new Grab1().play().soundTransform = SoundManager.getSoundTransform(0.1);
				} else {
					//TODO: Different sound
					//new sound plays with specific volume
					new Grab1().play().soundTransform = SoundManager.getSoundTransform(0.1);
				}

				//remove cat from stage
				collidedCat.destroy();
			}

			//======================================================================================
			//collide Atacker --> Defender
			var collidedAttacker_MC: MovieClip = collideArray(defender, attackers);
			if (collidedAttacker_MC) {

				//cast MovieClip to Attacker
				//var collidedAttacker: Attacker = Attacker(collidedAttacker_MC);
				trace("gameOver");
				gameOver(ENDMESSAGE_KILLEDBYMEXICAN);

			}
			//======================================================================================
			//refresh score and lives

			if ((getTimer() - lastTimeScoreUpdate) / 1000 >= 1) { //-->difference since last timerUpdate modulo 10 seconds
				lastTimeScoreUpdate = getTimer(); //refresh lastTimeScoreUpdate
				score += SCORE_PTS_PER_1_SEC; // add to score
			}

			//WARNING: hardcode
			DTF_Lives.text = LIVES.toString();

			DTF_Score.text = score.toString();

			//======================================================================================
			//Check for game end

			if (LIVES <= 0) {
				trace("gameOver");
				gameOver(ENDMESSAGE_MEXICANCONQUERES);
			}
		}

		//TODO: because of the Event System, the event for shooting goest trough here and not trough the defender
		//find a better way to start the shoot
		public function characterShoots(_event: Event) {

			if (defender.attachedCat) {
				defender.attachedCat.startFlying();
				//tell the defender he has to change the animation
				//defender.moveKey("updateCatWalkingFalse");
			}
		}


		public function gameOver(_message: String = "you lost") {

			//send score to the server
			doHighscore(true);

			//WARNING: hardcode
			//TODO: Display Score
			DTF_MessageEnd.text = _message;
			DTF_ScoreEnd.text = score.toString();
			DTF_NameEnd.text = playerName;

			//on the end game screen display this
			DTF_MessageEnd.visible = true;
			DTF_ScoreEnd.visible = true;
			STF_ScoreEnd.visible = true;
			STF_NameEnd.visible = true;
			DTF_NameEnd.visible = true;
			HUD_ScoreUmrandung.visible = true;


			//NOTE:
			//because AS3 does not have abstract methodes, I have to do the following castings manually
			for each(var attacker in attackers) {
				Attacker(attacker).destroy();
			}

			for each(var cat in cats) {
				Cat(cat).destroy();
			}

			for each(var flyingCat in flyingCats) {
				Cat(flyingCat).destroy();
			}

			//reset arrays
			attackers = new Array();
			cats = new Array();
			flyingCats = new Array();

			//destroy defender
			defender.destroy();
			defender = null;

			//tidy the event listeners up
			this.removeEventListener(Event.ENTER_FRAME, update);
			this.removeEventListener("characterShoots", characterShoots);

			inputManager.destroy(stage);

			//reset Lives and score
			LIVES = 3;
			score = 0;

			loadMenu();

		}

		function doHighscore(sendHigscore: Boolean = false) {

			var request: URLRequest = new URLRequest("./ServerCom/serverCom.php");
			request.method = URLRequestMethod.POST;

			if (sendHigscore) { //only send data if wanted
				//JSON COmmunication
				var variables: URLVariables = new URLVariables();
				variables["name"] = playerName;
				variables["score"] = score.toString();

				request.data = variables;
			}

			var loader: URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, httpRequestComplete);
			loader.load(request);
			//json end

			//make visible
			highscoreDisplay.visible = true;
			highscoreStatic.visible = true;
		}

		function httpRequestComplete(_event: Event) {

			//WARNING: hardcode
			highscoreDisplay.text = ""; //reset

			var result = JSON.parse(_event.target.data); // parse the JSON data
			var scoreArr: Array = new Array();

			//because bloody as3 doesnt give me the nicely sorted list, we have to do this umstand...
			for (var i in result) {

				scoreArr.push(new scoreItem(i as String, result[i]));
			}


			scoreArr.sortOn("p_score", Array.NUMERIC); //sort
			scoreArr.reverse();

			for each(var si: scoreItem in scoreArr) {
				//display
				highscoreDisplay.appendText(si.p_name + " = " + si.p_score + "\n");
			}

		}

		/**
		@param multiMC Has to be an Array With MovementClass
		
		collides every MovementClass in the Array with the given MovementClass
		the Movement class will figure out if the other MovementClass is within reach (y Position)
		
		returns null if nothing collides
		*/
		public static function collideArray(singleMC: MovementClass, multiMC: Array): MovieClip {
			for each(var mc in multiMC) {

				if (collide(MovementClass(mc), singleMC)) {
					return MovieClip(mc);
				}
			}

			return null;
		}


		public static function collide(singleMC: MovementClass, singleMC_2: MovementClass): Boolean {

			if (singleMC.isColliding(singleMC_2)) {
				return true;
			} else
				return false;

		}

		/**
		TODO: to be tested
		removes one specific element from an array.
		
		@returns true if successfull, otherwise false
		
		*/
		public static function removeElementFromArray(element: Object, array: Array): Boolean {

			if (array.indexOf(element) >= 0) {
				array.splice(array.indexOf(element), 1);
				return true;
			} else
				return false;

		}

	}

}