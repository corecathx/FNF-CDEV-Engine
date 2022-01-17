package;

#if desktop
import Discord.DiscordClient;
#end
import openfl.Lib;
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;

using StringTools;

class PlayState extends MusicBeatState
{
	var bfCamX:Int = 0;
	var bfCamY:Int = 0;

	var dadCamX:Int = 0;
	var dadCamY:Int = 0;

	public var grpNotePresses:FlxTypedGroup<NotePress>;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	var songName:FlxText;

	public static var songPosBG:FlxSprite;
	public static var songPosBar:FlxBar;

	var songPercent:Float = 0;

	var halloweenLevel:Bool = false;

	var susHuh:FlxText;

	private var vocals:FlxSound;

	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;

	public static var strumXpos:Float = 35;

	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	public static var convertedAccuracy:Float = 0;

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	var accuracyShit:Float = 0;
	var hittedNotes:Float = 0;

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var healthLerp:Float = 1;
	private var combo:Int = 0;

	var bruhZoom:Float = 0;

	var isDownscroll:Bool = false;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	var pressedNotes:Int = 0;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	var botplayTxt:FlxText;

	var zoomin:Float = 0;

	var p2Strums:FlxTypedGroup<FlxSprite>;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var halloweenBG:FlxSprite;
	var halloweenThunder:FlxSprite;
	var isHalloween:Bool = false;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var daRPCInfo:String = '';

	var ratingText:String = "";

	var songPosBGspr:FlxSprite;
	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;
	var songScore:Int = 0;
	var scoreTxt:FlxText;

	private var cheeringBF:Bool = false;

	public static var campaignScore:Int = 0;

	public static var defaultCamZoom:Float = 1.05;

	var bgScore:FlxSprite;
	var bgNoteLane:FlxSprite;

	public var ratingIdk:String;

	var difficultytxt:String = "";

	var alreadyTweened:Bool = false;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	var isPixel:Bool = false;

	var inCutscene:Bool = false;

