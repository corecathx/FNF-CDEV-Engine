package states;

import flixel.util.FlxTimer;
import haxe.zip.Compress;
import haxe.zip.Entry;
import haxe.zip.Reader;
import cdev.CDevZip;
import haxe.zip.Uncompress;
import sys.io.File;
import openfl.utils.ByteArray;
import lime.utils.Bytes;
import openfl.net.URLRequest;
import lime.app.Event;
import openfl.events.ProgressEvent;
import openfl.net.URLLoader;
import haxe.zip.Writer;
import flixel.math.FlxMath;
import sys.FileSystem;
import haxe.Http;
import flixel.ui.FlxBar;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxSprite;

using StringTools;

class UpdateState extends MusicBeatState
{
	var progressText:FlxText;
	var progBar_bg:FlxSprite;
	var progressBar:FlxBar;
	var entire_progress:Float = 0; // 0 to 100;
	var download_info:FlxText;

	public var online_url:String = "";

	var downloadedSize:Float = 0;
	var content:String = "";
	var maxFileSize:Float = 0;

	var zip:URLLoader;
	var text:FlxText;

	var currentTask:String = "download_update"; // download_update,install_update

	override function create()
	{
		super.create();
		var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image("aboutMenu", "preload"));
		bg.color = 0xFF005FAD;
		bg.scale.set(1.1, 1.1);
		bg.antialiasing = CDevConfig.saveData.antialiasing;
		add(bg);

		text = new FlxText(0, 0, 0, "Please wait while we downloading the new update of CDEV Engine...", 18);
		text.setFormat("VCR OSD Mono", 18, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(text);
		text.screenCenter(X);
		text.y = 280;

		progBar_bg = new FlxSprite(FlxG.width / 2, text.y + 50).makeGraphic(500, 20, FlxColor.BLACK);
		add(progBar_bg);
		progBar_bg.x -= 250;
		progressBar = new FlxBar(progBar_bg.x + 5, progBar_bg.y + 5, LEFT_TO_RIGHT, Std.int(progBar_bg.width - 10), Std.int(progBar_bg.height - 10), this,
			"entire_progress", 0, 100);
		progressBar.numDivisions = 3000;
		progressBar.createFilledBar(0xFF8F8F8F, 0xFF005FAD);
		add(progressBar);

		progressText = new FlxText(progressBar.x, progressBar.y - 20, 0, "0%", 16);
		progressText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(progressText);

		download_info = new FlxText(progressBar.x + progBar_bg.width, progressBar.y + progBar_bg.height, 0, "0B / 0B", 16);
		download_info.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(download_info);

		zip = new URLLoader();
		zip.dataFormat = BINARY;
		zip.addEventListener(ProgressEvent.PROGRESS, onDownloadProgress);
		zip.addEventListener(openfl.events.Event.COMPLETE, onDownloadComplete);

		getUpdateLink();
		prepareUpdate();
		startDownload();
	}

	var lastVare:Float = 0;

	var lastTrackedBytes:Float = 0;
	var lastTime:Float = 0;
	var time:Float = 0;
	var speed:Float = 0;

	var downloadTime:Float = 0;

