package game.system.native;

import flash.system.System;
import openfl.Lib;
import flixel.input.touch.FlxTouch;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

class IOS
{
	public static function initialize()
	{
		#if ios
		var foldersToCreate:Array<String> = ["cdev-mods", "crash", "savedata"];
		if (!FileSystem.exists(Sys.getCwd()))
			FileSystem.createDirectory(Sys.getCwd());

		for (flr in foldersToCreate)
		{
			var intendedPath:String = Sys.getCwd() + '/${flr}/';
			if (!FileSystem.exists(intendedPath))
				FileSystem.createDirectory(intendedPath);
			trace("created: " + flr);
		}
		#end
	}

	/**
	 * Crash Handler, for iOS.
	 * @param crashMessage  Message that will be shown.
	 * @param fileName      File Name for the crash log.
	 */
	public static function onCrash(crashMessage:String, fileName:String)
	{
		#if ios
		try
		{
			var crashPath:String = Sys.getCwd() + "/crash/";
			if (!FileSystem.exists(crashPath))
				FileSystem.createDirectory(crashPath);

			File.saveContent(crashPath + fileName, crashMessage);
		}
		catch (e)
		{
			trace("Failed to save crash log, reason: " + e);
		}

		Lib.application.window.alert(crashMessage, 'Error!');
		System.exit(1);
		#end
	}

	/**
	 * Returns FlxTouch, shortcut to `FlxG.touches.getFirst()`.
	 * @return FlxTouch
	 */
	public static function touch():FlxTouch
	{
		return (FlxG.touches.getFirst());
	}

	/**
	 * Touch checker for `spr`, then runs `onTouch` function
	 * @param spr       Sprite that will be checked
	 * @param onTouch   Function that will be runned if Touch = true
	 */
	public static function touchJustPressed(spr:FlxSprite, onTouch:Void->Void)
	{
		if (IOS.touch() != null)
		{
			var sprPos = spr.getScreenPosition(FlxG.camera);
			var touchX = IOS.touch().screenX;
			var touchY = IOS.touch().screenY;
			var overlap:Bool = (touchX >= sprPos.x && touchX <= sprPos.x + spr.frameWidth && touchY >= sprPos.y && touchY <= sprPos.y + spr.frameHeight);
			if (overlap && IOS.touch().justPressed)
			{
				onTouch();
			}
		}
	}
}
