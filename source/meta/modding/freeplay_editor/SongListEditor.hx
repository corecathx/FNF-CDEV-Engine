package meta.modding.freeplay_editor;

import flixel.addons.ui.FlxUIInputText;
import flixel.text.FlxText;
import flixel.util.FlxSpriteUtil;
import meta.substates.MusicBeatSubstate;
import game.cdev.engineutils.Discord.DiscordClient;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxButtonPlus;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup.FlxTypedGroup;
import game.objects.AttachedSprite;
import game.objects.HealthIcon;
import game.objects.Alphabet;
import sys.io.File;
import sys.FileSystem;
import meta.states.FreeplayState.SongMetadata;
import meta.states.MusicBeatState;
import meta.modding.ModdingScreen;

using StringTools;

class SongListEditor extends MusicBeatState
{
	// honestly, i don't know what this does
	public static var CDEV_IND:String = "CDEV";

	var menuBG:FlxSprite;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	public var songs:Array<SongMetadata> = [];
	var iconArray:Array<HealthIcon> = [];

	var curSelected:Int = 0;

	var initFinish:Bool = false;

	public function new()
	{
		super();

		DiscordClient.changePresence("Editing the song list", null);

		FlxG.mouse.visible = true;

		loadSongList();

		menuBG = new FlxSprite().loadGraphic(Paths.image('menuDesat', 'preload'));
		menuBG.color = 0xff0088ff;
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.alpha = 0.5;
		menuBG.antialiasing = CDevConfig.saveData.antialiasing;
		add(menuBG);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		updateDatas();
		createButtons();

		initFinish = true;
	}

	var buttonUp:FlxButtonPlus;
	var buttonDown:FlxButtonPlus;
	var buttonRemove:FlxButtonPlus;

	function createButtons()
	{
		buttonUp = new FlxButtonPlus(10, FlxG.height - 30, function()
		{
			moveObject(true);
		}, "v", 60, 60);
		buttonUp.updateInactiveButtonColors([0xff002980, 0xff0042d1]);
		buttonUp.updateActiveButtonColors([0xff0038a1, 0xff006cfa]);
		add(buttonUp);

		buttonDown = new FlxButtonPlus(10, FlxG.height - 115, function()
		{
			moveObject(false);
		}, "v", 60, 60);
		buttonDown.updateInactiveButtonColors([0xff002980, 0xff0042d1]);
		buttonDown.updateActiveButtonColors([0xff0038a1, 0xff006cfa]);
		add(buttonDown);

		buttonRemove = new FlxButtonPlus(10, FlxG.height - 115, function()
		{
			removeCurrent();
		}, "-", 60, 60);
		buttonRemove.updateInactiveButtonColors([0xff800000, 0xffd10000]);
		buttonRemove.updateActiveButtonColors([0xffa10000, 0xffff0000]);
		add(buttonRemove);

		buttonUp.textNormal.flipY = buttonUp.textHighlight.flipY = true;
		buttonUp.textNormal.size = buttonUp.textHighlight.size = 40;
		buttonDown.textNormal.size = buttonDown.textHighlight.size = 40;
		buttonRemove.textNormal.size = buttonRemove.textHighlight.size = 40;

		buttonUp.textNormal.y -= 5;
		buttonDown.textNormal.y -= 5;
		buttonUp.textHighlight.y = buttonUp.textNormal.y;
		buttonDown.textHighlight.y = buttonDown.textNormal.y;
	}

	function moveObject(up:Bool = false)
	{
		var movePos:Int = up ? -1 : 1;
		for (i => s in songs) // index, song
		{
			if (i == curSelected)
			{
				if (i + movePos < 0 || i + movePos > songs.length - 1)
					break;

				if (songs[i + movePos] != null && songs[i + movePos].fromMod == CDEV_IND)
					break;

				songs.remove(s);
				songs.insert(i + movePos, s);
				updateDatas(i + movePos);
				break;
			}
		}
	}

