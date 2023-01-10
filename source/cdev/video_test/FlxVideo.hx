package cdev.video;

import states.LoadingState;
import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.events.Event;
import cdev.video.vlc.VlcBitmap;

class FlxVideo
{
	public var finishCallback:Void->Void;
	public var stateCallback:FlxState;

	public var bitmap:VlcBitmap;

	var killed:Bool = false;

	public var sprite:FlxSprite;

	public function new()
	{
		// FlxG.autoPause = false;
	}

	public function playMP4(path:String, ?repeat:Bool = false, ?outputTo:FlxSprite = null, ?isWindow:Bool = false, ?isFullscreen:Bool = false,
			?midSong:Bool = false):Void
	{
		if (killed)
			return;
		if (!midSong)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.stop();
			}
		}

		bitmap = new VlcBitmap();

		if (FlxG.stage.stageHeight / 9 < FlxG.stage.stageWidth / 16)
		{
			bitmap.set_width(FlxG.stage.stageHeight * (16 / 9));
			bitmap.set_height(FlxG.stage.stageHeight);
		}
		else
		{
			bitmap.set_width(FlxG.stage.stageWidth);
			bitmap.set_height(FlxG.stage.stageWidth / (16 / 9));
		}

		bitmap.onVideoReady = onVLCVideoReady;
		bitmap.onComplete = onVLCComplete;
		bitmap.onError = onVLCError;

		FlxG.stage.addEventListener(Event.ENTER_FRAME, update);

		if (repeat)
			bitmap.repeat = -1;
		else
			bitmap.repeat = 0;

		bitmap.inWindow = isWindow;
		bitmap.fullscreen = isFullscreen;

		FlxG.addChildBelowMouse(bitmap);
		bitmap.play(checkFile(path));

		if (outputTo != null)
		{
			// lol this is bad kek
			bitmap.alpha = 0;

			sprite = outputTo;
		}
	}

	function checkFile(fileName:String):String
	{
		var pDir = "";
		var appDir = "file:///" + Sys.getCwd();

		if (fileName.indexOf(":") == -1) // Not a path
			pDir = appDir;
		else if (fileName.indexOf("file://") == -1 || fileName.indexOf("http") == -1) // C:, D: etc? ..missing "file:///" ?
			pDir = "file:///";

		return pDir + fileName;
	}

	/////////////////////////////////////////////////////////////////////////////////////

	function onVLCVideoReady()
	{
		if (killed)
			return;
		trace("video loaded!");

		if (sprite != null && !bitmap.isDisposed && bitmap.bitmapData != null)
		{
			var graph:FlxGraphic = FlxG.bitmap.add(bitmap.bitmapData, false, "");

			trace(graph.imageFrame);

			// super fucking weird behavoir where this just breaks when leaving cooling, something cuz of somethin ig.
			// fixed cuz of these statements.

			if (graph.imageFrame.frame == null)
				return;

			if (graph.imageFrame.frame.name == null)
			{
				if (killed)
					return;
			}

			trace("here is your graphic big man " + bitmap.videoWidth + "x" + bitmap.videoHeight + " " + bitmap.bitmapData.height);
			sprite.loadGraphic(graph);

			sprite.setGraphicSize(945, 472);
		}
	}

	public function onVLCComplete()
	{
		if (killed)
			return;
		bitmap.stop();

		// Clean player, just in case! Actually no.

		trace("Big, Big Chungus, Big Chungus!");

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			if (finishCallback != null)
			{
				finishCallback();
			}
			else if (stateCallback != null)
			{
				LoadingState.loadAndSwitchState(stateCallback);
			}

			bitmap.dispose();

			if (FlxG.game.contains(bitmap))
			{
				FlxG.game.removeChild(bitmap);
			}
		});
	}

	public function kill()
	{
		killed = true;
		bitmap.stop();

		if (finishCallback != null)
		{
			finishCallback();
		}

		bitmap.visible = false;
	}

	function onVLCError()
	{
		if (killed)
			return;
		if (finishCallback != null)
		{
			finishCallback();
		}
		else if (stateCallback != null)
		{
			LoadingState.loadAndSwitchState(stateCallback);
		}
	}

	function update(e:Event)
	{
		if (killed)
			return;
		bitmap.volume = FlxG.sound.volume + 0.3; // shitty volume fix. then make it louder.

		if (FlxG.sound.volume <= 0.1)
			bitmap.volume = 0;
	}
}