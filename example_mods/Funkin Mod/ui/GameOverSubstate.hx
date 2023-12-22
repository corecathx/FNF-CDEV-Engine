import("game.objects.Boyfriend");
import("flixel.FlxObject");
import("meta.states.LoadingState");
import("flixel.util.FlxGradient");
var bgWoof:FlxSprite;
var bf:Boyfriend;
var gf:Character;
var camFollow:FlxObject;

var stageSuffix:String = "";

var deathCharacter:String = "bf";
var disableFlipX:Bool = false; //false= flipX, true= no flipX

var songBpm:Float = 100;

var isEnding:Bool = false;
var textTitle:FlxText = null;
function create(x, y)
{
	trace("you're dead");
	bgWoof = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [FlxColor.BLACK, FlxColor.BLUE], 1, 90, true);
	bgWoof.antialiasing = CDevConfig.saveData.antialiasing;
	bgWoof.scale.set(1/PlayState.defaultCamZoom,1/PlayState.defaultCamZoom);
	bgWoof.alpha = 0.0001;
	bgWoof.scrollFactor.set();
	add(bgWoof);
	var daStage = PlayState.curStage;
	var daBf:String = '';
	switch (daStage)
	{
		case 'school', 'schoolEvil':
			stageSuffix = '-pixel';
	}
	switch (PlayState.boyfriend.curCharacter){
		case 'bf-pixel':
			daBf = 'bf-pixel-dead';
		case 'bf-holding-gf':
			daBf = 'bf-holding-gf-dead';
		default:
			daBf = deathCharacter;
	}

	Conductor.songPosition = 0;

	gf = new Character(PlayState.gf.getScreenPosition().x,PlayState.gf.getScreenPosition().y, "gf", false);
	add(gf);

	bf = new Boyfriend(x, y, daBf);
	if (disableFlipX) bf.flipX = false;
	add(bf);

	camFollow = new FlxObject(bf.getGraphicMidpoint().x-100, bf.getGraphicMidpoint().y-100, 1, 1);
	add(camFollow);

	FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix, "shared"));
	Conductor.changeBPM(songBpm);

	FlxG.camera.scroll.set();
	FlxG.camera.target = null;

	gf.playAnim("scared", true);
	bf.playAnim("firstDeath");

	textTitle = new FlxText(0, 0, -1,  "", 30/PlayState.defaultCamZoom);
	textTitle.setFormat("VCR OSD Mono", 22/PlayState.defaultCamZoom, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE(), FlxColor.BLACK);
	add(textTitle);
	textTitle.scrollFactor.set();
}
function update(elapsed)
{
	FlxG.camera.zoom = FlxMath.lerp(PlayState.defaultCamZoom, FlxG.camera.zoom, 1 - (elapsed * 6));

	if (controls.ACCEPT)
		endBullshit();

	if (controls.BACK){
		FlxG.sound.music.stop();

		if (PlayState.isStoryMode)
			FlxG.switchState(new StoryMenuState());
		else
			FlxG.switchState(new FreeplayState());
	}

	if (bf.animation.curAnim.name == "firstDeath" && bf.animation.curAnim.curFrame == 12)
		FlxG.camera.follow(camFollow, null, 0.01);

	if (bf.animation.curAnim.name == "firstDeath" && bf.animation.curAnim.finished){
		gf.playAnim("sad", true);
		textTitle.text = "You just died, Try again?";
		textTitle.screenCenter(FlxAxes.XY);
		textTitle.y += 200;
	
		FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
	}

	if (bgWoof.scale.x != PlayState.defaultCamZoom) bgWoof.scale.set(1/PlayState.defaultCamZoom,1/PlayState.defaultCamZoom);

	if (FlxG.sound.music.playing){
		Conductor.songPosition = FlxG.sound.music.time;
	}
}
var ea:FlxTween;
function beatHit(b){
	gf.playAnim("sad", true);
	bf.playAnim("deathLoop", true);

	if (ea != null){
		ea.cancel();
	}
	bgWoof.alpha += 0.3;
	ea = FlxTween.tween(bgWoof, {alpha: 0.0001}, 0.5, {ease:FlxEase.circInOut, onComplete:function(e){
		ea = null;
	}});

	FlxG.camera.zoom += 0.010;
}

function endBullshit():Void
{
	if (!isEnding)
	{
		if (textTitle != null) textTitle.text = "Restarting...";
		isEnding = true;
		textTitle.screenCenter(FlxAxes.XY);
		textTitle.y += 200;
		bf.playAnim("deathConfirm", true);
		gf.playAnim("cheer", true);
		FlxG.sound.music.stop();
		FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));
		if (ea != null){
			ea.cancel();
		}
		bgWoof.alpha += 0.5;
		ea = FlxTween.tween(bgWoof, {alpha: 0.0001}, 2, {ease:FlxEase.circInOut, onComplete:function(e){
			ea = null;
		}});
		new FlxTimer().start(0.7, function(tmr:FlxTimer)
		{
			FlxTween.tween(PlayState, {defaultCamZoom: PlayState.defaultCamZoom - 0.1}, 5, {ease:FlxEase.sineInOut});
			FlxTween.tween(camFollow, {y: camFollow.y - 1000}, 3, {ease:FlxEase.sineInOut});
			FlxTween.tween(FlxG.camera, {angle: -50}, 5, {ease:FlxEase.sineInOut});
			FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
			{
				LoadingState.loadAndSwitchState(new PlayState());
			});
		});
	}
}

