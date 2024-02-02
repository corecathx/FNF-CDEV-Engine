import("game.objects.Alphabet");
import("meta.substates.OptionsSubState");
import("game.cdev.engineutils.DiscordClient");

var menuItems:Array<String> = ['Resume', 'Restart Song', 'Options', 'Exit to menu'];
var grpMenuShit:Array<Alphabet> = [];
var curSelected:Int = 0;
var pauseMusic:FlxSound;
var traceWindow:TraceLog;

function create(x, y)
{
	current.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	menuItems = ['Resume', 'Restart Song', 'Options', 'Exit to menu'];

	pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
	pauseMusic.volume = 0;
	pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

	FlxG.sound.list.add(pauseMusic);

	var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
	bg.alpha = 0;
	bg.scrollFactor.set();
	add(bg);

	var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
	levelInfo.text += PlayState.SONG.song;
	levelInfo.scrollFactor.set();
	levelInfo.setFormat("VCR OSD Mono", 32);
	levelInfo.updateHitbox();
	add(levelInfo);

	var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
	levelDifficulty.text += PlayState.difficultyName;
	levelDifficulty.scrollFactor.set();
	levelDifficulty.setFormat("VCR OSD Mono", 32);
	levelDifficulty.updateHitbox();
	add(levelDifficulty);

	var chartingText:FlxText = new FlxText(20, 15 + 64, 0, "", 32);
	chartingText.text = 'CHARTING MODE';
	chartingText.scrollFactor.set();
	chartingText.setFormat("VCR OSD Mono", 32);
	chartingText.updateHitbox();
	add(chartingText);

	levelDifficulty.alpha = 0;
	levelInfo.alpha = 0;
	chartingText.alpha = 0;

	levelInfo.x = FlxG.width - (levelInfo.width + 20);
	levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
	chartingText.x = FlxG.width - (chartingText.width + 20);

	FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
	FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
	FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
	FlxTween.tween(chartingText, {alpha: 1, y: chartingText.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 1});

	if (PlayState.chartingMode)
		chartingText.visible = true;
	else
		chartingText.visible = false;

	for (i in 0...menuItems.length)
	{
		var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
		songText.isMenuItem = true;
		songText.targetY = i;
		add(songText);

		grpMenuShit.push(songText);
	}

	changeSelection(0);

}

function changePres(idk, stat){
	DiscordClient.changePresence(idk, stat);
}

function onDestroy(){
	pauseMusic.destroy();
}

function onCloseSubState(){
    changeSelection(0);
}
var waitTimer = 0;
var alreadyTriggered:Bool = false;
function onPauseStarted(e){
	waitTimer += e;
	if (waitTimer >= 0.2 && !alreadyTriggered){
		changePres("Paused on my face", "Bruh.");
		alreadyTriggered = true;
	}
}
function update(e)
{
	onPauseStarted(e);
	if (FlxG.keys.justPressed.CONTROL){
		trace("Called");
		changePres("Stop", "Stop that thing, dang it. AAAAAAAAAAAAAAAAAAAAAAA");
	}
	if (pauseMusic.volume < 0.5)
		pauseMusic.volume += 0.01 * e;

	var upP = controls.UI_UP_P;
	var downP = controls.UI_DOWN_P;
	var accepted = controls.ACCEPT;

	if (upP)
		changeSelection(-1);
	if (downP)
		changeSelection(1);

	if (accepted)
	{
		var daSelected:String = menuItems[curSelected];

		switch (daSelected)
		{
			case "Resume":
				close();
			case "Restart Song":
				FlxG.resetState();
            case "Options":
                for (item in grpMenuShit)
                    item.alpha = 0;
                current.openSubState(new OptionsSubState());
            case "Exit to menu":
                PlayState.chartingMode = false;
                FlxG.sound.music.onComplete = null;
                if (PlayState.isStoryMode)
                    FlxG.switchState(new MainMenuState());
                else{
                    FlxG.switchState(new FreeplayState());
                }
		}
	}
}

function changeSelection(change:Int = 0):Void
{
	FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
	curSelected += change;

	if (curSelected < 0)
		curSelected = menuItems.length - 1;
	if (curSelected >= menuItems.length)
		curSelected = 0;

	var bullShit:Int = 0;

    for (item in grpMenuShit){
		item.targetY = bullShit - curSelected;
		bullShit++;

		item.alpha = 0.6;
		// item.setGraphicSize(Std.int(item.width * 0.8));

		if (item.targetY == 0)
		{
			item.alpha = 1;
			// item.setGraphicSize(Std.int(item.width));
		}
    }
}