	function removeCurrent()
	{
		for (i => s in songs) // index, song
		{
			if (i == curSelected)
			{
				if (songs[i].fromMod == CDEV_IND)
					break;

				songs.remove(s);
				updateDatas(i);
				break;
			}
		}
	}

	var updating:Bool = false;

	public function updateDatas(switchToThis:Int = 1)
	{
		updating = true;

		grpSongs.clear();
		while (iconArray.length != 0)
		{
			for (i in iconArray)
			{
				if (i != null)
				{
					i.destroy();
					remove(i);
				}
				iconArray.remove(i);
			}
		}

		for (i in 0...songs.length)
		{
			var size:Int = 34;
			var offset:Float = 36;
			var songText:Alphabet = new Alphabet(120, ((i - curSelected) * (size + offset)) + (FlxG.height * 0.48), songs[i].songName, true, false, size);
			songText.isMenuItem = true;
			songText.isFreeplay = true;
			songText.forcePositionToScreen = false;
			songText.heightOffset = offset;
			songText.targetY = i;
			songText.ID = i;
			grpSongs.add(songText);

			var icon = null;

			if (songs[i].fromMod != CDEV_IND)
			{
				Paths.currentMod = songs[i].fromMod;
				icon = new HealthIcon(songs[i].songCharacter);
			}
			else
			{
				icon = new HealthIcon("", false, false);
				icon.loadGraphic(Paths.image("ui/add", "shared"));
				icon.color = 0xFF0084FF;
				songText.color = 0xFF68B6FF;
			}
			icon.offset.set(15, 15);
			icon.scale.set(0.7, 0.7);

			icon.sprTracker = songText;
			icon.ID = i;

			// just in case.....
			if (icon != null)
			{
				iconArray.push(icon);
				add(icon);
			}
		}

		if (initFinish) storeData();

		updating = false;
		changeSelection(switchToThis, true);
	}

	function loadSongList()
	{
		// stuff
		songs.push(new SongMetadata("Add a new song", 1, "add", CDEV_IND));

		// straight copied from freeplay state
		var customSongList:Array<String> = [];
		var songModListIdk:Array<String> = [];

		#if ALLOW_MODS
		var songListTxt:Array<String> = [];
		var mod:String = Paths.currentMod;

		var list:Array<String> = [];

		if (FileSystem.exists('cdev-mods/' + mod + '/songList.txt'))
		{
			list = File.getContent('cdev-mods/' + mod + '/songList.txt').trim().split('\n');
		}
		for (i in 0...list.length)
			list[i] = list[i].trim();

		songListTxt = list;
		for (i in 0...songListTxt.length)
		{
			if (songListTxt.length > 0)
			{
				customSongList.push(songListTxt[i]);
				songModListIdk.push(mod);
				// trace('\nSong: ' + songListTxt[i] + "\nMod: " + crapz);
			}
		}

		for (i in 0...customSongList.length)
		{
			var bruh:Array<String> = customSongList[i].split(':');
			songs.push(new SongMetadata(bruh[0], 1, bruh[1], songModListIdk[i]));
		}
		#end
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (updating)
			return;

		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.switchState(new ModdingScreen());
		}

		if (FlxG.mouse.wheel > 0 || controls.UI_UP_P)
		{
			// up
			changeSelection(-1);
		}
		else if (FlxG.mouse.wheel < 0 || controls.UI_DOWN_P)
		{
			// down
			changeSelection(1);
		}

		if (controls.ACCEPT)
		{
			openState();
		}

		for (item in grpSongs.members)
		{
			if (FlxG.mouse.overlaps(item))
			{
				if (FlxG.mouse.justPressed)
				{
					if (curSelected != item.ID)
					{
						changeSelection(item.ID, true);
					}
					else
					{
						openState();
					}
				}
			}
		}

