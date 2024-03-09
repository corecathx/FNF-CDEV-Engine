package meta.states;

import game.cdev.CDevPopUp.PopUpButton;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.animation.FlxAnimationController;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import meta.substates.GameOverSubstate;
import meta.modding.char_editor.CharacterEditor;
import openfl.display.BitmapData;
import game.cdev.log.GameLog;
import game.cdev.script.CDevScript;
import game.cdev.script.ScriptData;
import game.cdev.script.ScriptSupport;
import game.song.Section.SwagSection;
import game.song.Song.SwagSong;
import game.Stage.SpriteStage;
import game.*;
import game.cdev.*;
import game.song.*;
import game.objects.*;
#if desktop
import game.cdev.engineutils.Discord.DiscordClient;
#end
#if sys
import sys.FileSystem;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public var vars:Map<String, Dynamic> = [];

	var bfCamX:Int = 0;
	var bfCamY:Int = 0;

	var dadCamX:Int = 0;
	var dadCamY:Int = 0;

	public var BFXPOS:Float = 770;
	public var BFYPOS:Float = 100;
	public var DADXPOS:Float = 100;
	public var DADYPOS:Float = 100;
	public var GFXPOS:Float = 400;
	public var GFYPOS:Float = 130;

	public static var fromMod:String = '';

	public var grpNotePresses:FlxTypedGroup<NotePress>;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var weekName:String = '';

	public static var songName:FlxText;

	public static var songPosBG:FlxSprite;
	public static var songPosBar:FlxBar;

	public var songPercent:Float = 0;

	var halloweenLevel:Bool = false;

	public var vocals:FlxSound;

	// private var vocals_opponent:FlxSound;
	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;

	public static var notes:FlxTypedGroup<Note>;

	var toDoEvents:Array<ChartEvent> = [];

	private var unspawnNotes:Array<Note> = [];
	private var strumLine:FlxSprite;

	public static var strumXpos:Float = 35;

	private var curSection:Int = 0;

	public static var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	public static var camZooming:Bool = false;

	public static var accuracy:Float = 0;
	public static var convertedAccuracy:Float = 0; // backward compability support

	public static var strumLineNotes:FlxTypedGroup<StrumArrow>;
	public static var playerStrums:FlxTypedGroup<StrumArrow>;
	public static var p2Strums:FlxTypedGroup<StrumArrow>;

	var stageGroup:FlxTypedGroup<SpriteStage>;
	var stageHandler:Stage;

	private var curSong:String = "";

	public var gfSpeed:Int = 1;

	public static var health:Float = 1;

	private var healthLerp:Float = 1;
	private var combo:Int = 0;

	var isDownscroll:Bool = false;

	public static var healthBarBG:FlxSprite;
	public static var healthBar:FunkinBar;

	// the mods
	public static var randomNote:Bool = false;
	public static var suddenDeath:Bool = false;
	public static var scrSpd:Float = 1;
	public static var healthGainMulti:Float = 1;
	public static var healthLoseMulti:Float = 1;
	public static var comboMultiplier:Float = 1;
	public static var songSpeed:Float = 1.0;
	public static var playingLeftSide:Bool = false;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	var pressedNotes:Int = 0;

	public static var iconP1:HealthIcon;
	public static var iconP2:HealthIcon;
	public static var camHUD:FlxCamera;

	public var camGame:FlxCamera;

	public static var botplayTxt:FlxText;

	var camPos:FlxPoint;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var halloweenBG:FlxSprite;
	var halloweenThunder:FlxSprite;
	var isHalloween:Bool = false;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var daRPCInfo:String = '';

	var ratingText:String = "";

	// week7
	var tankWatchtower:FlxSprite;
	var tankGround:FlxSprite;
	var tankBG:FlxTypedGroup<BackgroundTankmen>;
	var foregroundSprites:FlxTypedGroup<FlxSprite>;

	var songPosBGspr:FlxSprite;
	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var bgGirls:BackgroundGirls;

	var talking:Bool = true;

	public var songScore:Int = 0;

	public static var scoreTxt:FlxText;
	public static var scoreTxtDiv:String = "//";

	private var cheeringBF:Bool = false;

	public static var campaignScore:Int = 0;

	public static var defaultCamZoom:Float = 1.05;
	public static var defaultHudZoom:Float = 1;

	public var bgScore:FlxSprite;

	var bgNoteLane:FlxSprite;

	var judgementText:FlxText;

	public var ratingIdk:String;

	var difficultytxt:String = "";

	var alreadyTweened:Bool = false;

	public static var perfect:Int = 0;
	public static var sick:Int = 0;
	public static var good:Int = 0;
	public static var bad:Int = 0;
	public static var shit:Int = 0;
	public static var misses:Int = 0;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	public static var isPixel:Bool = false;

	var inCutscene:Bool = false;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var songLength:Float = 0;
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	public static var difficultyName:String = "";

	public static var scripts:ScriptData;
	public static var intro_cutscene_script:CDevScript;
	public static var outro_cutscene_script:CDevScript;

	var currentCutscene:String = ""; // intro, outro;

	public static var stageScript:ScriptData;
	public static var current:PlayState = new PlayState(); // sorry

	public function getCurrent():PlayState
	{
		return current;
	}

	var bfCamXPos:Float = 0;
	var bfCamYPos:Float = 0;
	var dadCamXPos:Float = 0;
	var dadCamYPos:Float = 0;

	public static var cameraPosition:FlxObject;

	public static var chartingMode:Bool = false;

	var sRating:FlxSprite;
	var numGroup:FlxTypedGroup<FlxSprite>;

	public static var config:PlayStateConfig = null;
	public static var ratingPosition:FlxPoint = null;
	public static var comboPosition:FlxPoint = null;

	public static var forceCameraPos:Bool = false;
	public static var camPosForced:Array<Float> = [];

	var isModStage:Bool = false;

	public static var enableNoteTween:Bool = true;
	public static var enableCountdown:Bool = true;
	public static var enableEditors:Bool = true;

	var singAnimationNames:Array<String> = ["singLEFT", "singDOWN", "singUP", "singRIGHT"];

	function calculateRatingsPosition()
	{
		ratingPosition = new FlxPoint((FlxG.width * 0.55) - 125, (FlxG.height / 2) - 50);
		comboPosition = new FlxPoint(ratingPosition.x - 50, ratingPosition.y + 100);

		if (CDevConfig.saveData.rChanged)
		{
			ratingPosition.x = CDevConfig.saveData.rX;
			ratingPosition.y = CDevConfig.saveData.rY;
		}
		if (CDevConfig.saveData.cChanged)
		{
			comboPosition.x = CDevConfig.saveData.cX;
			comboPosition.y = CDevConfig.saveData.cY;
		}
	}

	public function new()
	{
		super();
		PlayState.current = this;
		current = this;
	}

	/**
	 * Used to reset all static variables.
	 * Usually intended for scripting.
	 */
	public function resetAll() {
		scoreTxtDiv = "//";
		health = 1;
		camZooming = false;
		defaultCamZoom = 1.09;
		defaultHudZoom = 1;

		forceCameraPos = false;
		camPosForced = [];
		enableNoteTween = true;
		enableCountdown = true;

		intro_cutscene_script = null;
		outro_cutscene_script = null;

		camFollow = null;
		cameraPosition = null;

		sick = 0;
		good = 0;
		bad = 0;
		shit = 0;
		misses = 0;
		accuracy = 0;
		convertedAccuracy = 0;
	}

	override public function create()
	{
		config = new PlayStateConfig();
		calculateRatingsPosition();
		Paths.destroyLoadedImages();
		game.cdev.CDevMods.script_clearAll();

		Note.noteTypeFail = [];

		CDevConfig.setExitHandler(function()
		{
		});
		resetAll();
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		config.noteImpactsCamera = camHUD;
		config.ratingSpriteCamera = camHUD;

		// How to
		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		initModifiers();

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm, true);
		Conductor.updateSettings();

		ScriptSupport.currentMod = fromMod;
		ScriptSupport.parseSongConfig();
		scripts = new ScriptData(ScriptSupport.scripts, curSong, this);
		scripts.loadFiles();

		Paths.currentMod = fromMod;
		initCutsceneScripts();

		switch (SONG.song.toLowerCase())
		{
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.dialogTxt('senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.dialogTxt('roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.dialogTxt('thorns/thornsDialogue'));
		}


		strumXpos = CDevConfig.saveData.middlescroll ? -260 : 65;

		#if desktop
		storyDifficultyText = CDevConfig.utils.capitalize(difficultyName).trim();
		detailsText = SONG.song + " // " + storyDifficultyText + (isStoryMode ? " // Story Mode" : " // Freeplay");
		
		detailsPausedText = "Paused - " + detailsText;
		daRPCInfo = "Countdown...";

		DiscordClient.changePresence(detailsText, daRPCInfo);
		#end

		var builtinstages:Array<String> = [
			'stage',
			'spooky',
			'philly',
			'limo',
			'mall',
			'mallEvil',
			'school',
			'schoolEvil',
			'tank'
		];
		stageGroup = new FlxTypedGroup<SpriteStage>();

		isPixel = false;

		if (builtinstages.contains(SONG.stage))
		{
			switch (SONG.stage)
			{
				case 'stage':
					{
						Paths.setCurrentLevel("week1");
						defaultCamZoom = 0.9;
						curStage = 'stage';
						var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
						bg.antialiasing = CDevConfig.saveData.antialiasing;
						bg.scrollFactor.set(0.9, 0.9);
						bg.active = false;
						add(bg);

						var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
						stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
						stageFront.updateHitbox();
						stageFront.antialiasing = CDevConfig.saveData.antialiasing;
						stageFront.scrollFactor.set(0.9, 0.9);
						stageFront.active = false;
						add(stageFront);

						var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
						stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
						stageCurtains.updateHitbox();
						stageCurtains.antialiasing = CDevConfig.saveData.antialiasing;
						stageCurtains.scrollFactor.set(1.3, 1.3);
						stageCurtains.active = false;

						add(stageCurtains);
					}
				case 'spooky':
					{
						Paths.setCurrentLevel("week2");
						curStage = 'spooky';
						halloweenLevel = true;

						var hallowTex = Paths.getSparrowAtlas('halloween_bg', 'week2');

						halloweenBG = new FlxSprite(-200, -100);
						halloweenBG.frames = hallowTex;
						halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
						halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
						halloweenBG.animation.play('idle');
						halloweenBG.antialiasing = CDevConfig.saveData.antialiasing;
						add(halloweenBG);

						halloweenThunder = new FlxSprite(-500, -500).makeGraphic(4000, 4000, FlxColor.WHITE);
						halloweenThunder.alpha = 0;
						halloweenThunder.blend = ADD;

						isHalloween = true;
					}
				case 'philly':
					{
						Paths.setCurrentLevel("week3");
						curStage = 'philly';

						var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky', 'week3'));
						bg.scrollFactor.set(0.1, 0.1);
						add(bg);

						var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city', 'week3'));
						city.scrollFactor.set(0.3, 0.3);
						city.setGraphicSize(Std.int(city.width * 0.85));
						city.updateHitbox();
						add(city);

						phillyCityLights = new FlxTypedGroup<FlxSprite>();
						add(phillyCityLights);

						for (i in 0...5)
						{
							var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i, 'week3'));
							light.scrollFactor.set(0.3, 0.3);
							light.visible = false;
							light.setGraphicSize(Std.int(light.width * 0.85));
							light.updateHitbox();
							light.antialiasing = CDevConfig.saveData.antialiasing;
							phillyCityLights.add(light);
						}

						var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain', 'week3'));
						add(streetBehind);

						phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train', 'week3'));
						add(phillyTrain);

						trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes', 'week3'));
						FlxG.sound.list.add(trainSound);

						// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

						var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street', 'week3'));
						add(street);
					}
				case 'limo':
					{
						Paths.setCurrentLevel("week4");
						curStage = 'limo';
						defaultCamZoom = 0.90;

						var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset', 'week4'));
						skyBG.scrollFactor.set(0.1, 0.1);
						add(skyBG);

						var bgLimo:FlxSprite = new FlxSprite(-200, 480);
						bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo', 'week4');
						bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
						bgLimo.animation.play('drive');
						bgLimo.scrollFactor.set(0.4, 0.4);
						add(bgLimo);

						grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
						add(grpLimoDancers);

						for (i in 0...5)
						{
							var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
							dancer.scrollFactor.set(0.4, 0.4);
							grpLimoDancers.add(dancer);
						}

						var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay', 'week4'));
						overlayShit.alpha = 0.5;
						// add(overlayShit);

						// var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

						// FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

						// overlayShit.shader = shaderBullshit;

						var limoTex = Paths.getSparrowAtlas('limo/limoDrive', 'week4');

						limo = new FlxSprite(-120, 550);
						limo.frames = limoTex;
						limo.animation.addByPrefix('drive', "Limo stage", 24);
						limo.animation.play('drive');
						limo.antialiasing = CDevConfig.saveData.antialiasing;

						fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol', 'week4'));
						// add(limo);
					}
				case 'mall':
					{
						Paths.setCurrentLevel("week5");
						curStage = 'mall';

						defaultCamZoom = 0.80;

						var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls', 'week5'));
						bg.antialiasing = CDevConfig.saveData.antialiasing;
						bg.scrollFactor.set(0.2, 0.2);
						bg.active = false;
						bg.setGraphicSize(Std.int(bg.width * 0.8));
						bg.updateHitbox();
						add(bg);

						upperBoppers = new FlxSprite(-240, -90);
						upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop', 'week5');
						upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
						upperBoppers.antialiasing = CDevConfig.saveData.antialiasing;
						upperBoppers.scrollFactor.set(0.33, 0.33);
						upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
						upperBoppers.updateHitbox();
						add(upperBoppers);

						var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator', 'week5'));
						bgEscalator.antialiasing = CDevConfig.saveData.antialiasing;
						bgEscalator.scrollFactor.set(0.3, 0.3);
						bgEscalator.active = false;
						bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
						bgEscalator.updateHitbox();
						add(bgEscalator);

						var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree', 'week5'));
						tree.antialiasing = CDevConfig.saveData.antialiasing;
						tree.scrollFactor.set(0.40, 0.40);
						add(tree);

						bottomBoppers = new FlxSprite(-300, 140);
						bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop', 'week5');
						bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
						bottomBoppers.antialiasing = CDevConfig.saveData.antialiasing;
						bottomBoppers.scrollFactor.set(0.9, 0.9);
						bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
						bottomBoppers.updateHitbox();
						add(bottomBoppers);

						var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow', 'week5'));
						fgSnow.active = false;
						fgSnow.antialiasing = CDevConfig.saveData.antialiasing;
						add(fgSnow);

						santa = new FlxSprite(-840, 150);
						santa.frames = Paths.getSparrowAtlas('christmas/santa', 'week5');
						santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
						santa.antialiasing = CDevConfig.saveData.antialiasing;
						add(santa);
					}
				case 'mallEvil':
					{
						Paths.setCurrentLevel("week5");
						curStage = 'mallEvil';
						var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG', 'week5'));
						bg.antialiasing = CDevConfig.saveData.antialiasing;
						bg.scrollFactor.set(0.2, 0.2);
						bg.active = false;
						bg.setGraphicSize(Std.int(bg.width * 0.8));
						bg.updateHitbox();
						add(bg);

						var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree', 'week5'));
						evilTree.antialiasing = CDevConfig.saveData.antialiasing;
						evilTree.scrollFactor.set(0.2, 0.2);
						add(evilTree);

						var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow", 'week5'));
						evilSnow.antialiasing = CDevConfig.saveData.antialiasing;
						add(evilSnow);
					}
				case 'school':
					{
						Paths.setCurrentLevel("week6");
						config.uiTextFont = 'Pixel Arial 11 Bold';
						isPixel = true;
						curStage = 'school';

						// defaultCamZoom = 0.9;

						var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky', 'week6'));
						bgSky.scrollFactor.set(0.1, 0.1);
						add(bgSky);

						var repositionShit = -200;

						var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool', 'week6'));
						bgSchool.scrollFactor.set(0.6, 0.90);
						add(bgSchool);

						var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet', 'week6'));
						bgStreet.scrollFactor.set(0.95, 0.95);
						add(bgStreet);

						var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack', 'week6'));
						fgTrees.scrollFactor.set(0.9, 0.9);
						add(fgTrees);

						var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
						var treetex = Paths.getPackerAtlas('weeb/weebTrees', 'week6');
						bgTrees.frames = treetex;
						bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
						bgTrees.animation.play('treeLoop');
						bgTrees.scrollFactor.set(0.85, 0.85);
						add(bgTrees);

						var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
						treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals', 'week6');
						treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
						treeLeaves.animation.play('leaves');
						treeLeaves.scrollFactor.set(0.85, 0.85);
						add(treeLeaves);

						var widShit = Std.int(bgSky.width * 6);

						bgSky.setGraphicSize(widShit);
						bgSchool.setGraphicSize(widShit);
						bgStreet.setGraphicSize(widShit);
						bgTrees.setGraphicSize(Std.int(widShit * 1.4));
						fgTrees.setGraphicSize(Std.int(widShit * 0.8));
						treeLeaves.setGraphicSize(widShit);

						fgTrees.updateHitbox();
						bgSky.updateHitbox();
						bgSchool.updateHitbox();
						bgStreet.updateHitbox();
						bgTrees.updateHitbox();
						treeLeaves.updateHitbox();

						bgGirls = new BackgroundGirls(-100, 190);
						bgGirls.scrollFactor.set(0.9, 0.9);

						if (SONG.song.toLowerCase() == 'roses')
						{
							bgGirls.getScared();
						}

						bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
						bgGirls.updateHitbox();
						add(bgGirls);
					}
				case 'schoolEvil':
					{
						Paths.setCurrentLevel("week6");
						config.uiTextFont = 'Pixel Arial 11 Bold';
						isPixel = true;
						curStage = 'schoolEvil';

						var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
						var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

						var posX = 400;
						var posY = 200;

						var bg:FlxSprite = new FlxSprite(posX, posY);
						bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool', 'week6');
						bg.animation.addByPrefix('idle', 'background 2', 24);
						bg.animation.play('idle');
						bg.scrollFactor.set(0.8, 0.9);
						bg.scale.set(6, 6);
						add(bg);
					}
				case 'tank':
					{
						Paths.setCurrentLevel("week7");
						curStage = 'tank';
						defaultCamZoom = 0.9;
						var sky:FlxSprite = new FlxSprite(-400, -400).loadGraphic(Paths.image('tankSky', 'week7'));
						sky.scrollFactor.set();
						add(sky);

						var clouds:FlxSprite = new FlxSprite(FlxG.random.int(-700, -100),
							FlxG.random.int(-20, 20)).loadGraphic(Paths.image('tankClouds', 'week7'));
						clouds.scrollFactor.set(0.1, 0.1);
						clouds.active = true;
						clouds.velocity.x = FlxG.random.float(5, 15);
						add(clouds);

						var mountains:FlxSprite = new FlxSprite(-300, -20).loadGraphic(Paths.image('tankMountains', 'week7'));
						mountains.scrollFactor.set(0.2, 0.2);
						mountains.setGraphicSize(Std.int(1.2 * mountains.width));
						add(mountains);

						mountains.updateHitbox();

						var buildings:FlxSprite = new FlxSprite(-200, 0).loadGraphic(Paths.image('tankBuildings', 'week7'));
						buildings.scrollFactor.set(0.3, 0.3);
						buildings.setGraphicSize(Std.int(1.1 * buildings.width));
						buildings.updateHitbox();
						add(buildings);

						var ruins:FlxSprite = new FlxSprite(-200, 0).loadGraphic(Paths.image('tankRuins', 'week7'));
						ruins.scrollFactor.set(0.35, 0.35);
						ruins.setGraphicSize(Std.int(1.1 * ruins.width));
						ruins.updateHitbox();
						add(ruins);

						var smokeLeft:FlxSprite = new FlxSprite(-200, -100);
						smokeLeft.frames = Paths.getSparrowAtlas('smokeLeft', 'week7');
						smokeLeft.animation.addByPrefix('SmokeBlurLeft', 'SmokeBlurLeft', 24, true);
						smokeLeft.scrollFactor.set(0.4, 0.4);
						smokeLeft.animation.play('SmokeBlurLeft', true);
						add(smokeLeft);

						var smokeRight:FlxSprite = new FlxSprite(1100, -100);
						smokeRight.frames = Paths.getSparrowAtlas('smokeRight', 'week7');
						smokeRight.animation.addByPrefix('SmokeRight', 'SmokeRight', 24, true);
						smokeRight.scrollFactor.set(0.4, 0.4);
						smokeRight.animation.play('SmokeRight', true);
						add(smokeRight);

						tankWatchtower = new FlxSprite(100, 50);
						tankWatchtower.frames = Paths.getSparrowAtlas('tankWatchtower', 'week7');
						tankWatchtower.animation.addByPrefix('watchtower gradient color', 'watchtower gradient color', 24, false);
						tankWatchtower.scrollFactor.set(0.5, 0.5);
						add(tankWatchtower);

						tankGround = new FlxSprite(300, 300);
						tankGround.frames = Paths.getSparrowAtlas('tankRolling', 'week7');
						tankGround.animation.addByPrefix('BG tank w lightning', 'BG tank w lighting', 24, true);
						tankGround.scrollFactor.set(0.5, 0.5);
						tankGround.animation.play('BG tank w lightning', true);
						add(tankGround);

						tankBG = new FlxTypedGroup<BackgroundTankmen>();
						add(tankBG);

						var ground:FlxSprite = new FlxSprite(-420, -150).loadGraphic(Paths.image('tankGround', 'week7'));
						ground.setGraphicSize(Std.int(1.15 * ground.width));
						ground.updateHitbox();
						add(ground);
						moveTank();

						foregroundSprites = new FlxTypedGroup<FlxSprite>();
						var f:FlxSprite = new FlxSprite(-500, 650);
						var u:FlxSprite = new FlxSprite(-300, 750);
						var c:FlxSprite = new FlxSprite(450, 940);
						var k:FlxSprite = new FlxSprite(1300, 900);

						var y:FlxSprite = new FlxSprite(1620, 700);
						var r:FlxSprite = new FlxSprite(1300, 1200);

						f.frames = Paths.getSparrowAtlas('tank0', 'week7');
						f.animation.addByPrefix('fg', 'fg', 24, false);
						f.scrollFactor.set(1.7, 1.5);

						u.frames = Paths.getSparrowAtlas('tank1', 'week7');
						u.animation.addByPrefix('fg', 'fg', 24, false);
						u.scrollFactor.set(2, 0.2);

						c.frames = Paths.getSparrowAtlas('tank2', 'week7');
						c.animation.addByPrefix('fg', 'foreground', 24, false);
						c.scrollFactor.set(1.5, 1.5);

						k.frames = Paths.getSparrowAtlas('tank4', 'week7');
						k.animation.addByPrefix('fg', 'fg', 24, false);
						k.scrollFactor.set(1.5, 1.5);

						y.frames = Paths.getSparrowAtlas('tank4', 'week7');
						y.animation.addByPrefix('fg', 'fg', 24, false);
						y.scrollFactor.set(1.5, 1.5);

						r.frames = Paths.getSparrowAtlas('tank3', 'week7');
						r.animation.addByPrefix('fg', 'fg', 24, false);
						r.scrollFactor.set(3.5, 2.5);

						foregroundSprites.add(f);
						foregroundSprites.add(u);
						foregroundSprites.add(c);
						foregroundSprites.add(k);
						foregroundSprites.add(y);
						foregroundSprites.add(r);
					}
				default:
					{
						defaultCamZoom = 0.7;
						curStage = 'stage';
					}
			}
		}
		else
		{
			curStage = SONG.stage;
			add(stageGroup);
			isModStage = true;
			stageHandler = new Stage(SONG.stage, this);
			defaultCamZoom = Stage.STAGEZOOM;
			// isPixel = Stage.PIXELSTAGE;
		}
		scripts.executeFunc('createStage', []); // incase you wanted to code the stage by yourselves.

		if (isStoryMode)
		{
			randomNote = false;
			suddenDeath = false;
			scrSpd = 1;
			healthGainMulti = 1;
			healthLoseMulti = 1;
			comboMultiplier = 1;
			songSpeed = 1.0;
			playingLeftSide = false;
		}

		/**CHARACTER INITIALIZATION**/
		var gfVer:String = (SONG.gfVersion == null ? 'gf' : SONG.gfVersion);
		dad = new Character(DADXPOS, DADYPOS, SONG.player2);
		moveCharToPos(dad, true);

		gf = new Character(GFXPOS, GFYPOS, gfVer);
		moveCharToPos(gf);

		boyfriend = new Boyfriend(BFXPOS, BFYPOS, SONG.player1);
		moveCharToPos(boyfriend);
		
		//Used for Week 7.
		if (gfVer == 'pico-speaker' && curStage == 'tank' && tankBG != null)
		{
			var firstTank:BackgroundTankmen = new BackgroundTankmen(20, 500, true);
			firstTank.resetStatus(20, 600, true);
			firstTank.strumTime = 10;
			tankBG.add(firstTank);

			for (i in 0...BackgroundTankmen.animNotes.length)
			{
				if (FlxG.random.bool(16))
				{
					var tankk = tankBG.recycle(BackgroundTankmen);
					tankk.strumTime = BackgroundTankmen.animNotes[i][0];
					tankk.resetStatus(500, 200 + FlxG.random.int(50, 100), BackgroundTankmen.animNotes[i][1] < 2);
					tankBG.add(tankk);
				}
			}
		}

		camPos = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		// change position of the characters if it's not a mod stage.
		if (!isModStage)
		{
			switch (curStage)
			{
				case 'limo':
					boyfriend.y = BFYPOS - 220;
					boyfriend.x = BFXPOS + 260;

					resetFastCar();
					add(fastCar);

					if (SONG.player1.toLowerCase().startsWith('bf'))
					{
						boyfriend.y += 300;
					}

				case 'mall':
					boyfriend.x = BFXPOS + 200;

				case 'mallEvil':
					boyfriend.x = BFXPOS + 320;
					dad.y = DADYPOS - 80;
				case 'school':
					boyfriend.x = BFXPOS + 200;
					boyfriend.y = BFYPOS + 220;
					gf.x = GFXPOS + 180;
					gf.y = GFYPOS + 300;
					if (SONG.player1.toLowerCase().startsWith('bf'))
						boyfriend.y += 300;
				case 'schoolEvil':
					var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
					add(evilTrail);
					boyfriend.x = BFXPOS + 200;
					boyfriend.y = BFYPOS + 220;
					gf.x = GFXPOS + 180;
					gf.y = GFYPOS + 300;
					if (SONG.player1.toLowerCase().startsWith('bf'))
					{
						boyfriend.y += 300;
					}
				case 'tank':
					dad.y -= 50;
					gf.x -= 100;
			}
		} else {
			boyfriend.x = Stage.BFPOS[0];
			boyfriend.y = Stage.BFPOS[1];
			gf.x = Stage.GFPOS[0];
			gf.y = Stage.GFPOS[1];
			dad.x = Stage.DADPOS[0];
			dad.y = Stage.DADPOS[1];
			stageHandler.createDaStage();
		}

		if (!isModStage)
			add(gf);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		if (!isModStage)
			add(dad);
		if (!isModStage)
			add(boyfriend);

		switch (curStage)
		{
			case 'tank':
				add(foregroundSprites);
		}

		camPosInit();
		dadGFCheck();

		switch (gf.curCharacter)
		{
			case 'boomBoxCHR':
				gf.y += 230;
		}

		if (curStage == 'spooky')
			add(halloweenThunder);

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.cameras = [camHUD];

		Conductor.songPosition = -5000;

		scripts.executeFunc('create', []);

		strumLine = new FlxSprite(strumXpos, 70).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (CDevConfig.saveData.downscroll)
			strumLine.y = FlxG.height - 160;

		// StrumArrow group instances
		strumLineNotes = new FlxTypedGroup<StrumArrow>();
		add(strumLineNotes);
		playerStrums = new FlxTypedGroup<StrumArrow>();
		p2Strums = new FlxTypedGroup<StrumArrow>();
		strumLineNotes.cameras = [camHUD];

		Conductor.checkFakeCrochet(SONG.bpm);
		generateSong(SONG.song);

		camFollow = new FlxObject(0, 0, 1, 1);
		cameraPosition = new FlxObject(0, 0, 1, 1);

		switch (CDevConfig.saveData.cameraStartFocus)
		{
			case 0:
				camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
				camFollow.x += dad.charCamPos[0];
				camFollow.y += dad.charCamPos[1];
			case 1:
				camFollow.setPosition(gf.getMidpoint().x, gf.getMidpoint().y);
			case 2:
				camFollow.setPosition(boyfriend.getMidpoint().x + 150, boyfriend.getMidpoint().y - 100);
				camFollow.x -= boyfriend.charCamPos[0];
				camFollow.y += boyfriend.charCamPos[1];
		}

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);
		add(cameraPosition);

		FlxG.camera.follow(camFollow, LOCKON, getCameraLerp());
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());
		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
		FlxG.fixedTimestep = false;

		initHUD();

		startingSong = true;

		if (isStoryMode)
		{
			switch (curSong.toLowerCase())
			{
				case "winter-horrorland":
					introCutscene();
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
				case 'ugh', 'guns', 'stress':
					tankIntro();
				default:
					if (intro_cutscene_script != null)
					{
						introCutscene();
					}
					else
					{
						startCountdown();
					}
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
					if (intro_cutscene_script != null)
					{
						intro_cutscene_script.executeFunc("init");
						if (intro_cutscene_script.getVariable("runOnFreeplay") == true)
							introCutscene();
						else
							startCountdown();
					}
					else
						startCountdown();
			}
		}

		super.create();
		scripts.executeFunc('postCreate', []);
	}

	/**
	 * Call this function to create the HUD.
	 */
	public function initHUD() {
		// Note Lane a.k.a Note BG Lane
		bgNoteLane = new FlxSprite().makeGraphic(500, FlxG.height, FlxColor.BLACK);
		bgNoteLane.screenCenter(X);
		bgNoteLane.alpha = 0;

		// Health bar
		healthBar = new FunkinBar(0, (!CDevConfig.saveData.downscroll ? (FlxG.height * 0.85) + 20 : 80), 'healthBar', () -> {return healthLerp;}, 0, 2);
		healthBar.screenCenter(X);
		healthBar.leftToRight = false;
		healthBar.scrollFactor.set();
		healthBar.setColors(FlxColor.fromRGB(dad.healthBarColors[0], dad.healthBarColors[1], dad.healthBarColors[2]),
				FlxColor.fromRGB(boyfriend.healthBarColors[0], boyfriend.healthBarColors[1], boyfriend.healthBarColors[2]));

		// Health Bar BG (Backwards compability??)
		healthBarBG = healthBar.bgSprite;

		// Health Icons
		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);

		// Score Text
		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 18);
		scoreTxt.setFormat(config.uiTextFont, 16, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		scoreTxt.borderSize = 1.1;
		scoreTxt.scrollFactor.set();
		if (CDevConfig.saveData.downscroll)
			scoreTxt.y = healthBarBG.y + 43;

		// Score Text's background.
		bgScore = new FlxSprite(scoreTxt.x, scoreTxt.y).makeGraphic(500, 500, FlxColor.BLACK);
		bgScore.alpha = 0.3;

		// Time Bar stuffs.
		songPosBG = new FlxSprite(0, 20).loadGraphic(Paths.image('healthBar'));
		var songPosBGWIDTH:Float = songPosBG.width * 0.6;
		var songPosBGHEIGHT:Float = songPosBG.height;
		songPosBG.setGraphicSize(Std.int(songPosBGWIDTH), Std.int(songPosBGHEIGHT));
		songPosBG.screenCenter(X);
		songPosBG.antialiasing = CDevConfig.saveData.antialiasing;
		songPosBG.scrollFactor.set();
		songPosBG.visible = false;
		if (CDevConfig.saveData.downscroll) songPosBG.y = FlxG.height * 0.9 + 35;

		songPosBGspr = new FlxSprite(songPosBG.x, songPosBG.y).makeGraphic(Std.int(songPosBGWIDTH), Std.int(songPosBGHEIGHT), FlxColor.BLACK);
		songPosBGspr.antialiasing = CDevConfig.saveData.antialiasing;
		songPosBGspr.screenCenter(X);
		songPosBGspr.alpha = 0;

		songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBGWIDTH - 8), Std.int(songPosBGHEIGHT - 8), this,
			'songPercent', 0, 1);
		songPosBar.numDivisions = 1000;
		songPosBar.scrollFactor.set();
		songPosBar.screenCenter(X);
		songPosBar.antialiasing = CDevConfig.saveData.antialiasing;
		songPosBar.createFilledBar(FlxColor.BLACK, config.timeBarColor);
		songPosBar.alpha = 0;

		songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - 20, songPosBG.y, 0, "", 16);
		songName.setFormat(config.uiTextFont, 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		songName.scrollFactor.set();
		songName.borderSize = 2;

		// Botplay Text
		botplayTxt = new FlxText(0, 0, FlxG.width, "> BOTPLAY <", 32);
		botplayTxt.setFormat(config.uiTextFont, 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		botplayTxt.antialiasing = CDevConfig.saveData.antialiasing;
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 2;
		botplayTxt.y = 150;
		if (CDevConfig.saveData.downscroll) botplayTxt.y = FlxG.height - 150;

		// Note Press Group & Instance
		grpNotePresses = new FlxTypedGroup<NotePress>();
		var hmmclicc:NotePress = new NotePress(100, 100, 0);
		grpNotePresses.add(hmmclicc);
		hmmclicc.alpha = 0;

		// Judgement Text a.k.a Note Delay Text.
		var strumYPOS:Float = (CDevConfig.saveData.downscroll ? 70 : FlxG.height - 160);
		var allNoteWidth:Float = (160 * 0.7) * 4;

		judgementText = new FlxText(0, 0, 500, '', 18);
		judgementText.setFormat(config.uiTextFont, 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		judgementText.x = (strumXpos + 50 + (allNoteWidth / 2) - (judgementText.width / 2));
		judgementText.bold = true;
		judgementText.borderSize = 1.5;
		judgementText.y = (CDevConfig.saveData.downscroll ? strumYPOS + 157 + 25 : strumYPOS - 25);
		judgementText.alpha = 0;

		// Engine Watermark
		var engineWM:FlxText = new FlxText(0, 0, MainMenuState.coreEngineText + (CDevConfig.saveData.testMode ? ' - [T]' : ''), 20);
		engineWM.setFormat(config.uiTextFont, 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		engineWM.scrollFactor.set();
		engineWM.borderSize = 1.5;
		engineWM.setPosition(20, FlxG.height - engineWM.height - 20);
		engineWM.antialiasing = CDevConfig.saveData.antialiasing;

		// Adding the UI objects to this state and assign them to camHUD.
		for (element in [bgNoteLane, healthBar, songPosBG, songPosBGspr, songPosBar,
						 songName, iconP2, iconP1, bgScore, scoreTxt, botplayTxt, judgementText]){
			add(element);
			element.cameras = [camHUD];
		}

		add(grpNotePresses);
		grpNotePresses.cameras = [config.noteImpactsCamera];

		if (CDevConfig.saveData.engineWM) {
			add(engineWM);
			engineWM.cameras = [camHUD];
		};

		notes.cameras = [camHUD];

		numGroup = new FlxTypedGroup<FlxSprite>();
		numGroup.cameras = [config.ratingSpriteCamera];
		add(numGroup);
	}

	function initModifiers()
	{
		randomNote = CDevConfig.saveData.randomNote;
		suddenDeath = CDevConfig.saveData.suddenDeath;
		scrSpd = CDevConfig.saveData.scrollSpeed;
		healthGainMulti = CDevConfig.saveData.healthGainMulti;
		healthLoseMulti = CDevConfig.saveData.healthLoseMulti;
		comboMultiplier = CDevConfig.saveData.comboMultipiler;
		songSpeed = FlxMath.roundDecimal(FreeplayState.speed, 2);
		playingLeftSide = FreeplayState.playOnLeftSide;
	}

	function initCutsceneScripts()
	{
		var introExist:Bool = false;
		var outroExist:Bool = false;

		var introPath:String = "";
		var outroPath:String = "";

		var pathIntro:Array<String> = [
			Paths.modChartPath(SONG.song + "/intro.hx"),
			"cdev-mods/" + fromMod + "/scripts/intro.hx"
		];
		var pathOutro:Array<String> = [
			Paths.modChartPath(SONG.song + "/outro.hx"),
			"cdev-mods/" + fromMod + "/scripts/outro.hx"
		];

		for (i in pathIntro)
		{
			if (FileSystem.exists(i))
			{
				introExist = true;
				intro_cutscene_script = CDevScript.create(i);
				ScriptSupport.setScriptDefaultVars(intro_cutscene_script, fromMod);
				introPath = i;
				break;
			}
		}

		for (i in pathOutro)
		{
			if (FileSystem.exists(i))
			{
				outroExist = true;
				outro_cutscene_script = CDevScript.create(i);
				ScriptSupport.setScriptDefaultVars(outro_cutscene_script, fromMod);
				outroPath = i;
				break;
			}
		}

		if (introExist)
		{
			intro_cutscene_script.loadFile(introPath);

			// variables
			intro_cutscene_script.setVariable("FlxTypeText", flixel.addons.text.FlxTypeText);
			intro_cutscene_script.setVariable("runOnFreeplay", false);
		}

		if (outroExist)
		{
			outro_cutscene_script.loadFile(outroPath);

			// variables
			outro_cutscene_script.setVariable("FlxTypeText", flixel.addons.text.FlxTypeText);
			outro_cutscene_script.setVariable("runOnFreeplay", false);
		}
	}

	// tank Week
	var prevCamZoom:Float = 0; // used on all tank week songs
	var tankmanSprite:FlxSprite; // used on all tank week songs
	var distorto:FlxSound;

	// ugh
	var tankmanTalk1Audio:FlxSound;
	var tankmanTalk2Audio:FlxSound;
	var bfBeep:FlxSound;
	var animPhase:Int = 0;
	var tankmanSpriteOffset:Array<Dynamic> = [
		[0, 5], // talk
		[35, 15] // talk2
	];
	// guns
	var tankmanTalkAudio:FlxSound;

	// stress
	var tankmanTalk1:FlxSprite;
	var tankmanTalk2:FlxSprite;
	var gfTurn1:FlxSprite;
	var gfTurn2:FlxSprite;
	var gfTurn3:FlxSprite;
	var gfTurn4:FlxSprite;
	var gfTurn5:FlxSprite;
	var audio:FlxSound;
	var bf:FlxSprite;
	var ggf:FlxSprite;

	function tankIntro()
	{
		switch (SONG.song.toLowerCase())
		{
			case 'ugh':
				prevCamZoom = defaultCamZoom;
				defaultCamZoom = 1.1;
				FlxG.camera.zoom = defaultCamZoom;
				camHUD.visible = false;
				// FlxG.sound.playMusic(Paths.music('DISTORTO', 'week7'), 0.6);
				dad.visible = false;

				distorto = FlxG.sound.play(Paths.music("DISTORTO", 'week7'));
				distorto.pause();

				tankmanSprite = new FlxSprite(dad.x, dad.y);
				tankmanSprite.frames = Paths.getSparrowAtlas('cutscenes/ugh', 'week7');
				tankmanSprite.antialiasing = CDevConfig.saveData.antialiasing;
				tankmanSprite.animation.addByPrefix("talk", "TANK TALK 1 P1", 24, false);
				tankmanSprite.animation.addByPrefix("talkk", "TANK TALK 1 P2", 24, false);
				add(tankmanSprite);

				tankmanTalk1Audio = FlxG.sound.play(Paths.sound("wellWellWell", 'week7'), 1, false, null, true);
				tankmanTalk1Audio.pause();

				tankmanTalk2Audio = FlxG.sound.play(Paths.sound("killYou", 'week7'), 1, false, null, true);
				tankmanTalk2Audio.pause();

				bfBeep = FlxG.sound.play(Paths.sound("bfBeep", 'week7'), 1, false, null, true);
				bfBeep.pause();

				distorto.fadeIn(5, 0, 0.4);
				distorto.play();
				inCutscene = true;
			case 'guns':
				prevCamZoom = defaultCamZoom;
				defaultCamZoom = 1;
				camHUD.visible = false;
				dad.visible = false;
				distorto = FlxG.sound.play(Paths.music("DISTORTO", 'week7'), 0.6);
				distorto.pause();

				tankmanTalkAudio = FlxG.sound.play(Paths.sound("tankSong2", 'week7'), 1, false, null, true);
				tankmanTalkAudio.pause();

				tankmanSprite = new FlxSprite(dad.x, dad.y);
				tankmanSprite.frames = Paths.getSparrowAtlas('cutscenes/guns', 'week7');
				tankmanSprite.antialiasing = CDevConfig.saveData.antialiasing;
				tankmanSprite.animation.addByPrefix("talk", "TANK TALK 2", 24, false);
				tankmanSprite.offset.set(0, 10);

				add(tankmanSprite);

				distorto.fadeIn(5, 0, 0.4);
				distorto.play();
				tankmanTalkAudio.play();
				tankmanSprite.animation.play("talk");
				inCutscene = true;
			case 'stress': // high memory usage moment
				cleanCache();
				gf.visible = false;
				dad.visible = false;
				camHUD.visible = false;

				prevCamZoom = PlayState.defaultCamZoom;
				defaultCamZoom = 1;

				tankmanTalk1 = new FlxSprite(dad.x, dad.y);
				tankmanTalk1.frames = Paths.getSparrowAtlas('cutscenes/stressCutscene/stress', 'week7');
				tankmanTalk1.antialiasing = CDevConfig.saveData.antialiasing;
				tankmanTalk1.animation.addByPrefix("talk", "TANK TALK 3 P1 UNCUT", 24, false);
				tankmanTalk1.animation.play("talk");
				tankmanTalk1.offset.set(93, 33);

				tankmanTalk2 = new FlxSprite(dad.x, dad.y);
				tankmanTalk2.frames = Paths.getSparrowAtlas('cutscenes/stressCutscene/stress2', 'week7');
				tankmanTalk2.antialiasing = CDevConfig.saveData.antialiasing;
				tankmanTalk2.animation.addByPrefix("talk", "TANK TALK 3 P2 UNCUT", 24, false);
				tankmanTalk2.animation.play("talk");
				tankmanTalk2.offset.set(4, 28);

				ggf = new FlxSprite(gf.x, gf.y);
				ggf.frames = Paths.getSparrowAtlas('characters/gfTankmen', 'shared');
				ggf.offset.set(99 * 1.1, -129 * 1.1);
				ggf.scrollFactor.set(gf.scrollFactor.x, gf.scrollFactor.y);
				ggf.animation.addByPrefix('dance', "GF Dancing at Gunpoint", 24, true);
				ggf.antialiasing = CDevConfig.saveData.antialiasing;
				ggf.animation.play('dance');

				gfTurn1 = new FlxSprite(400, 130);
				gfTurn1.frames = Paths.getSparrowAtlas('cutscenes/stressCutscene/gf-turn-1', 'week7');
				gfTurn1.antialiasing = CDevConfig.saveData.antialiasing;
				gfTurn1.animation.addByPrefix("turn", "GF STARTS TO TURN PART 1", 24, true);
				gfTurn1.animation.play("turn");
				gfTurn1.scrollFactor.set(gf.scrollFactor.x, gf.scrollFactor.y);
				gfTurn1.offset.set(124 * 1.1 + 1, 67 * 1.1 + 1);

				gfTurn2 = new FlxSprite(400, 130);
				gfTurn2.frames = Paths.getSparrowAtlas('cutscenes/stressCutscene/gf-turn-2', 'week7');
				gfTurn2.antialiasing = CDevConfig.saveData.antialiasing;
				gfTurn2.animation.addByPrefix("turn", "GF STARTS TO TURN PART 2", 24, true);
				gfTurn2.animation.play("turn");
				gfTurn2.scrollFactor.set(gf.scrollFactor.x, gf.scrollFactor.y);
				gfTurn2.offset.set(326 * 1.1 + 4, 468 * 1.1 + 5);

				gfTurn3 = new FlxSprite(400, 130);
				gfTurn3.frames = Paths.getSparrowAtlas('cutscenes/stressCutscene/pico-arrives-1', 'week7');
				gfTurn3.antialiasing = CDevConfig.saveData.antialiasing;
				gfTurn3.animation.addByPrefix("turn", "PICO ARRIVES PART 1", 24, true);
				gfTurn3.animation.play("turn");
				gfTurn3.scrollFactor.set(gf.scrollFactor.x, gf.scrollFactor.y);
				gfTurn3.offset.set(228 * 1.1, 227 * 1.1);

				gfTurn4 = new FlxSprite(400, 130);
				gfTurn4.frames = Paths.getSparrowAtlas('cutscenes/stressCutscene/pico-arrives-2', 'week7');
				gfTurn4.antialiasing = CDevConfig.saveData.antialiasing;
				gfTurn4.animation.addByPrefix("turn", "PICO ARRIVES PART 2", 24, true);
				gfTurn4.animation.play("turn");
				gfTurn4.scrollFactor.set(gf.scrollFactor.x, gf.scrollFactor.y);
				gfTurn4.offset.set(500 + (342 * 1.1), 500 + (-80 * 1.1));

				gfTurn5 = new FlxSprite(400, 130);
				gfTurn5.frames = Paths.getSparrowAtlas('cutscenes/stressCutscene/pico-arrives-3', 'week7');
				gfTurn5.antialiasing = CDevConfig.saveData.antialiasing;
				gfTurn5.animation.addByPrefix("turn", "PICO ARRIVES PART 3", 24, true);
				gfTurn5.animation.play("turn");
				gfTurn5.scrollFactor.set(gf.scrollFactor.x, gf.scrollFactor.y);
				gfTurn5.offset.set(500 + (312 * 1.1) + 1, 500 + (-265 * 1.1) - 7);
				gfTurn5.visible = true;

				bf = new FlxSprite(boyfriend.x, boyfriend.y).loadGraphic(Paths.image('cutscenes/stressCutscene/bf', 'week7'));
				bf.offset.set(boyfriend.offset.x, boyfriend.offset.y);
				bf.antialiasing = true;

				boyfriend.visible = false;

				add(tankmanTalk1);
				add(tankmanTalk2);
				add(bf);
				insert(members.indexOf(gf), ggf);
				insert(members.indexOf(gf), gfTurn1);
				insert(members.indexOf(gf), gfTurn2);
				insert(members.indexOf(gf), gfTurn3);
				insert(members.indexOf(gf), gfTurn4);
				insert(members.indexOf(gf), gfTurn5);

				audio = FlxG.sound.play(Paths.sound('stressCutscene', 'week7'));
				inCutscene = true;
		}
	}

	function dadGFCheck()
	{
		if (dad.curCharacter.startsWith('gf'))
		{
			gf.visible = false;
		}
		else
		{
			gf.visible = true;
		}
	}

	function introCutscene()
	{
		switch (SONG.song.toLowerCase())
		{
			case "winter-horrorland":
				var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				add(blackScreen);
				blackScreen.scrollFactor.set();
				camHUD.visible = false;

				new FlxTimer().start(0.1, function(tmr:FlxTimer)
				{
					remove(blackScreen);
					FlxG.camera.flash(FlxColor.RED);
					FlxG.sound.play(Paths.sound('Lights_Turn_On'));
					camFollow.y = -2050;
					camFollow.x += 200;
					FlxG.camera.focusOn(camFollow.getPosition());
					FlxG.camera.zoom = 1.5;

					new FlxTimer().start(0.8, function(tmr:FlxTimer)
					{
						camHUD.visible = true;
						remove(blackScreen);
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween)
							{
								startCountdown();
							}
						});
					});
				});
			default:
				inCutscene = true;
				currentCutscene = "intro";

				intro_cutscene_script.setVariable("startSong", function()
				{
					inCutscene = false;
					intro_cutscene_script.executeFunc("introEnd", []);
					intro_cutscene_script = null;
					startCountdown();
				});

				intro_cutscene_script.executeFunc("introStart", []);
				if (intro_cutscene_script != null)
					intro_cutscene_script.executeFunc("postIntro", []);
		}
	}

	function initCharPositions()
	{
		switch (SONG.player1)
		{
			// case 'bf', 'bf-car', 'bf-cscared', 'bf-christmas', 'bf-pixel':
			// BFXPOS = 770;
			// BFYPOS = 450;
			case "spooky":
				BFYPOS += 200;
			case "monster":
				BFYPOS += 100;
			case 'monster-christmas':
				BFYPOS += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				BFYPOS += 300;
			case 'parents-christmas':
				BFXPOS -= 500;
			case 'senpai':
				BFXPOS += 150;
				BFYPOS += 360;
			case 'senpai-angry':
				BFXPOS += 150;
				BFYPOS += 360;
			case 'spirit':
				BFXPOS -= 150;
				BFYPOS += 100;
		}
		switch (SONG.player2)
		{
			case 'bf', 'bf-car', 'bf-cscared', 'bf-christmas':
				DADYPOS = 450;
			case "spooky":
				DADYPOS += 200;
			case "monster":
				DADYPOS += 100;
			case 'monster-christmas':
				DADYPOS += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				DADYPOS += 300;
			case 'parents-christmas':
				DADXPOS -= 500;
			case 'senpai':
				DADXPOS += 150;
				DADYPOS += 360;
			case 'senpai-angry':
				DADXPOS += 150;
				DADYPOS += 360;
			case 'spirit':
				DADXPOS -= 150;
				DADYPOS += 100;
			case 'bf-pixel':
				DADYPOS = 450;
				if (SONG.song.toLowerCase() == 'mod-test')
				{
					DADXPOS = 320;
					DADYPOS = 600;
				}
		}
	}

	public static var instantEndSong:Bool = false;

	function camPosInit()
	{
		switch (SONG.player2)
		{
			case 'senpai', 'senpai-angry', 'spirit':
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
		}

		switch (SONG.player1)
		{
			case 'senpai', 'senpai-angry', 'spirit':
				camPos.set(boyfriend.getGraphicMidpoint().x + 300, boyfriend.getGraphicMidpoint().y);
		}
	}

	function moveCharToPos(char:Character, ?checkCurCharGF:Bool = false)
	{
		if (checkCurCharGF && char.curCharacter.startsWith('gf'))
		{
			char.setPosition(GFXPOS, GFYPOS);
			char.scrollFactor.set(0.95, 0.95);
		}
		char.x += char.charXYPos[0];
		char.y += char.charXYPos[1];
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy', "week6");
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai':
				FlxG.sound.playMusic(Paths.music('Lunchbox', "week6"), 0);
			case 'thorns':
				FlxG.sound.playMusic(Paths.music('LunchboxScary', "week6"), 0);
		}
		FlxG.sound.music.play();
		FlxG.sound.music.fadeIn(1, 0, 0.8);
		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
				camHUD.visible = false;
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					switch (SONG.song.toLowerCase())
					{
						case "thorns":
							add(senpaiEvil);
							senpaiEvil.alpha = 0;
							new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
							{
								senpaiEvil.alpha += 0.15;
								if (senpaiEvil.alpha < 1)
								{
									swagTimer.reset();
								}
								else
								{
									senpaiEvil.animation.play('idle');
									FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
									{
										remove(senpaiEvil);
										remove(red);
										FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
										{
											add(dialogueBox);
											camHUD.visible = true;
										}, true);
									});

									new FlxTimer().start(0.92, function(camMove:FlxTimer)
									{
										FlxTween.tween(senpaiEvil, {x: ((FlxG.width / 2) - (senpaiEvil.width / 2)) + 200}, 2, {ease: FlxEase.backOut});
									});

									new FlxTimer().start(2.30, function(camMove:FlxTimer)
									{
										FlxG.camera.shake(0.030, 5);
									});
									new FlxTimer().start(3.2, function(deadTime:FlxTimer)
									{
										FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
									});
								}
							});
						default:
							add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;

	public function startCountdown():Void
	{
		camHUD.visible = true;
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);

		talking = false;
		startedCountdown = true;

		if (enableCountdown)
		{
			scripts.executeFunc('onStartCountdown', []);

			Conductor.songPosition = 0;
			Conductor.songPosition -= ((Conductor.crochet * 5) + Conductor.offset) / songSpeed;
			Conductor.rawTime = Conductor.songPosition;

			var swagCounter:Int = 0;

			startTimer = new FlxTimer().start((Conductor.crochet / 1000) / songSpeed, function(tmr:FlxTimer)
			{
				dad.dance();
				gf.dance();
				boyfriend.dance();

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', ['ready', "set", "go"]);
				introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
				introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

				var introAlts:Array<String> = introAssets.get('default');
				var altSuffix:String = "";
				var introAudio:Array<String> = ['intro3', 'intro2', 'intro1', 'introGo'];

				switch (SONG.song.toLowerCase())
				{
					case 'thorns':
						introAudio = ['intro3-error', 'intro2-error', 'intro1-error', 'introGo-error'];
					default:
						introAudio = ['intro3', 'intro2', 'intro1', 'introGo'];
				}

				for (value in introAssets.keys())
				{
					if (value == curStage)
					{
						introAlts = introAssets.get(value);
						altSuffix = '-pixel';
					}
				}
				var libshit:String = 'shared';
				if (isPixel)
				{
					introAlts = introAssets.get("school");
					altSuffix = '-pixel';
					libshit = 'week6';
				}

				switch (swagCounter)
				{
					case 0:
						canPause = true;
						FlxG.sound.play(Paths.sound(introAudio[swagCounter] + altSuffix), 0.6);
					case 1:
						var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0], libshit));
						ready.scrollFactor.set();
						ready.updateHitbox();

						if (isPixel)
							ready.setGraphicSize(Std.int(ready.width * daPixelZoom));
						
						ready.scale.set(1/FlxG.camera.zoom, 1/FlxG.camera.zoom);

						ready.screenCenter();
						ready.y -= 50;
						add(ready);
						FlxTween.tween(ready, {y: ready.y + 50, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								ready.destroy();
							}
						});
						FlxG.sound.play(Paths.sound(introAudio[swagCounter] + altSuffix), 0.6);
					case 2:
						var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1], libshit));
						set.scrollFactor.set();

						if (isPixel)
							set.setGraphicSize(Std.int(set.width * daPixelZoom));

						set.scale.set(1/FlxG.camera.zoom, 1/FlxG.camera.zoom);
						set.screenCenter();
						set.y -= 50;
						add(set);
						FlxTween.tween(set, {y: set.y + 50, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								set.destroy();
							}
						});
						FlxG.sound.play(Paths.sound(introAudio[swagCounter] + altSuffix), 0.6);
					case 3:
						var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2], libshit));
						go.scrollFactor.set();

						if (isPixel)
							go.setGraphicSize(Std.int(go.width * daPixelZoom));

						go.updateHitbox();
						go.scale.set(1/FlxG.camera.zoom, 1/FlxG.camera.zoom);
						go.screenCenter();
						go.y -= 50;
						add(go);
						FlxTween.tween(go, {y: go.y + 50, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								go.destroy();
							}
						});
						FlxG.sound.play(Paths.sound(introAudio[swagCounter] + altSuffix), 0.6);
					case 4:
				}
				scripts.executeFunc('onCountdown', [swagCounter]);
				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
		}
		else
		{
			var wawaCat = (Conductor.crochet + Conductor.offset) / songSpeed;
			Conductor.songPosition = 0;
			Conductor.songPosition -= wawaCat;
			startTimer = new FlxTimer().start((Conductor.crochet + Conductor.offset) / 1000, function(ewa)
			{
				canPause = true;
			});
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, CDevConfig.saveData.downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
			checkPlayerStrum();
		}
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		if (!songStarted)
		{
			camHUD.visible = true;
			startingSong = false;
			songStarted = true;
			previousFrameTime = FlxG.game.ticks;
			lastReportedPlayheadPosition = 0;

			if (songSpeed == 1)
			{
				FlxG.sound.music.onComplete = endSong;
				FlxAnimationController.animSpeed = 1;
			}
			else
			{
				FlxAnimationController.animSpeed = songSpeed;
				FlxG.sound.music.onComplete = null;
			}

			if (!paused)
			{
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
				Conductor.songPosition = Conductor.offset;
				vocals.play();
			}

			FlxTween.tween(bgNoteLane, {alpha: 0.5}, Conductor.crochet / 1000, {ease: FlxEase.linear});
			FlxTween.tween(songPosBGspr, {alpha: 1}, Conductor.crochet / 1000, {ease: FlxEase.linear});
			FlxTween.tween(songPosBar, {alpha: 1}, Conductor.crochet / 1000, {ease: FlxEase.linear});
			
			#if desktop
			songLength = FlxG.sound.music.length;
			DiscordClient.changePresence(detailsText, daRPCInfo, iconRPC, true, songLength);
			#end

			scripts.executeFunc('onStartSong', []);
		}
	}

	var debugNum:Int = 0;

	public static var eventNames:Array<String> = [];

	private function generateSong(dataPath:String):Void
	{
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);
		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);
		vocals.pause();

		notes = new FlxTypedGroup<Note>();
		add(notes);
		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var crapNote:Note;

		var daBeats:Int = 0;
		var calledEvents:Array<String> = [];

		for (i in 0...ChartEvent.builtInEvents.length)
			eventNames.push(ChartEvent.builtInEvents[i][0]);

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				if (songNotes[1] > -1)
				{
					var daStrumTime:Float = songNotes[0] + SONG.offset + Conductor.offset;
					var daNoteData:Int = Std.int(songNotes[1] % 4);
					var daNoteType:String = "Default Note";
					if (songNotes[3] != null)
						daNoteType = songNotes[3];
					var daNoteArgs = ["", ""];
					if (songNotes[4] != null)
						daNoteArgs = songNotes[4];

					var gottaHitNote:Bool = section.mustHitSection;

					if (songNotes[1] > 3)
						gottaHitNote = !section.mustHitSection;

					var oldNote:Note;
					if (unspawnNotes.length > 0)
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
					else
						oldNote = null;

					if (unspawnNotes.length > 0)
						crapNote = oldNote;
					else
						crapNote = null;

					if (randomNote)
					{
						var data:Int = FlxG.random.int(0, 8) % 4;
						if (crapNote != null)
							if (data == crapNote.noteData)
								data = FlxG.random.int(0, 8) % 4;

						// FlxG.log.add('noteData: ' + data);

						daNoteData = data;
					}

					var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, false, daNoteType, daNoteArgs);
					swagNote.sustainLength = songNotes[2];
					swagNote.scrollFactor.set(0, 0);

					var susLength:Float = swagNote.sustainLength;

					susLength = susLength / Conductor.stepCrochet;

					unspawnNotes.push(swagNote);
					var susFloor = Math.floor(susLength);
					if (susFloor > 0)
					{
						for (susNote in 0...susFloor)
						{
							oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
							if (randomNote && !oldNote.isSustainNote)
								daNoteData = oldNote.noteData;

							var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote,
								true, true, daNoteType, daNoteArgs);
							sustainNote.scrollFactor.set();
							unspawnNotes.push(sustainNote);
							sustainNote.mainNote = swagNote;
							sustainNote.mustPress = gottaHitNote;

							if (!PlayState.isPixel)
							{
								if (oldNote.isSustainNote)
								{
									oldNote.scale.y *= 44 / oldNote.frameHeight;
									oldNote.updateHitbox();
								}
							}

							if (playingLeftSide)
								sustainNote.mustPress = !gottaHitNote;

							if (sustainNote.mustPress)
								sustainNote.x += FlxG.width / 2; // general offset
						}
					}
					swagNote.mustPress = gottaHitNote;

					if (playingLeftSide)
					{
						swagNote.mustPress = !gottaHitNote;
					}

					if (swagNote.mustPress)
						swagNote.x += FlxG.width / 2; // general offset
				}
			}

			if (section.sectionEvents != null)
			{
				for (songEvents in section.sectionEvents)
				{
					var strm:Float = songEvents[2] + SONG.offset + Conductor.offset;
					var eventName:String = songEvents[0];
					var val1:String = songEvents[3];
					var val2:String = songEvents[4];

					var event:ChartEvent = new ChartEvent(strm, 0, false);
					event.mod = fromMod;
					event.EVENT_NAME = eventName;
					event.value1 = val1;
					event.value2 = val2;
					toDoEvents.push(event);

					// onEventLoaded will only be called once.
					if (!calledEvents.contains(eventName))
					{
						scripts.executeFunc("onEventLoaded", [event.EVENT_NAME, event.value1, event.value2]);
						calledEvents.push(eventName);
					}
				}
			}

			daBeats += 1;
		}

		unspawnNotes.sort(sortByShit);

		if (toDoEvents.length > 1)
		{
			toDoEvents.sort(sortByTime);
		}
		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:ChartEvent, Obj2:ChartEvent):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.time, Obj2.time);
	}

	function sortByID(Obj1:Dynamic, Obj2:Dynamic):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[1], Obj2[1]);
	}

	private function generateStaticArrows(player:Int):Void
	{
		// animName, animID
		var animXML_static:Array<Dynamic> = [];
		var animXML_pressed:Array<Dynamic> = [];
		var animXML_confirm:Array<Dynamic> = [];

		animXML_static.push(['arrowLEFT', 0]);
		animXML_static.push(['arrowDOWN', 1]);
		animXML_static.push(['arrowUP', 2]);
		animXML_static.push(['arrowRIGHT', 3]);

		animXML_pressed.push(['left press', 0]);
		animXML_pressed.push(['down press', 1]);
		animXML_pressed.push(['up press', 2]);
		animXML_pressed.push(['right press', 3]);

		animXML_confirm.push(['left confirm', 0]);
		animXML_confirm.push(['down confirm', 1]);
		animXML_confirm.push(['up confirm', 2]);
		animXML_confirm.push(['right confirm', 3]);
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:StrumArrow = new StrumArrow(strumXpos, strumLine.y);

			if (isPixel)
			{
				babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels', 'week6'), true, 17, 17);
				babyArrow.animation.add('green', [6]);
				babyArrow.animation.add('red', [7]);
				babyArrow.animation.add('blue', [5]);
				babyArrow.animation.add('purplel', [4]);

				babyArrow.setGraphicSize(Std.int(babyArrow.width * (daPixelZoom - 0.1)));
				babyArrow.updateHitbox();
				babyArrow.antialiasing = false;

				switch (Math.abs(i))
				{
					case 0:
						babyArrow.x += Note.swagWidth * 0;
						babyArrow.animation.add('static', [0]);
						babyArrow.animation.add('pressed', [4, 8], 12, false);
						babyArrow.animation.add('confirm', [12, 16], 24, false);
					case 1:
						babyArrow.x += Note.swagWidth * 1;
						babyArrow.animation.add('static', [1]);
						babyArrow.animation.add('pressed', [5, 9], 12, false);
						babyArrow.animation.add('confirm', [13, 17], 24, false);
					case 2:
						babyArrow.x += Note.swagWidth * 2;
						babyArrow.animation.add('static', [2]);
						babyArrow.animation.add('pressed', [6, 10], 12, false);
						babyArrow.animation.add('confirm', [14, 18], 12, false);
					case 3:
						babyArrow.x += Note.swagWidth * 3;
						babyArrow.animation.add('static', [3]);
						babyArrow.animation.add('pressed', [7, 11], 12, false);
						babyArrow.animation.add('confirm', [15, 19], 24, false);
				}
			}
			else
			{
				babyArrow.frames = Paths.getSparrowAtlas('notes/NOTE_assets');
				babyArrow.animation.addByPrefix('purple', animXML_static[0][0]);
				babyArrow.animation.addByPrefix('blue', animXML_static[1][0]);
				babyArrow.animation.addByPrefix('green', animXML_static[2][0]);
				babyArrow.animation.addByPrefix('red', animXML_static[3][0]);

				babyArrow.antialiasing = CDevConfig.saveData.antialiasing;
				babyArrow.setGraphicSize(Std.int(babyArrow.width * Note.noteScale));

				switch (Math.abs(i))
				{
					case 0:
						babyArrow.x += Note.swagWidth * 0;
						babyArrow.animation.addByPrefix('static', animXML_static[0][0]);
						babyArrow.animation.addByPrefix('pressed', animXML_pressed[0][0], 24, false);
						babyArrow.animation.addByPrefix('confirm', animXML_confirm[0][0], 24, false);
					case 1:
						babyArrow.x += Note.swagWidth * 1;
						babyArrow.animation.addByPrefix('static', animXML_static[1][0]);
						babyArrow.animation.addByPrefix('pressed', animXML_pressed[1][0], 24, false);
						babyArrow.animation.addByPrefix('confirm', animXML_confirm[1][0], 24, false);
					case 2:
						babyArrow.x += Note.swagWidth * 2;
						babyArrow.animation.addByPrefix('static', animXML_static[2][0]);
						babyArrow.animation.addByPrefix('pressed', animXML_pressed[2][0], 24, false);
						babyArrow.animation.addByPrefix('confirm', animXML_confirm[2][0], 24, false);
					case 3:
						babyArrow.x += Note.swagWidth * 3;
						babyArrow.animation.addByPrefix('static', animXML_static[3][0]);
						babyArrow.animation.addByPrefix('pressed', animXML_pressed[3][0], 24, false);
						babyArrow.animation.addByPrefix('confirm', animXML_confirm[3][0], 24, false);
				}
			}

			babyArrow.ID = i;

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				if (enableNoteTween)
				{
					var posAddition = CDevConfig.saveData.downscroll ? -50 : 50;

					babyArrow.y += posAddition;
					babyArrow.alpha = 0;
					FlxTween.tween(babyArrow, {y: babyArrow.y - posAddition, alpha: 1}, ((Conductor.crochet * 4) / 1000) - 0.1,
						{ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
				}
			}

			switch (player)
			{
				case 0:
					p2Strums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			babyArrow.playAnim('static', false);
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			babyArrow.noteScroll = (CDevConfig.saveData.downscroll ? -1 : 1);

			if (CDevConfig.saveData.botplay)
				playerStrums.forEach(function(spr:StrumArrow)
				{
					spr.centerOffsets();
				});

			p2Strums.forEach(function(spr:StrumArrow)
			{
				spr.centerOffsets();
			});
			strumLineNotes.add(babyArrow);
		}
	}

	function checkPlayerStrum()
	{
		if (!CDevConfig.saveData.middlescroll)
		{
			var playerLeft:Array<Float> = [0, 0, 0, 0];
			var playerRight:Array<Float> = [0, 0, 0, 0];
			if (playingLeftSide)
			{
				// copying the x position.
				for (i in 0...p2Strums.members.length)
				{
					playerLeft[i] = p2Strums.members[i].x;
				}

				for (i in 0...playerStrums.members.length)
				{
					playerRight[i] = playerStrums.members[i].x;
				}

				// applying the copied x positions.
				for (i in 0...p2Strums.members.length)
				{
					p2Strums.members[i].x = playerRight[i];
				}

				for (i in 0...playerStrums.members.length)
				{
					playerStrums.members[i].x = playerLeft[i];
				}
			}
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function destroy()
	{
		scripts.executeFunc("onDestroy", []);
		super.destroy();
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
				// vocals_opponent.pause();
			}

			if (!inCutscene)
			{
				if (startTimer != null && !startTimer.finished)
					startTimer.active = false;
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			FlxG.camera.followLerp = getCameraLerp();

			if (!inCutscene)
			{
				if (!startTimer.finished)
					startTimer.active = true;
			}
			paused = false;

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, daRPCInfo, iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, daRPCInfo, iconRPC);
			}
			#end
			scripts.executeFunc("onGameResumed", []);
		}

		super.closeSubState();
	}

	var dotheThing:Bool = false;
	var imhungry:Bool = false;

	function doXPosNoteMove()
	{
		var thee = (Conductor.songPosition / 1000) * (Conductor.bpm / 60);
		if (imhungry)
			for (i in 0...4)
				playerStrums.members[i].x = playerStrums.members[i].x + (Math.sin((thee / 2) * 3.14));

		if (imhungry)
			for (e in 0...4)
				p2Strums.members[e].x = p2Strums.members[e].x + (Math.sin((thee / 2) * 3.14));
	}

	function doSwagNoteTests()
	{
		var the = (Conductor.songPosition / 1000) * (Conductor.bpm / 60);
		if (dotheThing)
			for (i in 0...4)
				playerStrums.members[i].y = playerStrums.members[i].y + (Math.cos((the / 2) * 3.14));

		if (dotheThing)
			for (e in 0...4)
				p2Strums.members[e].y = p2Strums.members[e].y + (Math.cos((the / 2) * 3.14));
	}

	public static function addNewTraceKey(key:Dynamic)
	{
		GameLog.log(key);
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused && CDevConfig.saveData.autoPause)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, daRPCInfo, iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
		}
		#end

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if desktop
		if (CDevConfig.saveData.autoPause)
		{
			if (health > 0 && !paused)
			{
				if (Main.discordRPC)
					DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if (FlxG.sound.music != null)
		{
			vocals.pause();
			// vocals_opponent.pause();

			FlxG.sound.music.play();
			Conductor.songPosition = FlxG.sound.music.time;
			vocals.time = Conductor.songPosition;
			// vocals_opponent.time = Conductor.songPosition;
			vocals.play();

			updateSongPitch();
		}
	}

	/**Updates the Inst and Voices pitch.**/
	public function updateSongPitch()
	{
		CDevConfig.utils.setSoundPitch(FlxG.sound.music, songSpeed);
		if (vocals != null && vocals.playing)
			CDevConfig.utils.setSoundPitch(vocals, songSpeed);
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = false;
	var crap:Float = 0;
	var p1Lerp:Float;
	var p2Lerp:Float;
	var bgL:Bool = false;
	var songStarted = false;

	// ugh
	var elapsedTimeShit:Float = 0;

	// stress
	var prevFolLerp:Float = 0;
	var isHug:Bool = false;

	var timeShit:Float = 0;
	var timeS:Float = 0;

	var followhuh:Bool = false;
	var xfp:Float = 0;
	var yfp:Float = 0;

	var offsetX:Float = 0;

	var pressed:Bool = false;

	override public function update(elapsed:Float)
	{
		scripts.executeFunc('update', [elapsed]);

		switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
			case 'tank':
				if (songStarted)
					moveTank(elapsed);
		}

		songCutsceneFunction(elapsed);

		if (FlxG.sound.music.playing) updateSongPitch();

		super.update(elapsed);
		if (generatedMusic && !endingSong) {
			if ((songStarted && FlxG.sound.music.time > FlxG.sound.music.length - 100) ||
				(startedCountdown && canPause && FlxG.sound.music.length - Conductor.songPosition <= 20)) {
				endSong();
			}
		}

		updateUITexts(elapsed);

		if (!inCutscene && controls.PAUSE && startedCountdown && canPause) pauseGame();

		iconUpdateFunction(elapsed); 
		cdevTestMode(elapsed);
		editorsHandler();
		conductorUpdate(elapsed);

		ratingUpdate(elapsed);
		beatBasedEvents();
		deathHandler();

		notesUpdateFunction();
		cameraFunctions(elapsed);

		if (!inCutscene) {
			songEventHandler();
			keyShit();
		}

		if (isModStage)
			stageHandler.onUpdate(elapsed);

		scripts.executeFunc('postUpdate', [elapsed]);
	}

	/**Used for updating the Conductor class.**/
	public function conductorUpdate(elapsed:Float){
		FlxAnimationController.animSpeed = songSpeed;
		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += (FlxG.elapsed * 1000) * songSpeed;
				Conductor.rawTime = Conductor.songPosition;
				if (Conductor.songPosition >= 0 + Conductor.offset)
				{
					startSong();
					if (songSpeed != 1)
					{
						for (i in members)
						{
							if (Std.isOfType(i, FlxSprite))
							{
								if (i != null)
								{
									var spr = cast(i, FlxSprite);
									if (spr.animation != null)
										spr.animation.useAnimSpeed = true;
								}
							}
						}
					}
				}
			}
		}
		else
		{
			Conductor.songPosition += (FlxG.elapsed * 1000) * songSpeed;
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.rawTime = FlxG.sound.music.time;
			if (!paused)
			{
				// Conductor.songPosition = FlxG.sound.music.time;
				songPosBG.visible = false;
				songPosBGspr.visible = CDevConfig.saveData.songtime;
				songName.visible = CDevConfig.saveData.songtime;
				songPosBar.visible = CDevConfig.saveData.songtime;

				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}

				if (CDevConfig.saveData.songtime)
				{
					songPercent = SongPosition.getSongPercent(FlxG.sound.music.time, FlxG.sound.music.length);
					songName.text = SONG.song
						+ ' '
						+ "("
						+ SongPosition.getSongDuration(FlxG.sound.music.time, FlxG.sound.music.length)
						+ ")";
					songName.screenCenter(X);
				}
			}
		}
	}
	public var isDead:Bool = false;
	/**Function that handles the death of your character (evil)**/
	public function deathHandler(){
		if (movingEditor) return;

		if (!inCutscene && controls.RESET && CDevConfig.saveData.resetButton)
			health = (playingLeftSide ? 2 : 0);

		if ((playingLeftSide ? (health >= 2) : (health <= 0)))
		{
			isDead = true;
			scripts.executeFunc("onGameOver", []);
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			var char:Character = (playingLeftSide ? dad : boyfriend);

			if (CDevConfig.utils.hasStateScript("GameOverSubstate"))
			{
				CDevConfig.utils.getSubStateScript(this, "GameOverSubstate", [char.getScreenPosition().x, char.getScreenPosition().y]);
			}
			else
			{
				openSubState(new meta.substates.GameOverSubstate(char.getScreenPosition().x, char.getScreenPosition().y));
			}

			#if desktop
			if (Main.discordRPC)
				DiscordClient.changePresence("Game Over - " + detailsText, daRPCInfo, iconRPC);
			#end
		}
	}

	public var movingEditor:Bool = false;
	/**Used for In-Game Editors, like switching the state to the Editor.**/
	public function editorsHandler() {
		if (isDead) return;
		if (enableEditors) {
			var pressingStuff:Array<Bool> = [FlxG.keys.justPressed.SIX, FlxG.keys.justPressed.EIGHT];
			var indexSONG:Array<String> = [SONG.player1, SONG.player2];
			var player:String = "bf";
			var playerIndex:Int = 1;
			for (index => press in pressingStuff)
			{
				if (press)
				{
					player = indexSONG[index];
					playerIndex = index + 1;
				}
			}
			if (pressingStuff.contains(true))
			{
				movingEditor = true;
				scripts.executeFunc('onStateLeaved', []);
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;
				FlxG.camera.zoom = 1;
				defaultCamZoom = 1;
				#if sys
				if (!FileSystem.exists(Paths.modChar(player)) && !FileSystem.exists(Paths.char(player)))
				{
					var butt:Array<PopUpButton> = [
						{
							text:"OK",
							callback:()->{
								FlxG.switchState(new CharacterEditor(true, true, playerIndex == 1));
							}
						}
					];
					var mes = "Can't find character json \""
						+ player
						+ ".json\"\nMake sure that the json file exists or create a new character on this engine's mod editor menu!";
					var eak = new CDevPopUp("Character Not Found", mes, butt, false, true);
					eak.cameras=[camHUD];
					openSubState(eak);
				}
				else
				{
				#end
					FlxG.switchState(new CharacterEditor(true, false, playerIndex == 1));
				#if sys
				}
				#end
			}
			if (FlxG.keys.justPressed.SEVEN)
			{
				movingEditor = true;
				canPause = false;
				scripts.executeFunc('onStateLeaved', []);
				songSpeed = 1.0;
				FlxG.sound.music.pause();
				vocals.pause();

				chartingMode = true;
				if (FlxG.keys.pressed.SHIFT)
					FlxG.switchState(new meta.modding.chart_editor.ChartEditor(SONG));
				else
					FlxG.switchState(new meta.modding.chart_editor.ChartingState());

				#if desktop
				if (Main.discordRPC)
					DiscordClient.changePresence("Chart Editor", null, null, true);
				#end
			}
		}
	}

	/**This function used to update texts such as scoreTxt and botplayTxt**/
	public function updateUITexts(elapsed:Float)
	{
		ratingText = RatingsCheck.getRating(accuracy)
			+ " ("
			+ RatingsCheck.getRatingText(accuracy)
			+ (accuracy == 0 ? ')' : ", " + RatingsCheck.getRankText() + ")");

		var scoreText:String = '${config.scoreText}: $songScore' + (CDevConfig.saveData.botplay ? " (Botplay)" : "");
		if (CDevConfig.saveData.fullinfo)
		{
			scoreText = '${config.missesText}: $misses $scoreTxtDiv '
				+ // MISSES
				'${config.scoreText}: $songScore $scoreTxtDiv '
				+ // SCORE
				'${config.accuracyText}: ${RatingsCheck.fixFloat(accuracy, 2)}% (${(CDevConfig.saveData.botplay ? "Botplay" : ratingText)})'
				+ // ACCURACY
				(CDevConfig.saveData.healthCounter ? ' $scoreTxtDiv Health: ${Math.floor(healthBarPercent)}%' : ''); // HEALTH
		}
		scoreTxt.text = scoreText;

		//RPC Related stuff
		daRPCInfo = '${config.scoreText}: ' + songScore + " | " + '${config.missesText}: ' + misses + ' | ' + '${config.accuracyText}: '
			+ RatingsCheck.fixFloat(accuracy, 2) + "% (" + ratingText + ')';
		if (songStarted) DiscordClient.changePresence(detailsText, (CDevConfig.saveData.botplay ? "Botplay" : daRPCInfo), iconRPC, true, songLength - Conductor.songPosition);

		bgScore.setGraphicSize(Std.int(((scoreTxt.size * 0.59) * scoreTxt.text.length) + 3), Std.int(scoreTxt.height + 3));
		bgScore.screenCenter(X);
		bgScore.y = scoreTxt.y - 2;
		bgScore.alpha = scoreTxt.alpha * 0.3;
		bgScore.updateHitbox();
		bgScore.visible = scoreTxt.visible;

		botplayTxt.screenCenter(X);
		botplayTxt.alpha = 0;

		if (songStarted && FlxG.sound.music.playing)
		{
			if (CDevConfig.saveData.botplay)
			{
				crap += SONG.bpm * elapsed;
				botplayTxt.alpha = Math.abs(Math.sin((Conductor.songPosition / 1000) * (Conductor.bpm / 60)));
			}
		}

		if (CDevConfig.saveData.botplay){
			bpsl = FlxMath.lerp(1, botplayTxt.scale.x, CDevConfig.utils.bound(1 - (elapsed * 9 * songSpeed), 0, 1));
			botplayTxt.scale.set(bpsl, bpsl);
		}
	}

	public function pauseGame()
	{
		#if desktop
		if (Main.discordRPC)
			DiscordClient.changePresence(detailsPausedText, daRPCInfo, iconRPC);
		#end
		scripts.executeFunc('onGamePaused', []);
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		if (CDevConfig.utils.hasStateScript("PauseSubState"))
		{
			CDevConfig.utils.getSubStateScript(this, "PauseSubState", [boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y]);
		}
		else
		{
			openSubState(new meta.substates.PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}
	}

	var bpsl:Float; // botplay scale lerp;
	var healthBarPercent:Float = 50;

	/**Icons update function, positioning and scaling**/
	function iconUpdateFunction(elapsed:Float)
	{
		var lerpTime:Float = CDevConfig.utils.bound(1 - (elapsed * 9) * songSpeed, 0, 1);

		p1Lerp = FlxMath.roundDecimal(FlxMath.lerp(1, iconP1.scale.x, lerpTime), 3);
		p2Lerp = FlxMath.roundDecimal(FlxMath.lerp(1, iconP2.scale.x, lerpTime), 3);

		iconP1.scale.set(p1Lerp, p1Lerp);
		iconP2.scale.set(p2Lerp, p2Lerp);

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 5;

		healthBarPercent = FlxMath.lerp(healthBar.percent, healthBarPercent, CDevConfig.utils.bound(1 - (elapsed * 15), 0, 1));
		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBarPercent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBarPercent, 0, 100, 100, 0) * 0.01)) - 150 + iconOffset;

		iconP1.y = healthBar.y - 70;
		iconP2.y = healthBar.y - 70;

		healthLerp = FlxMath.lerp(health, healthLerp, CDevConfig.utils.bound(1 - (elapsed * 15), 0, 1));

		if ((!playingLeftSide ? health > 2 : health < 0)) health = (!playingLeftSide ? 2 : 0);
		
		var hbp = healthBarPercent; //short
		var curP1Icon:Int = (hbp > 80 ? (iconP1.hasWinningIcon ? 2 : 0) : (hbp < 20 ? 1 : 0));
		var curP2Icon:Int = (hbp < 20 ? (iconP2.hasWinningIcon ? 2 : 0) : (hbp > 80 ? 1 : 0));

		iconP1.changeFrame(curP1Icon);
		iconP2.changeFrame(curP2Icon);
	}

	/**Base Game Cutscene's update function.**/
	function songCutsceneFunction(elapsed:Float)
	{
		if (isStoryMode)
		{
			if (inCutscene)
			{
				switch (SONG.song.toLowerCase())
				{
					case 'ugh':
						if (tankmanSprite != null)
						{
							switch (animPhase)
							{
								case 0:
									if (tankmanSprite.animation.curAnim == null)
									{
										tankmanSprite.animation.play("talk");
										tankmanSprite.offset.set(tankmanSpriteOffset[0][0], tankmanSpriteOffset[0][1]);
										tankmanTalk1Audio.play();
										camFollow.setPosition(dad.getMidpoint().x + 150 + dad.charCamPos[0], dad.getMidpoint().y - 100 + dad.charCamPos[1]);
									}
									if (tankmanSprite.animation.curAnim.finished) animPhase++;
								case 1:
									elapsedTimeShit += elapsed;
									camFollow.setPosition(boyfriend.getMidpoint().x - 100 + boyfriend.charCamPos[0],
										boyfriend.getMidpoint().y - 100 + boyfriend.charCamPos[1]);
									if (elapsedTimeShit > 1)
									{
										bfBeep.play();
										boyfriend.playAnim("singUP");
										elapsedTimeShit = 0;
										animPhase++;
									}
								case 2:
									elapsedTimeShit += elapsed;
									if (!bfBeep.playing)
									{
										boyfriend.playAnim("idle");
										elapsedTimeShit = 0;
										animPhase++;
									}
								case 3:
									elapsedTimeShit += elapsed;
									if (elapsedTimeShit > 1)
									{
										elapsedTimeShit = 0;
										animPhase++;
										tankmanSprite.animation.curAnim = null;
									}
								case 4:
									if (tankmanSprite.animation.curAnim == null)
									{
										tankmanSprite.animation.play("talkk");
										tankmanSprite.offset.set(tankmanSpriteOffset[1][0], tankmanSpriteOffset[1][1]);
										tankmanTalk2Audio.play();
										camFollow.setPosition(dad.getMidpoint().x + 150 + dad.charCamPos[0], dad.getMidpoint().y - 100 + dad.charCamPos[0]);
									}
									if (tankmanSprite.animation.curAnim.finished)
									{
										animPhase++;
									}
								case 5:
									distorto.fadeOut(0.5, 0, function(aa:FlxTween)
									{
										distorto.stop();
										distorto.destroy();
									});
									defaultCamZoom = prevCamZoom;

									startCountdown();

									dad.visible = true;
									remove(tankmanSprite);
									tankmanSprite.destroy();

									bfBeep.destroy();
									// done
							}
						}
					case 'guns':
						camFollow.setPosition(dad.getMidpoint().x + 150 + dad.charCamPos[0], PlayState.dad.getMidpoint().y - 100 + dad.charCamPos[1]);
						tankmanSprite.animation.curAnim.curFrame = Std.int(tankmanTalkAudio.time / tankmanTalkAudio.length * tankmanSprite.animation.curAnim.frames.length);

						if (tankmanTalkAudio.time > 4150)
						{
							gf.playAnim("sad");
							FlxG.camera.zoom = defaultCamZoom
								+ (Math.sin(FlxEase.quartOut(FlxMath.bound((tankmanTalkAudio.time - 4150) / 1500, 0, 1)) * Math.PI) * 0.1);
						}
						if (tankmanSprite.animation.curAnim.finished || !tankmanTalkAudio.playing)
						{
							remove(tankmanSprite);
							tankmanSprite.destroy();
							distorto.fadeOut(0.5, 0, function(aa:FlxTween)
							{
								distorto.stop();
								distorto.destroy();
							});
							defaultCamZoom = prevCamZoom;
							dad.visible = true;
							startCountdown();
						}
					case 'stress':
						// cam
						if (audio.time < 14750)
						{
							camFollow.setPosition(dad.getMidpoint().x + 150 + dad.charCamPos[0], dad.getMidpoint().y - 100 + dad.charCamPos[1]);
						}
						else if (audio.time < 17237)
						{
							var t = (audio.time - 14750) / (17237 - 14750);
							var gfCamPos = gf.getMidpoint();
							camFollow.setPosition(gfCamPos.x - 100, gfCamPos.y);
							FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, 1.25, FlxEase.quadInOut(t));
						}
						else if (audio.time < 20000)
						{
							defaultCamZoom = prevCamZoom;
							FlxG.camera.zoom = prevCamZoom;
						}
						else if (audio.time < 31250)
						{
							camFollow.setPosition(dad.getMidpoint().x + 150 + dad.charCamPos[0] + 200, dad.getMidpoint().y - 100 + dad.charCamPos[1]);
						}
						else if (audio.time < 32250)
						{
							foregroundSprites.forEach(function(spr:FlxSprite)
							{
								spr.visible = false;
							});
							boyfriend.playAnim("singUPmiss");
							camFollow.setPosition(boyfriend.getMidpoint().x, boyfriend.getMidpoint().y);
							if (prevFolLerp == 0)
							{
								prevFolLerp = FlxG.camera.followLerp;
								FlxG.camera.followLerp = 1;
							}
							FlxG.camera.zoom = 1.25;
						}
						else
						{
							foregroundSprites.forEach(function(spr:FlxSprite)
							{
								spr.visible = true;
							});
							boyfriend.dance();
							boyfriend.animation.curAnim.curFrame = boyfriend.animation.curAnim.frames.length - 1;

							FlxG.camera.followLerp = 1;
							camFollow.setPosition(dad.getMidpoint().x + 150 + dad.charCamPos[0] + 200, dad.getMidpoint().y - 100 + dad.charCamPos[1]);
							FlxG.camera.zoom = defaultCamZoom;
						}

						if (audio.playing)
						{
							if (audio.time > 21248)
							{
								ggf.visible = false;
								gfTurn1.visible = false;
								gfTurn2.visible = false;
								gfTurn3.visible = false;
								gfTurn4.visible = false;
								gfTurn5.visible = false;

								gf.visible = true;
								gf.dance();
							}
							else if (audio.time > 19620)
							{
								ggf.visible = false;
								gfTurn1.visible = false;
								gfTurn2.visible = false;
								gfTurn3.visible = false;
								gfTurn4.visible = false;
								gfTurn5.visible = true;

								var t = audio.time - 19620;
								gfTurn5.animation.curAnim.curFrame = Std.int(t / (21248 - 19620) * gfTurn5.animation.curAnim.frames.length);
							}
							else if (audio.time > 18245)
							{
								ggf.visible = false;
								gfTurn1.visible = false;
								gfTurn2.visible = false;
								gfTurn3.visible = false;
								gfTurn4.visible = true;
								gfTurn5.visible = false;

								var t = audio.time - 18245;
								gfTurn4.animation.curAnim.curFrame = Std.int(t / (19620 - 18245) * 32);
							}
							else if (audio.time > 17237)
							{
								ggf.visible = false;
								gfTurn1.visible = false;
								gfTurn2.visible = false;
								gfTurn3.visible = true;
								gfTurn4.visible = false;
								gfTurn5.visible = false;
								bf.visible = false;
								boyfriend.visible = true;
								if (isHug)
								{
									boyfriend.playAnim("bfCatch");
									isHug = false;
								}
								else
								{
									if (boyfriend.animation.curAnim.finished)
									{
										boyfriend.holdTimer = 20000;
										boyfriend.dance();
										boyfriend.animation.curAnim.curFrame = boyfriend.animation.curAnim.frames.length - 1;
									}
								}

								var t = audio.time - 17237;
								gfTurn3.animation.curAnim.curFrame = Std.int(t / (18245 - 17237) * gfTurn3.animation.curAnim.frames.length);
							}
							else if (audio.time > 16284)
							{
								ggf.visible = false;
								gfTurn1.visible = false;
								gfTurn2.visible = true;
								gfTurn3.visible = false;
								gfTurn4.visible = false;
								gfTurn5.visible = false;

								var t = audio.time - 16284;
								gfTurn2.animation.curAnim.curFrame = Std.int(t / (17237 - 16284) * gfTurn2.animation.curAnim.frames.length);
							}
							else if (audio.time > 14750)
							{
								ggf.visible = false;
								gfTurn1.visible = true;
								gfTurn2.visible = false;
								gfTurn3.visible = false;
								gfTurn4.visible = false;
								gfTurn5.visible = false;

								var t = audio.time - 14750;
								gfTurn1.animation.curAnim.curFrame = Std.int(t / (16284 - 14750) * gfTurn1.animation.curAnim.frames.length);
							}
							else
							{
								ggf.visible = true;
								gfTurn1.visible = false;
								gfTurn2.visible = false;
								gfTurn3.visible = false;
								gfTurn4.visible = false;
								gfTurn5.visible = false;
							}
						}

						// takn
						if (audio.time < 17042)
						{
							tankmanTalk1.visible = true;
							tankmanTalk2.visible = false;
							tankmanTalk1.animation.curAnim.curFrame = Std.int(audio.time / 17042 * tankmanTalk1.animation.curAnim.frames.length);
						}
						else
						{
							if (audio.time > 19250)
							{
								tankmanTalk1.visible = false;
								tankmanTalk2.visible = true;
								tankmanTalk2.animation.curAnim.curFrame = Std.int((audio.time - 19250) / (361 / 24 * 1000) * tankmanTalk2.animation.curAnim.frames.length);
							}
						}

						if (!audio.playing)
						{
							audio.destroy();
							gf.visible = true;
							dad.visible = true;

							var itemToDelete = [tankmanTalk1, tankmanTalk2, gfTurn1, gfTurn2, gfTurn3, gfTurn4, gfTurn5, ggf];
							for (i in itemToDelete)
							{
								remove(i);
								i.destroy();
							}
							cleanCache();
							FlxG.camera.followLerp = prevFolLerp;
							startCountdown();
						}
					default:
						switch (currentCutscene)
						{
							case "intro":
								if (intro_cutscene_script != null)
								{
									intro_cutscene_script.executeFunc("update", [elapsed]);
								}
							case "outro":
								if (outro_cutscene_script != null)
								{
									outro_cutscene_script.executeFunc("update", [elapsed]);
								}
						}
				}
			}
		}
		else
		{
			switch (currentCutscene)
			{
				case "intro":
					if (intro_cutscene_script != null)
					{
						if (intro_cutscene_script.getVariable("runOnFreeplay") == true)
							intro_cutscene_script.executeFunc("update", [elapsed]);
					}
				case "outro":
					if (outro_cutscene_script != null)
					{
						if (outro_cutscene_script.getVariable("runOnFreeplay") == true)
							outro_cutscene_script.executeFunc("update", [elapsed]);
					}
			}
		}
	}

	function ratingUpdate(elapsed:Float)
	{
		timeShit += elapsed;
		if (timeShit > 1)
			judgementText.alpha = FlxMath.lerp(0, judgementText.alpha, CDevConfig.utils.bound(1 - (elapsed * 4), 0, 1));

		var theJudgeScale:Float = FlxMath.lerp(1, judgementText.scale.x, CDevConfig.utils.bound(1 - (elapsed * 12), 0, 1));
		judgementText.scale.set(theJudgeScale, theJudgeScale);

		if (sRating == null)
			return;

		timeS += elapsed;
		sRating.y = FlxMath.lerp(ratingPosition.y, sRating.y, CDevConfig.utils.bound(1 - (elapsed * 12), 0, 1));

		if (timeS > Conductor.crochet * 0.001)
			sRating.alpha = FlxMath.lerp(0, sRating.alpha, CDevConfig.utils.bound(1 - (elapsed * 6), 0, 1));

		numGroup.forEachAlive(function(spr:FlxSprite)
		{
			spr.x = comboPosition.x + (43 * spr.ID);
			spr.y = FlxMath.lerp(comboPosition.y, spr.y, CDevConfig.utils.bound(1 - (elapsed * 12), 0, 1));

			if (timeS > Conductor.crochet * 0.001)
				spr.alpha = FlxMath.lerp(0, spr.alpha, CDevConfig.utils.bound(1 - (elapsed * 6), 0, 1));
		});
	}

	/**This function used for CDEV Engine's Test Mode features.**/
	function cdevTestMode(elapsed:Float)
	{
		if (CDevConfig.saveData.testMode)
		{
			if (FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.T) // Go to 10 seconds into the future, credit: Shadow Mario#9396
			{
				FlxG.sound.music.pause();
				vocals.pause();
				// vocals_opponent.pause();
				Conductor.songPosition += 10000;
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.strumTime + 800 < Conductor.songPosition)
					{
						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
				for (i in 0...unspawnNotes.length)
				{
					var daNote:Note = unspawnNotes[0];
					if (daNote.strumTime + 800 >= Conductor.songPosition)
					{
						break;
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					unspawnNotes.splice(unspawnNotes.indexOf(daNote), 1);
					daNote.destroy();
				}

				FlxG.sound.music.time = Conductor.songPosition;
				FlxG.sound.music.play();

				vocals.time = Conductor.songPosition;
				vocals.play();

				// vocals_opponent.time = Conductor.songPosition;
				// vocals_opponent.play();
			}

			// instantly end the song
			if (FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.ALT && FlxG.keys.justPressed.ONE)
				endSong();

			// hide / show the main camera
			if (FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.ALT && FlxG.keys.justPressed.C)
				FlxG.camera.visible = !FlxG.camera.visible;

			// hide / show the hud camera
			if (FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.ALT && FlxG.keys.justPressed.P)
				camHUD.visible = !camHUD.visible;

			// note shits
			if (FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.ALT && FlxG.keys.justPressed.N)
				dotheThing = !dotheThing;

			// note shits
			if (FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.ALT && FlxG.keys.justPressed.NUMPADEIGHT)
				imhungry = !imhungry;

			// helth
			if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.H)
				health = 0.7;

			// increase your combo
			if (FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.M)
				combo += 1;

			// increase your misses
			if (FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.N)
				misses += 1;

			// toggle/disable botplay
			if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.B)
			{
				CDevConfig.saveData.botplay = !CDevConfig.saveData.botplay;
			}

			// instant crash the game
			if (FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.ALT && FlxG.keys.justPressed.SPACE)
			{
				trace("crashing the game");
				var b:BitmapData = null;
				b.clone();
			}

			// pause stuff
			if (FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.ENTER)
			{
				pauseGame();
			}

			doSwagNoteTests();
			doXPosNoteMove();

			for (strum in playerStrums.members)
			{
				var add:Float = (strum.noteScroll < -1 ? 0 : -elapsed);
				if (FlxG.keys.pressed.FOUR)
					strum.noteScroll += add;
				var adad:Float = (strum.noteScroll >= 1 ? 0 : elapsed);
				if (FlxG.keys.pressed.FIVE)
					strum.noteScroll += adad;

				if (FlxG.keys.pressed.NUMPADEIGHT)
					strum.y -= 1;
				if (FlxG.keys.pressed.NUMPADFOUR)
					strum.x -= 1;
				if (FlxG.keys.pressed.NUMPADTWO)
					strum.y += 1;
				if (FlxG.keys.pressed.NUMPADSIX)
					strum.x += 1;
			}

			for (strum in p2Strums.members)
			{
				var add:Float = (strum.noteScroll < -1 ? 0 : -elapsed);
				if (FlxG.keys.pressed.FOUR)
					strum.noteScroll += add;
				var adad:Float = (strum.noteScroll >= 1 ? 0 : elapsed);
				if (FlxG.keys.pressed.FIVE)
					strum.noteScroll += adad;

				if (FlxG.keys.pressed.NUMPADEIGHT)
					strum.y -= 1;
				if (FlxG.keys.pressed.NUMPADFOUR)
					strum.x -= 1;
				if (FlxG.keys.pressed.NUMPADTWO)
					strum.y += 1;
				if (FlxG.keys.pressed.NUMPADSIX)
					strum.x += 1;
			}
		}
	}

	/** Notes Object update function, like determining the X and Y position of that note. **/
	function notesUpdateFunction()
	{
		bgNoteLane.visible = (CDevConfig.saveData.bgLane && CDevConfig.saveData.middlescroll);
		if (CDevConfig.saveData.middlescroll)
		{
			for (i in 0...p2Strums.length)
			{
				p2Strums.members[i].visible = false;
			}
		}

		if (unspawnNotes[0] != null)
		{
			var daTime:Float = 1500;

			var speed:Float = 0; // FlxMath.roundDecimal((scrSpd >= 1 || scrSpd < 1 ? scrSpd : SONG.speed));

			if (scrSpd >= 1 || scrSpd < 1)
				speed = FlxMath.roundDecimal(scrSpd, 2);
			else
				speed = FlxMath.roundDecimal(SONG.speed, 2);

			if (speed < 1)
				daTime /= speed;

			while (unspawnNotes.length > 0
				&& unspawnNotes[0].strumTime - Conductor.songPosition < daTime * (songSpeed == 1 ? 1 : songSpeed))
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);
				dunceNote.onNoteSpawn();

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				// check where the note is right now to see if it's active or not
				var noteValid:Bool = (CDevConfig.saveData.downscroll ? ((Conductor.songPosition - Conductor.safeZoneOffset) > daNote.strumTime
					+ (Conductor.crochet / 4)) : daNote.strumTime < (Conductor.songPosition - Conductor.safeZoneOffset));

				daNote.active = !noteValid;
				daNote.visible = !noteValid;

				if (!CDevConfig.saveData.middlescroll)
				{
					if (daNote.followX)
						daNote.x = (daNote.mustPress ? playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x : p2Strums.members[Math.floor(Math.abs(daNote.noteData))].x);
				}
				else
					daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;

				if (daNote.followX)
				{
					if (daNote.isSustainNote)
						daNote.x += daNote.width / 2 + (daNote.isPixelSkinNote ? 20 : 15);
				}

				if (!daNote.mustPress && CDevConfig.saveData.middlescroll)
					daNote.alpha = (CDevConfig.saveData.bgNote ? 0.07 : 0);

				var strum:StrumArrow = daNote.mustPress ? playerStrums.members[daNote.noteData] : p2Strums.members[daNote.noteData];

				if (!CDevConfig.saveData.middlescroll)
				{
					if (daNote.followAlpha)
					{
						daNote.alpha = strum.alpha;
						if (daNote.isSustainNote)
						{
							daNote.alpha = strum.alpha * 0.6;
						}
					}
				}

				if (daNote.followAngle)
				{
					if (!daNote.isSustainNote)
						daNote.angle = strum.angle;
				}

				// fixing this since the last code was ass (tbh this one also ass)
				var currentSongTime:Float = Conductor.songPosition;
				var noteDiff:Float = (currentSongTime - daNote.strumTime);
				var noteScroll:Float = (strum.noteScroll - strum.noteScroll * (2)); // used for up & down scroll
				var noteSpeed:Float = (FlxMath.roundDecimal(scrSpd == 1 ? SONG.speed * noteScroll : scrSpd * noteScroll, 2)); // note speed

				// NOTE CHECK STUFFS
				var checkStrumTime:Bool = ((Conductor.songPosition - RatingsCheck.theTimingWindow[0]) > daNote.strumTime + (Conductor.crochet / 4));
				if (checkStrumTime && !CDevConfig.saveData.botplay)
					daNote.tooLate = true;
				else if (checkStrumTime && CDevConfig.saveData.botplay)
					goodNoteHit(daNote);

				daNote.y = (strum.y + 0.45 * noteDiff * noteSpeed) - daNote.noteYOffset;

				if (daNote.isSustainNote)
				{
					// you don't know how much i hate this line of codes.
					// this took me AGES to finish.
					if (strum.noteScroll > 0)
						if ((daNote.animation.curAnim.name.endsWith('holdend')) && (daNote.prevNote != null))
						{
							daNote.y += (daNote.prevNote.height + (daNote.height / 2)) / 2;
							daNote.y -= (daNote.prevNote.height / 2);
							daNote.y += (daNote.prevNote.height) / noteSpeed;
							daNote.y += (daNote.height) / noteSpeed;
						}
						else
						{
							daNote.y -= (daNote.height / 2);
							daNote.y += (daNote.height) / noteSpeed;
						}
					else
					{
						if ((daNote.animation.curAnim.name.endsWith('holdend')) && (daNote.prevNote != null))
						{
							daNote.y += (daNote.prevNote.height) - (daNote.height / 2);
							daNote.y += (daNote.prevNote.height / 2);
							daNote.y -= daNote.height / noteSpeed;
						}
					}

					// this:
					// https://cdn.discordapp.com/attachments/1172878696844111892/1187717373675974706/image.png?ex=6597e700&is=65857200&hm=9bc44e18aefffdeb9f4d3cc233b5b5c936ef4057a771750f1544d97648b77508&
					daNote.flipY = (strum.noteScroll < 0);

					StrumArrow.checkRects(daNote, strum);
				}

				if (!daNote.mustPress && daNote.wasGoodHit && !daNote.canIgnore)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var animToPlay:String = singAnimationNames[daNote.noteData];
					var isAlt:Bool = false;
					var char:Character = (playingLeftSide ? boyfriend : dad);

					if (SONG.notes[Math.floor(curStep / 16)] != null)
						isAlt = (playingLeftSide ? SONG.notes[Math.floor(curStep / 16)].p1AltAnim : SONG.notes[Math.floor(curStep / 16)].altAnim);

					if (isAlt && char.animOffsets.exists(singAnimationNames[daNote.noteData] + char.singAltPrefix))
						animToPlay = singAnimationNames[daNote.noteData] + char.singAltPrefix;

					if (!isAlt
						&& daNote.noteType == "Alt Anim"
						&& char.animOffsets.exists(singAnimationNames[daNote.noteData] + char.singAltPrefix))
						animToPlay = singAnimationNames[daNote.noteData] + char.singAltPrefix;

					if (daNote.noteType == "GF Note")
					{
						char = gf;
					}
					if (!daNote.noAnim)
					{
						char.playAnim(animToPlay, true);
						char.holdTimer = 0;
					}
					p2Strums.forEach(function(spr:StrumArrow)
					{
						if (Math.abs(daNote.noteData) == spr.ID)
						{
							spr.playAnim('confirm', true);
						}
					});

					if (SONG.needsVoices)
						vocals.volume = 1;

					daNote.onNoteHit(daNote.rating, false);
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();

					var funct:String = "onP2Hit";
					scripts.executeFunc(funct, [daNote]);

					// we do some changes here.
					// if (playingLeftSide)
					//	scripts.executeFunc('p1NoteHit', [daNote.noteData, daNote.isSustainNote]);
					// else
					scripts.executeFunc('p2NoteHit', [daNote.noteData, daNote.isSustainNote]);
				}

				if ((daNote.mustPress && daNote.tooLate && !CDevConfig.saveData.downscroll || daNote.mustPress && daNote.tooLate
					&& CDevConfig.saveData.downscroll)
					&& daNote.mustPress)
				{
					if (daNote.isSustainNote && daNote.wasGoodHit)
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
					else
					{
						// health -= 0.075;
						if (!daNote.canIgnore)
						{
							vocals.volume = 0;

							daNote.onNoteMiss();
							noteMiss(daNote.noteData);
						}
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}

		p2Strums.forEach(function(spr:StrumArrow)
		{
			if (spr.animation.finished)
			{
				spr.playAnim('static', false);
			}
		});
	}

	/** Used for panning the camera of current player (based on MustHitSection) **/
	function cameraFunctions(elapsed:Float)
	{
		if (!forceCameraPos)
			mustHitCamera();
		else
			camFollow.setPosition(camPosForced[0], camPosForced[1]);

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CDevConfig.utils.bound(1 - (elapsed * 4 * songSpeed), 0, 1));
			camHUD.zoom = FlxMath.lerp(defaultHudZoom, camHUD.zoom, CDevConfig.utils.bound(1 - (elapsed * 4 * songSpeed), 0, 1));
		}

		if (generatedMusic && PlayState.SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (!PlayState.SONG.notes[Math.floor(curStep / 16)].mustHitSection)
			{
				if ((dad.animation.curAnim != null)
					&& (dad.animation.curAnim.name == 'idle'
						|| dad.animation.curAnim.name == 'danceLeft'
						|| dad.animation.curAnim.name == 'danceRight'))
				{
					dadCamX = 0;
					dadCamY = 0;
				}
			}
			if (PlayState.SONG.notes[Math.floor(curStep / 16)].mustHitSection)
			{
				if ((boyfriend.animation.curAnim != null)
					&& (boyfriend.animation.curAnim.name == 'idle'
						|| boyfriend.animation.curAnim.name == 'danceLeft'
						|| boyfriend.animation.curAnim.name == 'danceRight'))
				{
					bfCamX = 0;
					bfCamY = 0;
				}
			}
			if (!PlayState.SONG.notes[Math.floor(curStep / 16)].mustHitSection)
			{
				if (dad.curCharacter == 'mom')
					vocals.volume = 1;

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					tweenCamIn();
				}
			}

			if (PlayState.SONG.notes[Math.floor(curStep / 16)].mustHitSection)
			{
				if (SONG.song.toLowerCase() == 'tutorial')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
				}
			}
		}
	}

	var gunsBanger:Bool = false;

	/**Used for a beat-specific events that are hardcoded to the engine.**/
	function beatBasedEvents()
	{
		if (generatedMusic)
		{
			switch (SONG.song.toLowerCase())
			{
				case 'guns':
					{
						if (gunsBanger)
						{
							// FlxG.camera.angle = Math.sin((game.Conductor.songPosition / 1000) * (game.Conductor.bpm / 60) * -1.0) * 2;
							camHUD.angle = Math.sin((game.Conductor.songPosition / 1000) * (game.Conductor.bpm / 60) * -1.0) * 0.5;

							cameraPosition.y = Math.sin((game.Conductor.songPosition / 1000) * (game.Conductor.bpm / 60) * -1.0) * 24;
						}
					}
				case 'philly':
					{
						if (curBeat < 250)
						{
							if (curBeat != 184 && curBeat != 216)
							{
								if (curBeat % 16 == 8)
								{
									if (!cheeringBF)
									{
										gf.playAnim('cheer', true);
										cheeringBF = true;
									}
								}
								else
									cheeringBF = false;
							}
						}
					}
				case 'bopeebo':
					{
						if (curBeat > 5 && curBeat < 130)
						{
							if (curBeat % 8 == 7)
							{
								if (!cheeringBF)
								{
									gf.playAnim('cheer', true);
									cheeringBF = true;
								}
							}
							else
								cheeringBF = false;
						}
					}
				case 'blammed':
					{
						if (curBeat > 30 && curBeat < 190)
						{
							if (curBeat < 90 || curBeat > 128)
							{
								if (curBeat % 4 == 2)
								{
									if (!cheeringBF)
									{
										gf.playAnim('cheer', true);
										cheeringBF = true;
									}
								}
								else
									cheeringBF = false;
							}
						}
					}
				case 'cocoa':
					{
						if (curBeat < 170)
						{
							if (curBeat < 65 || curBeat > 130 && curBeat < 145)
							{
								if (curBeat % 16 == 15)
								{
									if (!cheeringBF)
									{
										gf.playAnim('cheer', true);
										cheeringBF = true;
									}
								}
								else
									cheeringBF = false;
							}
						}
					}
				case 'eggnog':
					{
						if (curBeat > 10 && curBeat != 111 && curBeat < 220)
						{
							if (curBeat % 8 == 7)
							{
								if (!cheeringBF)
								{
									gf.playAnim('cheer', true);
									cheeringBF = true;
								}
							}
							else
								cheeringBF = false;
						}
					}
			}
		}

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
			}
		}
	}

	// stuff used for this thing
	public function getBaseGamePosition(mustSect:Bool):FlxPoint
	{
		var point:FlxPoint = new FlxPoint(0, 0);
		if (mustSect)
		{
			switch (curStage)
			{
				case 'limo':
					point.x = boyfriend.getMidpoint().x - 300;
					point.y = boyfriend.getMidpoint().y - 100;
				case 'mall':
					point.y = boyfriend.getMidpoint().y - 200;
					point.x = boyfriend.getMidpoint().x - 100;
				case 'school':
					point.x = boyfriend.getMidpoint().x - 200;
					point.y = boyfriend.getMidpoint().y - 200;
				case 'schoolEvil':
					point.x = boyfriend.getMidpoint().x - 200;
					point.y = boyfriend.getMidpoint().y - 200;
				default:
					point.x = boyfriend.getMidpoint().x - 100;
					point.y = boyfriend.getMidpoint().y - 100;
			}
		}
		else
		{
			switch (dad.curCharacter)
			{
				case 'mom':
					point.x = dad.getMidpoint().x + 150;
					point.y = dad.getMidpoint().y;
				case 'senpai':
					point.y = dad.getMidpoint().y - 430;
					point.x = dad.getMidpoint().x - 100;
				case 'senpai-angry':
					point.y = dad.getMidpoint().y - 430;
					point.x = dad.getMidpoint().x - 100;
				default:
					point.x = dad.getMidpoint().x + 150;
					point.y = dad.getMidpoint().y - 100;
			}
		}
		return point;
	}

	// tried my best
	function mustHitCamera()
	{
		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			var must:Bool = PlayState.SONG.notes[Math.floor(curStep / 16)].mustHitSection;
			var p:FlxPoint = getBaseGamePosition(must);
			var curPos:FlxPoint = new FlxPoint();
			var char:Character = (must ? boyfriend : dad);
			var offset = [(must ? bfCamX : dadCamX), (must ? bfCamY : dadCamY)];

			curPos.x = p.x + cameraPosition.x + offset[0];
			curPos.y = p.y + cameraPosition.y + offset[1];

			camFollow.setPosition(curPos.x, curPos.y);
			camFollow.x += (must ? -char.charCamPos[0] : char.charCamPos[0]);
			camFollow.y += char.charCamPos[1];
		}
	}

	function voice_panning()
	{
		// idk lmao
		// if (vocals.playing) vocals.proximity(bfCamXPos + boyfriend.charCamPos[0], bfCamYPos + boyfriend.charCamPos[1], camFollow,1200,true);
		// if (vocals_opponent.playing) vocals_opponent.proximity(dadCamXPos + dad.charCamPos[0], dadCamYPos + dad.charCamPos[1], camFollow,1200,true);
	}

	public function killnoteshit()
	{
		for (i in 0...unspawnNotes.length)
		{
			var daNote:Note = unspawnNotes[0];

			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			unspawnNotes.splice(unspawnNotes.indexOf(daNote), 1);
			daNote.destroy();
		}
	}

	public var songEnded:Bool = false;

	public function endSong():Void
	{
		if (!songEnded)
		{
			songEnded = true;
			scripts.executeFunc('onEndSong', []);
			canPause = false;
			FlxG.sound.music.volume = 0;
			vocals.volume = 0;
			vocals.kill();

			FlxG.sound.music.onComplete = null;
			if (SONG.validScore && !chartingMode)
			{
				#if !switch
				var val:Float = accuracy;
				if (Math.isNaN(val))
					val = 0;
				game.cdev.engineutils.Highscore.saveScore(SONG.song, songScore, storyDifficulty, val, Date.now());
				#end
			}

			if (!chartingMode)
			{
				if (isStoryMode)
				{
					campaignScore += songScore;

					storyPlaylist.remove(storyPlaylist[0]);

					if (storyPlaylist.length <= 0)
					{
						if (outro_cutscene_script != null)
						{
							outroCutscene(false, true);
						}
						else
						{
							switchAfterEnd(true);
						}
					}
					else
					{
						var difficulty:String = "-" + difficultyName;

						trace('LOADING NEXT SONG');
						trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

						switch (SONG.song.toLowerCase())
						{
							case 'eggnog':
								var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
									-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
								blackShit.scrollFactor.set();
								add(blackShit);
								camHUD.visible = false;

								FlxG.sound.play(Paths.sound('Lights_Shut_off'));
								FlxG.sound.music.stop();
								new FlxTimer().start(2, function(daTimer:FlxTimer)
								{
									FlxTransitionableState.skipNextTransIn = true;
									FlxTransitionableState.skipNextTransOut = true;
									prevCamFollow = camFollow;

									PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);

									LoadingState.loadAndSwitchState(new PlayState());
								});
							default:
								if (outro_cutscene_script != null)
								{
									outroCutscene(true, true);
								}
								else
								{
									nextSong();
								}
						}

						GameOverSubstate.resetDeathStatus();
					}
				}
				else
				{
					if (outro_cutscene_script != null)
					{
						outro_cutscene_script.executeFunc("init");
						if (outro_cutscene_script.getVariable("runOnFreeplay") == true)
							outroCutscene(false, false);
						else
							switchAfterEnd(false);
					}
					else
						switchAfterEnd(false);
				}
			}
			else
			{
				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;
				scripts.executeFunc('onStateLeaved', []);

				FlxG.switchState(new meta.modding.chart_editor.ChartingState());
				GameOverSubstate.resetDeathStatus();
			}
		}
	}

	function outroCutscene(next:Bool, story:Bool)
	{
		inCutscene = true;
		currentCutscene = "outro";
		outro_cutscene_script.setVariable("endSong", function()
		{
			inCutscene = false;
			outro_cutscene_script.executeFunc("outroEnd", []);
			outro_cutscene_script = null;
			if (next)
				nextSong();
			else
				switchAfterEnd(story);
		});

		outro_cutscene_script.executeFunc("outroStart", []);

		if (intro_cutscene_script != null)
			intro_cutscene_script.executeFunc("postOutro", []);
	}

	function switchAfterEnd(story:Bool)
	{
		scripts.executeFunc('onStateLeaved', []);
		if (story)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			FlxG.switchState(new StoryMenuState());

			if (SONG.validScore)
				game.cdev.engineutils.Highscore.saveWeekScore(weekName, campaignScore, storyDifficulty);

			FlxG.save.flush();
		}
		else
		{
			GameOverSubstate.resetDeathStatus();
			FlxG.switchState(new FreeplayState());
		}
		game.cdev.CDevMods.script_clearAll();
	}

	function nextSong()
	{
		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
		prevCamFollow = camFollow;

		PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + "-" + difficultyName, PlayState.storyPlaylist[0]);
		FlxG.sound.music.stop();

		LoadingState.loadAndSwitchState(new PlayState());
		game.cdev.CDevMods.script_clearAll();
	}

	function zoomIcon()
	{
		iconP1.scale.x += 0.3;
		iconP1.scale.y += 0.3;
		iconP1.updateHitbox();

		iconP2.scale.x += 0.3;
		iconP2.scale.y += 0.3;
		iconP2.updateHitbox();
	}

	var endingSong:Bool = false;

	var accuracyScore:Int = 0;

	public static function cleanCache()
	{
		openfl.Assets.cache.clear();
		FlxG.save.flush();
		Paths.destroyLoadedImages();
	}

	var toIgnoreEvents:Array<ChartEvent> = [];

	function songEventHandler()
	{
		for (i in 0...toDoEvents.length)
		{
			var daEvent:ChartEvent = toDoEvents[i];

			if (!toIgnoreEvents.contains(daEvent))
			{
				var nameShit:String = Std.string(daEvent.EVENT_NAME);
				var strum:Float = daEvent.time;
				var input1:String = Std.string(daEvent.value1);
				var input2:String = Std.string(daEvent.value2);

				if (strum < FlxG.sound.music.time)
				{
					executeEvents(daEvent, nameShit, input1, input2);
					toIgnoreEvents.push(daEvent);
				}
			}
		}
	}

	// also add your custom events here.
	public static function executeEvents(event:ChartEvent, nameShit:String, input1:String, input2:String)
	{
		if (eventNames.contains(nameShit))
		{
			switch (nameShit)
			{
				case 'Add Camera Zoom':
					if (CDevConfig.saveData.camZoom)
					{
						var fkinCam:String = input1.toLowerCase().trim();
						var fkinZoom:Float = (!Math.isNaN(Std.parseFloat(input2)) ? Std.parseFloat(input2) : 0.3);
						if (fkinCam == 'gamecam')
						{
							FlxG.camera.zoom += fkinZoom;
						}
						else if (fkinCam == 'hudcam')
						{
							camHUD.zoom += fkinZoom;
						}
						else
						{
							FlxG.camera.zoom += fkinZoom;
						}
					}

				case 'Force Camera Position':
					var posShit:Array<Float> = [Std.parseFloat(input1), Std.parseFloat(input2)];
					if (Math.isNaN(posShit[0]) || Math.isNaN(posShit[1]))
					{
						forceCameraPos = true;
						if (posShit[0] == 0 && posShit[1] == 0)
						{
							forceCameraPos = false;
						}
						else
						{
							camPosForced = posShit;
						}
					}
				case 'Play Animation':
					var daChar:String = input1;
					if (daChar == 'dad')
					{
						dad.playAnim(input2, true);
						dad.specialAnim = true;
					}
					else if (daChar == 'gf')
					{
						gf.playAnim(input2, true);
						gf.specialAnim = true;
					}
					else if (daChar == 'bf')
					{
						boyfriend.playAnim(input2, true);
						boyfriend.specialAnim = true;
					}
				case 'Change Scroll Speed':
					scrSpd = Std.parseFloat(input1);
			}
		}
		else
		{
			scripts.executeFunc('onEvent', [nameShit, input1, input2]);
		}
	}

	private function popUpScore(daNote:Note, isSus:Bool):Void
	{
		var score:Int = 350;
		var daRating = daNote.rating;

		if (!isSus)
		{
			switch (daRating)
			{
				case 'shit':
					shit++;
					daRating = 'shit';
					score = 50;
					if (!isSus)
						accuracyScore += 100;
				case 'bad':
					bad++;
					daRating = 'bad';
					score = 100;
					if (!isSus)
						accuracyScore += 200;
				case 'good':
					good++;
					daRating = 'good';
					score = 200;
					if (!isSus)
						accuracyScore += 300;
				case 'sick':
					sick++;
					daRating = 'sick';
					score = 350;
					if (!isSus)
						accuracyScore += 400;
					if (!isSus)
					{
						if (CDevConfig.saveData.noteImpact)
							notePressAt(daNote);
					}
			}
		}
		else
		{
			daRating = 'sick';
			score = 450;
		}

		songScore += score;

		// trying to shorten stuffs here.
		var setting = CDevConfig.saveData.multiRateSprite;
		var sRatingNull = (sRating == null);
		var rating = new FlxSprite();

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';
		var librshit:String = 'shared';

		if (isPixel)
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
			librshit = 'week6';
		}

		if (!setting)
		{
			timeS = 0;

			if (!sRatingNull)
				remove(sRating);
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2, librshit));
		rating.screenCenter();
		rating.setPosition(ratingPosition.x, ratingPosition.y);

		if (setting)
		{
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);
		}
		else
		{
			rating.y -= 10;
		}

		rating.cameras = [config.ratingSpriteCamera];

		if (!isPixel)
		{
			rating.setGraphicSize(Std.int(rating.width * 0.6));
			rating.antialiasing = CDevConfig.saveData.antialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.6));
		}
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		var comboString:String = Std.string(combo);
		var comboArray:Array<String> = comboString.split('');
		for (i in 0...comboArray.length)
		{
			seperatedScore.push(Std.parseInt(comboArray[i]));
		}
		var daLoop:Int = 0;

		var sus:String = (isPixel ? 'week6' : 'shared');
		numGroup.clear();
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2, sus));
			numScore.screenCenter();
			numScore.x = comboPosition.x + (36 * daLoop);
			numScore.y = comboPosition.y;
			numScore.ID = daLoop;

			numScore.cameras = [config.ratingSpriteCamera];

			if (!isPixel)
			{
				numScore.antialiasing = CDevConfig.saveData.antialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.4));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();
			if (setting)
			{
				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);
				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.destroy();
						remove(rating);
					},
					startDelay: Conductor.crochet * 0.002
				});
				add(numScore);
			}
			else
			{
				numScore.y -= 10;
				numGroup.add(numScore);
			}

			daLoop++;
		}

		if (setting)
			add(rating);
		else
		{
			sRating = rating;
			add(sRating);
		}

		if (setting)
			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					rating.destroy();
					remove(rating);
				},
				startDelay: Conductor.crochet * 0.001
			});
	}

	private function keyShit():Void
	{
		var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		var pressArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
		if (CDevConfig.saveData.botplay) // blocking the player's inputs
		{
			holdArray = [false, false, false, false];
			pressArray = [false, false, false, false];
		}

		if (holdArray.contains(true))
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData])
				{
					goodNoteHit(daNote);
				}
			});
		}

		if (pressArray.contains(true) && CDevConfig.saveData.hitsound)
			FlxG.sound.play(Paths.sound('hitsound', 'shared'), 0.6);

		if (pressArray.contains(true) && generatedMusic)
		{
			if (!playingLeftSide)
				boyfriend.holdTimer = 0;
			else
				dad.holdTimer = 0;

			var possibleNotes:Array<Note> = [];
			var directions:Array<Int> = [];
			var countedDirs:Array<Bool> = [false, false, false, false];

			var killList:Array<Note> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData])
					goodNoteHit(daNote);
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
				{
					if (directions.contains(daNote.noteData))
					{
						for (coolNote in possibleNotes)
						{
							if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
							{
								killList.push(daNote);
								break;
							}
							else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
							{
								possibleNotes.remove(coolNote);
								possibleNotes.push(daNote);
								break;
							}
						}
					}
					else
					{
						possibleNotes.push(daNote);
						directions.push(daNote.noteData);
					}
				}
			});
			for (daNote in killList)
			{
				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
			possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

			var blockNote:Bool = false;
			for (i in 0...pressArray.length)
			{
				if (pressArray[i] && !directions.contains(i))
					blockNote = true;
			}

			if (possibleNotes.length > 0 && !blockNote)
			{
				if (!CDevConfig.saveData.ghost)
				{
					for (shit in 0...pressArray.length)
						if (pressArray[shit] && !directions.contains(shit))
							noteMiss(shit);
				}
				for (note in possibleNotes)
				{
					if (pressArray[note.noteData])
					{
						goodNoteHit(note);
					}
				}
			}
			else if (!CDevConfig.saveData.ghost)
			{
				for (shit in 0...pressArray.length)
					if (pressArray[shit])
						noteMiss(shit);
			}

			if (possibleNotes.length > 0 && !blockNote && CDevConfig.saveData.ghost && !CDevConfig.saveData.botplay)
			{
				if (pressedNotes > 4)
					noteMiss(0);
				else
					pressedNotes++;
			}
		}

		if (CDevConfig.saveData.botplay)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (Conductor.songPosition > daNote.strumTime)
				{
					if (daNote.canBeHit && daNote.mustPress || daNote.tooLate && daNote.mustPress)
					{
						goodNoteHit(daNote);

						if (!playingLeftSide)
							boyfriend.holdTimer = 0;
						else
							dad.holdTimer = 0;
					}
				}
			});
		}

		if (!playingLeftSide)
		{
			if (boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.charHoldTime
				&& boyfriend.animation.curAnim.name.startsWith('sing')
				&& !boyfriend.animation.curAnim.name.endsWith('miss')
				&& (!holdArray.contains(true) || CDevConfig.saveData.botplay))
			{
				var altIdle:Bool = false;
				if (SONG.notes[Math.floor(curStep / 16)] != null)
				{
					altIdle = SONG.notes[Math.floor(curStep / 16)].p1AltAnim;
				}
				boyfriend.dance(altIdle, curBeat);
			}
		}
		else
		{
			if (dad.holdTimer > Conductor.stepCrochet * 0.001 * dad.charHoldTime
				&& dad.animation.curAnim.name.startsWith('sing')
				&& !dad.animation.curAnim.name.endsWith('miss')
				&& (!holdArray.contains(true) || CDevConfig.saveData.botplay))
			{
				var altIdle:Bool = false;
				if (SONG.notes[Math.floor(curStep / 16)] != null)
				{
					altIdle = SONG.notes[Math.floor(curStep / 16)].altAnim;
				}
				dad.dance(altIdle, curBeat);
			}
		}

		if (!CDevConfig.saveData.botplay)
		{
			playerStrums.forEach(function(spr:StrumArrow)
			{
				if (pressArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
					spr.playAnim('pressed', false);
				if (!holdArray[spr.ID])
					spr.playAnim('static', false);
			});
		}
		else
		{
			playerStrums.forEach(function(spr:StrumArrow)
			{
				if (spr.animation.finished)
				{
					spr.playAnim('static', false);
				}
			});
		}
	}

	function checkCanHitNote(daNote:Note):Bool
	{
		var theDiff = Math.abs((daNote.strumTime - game.Conductor.songPosition));
		for (i in 0...RatingsCheck.theTimingWindow.length)
		{
			var judgeTime = RatingsCheck.theTimingWindow[i];
			var newTime = i + 1 > RatingsCheck.theTimingWindow.length - 1 ? 0 : RatingsCheck.theTimingWindow[i + 1];
			if (theDiff < judgeTime && theDiff >= newTime)
			{
				return true;
			}
		}
		return false;
	}

	var when:Float;

	var timesChecked:Float = 0;

	function notePressAt(note:Note)
	{
		if (note != null)
			doArrowEffect(playerStrums.members[note.noteData].x, playerStrums.members[note.noteData].y, note.noteData, note);
	}

	function doArrowEffect(x:Float, y:Float, thedata:Int, ?note:Note = null)
	{
		var click:NotePress = grpNotePresses.recycle(NotePress);
		click.prepareImage(x, y, thedata, note.noteColor);
		grpNotePresses.add(click);
	}

	public var allDaNotesHit:Int = 0;

	public function recalculateAccuracy()
	{
		accuracy = (accuracyScore / ((allDaNotesHit + misses) * 400)) * 100;
		convertedAccuracy = accuracy; // backwards compability
	}

	function noteMiss(direction:Int = 1):Void
	{
		if (!boyfriend.stunned)
		{
			if (!CDevConfig.saveData.botplay)
			{
				if (suddenDeath)
					health = -10;
				if (!playingLeftSide)
					health -= 0.075 * healthLoseMulti;
				else
					health += 0.075 * healthLoseMulti;
				if (combo > 5 && gf.animOffsets.exists('sad'))
				{
					gf.playAnim('sad', true);
					gf.specialAnim = true;
				}
				combo = 0;
				misses++;

				songScore -= 10;
				accuracyScore -= 30;

				FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
				// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
				// FlxG.log.add('played imss note');

				var animToPlay:String = singAnimationNames[direction] + "miss";
				var char:Character = (!playingLeftSide ? boyfriend : dad);

				if (char.animOffsets.exists(animToPlay))
					char.playAnim(animToPlay, true);

				recalculateAccuracy();

				scripts.executeFunc('onNoteMiss', [direction]);
			}
			else
			{
				goodNoteHit(Note.getNoteInfo(direction));
			}
		}
	}

	var tX:Float = 400;
	var tSpeed:Float = FlxG.random.float(5, 7);
	var tAngle:Float = FlxG.random.int(-90, 45);

	function moveTank(?elapsed:Float = 0):Void
	{
		if (!inCutscene)
		{
			tAngle += elapsed * tSpeed;
			if (tankGround != null)
			{
				tankGround.angle = tAngle - 90 + 15;
				tankGround.x = tX + 1500 * Math.cos(Math.PI / 180 * (1 * tAngle + 180));
				tankGround.y = 1300 + 1100 * Math.sin(Math.PI / 180 * (1 * tAngle + 180));
			}
		}
	}

	function noteCheck(keyP:Bool, note:Note):Void
	{
		if (keyP)
			goodNoteHit(note);
		else
		{
		}
	}

	function showNoteDiff(note:Note)
	{
		if (CDevConfig.saveData.showDelay && !note.isSustainNote)
		{
			timeShit = 0;
			var colshit:FlxColor = FlxColor.WHITE;
			switch (note.rating)
			{
				case 'shit', 'bad':
					colshit = FlxColor.RED;
				case 'good':
					colshit = FlxColor.LIME;
				case 'sick', 'perfect':
					colshit = FlxColor.CYAN;
			}

			var msShits:Float = Math.abs((note.strumTime - game.Conductor.songPosition));
			judgementText.text = RatingsCheck.fixFloat(msShits, 2) + 'ms';
			judgementText.color = colshit;

			judgementText.alpha = 1;

			var allNoteWidth:Float = (160 * 0.7) * 16;
			judgementText.x = (strumXpos + 50 + (allNoteWidth / 2) - 30 - (judgementText.width / 2)) - (playingLeftSide ? FlxG.width / 2 : 0);
			var strumYPOS:Float = 70;
			if (CDevConfig.saveData.downscroll)
			{
				if (!CDevConfig.saveData.middlescroll)
					strumYPOS = FlxG.height - 160;
				else
					strumYPOS = FlxG.height - 175;
				judgementText.y = strumYPOS + (160 * 0.7);
			}
			else
			{
				judgementText.y = strumYPOS / 2;
			}

			judgementText.scale.x = 1.2;
		}
	}

	var killedNotes:Int = 0;
	var lastMs:Float = 0;

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			note.rating = RatingsCheck.noteJudge(note);

			showNoteDiff(note); // shorter and better code ass

			popUpScore(note, note.isSustainNote);
			combo += 1 * Std.int(comboMultiplier);

			killedNotes++;

			// i know this is bad, yeah
			var healthCheck = (!note.isSustainNote ? 0.06 : 0.03);
			var healthAdd = (!playingLeftSide ? healthCheck : -healthCheck);

			health += healthAdd * healthGainMulti;

			if (pressedNotes >= 1)
				pressedNotes--;

			if (pressedNotes < 0)
				pressedNotes = 0;

			cameraMovements(singAnimationNames[note.noteData], true);

			// rewrite!!!
			var animToPlay:String = singAnimationNames[note.noteData];
			var isAlt:Bool = false;
			var char:Character = (!playingLeftSide ? boyfriend : dad);

			if (SONG.notes[Math.floor(curStep / 16)] != null)
				isAlt = (!playingLeftSide ? SONG.notes[Math.floor(curStep / 16)].p1AltAnim : SONG.notes[Math.floor(curStep / 16)].altAnim);

			if (isAlt && char.animOffsets.exists(singAnimationNames[note.noteData] + char.singAltPrefix))
				animToPlay = singAnimationNames[note.noteData] + char.singAltPrefix;

			if (!isAlt && note.noteType == "Alt Anim" && char.animOffsets.exists(singAnimationNames[note.noteData] + char.singAltPrefix))
				animToPlay = singAnimationNames[note.noteData] + char.singAltPrefix;

			if (note.noteType == "GF Note")
			{
				char = gf;
			}

			if (!note.noAnim)
			{
				char.playAnim(animToPlay, true);
				char.holdTimer = 0;
			}
			// eeeeeeeeee

			playerStrums.forEach(function(spr:StrumArrow)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.playAnim('confirm', true);
				}
			});

			if (CDevConfig.saveData.hitsound && CDevConfig.saveData.botplay && !note.isSustainNote)
				FlxG.sound.play(Paths.sound('hitsound', 'shared'), 0.6);

			note.wasGoodHit = true;
			vocals.volume = 1;

			if (!note.isSustainNote)
				allDaNotesHit += 1;

			note.onNoteHit(note.rating, true);

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}

			recalculateAccuracy();

			var funct:String = "onP1Hit";
			scripts.executeFunc(funct, [note]);

			// Deprecated.
			// if (!playingLeftSide)
			scripts.executeFunc('p1NoteHit', [note.noteData, note.isSustainNote]);
			// else
			//	scripts.executeFunc('p2NoteHit', [note.noteData, note.isSustainNote]);
		}
	}

	function cameraMovements(daAnim:String, isBF:Bool = false)
	{
		if (CDevConfig.saveData.camMovement)
		{
			if (isBF)
			{
				var theAnim:String = daAnim;
				switch (theAnim)
				{
					case 'singLEFT':
						bfCamX = -10;
						bfCamY = 0;
					case 'singDOWN':
						bfCamY = 10;
						bfCamX = 0;
					case 'singUP':
						bfCamY = -10;
						bfCamX = 0;
					case 'singRIGHT':
						bfCamX = 10;
						bfCamY = 0;
				}

				// camFollow.setPosition(bfCamXPos + bfCamX, bfCamYPos + bfCamY);
			}
			if (!isBF)
			{
				var anim:String = daAnim;
				switch (anim)
				{
					case 'singLEFT':
						dadCamX = -10;
						dadCamY = 0;
					case 'singDOWN':
						dadCamY = 10;
						dadCamX = 0;
					case 'singUP':
						dadCamY = -10;
						dadCamX = 0;
					case 'singRIGHT':
						dadCamX = 10;
						dadCamY = 0;
				}
				// camFollow.setPosition(dadCamXPos + dadCamX, dadCamYPos + dadCamY);
			}
		}
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
			gf.specialAnim = true;
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		if (CDevConfig.saveData.flashing)
		{
			halloweenBG.animation.play('lightning');
			halloweenThunder.alpha = 0.7;

			FlxG.camera.shake(0.01, 0.2);
			FlxG.camera.zoom += 0.050;

			FlxTween.tween(halloweenThunder, {alpha: 0}, 1);
		}

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	public var playingBlammedVideo:Bool = false;

	override function stepHit()
	{
		super.stepHit();

		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > (20 * songSpeed)
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > (20 * songSpeed)))
		{
			resyncVocals();
		}

		switch (curSong.toLowerCase())
		{
			case 'stress':
				switch (curStep)
				{
					case 252, 253, 254, 255:
						FlxG.camera.zoom += 0.025;
						camHUD.zoom += 0.01;
					case 736:
						dad.canDance = false;
					case 768:
						dad.canDance = true;
					case 1408:
						forceCameraPos = true;
						camPosForced = [gf.getMidpoint().x - 300, gf.getMidpoint().y];
				}
		}

		scripts.executeFunc('stepHit', [curStep]);

		if (isModStage)
			stageHandler.onStepHit(curStep);

		if (instantEndSong)
		{
			instantEndSong = false;
			endSong();
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, (CDevConfig.saveData.downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
		}
		// wiggleShit.update(Conductor.crochet);
		if (CDevConfig.saveData.camZoom)
		{
			if (SONG.notes[Math.floor(curStep / 16)] != null)
			{
				if (camZooming && PlayState.SONG.notes[Std.int(curStep / 16)].banger && !endingSong)
				{
					FlxG.camera.zoom += 0.022;
					camHUD.zoom += 0.032;
				}
			}
			if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
			{
				FlxG.camera.zoom += 0.02;
				camHUD.zoom += 0.03;
			}

			if (camZooming && curBeat % 4 == 0)
			{
				FlxG.camera.zoom += 0.02;
				camHUD.zoom += 0.03;
			}

			if (curSong.toLowerCase() == 'blammed' && curBeat >= 128 && curBeat < 192 && camZooming)
			{
				FlxG.camera.zoom += 0.02;
				camHUD.zoom += 0.03;
			}

			if (curSong.toLowerCase() == "stress" && curBeat >= 320 && curBeat < 352 && camZooming)
			{
				FlxG.camera.zoom += 0.02;
				camHUD.zoom += 0.03;
			}
		}

		zoomIcon();

		if (!gf.curAnimStartsWith("sing"))
		{
			gf.dance();
		}

		if (!dad.curAnimStartsWith("sing"))
		{
			var altIdle:Bool = false;
			if (SONG.notes[Math.floor(curStep / 16)] != null)
			{
				altIdle = SONG.notes[Math.floor(curStep / 16)].altAnim;
			}
			dad.dance(altIdle, curBeat);
		}
		if (!boyfriend.curAnimStartsWith("sing"))
		{
			var altIdle:Bool = false;
			if (SONG.notes[Math.floor(curStep / 16)] != null)
			{
				altIdle = SONG.notes[Math.floor(curStep / 16)].p1AltAnim;
			}
			boyfriend.dance(altIdle, curBeat);
		}

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			if (boyfriend.animOffsets.exists('hey'))
				boyfriend.playAnim('hey', true);
			if (gf.animOffsets.exists('cheer'))
				gf.playAnim('cheer', true);
		}

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			if (boyfriend.animOffsets.exists('hey'))
				boyfriend.playAnim('hey', true);
			if (gf.animOffsets.exists('cheer'))
				gf.playAnim('cheer', true);
		}

		switch (curSong.toLowerCase())
		{
			case 'ugh':
				switch (curBeat)
				{
					case 15, 111, 131, 135, 207:
						if (dad.animOffsets.exists('ugh'))
							dad.playAnim('ugh', true);
						dad.specialAnim = true;
				}
			case 'guns':
				if (curBeat >= 128 && curBeat < 160)
				{
					FlxG.camera.zoom += 0.025;
					camHUD.zoom += 0.01;
				}
				switch (curBeat)
				{
					case 224:
						camHUD.flash();
						gunsBanger = true;
					case 288:
						gunsBanger = false;
						// FlxTween.tween(FlxG.camera, {angle: 0}, 1, {ease: FlxEase.circIn});
						FlxTween.tween(camHUD, {angle: 0}, 1, {ease: FlxEase.cubeIn});
						FlxTween.tween(cameraPosition, {y: 0}, 1, {ease: FlxEase.cubeIn});
				}
		}

		switch (curStage)
		{
			case 'school':
				bgGirls.dance();

			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'limo':
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(light:FlxSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					phillyCityLights.members[curLight].visible = true;
					// phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
			case 'tank':
				tankWatchtower.animation.play('watchtower gradient color', true);
				foregroundSprites.forEach(function(spr:FlxSprite)
				{
					spr.animation.play('fg', true);
				});
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}

		if (isModStage)
			stageHandler.beatHit(curBeat);

		scripts.executeFunc('beatHit', [curBeat]);
		if (CDevConfig.saveData.botplay)
			botplayTextBeat();
	}

	function botplayTextBeat()
	{ // added this cuz i think it would be cool if the botplay text zooms on the beat lol
		botplayTxt.scale.x += 0.1;
		botplayTxt.scale.y += 0.1;
	}

	var curLight:Int = 0;

	// used for scripting
	public static function setDeathCharacter(char:String = "bf", disableFlip:Bool = false)
	{
		GameOverSubstate.disableFlipX = disableFlip;
		GameOverSubstate.deathCharacter = char;
		GameLog.log("[PlayState] Set Death Character to: " + GameOverSubstate.deathCharacter);
		var txte:String = (GameOverSubstate.disableFlipX ? "disabled." : "enabled.");
		GameLog.log("[PlayState] Death Character FlipX was " + txte);
	}

	public static function setDeathSongBpm(bpm:Float = 100)
	{
		GameLog.log("[PlayState] Set Game Over song bpm to " + bpm);
		GameOverSubstate.songBpm = bpm;
	}

	public static function triggerEvent(nameShit:String, input1:String, input2:String)
	{
		GameLog.log("[PlayState] Triggering an event... " + nameShit);
		var s:ChartEvent = new ChartEvent(0, 0, false);
		s.EVENT_NAME = nameShit;
		s.value1 = input1;
		s.value2 = input2;

		executeEvents(s, s.EVENT_NAME, s.value1, s.value2);
	}

	public function getCameraLerp():Float
	{
		var followLerp:Float = CDevConfig.utils.bound((0.08 / (CDevConfig.saveData.fpscap / 60)), 0, 1);
		if (isModStage)
		{
			if (Stage.USECUSTOMFOLLOWLERP)
			{
				followLerp = CDevConfig.utils.bound((Stage.FOLLOW_LERP / (CDevConfig.saveData.fpscap / 60)), 0, 1);
			}
		}
		return followLerp;
	}
}