	public static var misses:Int = 0;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var songLength:Float = 0;
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	override public function create()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		defaultCamZoom = 1.09;

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);
		Conductor.updateSettings();

		if (FlxG.save.data.downscroll)
		{
			isDownscroll = true;
		}
		else
		{
			isDownscroll = false;
		}
		misses = 0;
		convertedAccuracy = 0;

		switch (SONG.song.toLowerCase())
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go \nthrough ME first!"
				];
			case 'fresh':
				dialogue = ["Not too shabby boy.", ""];
			case 'dadbattle':
				dialogue = [
					"gah you think you're hot stuff?",
					"If you can beat me here...",
					"Only then I will even CONSIDER letting you\ndate my daughter!"
				];
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('thorns/thornsDialogue'));
		}

		var originalXPos:Float = 35;

		if (FlxG.save.data.middlescroll)
			originalXPos = -270;
		// originalXPos = -278;

		strumXpos = originalXPos;

		#if desktop
		// Making difficulty text for Discord Rich Presence.
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
		}

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = SONG.song + " " + storyDifficultyText + " Story Mode";
		}
		else
		{
			detailsText = SONG.song + " " + storyDifficultyText + " Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		daRPCInfo = 'Score: ' + songScore + "\n" + 'Misses: ' + misses + '\n' + 'Accuracy: ' + RatingsCheck.fixFloat(convertedAccuracy, 2) + "% (" + ratingText + ')';

		// Updating Discord Rich Presence.
		if (Main.discordRPC)
			DiscordClient.changePresence(detailsText, daRPCInfo, iconRPC);
		#end

		switch (storyDifficulty)
		{
			case 0:
				difficultytxt = "Easy";
			case 1:
				difficultytxt = "Normal";
			case 2:
				difficultytxt = "Hard";
		}

		switch (SONG.stage)
		{
			case 'stage':
				{
					defaultCamZoom = 0.9;
					curStage = 'stage';
					var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
					bg.antialiasing = FlxG.save.data.antialiasing;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					add(bg);

					var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					stageFront.antialiasing = FlxG.save.data.antialiasing;
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					add(stageFront);

					var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					stageCurtains.antialiasing = FlxG.save.data.antialiasing;
					stageCurtains.scrollFactor.set(1.3, 1.3);
					stageCurtains.active = false;

					add(stageCurtains);
				}
			case 'spooky':
				{
					curStage = 'spooky';
					halloweenLevel = true;

					var hallowTex = Paths.getSparrowAtlas('halloween_bg', 'week2');

					halloweenBG = new FlxSprite(-200, -100);
					halloweenBG.frames = hallowTex;
					halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
					halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
					halloweenBG.animation.play('idle');
					halloweenBG.antialiasing = FlxG.save.data.antialiasing;
					add(halloweenBG);

					halloweenThunder = new FlxSprite(-500,-500).makeGraphic(4000,4000,FlxColor.WHITE);
					halloweenThunder.alpha = 0;
					halloweenThunder.blend = ADD;

					isHalloween = true;
				}
			case 'philly':
				{
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
						light.antialiasing = FlxG.save.data.antialiasing;
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
					limo.antialiasing = FlxG.save.data.antialiasing;

					fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol', 'week4'));
					// add(limo);
				}
			case 'mall':
				{
					curStage = 'mall';

					defaultCamZoom = 0.80;

					var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls', 'week5'));
					bg.antialiasing = FlxG.save.data.antialiasing;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					add(bg);

					upperBoppers = new FlxSprite(-240, -90);
					upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop', 'week5');
					upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
					upperBoppers.antialiasing = FlxG.save.data.antialiasing;
					upperBoppers.scrollFactor.set(0.33, 0.33);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					add(upperBoppers);

					var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator', 'week5'));
					bgEscalator.antialiasing = FlxG.save.data.antialiasing;
					bgEscalator.scrollFactor.set(0.3, 0.3);
					bgEscalator.active = false;
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					add(bgEscalator);

					var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree', 'week5'));
					tree.antialiasing = FlxG.save.data.antialiasing;
					tree.scrollFactor.set(0.40, 0.40);
					add(tree);

					bottomBoppers = new FlxSprite(-300, 140);
					bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop', 'week5');
					bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
					bottomBoppers.antialiasing = FlxG.save.data.antialiasing;
					bottomBoppers.scrollFactor.set(0.9, 0.9);
					bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
					bottomBoppers.updateHitbox();
					add(bottomBoppers);

					var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow', 'week5'));
					fgSnow.active = false;
					fgSnow.antialiasing = FlxG.save.data.antialiasing;
					add(fgSnow);

					santa = new FlxSprite(-840, 150);
					santa.frames = Paths.getSparrowAtlas('christmas/santa', 'week5');
					santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
					santa.antialiasing = FlxG.save.data.antialiasing;
					add(santa);
				}
			case 'mallEvil':
				{
					curStage = 'mallEvil';
					var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG', 'week5'));
					bg.antialiasing = FlxG.save.data.antialiasing;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					add(bg);

					var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree', 'week5'));
					evilTree.antialiasing = FlxG.save.data.antialiasing;
					evilTree.scrollFactor.set(0.2, 0.2);
					add(evilTree);

					var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow", 'week5'));
					evilSnow.antialiasing = FlxG.save.data.antialiasing;
					add(evilSnow);
				}
			case 'school':
				{
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

					/* 
						var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolBG'));
						bg.scale.set(6, 6);
						// bg.setGraphicSize(Std.int(bg.width * 6));
						// bg.updateHitbox();
						add(bg);

						var fg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolFG'));
						fg.scale.set(6, 6);
						// fg.setGraphicSize(Std.int(fg.width * 6));
						// fg.updateHitbox();
						add(fg);

						wiggleShit.effectType = WiggleEffectType.DREAMY;
						wiggleShit.waveAmplitude = 0.01;
						wiggleShit.waveFrequency = 60;
						wiggleShit.waveSpeed = 0.8;
					 */

					// bg.shader = wiggleShit.shader;
					// fg.shader = wiggleShit.shader;

					/* 
						var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);
						var waveSpriteFG = new FlxEffectSprite(fg, [waveEffectFG]);

						// Using scale since setGraphicSize() doesnt work???
						waveSprite.scale.set(6, 6);
						waveSpriteFG.scale.set(6, 6);
						waveSprite.setPosition(posX, posY);
						waveSpriteFG.setPosition(posX, posY);

						waveSprite.scrollFactor.set(0.7, 0.8);
						waveSpriteFG.scrollFactor.set(0.9, 0.8);

						// waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
						// waveSprite.updateHitbox();
						// waveSpriteFG.setGraphicSize(Std.int(fg.width * 6));
						// waveSpriteFG.updateHitbox();

						add(waveSprite);
						add(waveSpriteFG);
					 */
				}
			default:
				{
					defaultCamZoom = 0.9;
					curStage = 'stage';
					var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
					bg.antialiasing = FlxG.save.data.antialiasing;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					add(bg);

					var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					stageFront.antialiasing = FlxG.save.data.antialiasing;
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					add(stageFront);

					var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					stageCurtains.antialiasing = FlxG.save.data.antialiasing;
					stageCurtains.scrollFactor.set(1.3, 1.3);
					stageCurtains.active = false;

					add(stageCurtains);
				}
		}

		var gfVer:String = 'gf';
		if (SONG.gfVersion != null)
			gfVer = SONG.gfVersion;
		gf = new Character(400, 130, gfVer);
		gf.scrollFactor.set(0.95, 0.95);

		switch (gf.curCharacter)
		{
			case 'boomBoxCHR':
				gf.y += 230;
		}

		dad = new Character(100, 100, SONG.player2);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'bf', 'bf-car', 'bf-cscared', 'bf-christmas':
				dad.y = 450;
			case 'gf', 'gf-christmas':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}

			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'bf-pixel':
				dad.y = 450;
				if (SONG.song.toLowerCase() == 'mod-test')
				{
					dad.x = 320;
					dad.y = 600;
				}
		}

		boyfriend = new Boyfriend(770, 100, SONG.player1);

		switch (SONG.player1)
		{
			case 'bf', 'bf-car', 'bf-cscared', 'bf-christmas', 'bf-pixel':
				boyfriend.x = 770;
				boyfriend.y = 450;
			case "spooky":
				boyfriend.y += 200;
			case "monster":
				boyfriend.y += 100;
			case 'monster-christmas':
				boyfriend.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				boyfriend.y += 300;
			case 'parents-christmas':
				boyfriend.x -= 500;
			case 'senpai':
				boyfriend.x += 150;
				boyfriend.y += 360;
				camPos.set(boyfriend.getGraphicMidpoint().x + 300, boyfriend.getGraphicMidpoint().y);
			case 'senpai-angry':
				boyfriend.x += 150;
				boyfriend.y += 360;
				camPos.set(boyfriend.getGraphicMidpoint().x + 300, boyfriend.getGraphicMidpoint().y);
			case 'spirit':
				boyfriend.x -= 150;
				boyfriend.y += 100;
				camPos.set(boyfriend.getGraphicMidpoint().x + 300, boyfriend.getGraphicMidpoint().y);
		}

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				// trailArea.scrollFactor.set();

				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				// evilTrail.changeValuesEnabled(false, false, false, false);
				// evilTrail.changeGraphic()
				add(evilTrail);
				// evilTrail.scrollFactor.set(1.1, 1.1);

				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
		}

		add(gf);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(dad);
		add(boyfriend);

		if (curStage == 'spooky')
			add(halloweenThunder);

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(strumXpos, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (FlxG.save.data.downscroll)
			strumLine.y = FlxG.height - 160;

		bgNoteLane = new FlxSprite().makeGraphic(500,FlxG.height,FlxColor.BLACK);
		bgNoteLane.screenCenter(X);
		bgNoteLane.alpha = 0;
		add(bgNoteLane);

		bgNoteLane.cameras = [camHUD];

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		p2Strums = new FlxTypedGroup<FlxSprite>();

		grpNotePresses = new FlxTypedGroup<NotePress>();
		add(grpNotePresses);

		var hmmclicc:NotePress = new NotePress(100, 100, 0);
		grpNotePresses.add(hmmclicc);
		hmmclicc.alpha = 0;
		// startCountdown();

		Conductor.checkFakeCrochet(SONG.bpm);
		generateSong(SONG.song);

		// this is dumb
		bruhZoom = defaultCamZoom;
		zoomin = defaultCamZoom + 0.2;

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, CDevConfig.utils.bound((0.04 * (30 / FlxG.save.data.fpscap)), 0, 1));
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		cacheSounds();

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		
		iconP2 = new HealthIcon(dad.healthIcon, false);

		healthBarBG = new FlxSprite(0, FlxG.height * 0.85).loadGraphic(Paths.image('healthBar'));
		if (FlxG.save.data.downscroll)
			healthBarBG.y = 80;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'healthLerp', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(FlxColor.fromRGB(iconP2.charColorArray[0], iconP2.charColorArray[1],iconP2.charColorArray[2]), FlxColor.fromRGB(iconP1.charColorArray[0], iconP1.charColorArray[1],iconP1.charColorArray[2]));
		// healthBar
		add(healthBar);

		iconP1.y = healthBar.y - (iconP1.height / 2);
		iconP2.y = healthBar.y - (iconP2.height / 2);

		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		scoreTxt.borderSize = 1.3;
		scoreTxt.scrollFactor.set();

		bgScore = new FlxSprite().makeGraphic(1,1, FlxColor.BLACK);
		bgScore.alpha = 0.6;

		// songPositionshit
		var songPosBGWIDTH:Float = 0;
		var songPosBGHEIGHT:Float = 0;

		songPosBG = new FlxSprite(0, 20).loadGraphic(Paths.image('healthBar'));
		songPosBGWIDTH = songPosBG.width * 0.8;
		songPosBGHEIGHT = songPosBG.height;
		songPosBG.setGraphicSize(Std.int(songPosBG.width * 0.6), Std.int(songPosBG.height));
		songPosBG.screenCenter(X);
		songPosBG.antialiasing = FlxG.save.data.antialiasing;
		songPosBG.scrollFactor.set();
		add(songPosBG);

		if (FlxG.save.data.downscroll)
			songPosBG.y = FlxG.height * 0.9 + 35;

		// doin this cuz' the original fnf healthbar sprite is not precise
		songPosBGspr = new FlxSprite(songPosBG.x, songPosBG.y).makeGraphic(Std.int(songPosBGWIDTH), Std.int(songPosBGHEIGHT), FlxColor.BLACK);
		songPosBGspr.antialiasing = FlxG.save.data.antialiasing;
		songPosBGspr.screenCenter(X);

		songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBGWIDTH - 8), Std.int(songPosBGHEIGHT - 8), this,
			'songPercent', 0, 1);
		songPosBar.numDivisions = 1000;
		songPosBar.scrollFactor.set();
		songPosBar.screenCenter(X);
		songPosBar.antialiasing = FlxG.save.data.antialiasing;
		songPosBar.createFilledBar(FlxColor.BLACK, FlxColor.CYAN);

		songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - 20, songPosBG.y, 0, "", 16);
		// songName.y += 4;
		songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		songName.scrollFactor.set();
		// songName.screenCenter(X);
		songName.borderSize = 2;

		var engineWM:FlxText;
		engineWM = new FlxText(0, 0, MainMenuState.coreEngineText + (FlxG.save.data.testMode ? ' - [TESTMODE]' : ''), 20);
		engineWM.y -= 3;
		engineWM.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		engineWM.scrollFactor.set();
		// engineWM.screenCenter(X);
		engineWM.borderSize = 1.5;
		engineWM.setPosition(20, FlxG.height - engineWM.height - 20);
		add(engineWM);

		susHuh = new FlxText(0, 0, SONG.song + ' ' + difficultytxt, 20);
		susHuh.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		susHuh.scrollFactor.set();
		susHuh.borderSize = 1.5;
		susHuh.setPosition(FlxG.width - susHuh.width - 20, FlxG.height - susHuh.height - 20);
		add(susHuh);

		engineWM.antialiasing = FlxG.save.data.antialiasing;
		susHuh.antialiasing = FlxG.save.data.antialiasing;

		add(songPosBG);
		add(songPosBGspr);
		add(songPosBar);
		add(songName);

		songPosBG.cameras = [camHUD];
		songPosBGspr.cameras = [camHUD];
		songPosBar.cameras = [camHUD];
		songName.cameras = [camHUD];

		// boob

		add(iconP1);
		add(iconP2);

		add(bgScore);
		add(scoreTxt);

		botplayTxt = new FlxText(0, 0, FlxG.width, "BOTPLAY", 32);
		botplayTxt.setFormat('VCR OSD Mono', 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		botplayTxt.antialiasing = FlxG.save.data.antialiasing;
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 2;
		botplayTxt.y = 150;
		if (FlxG.save.data.downscroll)
			botplayTxt.y = FlxG.height - 150;
		add(botplayTxt);

		bgScore.cameras = [camHUD];
		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		grpNotePresses.cameras = [camHUD];

		engineWM.cameras = [camHUD];
		susHuh.cameras = [camHUD];

		botplayTxt.cameras = [camHUD];

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
				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
					startCountdown();
			}
		}
		super.create();
	}

	function introCutscene()
	{
		switch (SONG.song.toLowerCase())
		{
			case 'milf':
				FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);
				camFollow.x = -400;
				camFollow.y = -500;
				FlxG.camera.focusOn(camFollow.getPosition());
				new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					camHUD.visible = true;
					camFollow.x = dad.getMidpoint().x;
					camFollow.y = dad.getMidpoint().y;
					FlxG.camera.focusOn(camFollow.getPosition());
					startCountdown();
				});
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
		}
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
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
										}, true);
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

	function cacheSounds()
		{
			//HELL
			var altSuffix:String = '';
			if (curStage.startsWith('school'))
				altSuffix = '-pixel';
			CDevConfig.utils.doSoundCaching('missnote1', 'shared');
			CDevConfig.utils.doSoundCaching('missnote2', 'shared');
			CDevConfig.utils.doSoundCaching('missnote3', 'shared');


			CDevConfig.utils.doSoundCaching('intro1' + altSuffix, 'shared');
			CDevConfig.utils.doSoundCaching('intro2' + altSuffix, 'shared');
			CDevConfig.utils.doSoundCaching('intro3' + altSuffix, 'shared');
			CDevConfig.utils.doSoundCaching('introGo' + altSuffix, 'shared');
			
			if (SONG.song.toLowerCase() == 'winter-horrorland')
				CDevConfig.utils.doSoundCaching('Lights_Shut_off', 'shared');

			if (curStage.toLowerCase() == 'spooky')
				{
					CDevConfig.utils.doSoundCaching('thunder_1', 'shared');
					CDevConfig.utils.doSoundCaching('thunder_2', 'shared');
				}
			
			if (curStage.toLowerCase() == 'limo')
				{
					CDevConfig.utils.doSoundCaching('carPass0', 'shared');
					CDevConfig.utils.doSoundCaching('carPass1', 'shared');
				}
				
		}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= (Conductor.crochet * 5) + SONG.offset + Conductor.offset;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
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

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxG.save.data.downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);

		//FlxG.sound.music.time += SONG.offset + Conductor.offset;
		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		FlxTween.tween(bgNoteLane, {alpha: 0.5}, Conductor.crochet / 1000, {ease: FlxEase.linear});

		#if desktop
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		if (Main.discordRPC)
			DiscordClient.changePresence(detailsText, daRPCInfo, iconRPC, true, songLength);
		#end
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] + SONG.offset + Conductor.offset;
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else
				{
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(strumXpos, strumLine.y);

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
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

				default:
					babyArrow.frames = Paths.getSparrowAtlas('notes/' + (FlxG.save.data.fnfNotes ? 'NOTE_assets' : 'CDEVNOTE_assets'));
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = FlxG.save.data.antialiasing;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					}
			}

			babyArrow.ID = i;

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			switch (player)
			{
				case 0:
					p2Strums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			if (FlxG.save.data.botplay)
				playerStrums.forEach(function(spr:FlxSprite)
				{
					spr.centerOffsets();
				});

			p2Strums.forEach(function(spr:FlxSprite)
			{
				spr.centerOffsets();
			});
			strumLineNotes.add(babyArrow);
		}
	}

	function removeStrums()
	{
		playerStrums.clear();
		p2Strums.clear();
		strumLineNotes.clear();
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
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

			FlxG.camera.followLerp = CDevConfig.utils.bound((0.04 * (30 / FlxG.save.data.fpscap)), 0, 1);

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if desktop
			if (startTimer.finished)
			{
				if (Main.discordRPC)
					DiscordClient.changePresence(detailsText, daRPCInfo, iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				if (Main.discordRPC)
					DiscordClient.changePresence(detailsText, daRPCInfo, iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				if (Main.discordRPC)
					DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				if (Main.discordRPC)
					DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
		}
		#end

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused && FlxG.save.data.autoPause)
		{
			if (Main.discordRPC)
				DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var crap:Float = 0;

	var p1Lerp:Float;
	var p2Lerp:Float;
	var bgL:Bool = false;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}

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
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
		}

		super.update(elapsed);

		ratingText = RatingsCheck.getRating(convertedAccuracy) + " (" + RatingsCheck.getRatingText(convertedAccuracy) + ")";

		if (FlxG.save.data.fullinfo)
			scoreTxt.text = 'Score: ' + songScore + ' // Misses: ' + misses + ' // Accuracy: ' + RatingsCheck.fixFloat(convertedAccuracy, 2) + "% "
				+ "// Rank: " + ratingText;
		else
			scoreTxt.text = 'Score: ' + songScore;

		daRPCInfo = 'Score: ' + songScore + " | " + 'Misses: ' + misses + ' | ' + 'Accuracy: ' + RatingsCheck.fixFloat(convertedAccuracy, 2) + "% (" + ratingText + ')';

		bgScore.setSize(scoreTxt.width + 3, scoreTxt.height + 3);
		bgScore.screenCenter(X);
		bgScore.y = scoreTxt.y;

		if (FlxG.save.data.bgLane && FlxG.save.data.middlescroll)
			bgL = true;
		else
			bgL = false;

		bgNoteLane.visible = bgL;

		if (FlxG.save.data.botplay)
		{
			botplayTxt.screenCenter(X);
			crap += SONG.bpm * elapsed;
			botplayTxt.alpha = 1 - Math.sin((3.14 * crap) / SONG.bpm);
			// botplayTxt.alpha = Math.sin((Conductor.songPosition / 1000) * (Conductor.bpm / 60) * -1.0) * 2.5;
		}
		else
		{
			botplayTxt.screenCenter(X);
			botplayTxt.alpha = 0;
		}
		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if desktop
			if (Main.discordRPC)
				DiscordClient.changePresence(detailsPausedText, daRPCInfo, iconRPC);
			#end
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			FlxG.sound.music.pause();
			vocals.pause();

			FlxG.switchState(new ChartingState());

			#if desktop
			if (Main.discordRPC)
				DiscordClient.changePresence("Charting Screen", null, null, true);
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);
		p1Lerp = FlxMath.lerp(1, iconP1.scale.x, CDevConfig.utils.bound(1 - (elapsed * 14), 0, 1));
		p2Lerp = FlxMath.lerp(1, iconP2.scale.x, CDevConfig.utils.bound(1 - (elapsed * 14), 0, 1));
		
		iconP1.scale.set(p1Lerp,p1Lerp);
		iconP2.scale.set(p2Lerp,p2Lerp);

		//iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, CDevConfig.utils.bound(1 - (elapsed * 14), 0, 1))));
		//iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, CDevConfig.utils.bound(1 - (elapsed * 14), 0, 1))));
		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 35;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - iconOffset * 2;
		//smooth healthbar shit
		healthLerp = FlxMath.lerp(health, healthLerp, CDevConfig.utils.bound(1 - (elapsed * 15), 0, 1));
		
		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		if (FlxG.save.data.middlescroll)
		{
			for (i in 0...p2Strums.length)
			{
				p2Strums.members[i].visible = false;
			}
		}

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		if (FlxG.save.data.testMode)
			{
				if (FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.T)
					{
							FlxG.sound.music.pause();
							vocals.pause();
							Conductor.songPosition += 1000;
							notes.forEachAlive(function(daNote:Note)
							{
								if(daNote.strumTime + 800 < Conductor.songPosition) {
									daNote.active = false;
									daNote.visible = false;
			
									daNote.kill();
									notes.remove(daNote, true);
									daNote.destroy();
								}
							});
							for (i in 0...unspawnNotes.length) {
								var daNote:Note = unspawnNotes[0];
								if(daNote.strumTime + 800 >= Conductor.songPosition) {
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
					}

				if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.EIGHT)
					FlxG.switchState(new AnimationDebug(SONG.player2));

				if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.SIX)
					FlxG.switchState(new AnimationDebug(SONG.player1));

				if (FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.ALT && FlxG.keys.justPressed.ONE)
					endSong();				
			}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				if (FlxG.save.data.songtime)
				{
					songPosBG.visible = false;
					songPosBGspr.visible = true;
					songName.visible = true;
					songPosBar.visible = true;
					susHuh.visible = false;
				}
				else
				{
					songPosBG.visible = false;
					songPosBGspr.visible = false;
					songName.visible = false;
					songPosBar.visible = false;
					susHuh.visible = true;
				}
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if (FlxG.save.data.songtime)
				{
					songPercent = SongPosition.getSongPercent(FlxG.sound.music.time, FlxG.sound.music.length);
					songName.text = SONG.song.replace('-', ' ')
						+ ' '
						+ difficultytxt
						+ " ("
						+ SongPosition.getSongDuration(FlxG.sound.music.time, FlxG.sound.music.length)
						+ ")";
					songName.screenCenter(X);
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
				{
					if (dad.animation.curAnim.name == 'idle' || dad.animation.curAnim.name == 'danceLeft' || dad.animation.curAnim.name == 'danceRight')
					{
						dadCamX = 0;
						dadCamY = 0;						
					}

				}
			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
				{
					if (boyfriend.animation.curAnim.name == 'idle' || boyfriend.animation.curAnim.name == 'danceLeft' || boyfriend.animation.curAnim.name == 'danceRight')
					{
						bfCamX = 0;
						bfCamY = 0;
					}
				}

			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				var dudeX:Float = 0;
				var dudeY:Float = 0;

				switch (curStage)
				{
					case 'limo':
						dudeX = boyfriend.getMidpoint().x - 300;
						dudeY = boyfriend.getMidpoint().y - 100;
					case 'mall':
						dudeY = boyfriend.getMidpoint().y - 200;
						dudeX = boyfriend.getMidpoint().x - 100;
					case 'school':
						dudeX = boyfriend.getMidpoint().x - 200;
						dudeY = boyfriend.getMidpoint().y - 200;
					case 'schoolEvil':
						dudeX = boyfriend.getMidpoint().x - 200;
						dudeY = boyfriend.getMidpoint().y - 200;
					default:
						dudeX = boyfriend.getMidpoint().x - 100;
						dudeY = boyfriend.getMidpoint().y - 100;
				}

				camFollow.setPosition(dudeX + bfCamX, dudeY + bfCamY);
			}
			else
			{
				var dudeeX:Float = 0;
				var dudeeY:Float = 0;

				switch (dad.curCharacter)
				{
					case 'mom':
						dudeeX = dad.getMidpoint().x + 150;
						dudeeY = dad.getMidpoint().y;
					case 'senpai':
						dudeeY = dad.getMidpoint().y - 430;
						dudeeX = dad.getMidpoint().x - 100;
					case 'senpai-angry':
						dudeeY = dad.getMidpoint().y - 430;
						dudeeX = dad.getMidpoint().x - 100;
					default:
						dudeeX = dad.getMidpoint().x + 150;
						dudeeY = dad.getMidpoint().y - 100;
				}
				camFollow.setPosition(dudeeX + dadCamX, dudeeY + dadCamY);
			}

			if (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				if (dad.curCharacter == 'mom')
					vocals.volume = 1;

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					tweenCamIn();
				}
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				if (SONG.song.toLowerCase() == 'tutorial')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
				}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CDevConfig.utils.bound(1 - (elapsed * 3), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CDevConfig.utils.bound(1 - (elapsed * 3), 0, 1));
		}

		if (boyfriend.animation.curAnim.name == 'hey')
		{
			camHUD.visible = false;
			defaultCamZoom = zoomin;
		}
		else
		{
			defaultCamZoom = bruhZoom;
			camHUD.visible = true;
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// this if () code is used for hey anims on certain part of the song
		// this code is bad so just ignore it loll
		if (generatedMusic)
		{
			switch (SONG.song.toLowerCase())
			{
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
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}
		// better streaming of shit

		// RESET = Quick Game Over Screen
		if (controls.RESET)
		{
			health = 0;
			trace("RESET = True");
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
			health += 1;
			trace("User is cheating!");
		}

		if (health <= 0)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if desktop
			// Game Over doesn't get his own variable because it's only used here
			if (Main.discordRPC)
				DiscordClient.changePresence("Game Over - " + detailsText, daRPCInfo, iconRPC);
			#end
		}

		if (unspawnNotes[0] != null)
		{
			var daTime:Float = 1500;

			if (FlxMath.roundDecimal(SONG.speed, 2) < 1)
				daTime /= FlxMath.roundDecimal(SONG.speed, 2);

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < daTime)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (FlxG.save.data.downscroll)
					{
						if (((Conductor.songPosition - Conductor.safeZoneOffset) > daNote.strumTime + (Conductor.crochet / 4)))
						{
							daNote.active = false;
							daNote.visible = false;
						}
						else
						{
							daNote.visible = true;
							daNote.active = true;
						}						
					} else{
						if (daNote.strumTime < (Conductor.songPosition - Conductor.safeZoneOffset))
							{
								daNote.active = false;
								daNote.visible = false;
							}
							else
							{
								daNote.visible = true;
								daNote.active = true;
							}		
					}

				if (!daNote.mustPress && FlxG.save.data.middlescroll)
					{
						switch (daNote.noteData)
						{
							case 0:
								daNote.x = playerStrums.members[0].x;
							case 1:
								daNote.x = playerStrums.members[1].x;
							case 2:
								daNote.x = playerStrums.members[2].x;
							case 3:
								daNote.x = playerStrums.members[3].x;
						}
						if (daNote.isSustainNote)
							daNote.x += daNote.width / 2 + 30;

						//daNote.color.setHSB(0,0,1,1);

						if (FlxG.save.data.bgNote)
							daNote.alpha = 0.1;
						else
							daNote.alpha = 0;
					}

				// daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));

				if (FlxG.save.data.downscroll)
				{
					if (((Conductor.songPosition - Conductor.safeZoneOffset) > daNote.strumTime + (Conductor.crochet / 4)) && !FlxG.save.data.botplay)
						daNote.tooLate = true; 
						else if (((Conductor.songPosition - Conductor.safeZoneOffset) > daNote.strumTime + (Conductor.crochet / 4)) && FlxG.save.data.botplay)
						goodNoteHit(daNote); // welp LOL
						
					daNote.y = (strumLine.y + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2));
					
					if (daNote.isSustainNote)
					{
						if (daNote.animation.curAnim.name.endsWith('end'))
						{
							daNote.y += 10.5 * (Conductor.fakeCrochet / 400) * 1.5 * FlxMath.roundDecimal(SONG.speed, 2)
								+ (46 * (FlxMath.roundDecimal(SONG.speed, 2) - 1));
							daNote.y -= 46 * (1 - (Conductor.fakeCrochet / 600)) * FlxMath.roundDecimal(SONG.speed, 2);
							if (isPixel)
							{
								daNote.y += 8;
							}
							else
							{
								daNote.y -= 19;
							}
						}
						daNote.y += (Note.swagWidth / 2) - (60.5 * (FlxMath.roundDecimal(SONG.speed, 2) - 1));
						daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (FlxMath.roundDecimal(SONG.speed, 2) - 1);

						if (daNote.mustPress || !daNote.tooLate)
						{
							if (daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (strumLine.y + Note.swagWidth / 2)
								&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
							{
								var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
								swagRect.height = ((strumLine.y + Note.swagWidth / 2) - daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;

								daNote.clipRect = swagRect;
							}
						}
					}
				}
				else
				{
					daNote.y = (strumLine.y - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2));

					if (daNote.mustPress || !daNote.tooLate)
					{
						if (daNote.isSustainNote
							&& daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2)
							&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
						{
							var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
							swagRect.y = ((strumLine.y + Note.swagWidth / 2) - daNote.y) / daNote.scale.y;
							swagRect.height -= swagRect.y;

							daNote.clipRect = swagRect;
						}
					}
				}

				// daNote.y = (strumLineNotes.members[daNote.noteData].y + (Conductor.songPosition - daNote.strumTime) * (FlxMath.roundDecimal(SONG.speed, 2)));
				// if (daNote.isSustainNote
				//	&& daNote.y + daNote.offset.y <= strumLine.y + Note.swagWidth / 2
				//	&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				//	{
				//		var swagRect = new FlxRect(0, strumLine.y + Note.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);
				//		swagRect.y /= daNote.scale.y;
				//		swagRect.height -= swagRect.y;

				//		daNote.clipRect = swagRect;
				//	}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}

					p2Strums.members[daNote.noteData].animation.play('confirm', true);
					if (!curStage.startsWith('school'))
					{
						p2Strums.members[daNote.noteData].centerOffsets();
						p2Strums.members[daNote.noteData].offset.x -= 13;
						p2Strums.members[daNote.noteData].offset.y -= 13;
					}
					else
					{
						p2Strums.members[daNote.noteData].centerOffsets();
					}

					switch (Math.abs(daNote.noteData))
					{
						case 0:
							dad.playAnim('singLEFT' + altAnim, true);
							if (FlxG.save.data.camMovement)
								dadCamX = -50;
						case 1:
							dad.playAnim('singDOWN' + altAnim, true);
							if (FlxG.save.data.camMovement)
								dadCamY = 50;
						case 2:
							dad.playAnim('singUP' + altAnim, true);
							if (FlxG.save.data.camMovement)
								dadCamY = -50;
						case 3:
							dad.playAnim('singRIGHT' + altAnim, true);
							if (FlxG.save.data.camMovement)
								dadCamX = 50;
					}

					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				if ((daNote.mustPress && daNote.tooLate && !FlxG.save.data.downscroll || daNote.mustPress && daNote.tooLate && FlxG.save.data.downscroll)
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
						health -= 0.075;
						vocals.volume = 0;

						noteMiss(daNote.noteData);
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}

		p2Strums.forEach(function(spr:FlxSprite)
		{
			if (spr.animation.finished)
			{
				spr.animation.play('static');
				spr.centerOffsets();
			}
		});

		if (!inCutscene)
			keyShit();
	}

	function endSong():Void
	{
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore)
		{
			#if !switch
			var val:Float = convertedAccuracy;
			if (Math.isNaN(val))
				val = 0;
			Highscore.saveScore(SONG.song, songScore, storyDifficulty, val, Date.now());
			#end
		}

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				FlxG.switchState(new StoryMenuState());

				// if ()
				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore)
				{
					NGio.unlockMedal(60961);
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				}

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);


				//put your end song cutscenes here
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
						new FlxTimer().start(2, function (daTimer:FlxTimer) {
							FlxTransitionableState.skipNextTransIn = true;
							FlxTransitionableState.skipNextTransOut = true;
							prevCamFollow = camFollow;
			
							PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);

							LoadingState.loadAndSwitchState(new PlayState());
						});
					default:
						FlxTransitionableState.skipNextTransIn = true;
						FlxTransitionableState.skipNextTransOut = true;
						prevCamFollow = camFollow;
		
						PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
						FlxG.sound.music.stop();
		
						LoadingState.loadAndSwitchState(new PlayState());
				}
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			FlxG.switchState(new FreeplayState());
		}
	}

	function zoomIcon()
	{
		//iconP1.setGraphicSize(Std.int(iconP1.width + 50));
		//iconP2.setGraphicSize(Std.int(iconP2.width + 50));

		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);
		iconP1.updateHitbox();
		iconP2.updateHitbox();
	}

	var endingSong:Bool = false;

	private function popUpScore(daNote:Note, isSus:Bool):Void
	{
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating = daNote.rating;

		if (!isSus)
		{
			switch (daRating)
			{
				case 'shit':
					daRating = 'shit';
					score = 50;
					hittedNotes += 0.10;
				case 'bad':
					daRating = 'bad';
					score = 100;
					hittedNotes += 0.50;
				case 'good':
					daRating = 'good';
					score = 200;
					hittedNotes += 0.75;
				case 'sick':
					daRating = 'sick';
					score = 350;
					if (!isSus)
					{
						hittedNotes += 1;
						if (FlxG.save.data.noteRipples)
							notePressAt(daNote);
					}
			}
		}
		else
		{
			daRating = 'sick';
			score = 350;
			hittedNotes += 1;
		}

		songScore += score;

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.screenCenter();
		rating.y -= 50;
		rating.x = coolText.x - 125;

		if (FlxG.save.data.rChanged)
		{
			rating.x = FlxG.save.data.rX;
			rating.y = FlxG.save.data.rY;
		}
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		rating.cameras = [camHUD];

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);

		if (!curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = FlxG.save.data.antialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = FlxG.save.data.antialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		// for overcharted songs or shit idk
		if (combo >= 10000)
			seperatedScore.push(Math.floor(combo / 10000) % 10);

		if (combo >= 1000)
			seperatedScore.push(Math.floor(combo / 1000) % 10);

		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);
		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.screenCenter();
			numScore.x = rating.x + (43 * daLoop) - 50;
			numScore.y = rating.y + 100;

			if (!curStage.startsWith('school'))
			{
				numScore.antialiasing = FlxG.save.data.antialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);
			numScore.cameras = [camHUD];

			// if (combo >= 10 || combo == 0)
			add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
	}

	private function keyShit():Void
	{
		var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		var pressArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];

		if (FlxG.save.data.botplay)
		{
			holdArray = [false, false, false, false];
			pressArray = [false, false, false, false];
		}

		if (holdArray.contains(true) && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData])
					goodNoteHit(daNote);
			});
		}

		if (pressArray.contains(true) && generatedMusic)
		{
			boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = [];
			var directions:Array<Int> = [];
			var toBeKilledNotes:Array<Note> = [];

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
								toBeKilledNotes.push(daNote);
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

			for (note in toBeKilledNotes)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}

			possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

			var stopNote = false;

			for (i in 0...pressArray.length)
			{
				if (pressArray[i] && !directions.contains(i))
					stopNote = true;
			}

			if (perfectMode)
				goodNoteHit(possibleNotes[0]);
			else if (possibleNotes.length > 0 && !stopNote)
			{
				if (!FlxG.save.data.ghost)
				{
					for (shit in 0...pressArray.length)
					{
						if (pressArray[shit] && !directions.contains(shit))
							noteMiss(shit);
					}
				}
				for (coolNote in possibleNotes)
				{
					if (pressArray[coolNote.noteData])
					{
						goodNoteHit(coolNote);
					}
				}
			}
			else if (!FlxG.save.data.ghost)
			{
				for (shit in 0...pressArray.length)
					if (pressArray[shit])
						noteMiss(shit);
			}

			if (stopNote && possibleNotes.length > 0 && FlxG.save.data.ghost && !FlxG.save.data.botplay)
			{
				if (pressedNotes > 4)
				{
					noteMiss(0);
				}
				else
					pressedNotes++;
			}
		}

		notes.forEachAlive(function(daNote:Note)
		{
			if (FlxG.save.data.downscroll && daNote.y > strumLine.y || !FlxG.save.data.downscroll && daNote.y < strumLine.y)
			{
				if (FlxG.save.data.botplay && daNote.canBeHit && daNote.mustPress || FlxG.save.data.botplay && daNote.tooLate && daNote.mustPress)
				{
					goodNoteHit(daNote);
					boyfriend.holdTimer = daNote.sustainLength;
				}
			}
		});

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || FlxG.save.data.botplay))
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
				boyfriend.dance();
		}

		if (!FlxG.save.data.botplay)
		{
			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (pressArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
					spr.animation.play('pressed');
				if (!holdArray[spr.ID])
					spr.animation.play('static');

				if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
				{
					spr.centerOffsets();
					spr.offset.x -= 13;
					spr.offset.y -= 13;
				}
				else
					spr.centerOffsets();
			});
		}
		else
		{
			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (spr.animation.finished)
				{
					spr.animation.play('static');
					spr.centerOffsets();
				}
				if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
				{
					spr.centerOffsets();
					spr.offset.x -= 13;
					spr.offset.y -= 13;
				}
				else
					spr.centerOffsets();
			});
		}
	}

	var when:Float;

	var timesChecked:Float = 0;

	function notePressAt(note:Note)
	{
		doArrowEffect(playerStrums.members[note.noteData].x, playerStrums.members[note.noteData].y, note.noteData, note);
	}

	public function doArrowEffect(x:Float, y:Float, thedata:Int, ?note:Note = null)
	{
		var click:NotePress = grpNotePresses.recycle(NotePress);
		click.prepareImage(x, y, thedata);
		grpNotePresses.add(click);
	}

	function recalculateAccuracy()
	{
		timesChecked += 1;
		convertedAccuracy = Math.max(0, hittedNotes / timesChecked * 100);
		// convertedAccuracy = (hittedNotes / timesChecked) * 100;
	}

	function noteMiss(direction:Int = 1):Void
	{
		if (!boyfriend.stunned)
		{
			health -= 0.02;
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;
			misses++;

			// var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);
			// var wife:Float = EtternaFunctions.wife3(noteDiff, FlxG.save.data.etternaMode ? 1 : 1.7);
			hittedNotes -= 1;

			songScore -= 10;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			switch (direction)
			{
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
			}
			recalculateAccuracy();
		}
	}

	/*function badNoteCheck()
		{
			// just double pasting this shit cuz fuk u
			// REDO THIS SYSTEM!
			var upP = controls.UP_P;
			var rightP = controls.RIGHT_P;
			var downP = controls.DOWN_P;
			var leftP = controls.LEFT_P;

			if (leftP)
				noteMiss(0);
			if (downP)
				noteMiss(1);
			if (upP)
				noteMiss(2);
			if (rightP)
				noteMiss(3);
	}*/
	function noteCheck(keyP:Bool, note:Note):Void
	{
		if (keyP)
			goodNoteHit(note);
		else
		{
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}

			note.rating = RatingsCheck.getNoteRating(noteDiff);
			if (!note.isSustainNote)
			{
				popUpScore(note, false);
				combo += 1;
			}
			else
			{
				// songScore += 20;
				popUpScore(note, true);
				combo += 1;
				// hittedNotes += 1;
			}

			if (!note.isSustainNote)
				health += 0.05;
			else
				health += 0.02;

			if (pressedNotes >= 1)
				pressedNotes--;

			if (pressedNotes < 0)
				pressedNotes = 0;

			var daAnim:String = '';
			switch (Std.int(Math.abs(note.noteData)))
			{
				case 0:
					daAnim = 'singLEFT';
					if (FlxG.save.data.camMovement)
						bfCamX = -50;
				case 1:
					daAnim = 'singDOWN';
					if (FlxG.save.data.camMovement)
						bfCamY = 50;
				case 2:
					daAnim = 'singUP';
					if (FlxG.save.data.camMovement)
						bfCamY = -50;
				case 3:
					daAnim = 'singRIGHT';
					if (FlxG.save.data.camMovement)
						bfCamX = 50;
			}
			
			boyfriend.playAnim(daAnim, true);
			//boyfriend.holdTimer = 0;

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}
			});

			note.wasGoodHit = true;
			vocals.volume = 1;

			recalculateAccuracy();
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
		if (FlxG.save.data.flashing)
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

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		if (dad.curCharacter == 'spooky' && curStep % 4 == 2)
		{
			// dad.dance();
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, (FlxG.save.data.downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			// if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
			// dad.dance();
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		if (FlxG.save.data.camZoom)
		{
			if (camZooming && PlayState.SONG.notes[Std.int(curStep / 16)].banger && !endingSong)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}
			if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}

			if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}

			if (curSong.toLowerCase() == 'blammed' && curBeat >= 128 && curBeat < 192 && camZooming)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}
		}

		zoomIcon();

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
		}

		if (!dad.animation.curAnim.name.startsWith('sing'))
		{
			dad.dance();
		}
		if (!boyfriend.animation.curAnim.name.startsWith("sing"))
		{
			boyfriend.dance();
		}

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);
			gf.playAnim('cheer', true);
		}

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
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
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
	}

	var curLight:Int = 0;
}
// what