	var currentFile:String = "";

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		switch (currentTask)
		{
			case "download_update":
				time += elapsed;
				if (time > 1)
				{
					speed = downloadedSize - lastTrackedBytes;
					lastTime = time;
					lastTrackedBytes = downloadedSize;
					time = 0;

					// Divide file size by data speed to obtain download time.
					downloadTime = maxFileSize / (speed / 8);
				}

				if (downloadedSize != lastVare)
				{
					lastVare = downloadedSize;
					download_info.text = convert_size(Std.int(downloadedSize)) + " / " + convert_size(Std.int(maxFileSize));
					download_info.x = (progBar_bg.x + progBar_bg.width) - download_info.width;

					entire_progress = (downloadedSize / maxFileSize) * 100;
				}

				progressText.text = FlxMath.roundDecimal(entire_progress, 2) + "%" + " - " + convert_size(Std.int(speed)) + "/s" + " - "
					+ convert_time(downloadTime);
			case "install_update":
				entire_progress = (downloadedSize / maxFileSize) * 100;
				progressText.text = FlxMath.roundDecimal(entire_progress, 2) + "%";
				download_info.text = currentFile;
				download_info.x = (progBar_bg.x + progBar_bg.width) - download_info.width;
		}
	}

	function getUpdateLink()
	{
		trace('reading from github: update.txt');
		var http = new Http("https://raw.githubusercontent.com/Core5570RYT/FNF-CDEV-Engine/master/update.txt");

		http.onData = function(data:String)
		{
			online_url = "https://github.com" + data.split('\n')[0].trim();

			trace("update url: " + online_url);
		}

		http.onError = function(error)
		{
			trace("can't read file, error: " + error);
		}

		http.request();

		//online_url = "https://github.com/Core5570RYT/fnf-cdev-engine-testing/releases/download/heh/CDEV.Engine.zip";
	}

	function prepareUpdate()
	{
		trace("preparing update...");
		trace("checking if update folder exists...");

		if (!FileSystem.exists("./update/"))
		{
			trace("update folder not found, creating the directory...");
			FileSystem.createDirectory("./update");
			FileSystem.createDirectory("./update/temp/");
			FileSystem.createDirectory("./update/raw/");
		}
		else
		{
			trace("update folder found");
		}
	}

	var httpHandler:Http;

	public function startDownload()
	{
		trace("starting download process...");

		zip.load(new URLRequest(online_url));

		/*var aa = new Http(online_url);
			aa.request();
			trace(aa.responseHeaders);
			trace(aa.responseHeaders.get("size"));

			maxFileSize = Std.parseInt(aa.responseHeaders.get("size")); 

			content = requestUrl(online_url);
			sys.io.File.write(path, true).writeString(content);
			trace(content.length + " bytes downloaded"); */
	}

	public function requestUrl(url:String):String
	{
		httpHandler = new Http(url);
		var r = null;
		httpHandler.onData = function(d)
		{
			r = d;
		}
		httpHandler.onError = function(e)
		{
			trace("error while downloading file, error: " + e);
		}
		httpHandler.request(false);
		return r;
	}

	function convert_size(bytes:Int)
	{
		// public static String readableFileSize(long size) {
		//	if(size <= 0) return "0";
		//	final String[] units = new String[] { "B", "kB", "MB", "GB", "TB" };
		//	int digitGroups = (int) (Math.log10(size)/Math.log10(1024));
		//	return new DecimalFormat("#,##0.#").format(size/Math.pow(1024, digitGroups)) + " " + units[digitGroups];
		// }
		if (bytes == 0)
		{
			return "0B";
		}

		var size_name:Array<String> = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
		var digit:Int = Std.int(Math.log(bytes) / Math.log(1024));
		return FlxMath.roundDecimal(bytes / Math.pow(1024, digit), 2) + " " + size_name[digit];
	}

	function convert_time(time:Float)
	{
		var seconds = Std.int((time / 1000) % 60);
		var minutes = Std.int((time / (1000 * 60)) % 60);
		var hours = Std.int((time / (1000 * 60 * 60)) % 24);

		var secStr:String = '' + seconds;
		var minStr:String = '' + minutes;
		var hoeStr:String = '' + hours;

		var string:String = "";

		if (secStr.length < 2)
		{
			secStr = "0" + seconds;
		}
		if (minStr.length < 2 && hours != 0)
		{
			minStr = "0" + minutes;
		}
		if (hoeStr.length < 2)
		{
			hoeStr = "0" + hours;
		}

		string = '$hoeStr:$minStr:$secStr';
		return string;
	}

	function onDownloadProgress(result:ProgressEvent)
	{
		downloadedSize = result.bytesLoaded;
		maxFileSize = result.bytesTotal;
	}

	function onDownloadComplete(result:openfl.events.Event)
	{
		var path:String = './update/temp/'; // cdev-engine_' + TitleState.onlineVer + ".rar";

		if (!FileSystem.exists(path))
		{
			FileSystem.createDirectory(path);
		}

		if (!FileSystem.exists("./update/raw/"))
		{
			FileSystem.createDirectory("./update/raw/");
		}

		var fileBytes:Bytes = cast(zip.data, ByteArray);
		text.text = "Update downloaded successfully, saving update file...";
		text.screenCenter(X);
		File.saveBytes(path + "cdev-" + TitleState.onlineVer + ".zip", fileBytes);
		text.text = "Unpacking update file...";
		text.screenCenter(X);
		// Uncompress.run(File.getBytes(path + "cdev-" + TitleState.onlineVer + ".zip"))
		CDevZip.unzip(path + "cdev-" + TitleState.onlineVer + ".zip", "./update/raw/");
		text.text = "Update file has unpacked, installing update...";
		text.screenCenter(X);

		FlxG.sound.play(Paths.sound('confirmMenu'));

		new FlxTimer().start(1, function(e:FlxTimer)
		{
			installUpdate("./update/raw/");
		});
	}

	function installUpdate(updateFolder:String)
	{
		currentTask = "install_update";
		downloadedSize = 0;
		maxFileSize = 0;
		entire_progress = 0;
		var game_path:String = FileSystem.fullPath("./assets/data").replace("/assets/data", "");
		trace(game_path);

		var game_exe_path:String = "";

		var directories:Array<String> = FileSystem.readDirectory(updateFolder);
		trace(directories);
		maxFileSize = directories.length;
		for (file in directories)
		{
			currentFile = file;
			//folder
			if (FileSystem.isDirectory(updateFolder + "/" + file))
			{
				trace(file + " was a directory.");
				if (!FileSystem.exists(game_path + "/" + file))
				{
					FileSystem.createDirectory(game_path + "/" + file);
				}

				directories.remove(file);
				continue;
			}

			if (file.contains("CDEV Engine"))
			{
				game_exe_path = file;
				trace(game_exe_path);
				directories.remove(file);
				continue;
			}

			downloadedSize = directories.indexOf(file);
		}
	}
}