class PlayStateConfig
{
	/**
	 * Font that will be used for every text on playstate.
	 * must be the font name "VCR OSD Mono"
	 */
	public var uiTextFont:String = 'VCR OSD Mono';

	/**
	 * "Score: " text in PlayState.scoreTxt
	 */
	public var scoreText:String = 'Score';

	/**
	 * "Accuracy: " text in PlayState.scoreTxt
	 */
	public var accuracyText:String = 'Accuracy';

	/**
	 * "Misses: " text in PlayState.scoreTxt
	 */
	public var missesText:String = 'Misses';

	/**
	 * Set the color of the time bar!
	 */
	public var timeBarColor:Int = 0xFFFFFFFF;

	/**
	 * Set the camera of the Note Impacts!
	 */
	public var noteImpactsCamera:FlxCamera = null;

	/**
	 * Set the camera of the Rating Sprite!
	 * (including the combo counter sprites)
	 */
	public var ratingSpriteCamera:FlxCamera = null;

	public function new()
	{
	}

	public function resetConfig()
	{
		uiTextFont = 'VCR OSD Mono';
		scoreText = 'Score';
		missesText = 'Misses';
		accuracyText = 'Accuracy';
		timeBarColor = 0xFFFFFFFF;
		noteImpactsCamera = PlayState.camHUD;
		ratingSpriteCamera = PlayState.camHUD;
	}
}

// what are you looking for?