		menuBG.alpha = 0.7;
		updateButtons();
	}

	function openState(){
		if (songs[curSelected].fromMod != CDEV_IND)
			return;

		Paths.currentMod = Paths.curModDir[0];
		openSubState(new NewSongSubstate(this));
	}

	function updateButtons()
	{
		// Only make the buttons visible when it's not selecting "Add a new song" option.
		var shouldActive:Bool = (songs[curSelected].fromMod != CDEV_IND);
		buttonUp.visible = buttonDown.visible = buttonRemove.visible = buttonUp.active = buttonDown.active = buttonRemove.active = shouldActive;

		if (shouldActive)
		{
			var songText:Alphabet = grpSongs.members[curSelected];
			var icon:FlxSprite = iconArray[curSelected];
			var textEndPos:Float = songText.x + songText.width;
			var iconPos:Float = icon.x - textEndPos;

			buttonUp.x = textEndPos + iconPos + icon.width + 5;
			buttonDown.x = buttonUp.x + buttonUp.width + 10;
			buttonRemove.x = buttonDown.x + buttonDown.width + 10;

			buttonUp.y = buttonDown.y = buttonRemove.y = songText.y;
		}
	}

	var toThisColor:Int = 0;
	var tween:FlxTween;

	function changeBGColor(?fromColor:Array<Int>)
	{
		var nextColor:Int = -1;
		if (fromColor != null)
		{
			nextColor = FlxColor.fromRGB(fromColor[0], fromColor[1], fromColor[2]);
		}
		else
		{
			nextColor = game.cdev.CDevConfig.utils.getColor(iconArray[curSelected]);
		}

		if (nextColor != toThisColor)
		{
			if (tween != null)
				tween.cancel();

			toThisColor = nextColor;
			tween = FlxTween.color(menuBG, 1, menuBG.color, toThisColor, {
				onComplete: function(twn:FlxTween)
				{
					tween = null;
				}
			});
		}
	}

	function changeSelection(change:Int = 0, forceChange:Bool = false)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (!forceChange)
			curSelected += change;
		else
			curSelected = change;
		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
			iconArray[i].alpha = 0.6;

		changeBGColor(songs[curSelected].color);

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;
			item.selected = false;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.selected = true;
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}

		Paths.currentMod = songs[curSelected].fromMod;
	}

	public function storeData(){
		var data:String = "";
		for (i => s in songs){
			if (s.fromMod == CDEV_IND) continue;
			var d:String = s.songName + ":" + s.songCharacter + ":" + s.week;
			data += d + (i < songs.length-1 ? "\n" : "");
		}
		var path:String = Paths.modFolders("songList.txt");

		if (FileSystem.exists(path)){
			File.saveContent(path, data);
		}
	}
}

class NewSongSubstate extends MusicBeatSubstate
{
	var bg:FlxSprite;
	var bgB:FlxSprite;
	var title:FlxSprite;

	var icon:FlxSprite;
	var titleText:FlxText;

	var state:SongListEditor;

	public function new(calledFrom:SongListEditor)
	{
		super();

		state = calledFrom;

		bgB = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		bgB.alpha = 0.1;
		add(bgB);

		bg = FlxSpriteUtil.drawRoundRect(new FlxSprite().makeGraphic(800, 400, FlxColor.TRANSPARENT), 0, 0, 800, 400, 15, 15, FlxColor.BLACK);
		bg.screenCenter();
		bg.alpha = 0.9;
		add(bg);

		title = FlxSpriteUtil.drawRoundRectComplex(new FlxSprite().makeGraphic(Std.int(bg.width), 32, FlxColor.TRANSPARENT), 0, 0, Std.int(bg.width), 32, 5,
			5, 0, 0, FlxColor.fromRGB(64, 62, 60, 255));
		title.setPosition(bg.x, bg.y);
		title.alpha = 0.9;
		add(title);

		icon = new FlxSprite().loadGraphic(Paths.image("icon16", "shared"));
		icon.setPosition(title.x + 9, title.y + 9);
		add(icon);

		titleText = new FlxText(icon.x + icon.width + 8, 0, -1, "CDEV Engine - New Song", 14);
		titleText.setFormat("VCR OSD Mono", 14, FlxColor.WHITE);
		titleText.y = icon.y + ((icon.width / 2) - (titleText.height / 2));
		add(titleText);
		loadUI();
	}

