package meta.modding.week_editor;

import meta.modding.week_editor.backup.WeekEditor.FreeplayEditor;
import openfl.events.IOErrorEvent;
import openfl.events.Event;
import openfl.net.FileReference;
import haxe.Json;
import flixel.addons.ui.FlxUIButton;
import game.cdev.objects.CDevInputText;
import game.Stage;
import meta.substates.LoadingSubstate;
import game.song.Song;
import sys.FileSystem;
import haxe.Timer;
import game.system.FunkinThread;
import game.objects.Character;
import game.objects.DifficultyText;
import flixel.group.FlxGroup.FlxTypedGroup;
import game.CoolUtil;
import game.objects.StoryItem;
import openfl.display.BlendMode;
import flixel.addons.display.FlxBackdrop;
import game.cdev.engineutils.Discord.DiscordClient;
import flixel.group.FlxSpriteGroup;
import meta.modding.week_editor.WeekData;
import game.cdev.engineutils.Highscore;

using StringTools;

/**
 * Complete rework of the Week Editor
 */
class WeekEditor extends MusicBeatState
{
	var _modWeeks:Array<StoryData> = [];
	var curWeek:Int = 0;
	var curDiff:Int = 0;
	var diffStr:String = "easy";
	var goBack:Bool = false; // does the escape button pressed?

	// Objects
	var bg:FlxSprite;
	var checkerBG:FlxBackdrop;

	var weekListBG:FlxSpriteGroup;
	var weekList:FlxTypedGroup<StoryItem>;

	var diffText:DifficultyText;

	var weekName:FlxText;
	var trackTxt:FlxText;

	var character_group:FlxTypedGroup<Character>;

	//editor objects
	var infoText:FlxText;
	var butt_save:FlxUIButton;
	var butt_free:FlxUIButton;

	var weekToReplace = null;
	var newFile = null;
	public function new(?repWeek:Int, ?repFile:WeekFile){
		super();
		weekToReplace = repWeek;
		newFile = repFile;
	}

	override function create()
	{
		initialize();
		createStateUI();
		changeWeek();

		editorInit();
		super.create();
	}

	// Editor Objects
	var label_weekImage:FlxText;
	var input_weekImage:CDevInputText;

	var label_weekName:FlxText;
	var input_weekName:CDevInputText;

	var label_characters:FlxText;
	var input_characters:CDevInputText;

	var label_tracks:FlxText;
	var input_tracks:CDevInputText;

	var label_difficulties:FlxText;
	var input_difficulties:CDevInputText;

