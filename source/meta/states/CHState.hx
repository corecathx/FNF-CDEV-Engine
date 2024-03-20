package meta.states;

import flixel.FlxG;
import game.cdev.SongPosition;
import flixel.math.FlxMath;
import sys.io.File;
import openfl.utils.ByteArray;
import openfl.net.URLRequest;
import openfl.events.ProgressEvent;
import openfl.net.URLLoader;
import flixel.util.FlxColor;
import game.objects.FunkinBar;
import openfl.display.BlendMode;
import flixel.text.FlxText;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxSprite;

typedef MAStuff = {
	var name:String;
	var url:String;
	var fname:String;
}
/**
 * Used when Crash Handler is missing for CDEV Engine.
 */
class CHState extends MusicBeatState {
    var checker:FlxBackdrop;
    var mainText:FlxText;
	var progBar:FunkinBar;

	var updateStuff:Array<MAStuff> = [];
	var curStat:Int = 0;

	var progress = {min: 0.0,max:1.0};
	var downloadSize:Float = 0;
	var curProgress:Float = 0;

	var download_info:FlxText;
	var progressText:FlxText;

	var dataLoad:URLLoader;
    override function create() 
    {
		updateStuff = [
			{
				name: "CDEV Engine Crash Handler",
				url: "https://github.com/Core5570RYT/FNF-CDEV-Engine/releases/download/v"+CDevConfig.engineVersion+"/cdev-crash_handler.exe",
				fname: "./cdev-crash_handler.exe"
			}
		];

        var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image("aboutMenu", "preload"));
		bg.color = 0xFF005FAD;
		bg.scale.set(1.1, 1.1);
		bg.antialiasing = CDevConfig.saveData.antialiasing;
		add(bg);

        checker = new FlxBackdrop(Paths.image('checker', 'preload'), XY);
		checker.scale.set(1.4, 1.4);
		checker.color = 0xFF006AFF;
		checker.blend = BlendMode.LAYER;
		add(checker);
		checker.scrollFactor.set(0, 0.07);
		checker.alpha = 0.2;
		checker.updateHitbox();

		mainText = new FlxText(0, 290, 0, "Downloading update...", 18);
		mainText.setFormat("VCR OSD Mono", 18, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(mainText);
		mainText.screenCenter(X);

		progBar = new FunkinBar(0,mainText.y + 50,"healthBar", ()->{return progress.min;},0, progress.max);
		progBar.leftToRight = true;
		progBar.setColors(0xFF8F8F8F, 0xFF005FAD);
		progBar.screenCenter(X);
		add(progBar);

		progressText = new FlxText(progBar.x, progBar.y - 20, 0, "0%", 16);
		progressText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(progressText);

		download_info = new FlxText(progBar.x + progBar.width, progBar.y + progBar.height, 0, "0B / 0B", 16);
		download_info.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(download_info);

		dataLoad = new URLLoader();
		dataLoad.dataFormat = BINARY;
		dataLoad.addEventListener(ProgressEvent.PROGRESS, (result:ProgressEvent) -> {
			curProgress = result.bytesLoaded;
			downloadSize = result.bytesTotal;
		});
		dataLoad.addEventListener(openfl.events.Event.COMPLETE, (_) ->{
			var fileBytes:lime.utils.Bytes = cast(dataLoad.data, ByteArray);
			File.saveBytes(updateStuff[curStat].fname, fileBytes);
			dataLoad.close();
			curStat++;
			if (curStat < updateStuff.length){
				doThis(updateStuff[curStat].url);
			} else{
				FlxG.switchState(new TitleState());
			}
		});
		doThis(updateStuff[curStat].url);
        super.create();
    }

	function doThis(url:String){
		mainText.text = "Downloading: "+updateStuff[curStat].name;
		mainText.screenCenter(X);
		dataLoad.load(new URLRequest(url));
	}

	var lastVare:Float = 0;

	var lastTrackedBytes:Float = 0;
	var lastTime:Float = 0;
	var time:Float = 0;
	var speed:Float = 0;

	var downloadTime:Float = 0;

	override function update(elapsed:Float){
		super.update(elapsed);

		time += elapsed;
		if (time > 1)
		{
			speed = curProgress - lastTrackedBytes;
			lastTime = time;
			lastTrackedBytes = curProgress;
			time = 0;

			// Divide file size by data speed to obtain download time.
			downloadTime = ((downloadSize - curProgress) / speed) * 1000;
		}

		if (curProgress != lastVare)
		{
			lastVare = curProgress;
			download_info.text = CDevConfig.utils.convert_size(Std.int(curProgress)) + " / " + CDevConfig.utils.convert_size(Std.int(downloadSize));
			download_info.x = (progBar.x + progBar.width) - download_info.width;

			progress.min = (curProgress / downloadSize);
		}

		progressText.text = FlxMath.roundDecimal(progress.min*100, 2) + "%" + " - " + CDevConfig.utils.convert_size(Std.int(speed)) + "/s" + " - "
			+ SongPosition.getCurrentDuration(downloadTime) + " remaining";
	}
	
}