	var input_songName:FlxUIInputText;
	var txtSn:FlxText;

	var input_character:FlxUIInputText;
	var txtC:FlxText;
	var iconP:HealthIcon;

	var addButton:FlxButtonPlus;

	function loadUI() {
		input_songName = new FlxUIInputText(title.x+10, title.y+68, 300, "", 16, FlxColor.WHITE, FlxColor.fromRGB(70, 70, 70));
		input_songName.font = "VCR OSD Mono";
		add(input_songName);
		txtSn = new FlxText(input_songName.x, input_songName.y - 25, 300, "Song Name", 20);
		txtSn.font = "VCR OSD Mono";
		add(txtSn);

		input_character = new FlxUIInputText(title.x+10, input_songName.y+input_songName.height+38, 200, "", 16, FlxColor.WHITE, FlxColor.fromRGB(70, 70, 70));
		input_character.font = "VCR OSD Mono";
		add(input_character);
		txtC = new FlxText(input_character.x, input_character.y - 25, 200, "Character Icon", 20);
		txtC.font = "VCR OSD Mono";
		add(txtC);

		iconP = new HealthIcon("face", false, true);
		iconP.setPosition(input_character.x + input_character.width+10, input_character.y);
		add(iconP);

		addButton = new FlxButtonPlus(0,0, function()
		{
			var canLeave:Bool = (input_character.text.trim() != "" && input_songName.text.trim() != "");

			if (!canLeave){
				txtC.color = input_character.text.trim() == "" ? FlxColor.RED : FlxColor.WHITE;
				txtSn.color = input_songName.text.trim() == "" ? FlxColor.RED : FlxColor.WHITE;
				FlxG.sound.play(Paths.sound("cancelMenu"), 0.6);
				return;
			}
			state.songs.push(new SongMetadata(input_songName.text.trim(), 1, input_character.text, Paths.currentMod));
			FlxG.sound.play(Paths.sound("confirmMenu"), 0.6);
			state.updateDatas(state.songs.length-1);
			close();
		}, "Add Song", 100, 25);
		addButton.textNormal.size = addButton.textHighlight.size = 10;
		addButton.updateInactiveButtonColors([0xff4e4e4e, 0xff4e4e4e]);
		addButton.updateActiveButtonColors([0xff7a7a7a, 0xff7a7a7a]);
		add(addButton);

		addButton.setPosition(bg.x + (bg.width - (addButton.width + 20)), bg.y + (bg.height - (addButton.height + 20)));
	}
	var lastTracedText:String = "";
	var lastObjectFocusedOn:FlxUIInputText = null;
	var currentFocus:FlxUIInputText = null;

	var lastChar:String = "";
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.keys.justPressed.ESCAPE)
			close();

		for (obj in [input_songName, input_character]){
			if (obj.hasFocus){
				if (currentFocus != obj){
					lastObjectFocusedOn = currentFocus;
					currentFocus = obj;
					
					lastTracedText = obj.text;
				}

				if (FlxG.keys.justPressed.ENTER) obj.hasFocus = false;
			}
		}

		if (input_songName.hasFocus) {
			txtSn.color = FlxColor.WHITE;
		}
		if (input_character.hasFocus) {
			txtC.color = FlxColor.WHITE;
		}
		if (currentFocus != null){
			if (currentFocus.text != lastTracedText){
				FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);
				lastTracedText = currentFocus.text;
			}
		}

		if (lastChar != input_character.text) {
			lastChar = input_character.text;
			iconP.changeDaIcon(lastChar);
		}
	}
}