	function editorInit()
	{
		try
		{
			var font = "VCR OSD Mono";
			var boxWidth = 380;
			// week image sprite
			label_weekImage = new FlxText(0, FlxG.height * 0.65, boxWidth, "Week Image file path", 14);
			input_weekImage = new CDevInputText(0, label_weekImage.y + label_weekImage.height + 2, boxWidth, "week0", 16, FlxColor.WHITE,
				FlxColor.fromRGB(70, 70, 70));
			input_weekImage.size = label_weekImage.size;
			input_weekImage.onTextChanged = (nText:String) ->
			{
				_modWeeks[curWeek].data.weekTxtImgPath = nText;
				weekList.members[curWeek].changeGraphic(_modWeeks[curWeek].data.weekTxtImgPath);
			}

			label_weekImage.font = input_weekImage.font = font;
			label_weekImage.alignment = input_weekImage.alignment = RIGHT;

			// week name
			label_weekName = new FlxText(0, input_weekImage.y + input_weekImage.height + 2, boxWidth, "Week Name", 14);
			input_weekName = new CDevInputText(0, label_weekName.y + label_weekName.height + 2, boxWidth, "Your Week Name Here", 16, FlxColor.WHITE,
				FlxColor.fromRGB(70, 70, 70));
			input_weekName.size = label_weekName.size;
			input_weekName.onTextChanged = (nText:String) ->
			{
				_modWeeks[curWeek].data.weekName = nText;
				weekName.text = _modWeeks[curWeek].data.weekName.toUpperCase();
			}

			label_weekName.font = input_weekName.font = font;
			label_weekName.alignment = input_weekName.alignment = RIGHT;

			// characters
			label_characters = new FlxText(0, input_weekName.y + input_weekName.height + 2, boxWidth, "Characters (Separate with \",\")", 14);
			input_characters = new CDevInputText(0, label_characters.y + label_characters.height + 2, boxWidth, "dad,bf,gf", 16, FlxColor.WHITE,
				FlxColor.fromRGB(70, 70, 70));
			input_characters.size = label_characters.size;
			input_characters.onTextChanged = (nText:String) ->
			{
				_modWeeks[curWeek].data.weekCharacters = nText.trim().split(",");
				updateCharacters();
			}

			label_characters.font = input_characters.font = font;
			label_characters.alignment = input_characters.alignment = RIGHT;

			// tracks
			label_tracks = new FlxText(0, input_characters.y + input_characters.height + 2, boxWidth, "Tracks (Separate with \",\")", 14);
			input_tracks = new CDevInputText(0, label_tracks.y + label_tracks.height + 2, boxWidth, "Bopeebo,Fresh,Dadbattle", 16, FlxColor.WHITE,
				FlxColor.fromRGB(70, 70, 70));
			input_tracks.size = label_characters.size;
			input_tracks.onTextChanged = (nText:String) ->
			{
				_modWeeks[curWeek].data.tracks = nText.trim().split(",");
				updateTrackList();
				updateFreeplaySongs(nText);
			}

			label_tracks.font = input_tracks.font = font;
			label_tracks.alignment = input_tracks.alignment = RIGHT;

			// difficulties
			label_difficulties = new FlxText(0, input_tracks.y + input_tracks.height + 2, boxWidth, "Difficulties (Separate with \",\")", 14);
			input_difficulties = new CDevInputText(0, label_difficulties.y + label_difficulties.height + 2, boxWidth, "Bopeebo,Fresh,Dadbattle", 16,
				FlxColor.WHITE, FlxColor.fromRGB(70, 70, 70));
			input_difficulties.size = label_characters.size;
			input_difficulties.onTextChanged = (nText:String) ->
			{
				_modWeeks[curWeek].data.weekDifficulties = nText.trim().split(",");
			}

			label_difficulties.font = input_difficulties.font = font;
			label_difficulties.alignment = input_difficulties.alignment = RIGHT;

			// Positioning (bruh)
			for (index => object in [
				label_weekImage,
				label_weekName,
				label_characters,
				label_tracks,
				label_difficulties,
				input_weekImage,
				input_weekName,
				input_characters,
				input_tracks,
				input_difficulties
			])
			{
				@:privateAccess object.calcFrame();
				if (index+1 > 5) {
					var inp:CDevInputText = cast object;
					@:privateAccess inp.caret.visible = false;
					inp.onFocus = onTBFocusChange;
				} else {
					var txt:FlxText = cast object;
					txt.borderStyle = OUTLINE;
					txt.borderColor = FlxColor.BLACK;
					txt.borderSize = 1;
				}
				object.x = FlxG.width - (boxWidth + 20);
				add(object);
			}
		}
		catch (e)
		{
			Log.error("WHAT??" + e.toString());
		}

		infoText = new FlxText(0, 0, -1, "", 18);
		infoText.setFormat(FunkinFonts.VCR, 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		add(infoText);
		infoText.alpha = 0.8;

		butt_save = new FlxUIButton(20,FlxG.height-40,"",()->{
			var jString:String = Json.stringify(_modWeeks[curWeek].data, "\t");
			if (jString != null && jString.length > 0){
				var fr:FileReference = new FileReference();
				fr.addEventListener(Event.COMPLETE, (_)->{
					CDevPopUp.open(this, "Info", "File saved successfully.", [{text: "OK", callback:()->{closeSubState();}}], false, true);
				});
				fr.addEventListener(Event.CANCEL, (_)->{
					CDevPopUp.open(this, "Info", "File save process cancelled.", [{text: "OK", callback:()->{closeSubState();}}], false, true);
				});
				fr.addEventListener(IOErrorEvent.IO_ERROR, (a)->{
					CDevPopUp.open(this, "Error", "Failed saving week data, " + a.toString(), [{text: "OK", callback:()->{closeSubState();}}], false, true);
				});
				fr.save(jString.trim(), "week.json");
			} else {
				CDevPopUp.open(this, "Error", "An error occured while generating JSON data for your week.", [{text: "OK", callback:()->{closeSubState();}}], false, true);
			}
		},true,false,0xFF0D8AC4);
		add(butt_save);
		butt_save.resize(50,20);
		butt_save.addIcon(new FlxSprite().loadGraphic(Paths.image("ui/file","shared")));

		butt_free = new FlxUIButton(butt_save.x + butt_save.width + 10,FlxG.height-40,"Freeplay",()->{
			var jsonShit:WeekFile = _modWeeks[curWeek].data;
			if (CDevConfig.saveData.smoothAF)
				FlxTween.tween(FlxG.camera, {zoom: 1.5}, 1, {ease: FlxEase.quadOut});
			FlxG.switchState(new FreeplayEditor(curWeek,jsonShit));
		},true,false);
		add(butt_free);
		butt_free.resize(50,20);

		updateUI();
	}

	function updateUI() {
		if (input_weekImage == null || _modWeeks[curWeek] == null) return; // bro
		input_weekImage.text = _modWeeks[curWeek].data.weekTxtImgPath;
		input_weekName.text = _modWeeks[curWeek].data.weekName;

		var wc =  _modWeeks[curWeek].data.weekCharacters.toString();
		var wt =  _modWeeks[curWeek].data.tracks.toString();
		var wd =  _modWeeks[curWeek].data.weekDifficulties.toString();
		input_characters.text = wc.substr(1, wc.length - 2);
		input_tracks.text = wt.substr(1, wt.length - 2);
		input_difficulties.text = wd.substr(1, wd.length - 2);
	}

	var currently_writing:Bool = false;
	function onTBFocusChange(focus:Bool) {
        currently_writing = focus;
		trace("controls: "+currently_writing);
    }

	function initialize()
	{
		#if desktop
		DiscordClient.changePresence("Editing Story Mode weeks", null);
		#end
		Paths.destroyLoadedImages(false);

		// load
		var path = Paths.mods(Paths.currentMod + '/data/weeks/');
		if (FileSystem.isDirectory(path))
			WeekData.loadWeekFileFromPath(path, Paths.currentMod, _modWeeks, true);

		if (weekToReplace != null && newFile != null) {
			_modWeeks[weekToReplace].data = newFile;
		}

		FlxG.mouse.visible = true;
	}

	function createStateUI()
	{
		bg = new FlxSprite().loadGraphic(Paths.image('aboutMenu', "preload"));
		bg.updateHitbox();
		bg.screenCenter();
		bg.color = 0xFF0066FF;
		bg.antialiasing = CDevConfig.saveData.antialiasing;
		add(bg);

		checkerBG = new FlxBackdrop(Paths.image('checker', 'preload'), XY);
		checkerBG.color = 0xFF006AFF;
		checkerBG.blend = BlendMode.ADD;
		checkerBG.alpha = 0.3;
		add(checkerBG);

		character_group = new FlxTypedGroup<Character>();
		add(character_group);

		genBlackBars();

		weekList = new FlxTypedGroup<StoryItem>();
		add(weekList);

		makeWeekSprites();

		// Top and Bottom bars
		var bHeight:Int = 50;
		for (i in 0...2)
		{
			var spr:FlxSprite = new FlxSprite(0, (FlxG.height - bHeight) * i).makeGraphic(FlxG.width, bHeight, FlxColor.BLACK);
			spr.alpha = 0.7;
			add(spr);
		}

		weekName = new FlxText(0, 10, FlxG.width - 20, "AWESOME WEEK NAME", 30);
		weekName.setFormat(FunkinFonts.VCR, 30, FlxColor.WHITE, RIGHT);
		add(weekName);

		trackTxt = new FlxText(20, 0, FlxG.width, "TRACKS: Song", 30);
		trackTxt.y = (FlxG.height - trackTxt.height) + 5;
		trackTxt.setFormat(FunkinFonts.VCR, 30, FlxColor.WHITE, CENTER);
		add(trackTxt);

		diffText = new DifficultyText(0, 0);
		diffText.active = diffText.visible = false;
		add(diffText);
	}

	function makeWeekSprites()
	{
		for (index => week in _modWeeks)
		{
			Paths.currentMod = week.mod;
			var weekThing:StoryItem = new StoryItem(0, 0, 0, week.data.weekTxtImgPath);
			weekThing.y = ((FlxG.height - weekThing.height) / 2) + ((weekThing.height + 40) * index);
			weekThing.x = (-500) - (35 * index);
			weekThing.targetY = index;
			weekThing.scale.set(0.6, 0.6);
			weekThing.ID = index;
			weekList.add(weekThing);

			weekThing.antialiasing = CDevConfig.saveData.antialiasing;
			weekThing.changeGraphic(week.data.weekTxtImgPath);

			if (weekThing.fileMissing)
				weekThing.visible = false;
		}
	}

	/**
	 * Generating most blackbar stuffs used in the menu.
	 */
	function genBlackBars()
	{
		// Week List BG
		weekListBG = new FlxSpriteGroup(-150);
		add(weekListBG);
		var tmp:FlxSprite = new FlxSprite().makeGraphic(576, 884, FlxColor.BLACK);
		var tmp2:FlxSprite = new FlxSprite(tmp.x + tmp.width + 30).makeGraphic(20, Std.int(tmp.height), FlxColor.BLACK);

		for (i in [tmp, tmp2])
		{
			i.angle = 20;
			i.alpha = 0.5;
			weekListBG.add(i);
		}
		weekListBG.antialiasing = CDevConfig.saveData.antialiasing;
	}

	function updateFreeplaySongs(wa:String)
	{
		var text:Array<String> = wa.trim().split(',');
		for (i in 0...text.length)
			text[i] = text[i].trim();

		while (text.length < _modWeeks[curWeek].data.freeplaySongs.length)
			_modWeeks[curWeek].data.freeplaySongs.pop();

		for (i in 0...text.length)
		{
			if (i >= _modWeeks[curWeek].data.freeplaySongs.length)
			{
				var free:FreeplaySong = {
					song: text[i],
					character: "dad",
					bpm: 120,
					colors: [150, 120, 255]
				}
				_modWeeks[curWeek].data.freeplaySongs.push(free);
				trace("can't find one, creating new one");
			}
			else
			{
				_modWeeks[curWeek].data.freeplaySongs[i].song = text[i];
				// (weekFile.songs[i][1] == null || weekFile.songs[i][1])
				if (_modWeeks[curWeek].data.freeplaySongs[i].character == null)
				{
					_modWeeks[curWeek].data.freeplaySongs[i].character = 'dad';
					_modWeeks[curWeek].data.freeplaySongs[i].colors = [150, 120, 255];
					_modWeeks[curWeek].data.freeplaySongs[i].bpm = 120;
				}
				trace("find one, editing the existing one");
			}
		}
	}

	var bgAlphaI:Float = 1;
	var bgScaleI:Float = 1;
	var speed:Float = 1;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		checkerBG.x -= elapsed * 20;
		checkerBG.y -= elapsed * 20;

		var lerpFactor:Float = 1 - (elapsed * 12);
		var bgLerp:Float = FlxMath.lerp(bgScaleI, bg.scale.x, lerpFactor);
		bg.scale.set(bgLerp, bgLerp);
		bg.alpha = FlxMath.lerp(bgAlphaI, bg.alpha, lerpFactor);

		CDevConfig.utils.setSoundPitch(FlxG.sound.music, FlxMath.lerp(speed, FlxG.sound.music.pitch, 1 - (elapsed * 4)));

		if (!currently_writing) {
			if (controls.UI_UP_P)
			{
				changeWeek(-1);
				changeDifficulty();
			}
	
			if (controls.UI_DOWN_P)
			{
				changeWeek(1);
				changeDifficulty();
			}
			if (controls.BACK && !goBack)
			{
				CDevPopUp.open(this, "Prompt", "You haven't saved this week's file, are you sure to exit?",[
					{text:"YES",callback:()->{
						closeSubState();
						FlxG.sound.play(Paths.sound('cancelMenu'));
						goBack = true;
						if (CDevConfig.saveData.smoothAF)
						{
							FlxG.camera.zoom = 1;
							FlxTween.tween(FlxG.camera, {zoom: 0.5}, 1, {ease: FlxEase.cubeOut});
						}
						FlxG.switchState(new ModdingScreen());
					}}, 
					{text:"NO", callback:()->{
						closeSubState();
					}}
				],false, true);
			}
	
			if (controls.ACCEPT)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				for (spr in weekList.members)
				{
					if (spr.ID == curWeek)
					{
						spr.x += 20;
					}
				}
				//diffText.changeDiff(diffStr);
				//bgScaleI = 1.2;
				//bgAlphaI = 0.5;
				//speed = 0.8;
			}
		}

		handleCharControls(elapsed);

		diffText.active = diffText.visible = false;
	}

	var currentCharacter:Int = 0;
	var curSelectedObj:Character = null;
	var selectedThing = false;
	function handleCharControls(elapsed:Float) {
		// Mouse
		var overlap_something:Bool = false;
		for (index => char in character_group.members) {
			if (char == null) continue;
			if (FlxG.mouse.overlaps(char)) overlap_something = true;
			if (FlxG.mouse.overlaps(char) && FlxG.mouse.pressed && !char.lockedChar && !selectedThing) {
				selectedThing = true;
				curSelectedObj = char;
				currentCharacter = index;
			}
		}

		if (!FlxG.mouse.pressed) 
			selectedThing = false;
	
		var curAlpha:Float = 1;
		if (FlxG.mouse.pressed && selectedThing && curSelectedObj != null) {
			if (!character_group.members[currentCharacter].lockedChar)
			{
				curAlpha = 0.4;
				curSelectedObj.x = FlxG.mouse.x - curSelectedObj.frameWidth / 2;
				curSelectedObj.y = FlxG.mouse.y - curSelectedObj.frameHeight / 2;
			}
		}
		for (index => object in [
			label_weekImage,
			label_weekName,
			label_characters,
			label_tracks,
			label_difficulties,
			input_weekImage,
			input_weekName,
			input_characters,
			input_tracks,
			input_difficulties
		]) object.alpha = curAlpha;
		// Keyboard
		if (!currently_writing)
		{
			if (FlxG.keys.justPressed.A)
			{
				currentCharacter -= 1;
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
			}
			else if (FlxG.keys.justPressed.D)
			{
				currentCharacter += 1;
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
			}

			if (currentCharacter >= character_group.members.length)
				currentCharacter = 0;
			if (currentCharacter < 0)
				currentCharacter = character_group.members.length - 1;
		}
		var obj:Character = character_group.members[currentCharacter];
		var set = _modWeeks[curWeek].data.charSetting[currentCharacter];

		if (obj != null && set != null) {
			if (!currently_writing)
			{
				var msize = (FlxG.keys.pressed.SHIFT ? 0.1 : 0.05);
				if (!obj.lockedChar)
				{
					if (FlxG.keys.justPressed.Q || FlxG.keys.justPressed.E){
						set.scale += FlxG.keys.justPressed.Q ? -msize : msize;
						set.scale = FlxMath.bound(set.scale, 0.05, 10);
					}
					if (FlxG.keys.justPressed.F)
					{
						set.flipX = !set.flipX;
						obj.flipX = set.flipX;
					}
				}
	
				if (FlxG.keys.justPressed.Z) {
					obj.lockedChar = !obj.lockedChar;
					FlxG.sound.play(Paths.sound('confirmMenu'), 0.6);
				}
			}
			set.scale = FlxMath.roundDecimal(set.scale, 2);
			obj.scale.set(set.scale, set.scale);
			set.position = [obj.x, obj.y];
		}
		_modWeeks[curWeek].data.charSetting[currentCharacter] = set;

		// alpha thing
		for (index => char in character_group.members)
			char.alpha = overlap_something ? index != currentCharacter ? 0.5 : 1 : 1; 

		// Current info text
		var curChar:String = '[${_modWeeks[curWeek].data.weekCharacters[currentCharacter]}]';
		if (obj != null && set != null) {
			infoText.text = '$curChar\n[LMB] - Position: ${set.position}\n[Q / E] - Scale: ${set.scale}\n[F] - Flip X: ${set.flipX}\n[Z] - Lock Character: ${(obj != null ? obj.lockedChar : false)}\n\n[A / D] Change Current Character';
		} else {
			infoText.text = "Failed getting char info.";
		}
		infoText.setPosition(20, FlxG.height - infoText.height - 56);
	}

	function changeDifficulty(change:Int = 0):Void
	{
		var difficulties = CoolUtil.songDifficulties;
		if (difficulties.length == 0)
			return;

		curDiff = (curDiff + change + difficulties.length) % difficulties.length;

		var diff:String = difficulties[curDiff].toLowerCase().trim();
		diffStr = difficulties[curDiff];
	}

	function changeWeek(change:Int = 0):Void
	{
		var loadedWeeks = _modWeeks;
		if (loadedWeeks.length == 0)
			return;

		curWeek = (curWeek + change + loadedWeeks.length) % loadedWeeks.length;

		for (index => obj in weekList.members)
			obj.targetY = index - curWeek;

		Paths.currentMod = loadedWeeks[curWeek].mod;
		FlxG.sound.play(Paths.sound('scrollMenu'));

		updateTrackList();
	

		var curWDiff = loadedWeeks[curWeek].data.weekDifficulties;
		if (curWDiff != null)
		{
			if (curWDiff.length > 0)
				CoolUtil.songDifficulties = curWDiff;
			else
				CoolUtil.songDifficulties = CoolUtil.defaultDifficulties;
		}
		else
		{
			CoolUtil.songDifficulties = CoolUtil.defaultDifficulties;
		}

		weekName.text = loadedWeeks[curWeek].data.weekName.toUpperCase();
		updateUI();
	}

	function updateTrackList()
	{
		var cwd = _modWeeks[curWeek].data;
		var trackList:Array<String> = [ for (track in cwd.tracks) track ];

		trackTxt.text = "TRACKS: " + trackList.join(", ");
	}

	function updateCharacters()
	{
		character_group.forEachAlive((char:Character) ->
		{
			char.kill();
		});
		character_group.clear();
		updateCharSettings();

		var currentWeekData = _modWeeks[curWeek].data;

		for (index => data in currentWeekData.weekCharacters)
		{
			var char = data.trim();
			if (char == "")
				continue;

			var cSetting = currentWeekData.charSetting[index];
			if (cSetting == null) cSetting = {
				position: [0, 100],
				scale: 0.5,
				flipX: false
			};
			var charObj = new Character(cSetting.position[0], cSetting.position[1], char, false, true);
			charObj.scale.set(cSetting.scale, cSetting.scale);
			charObj.flipX = cSetting.flipX;
			character_group.add(charObj);
		}
	}

	function updateCharSettings() {
		for (index => char in _modWeeks[curWeek].data.weekCharacters) {
			if (_modWeeks[curWeek].data.charSetting[index] == null) {
				_modWeeks[curWeek].data.charSetting.push({
					position: [0, 100],
					scale: 0.5,
					flipX: false
				});
			}
		}
	}

	override function beatHit()
	{
		super.beatHit();
		character_group.forEachAlive((char:Character) ->
		{
			char.dance(false, curBeat);
		});
	}
}
