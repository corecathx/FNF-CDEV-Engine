package meta.modding.song_editor;

import meta.states.LoadingState;
import meta.states.PlayState;
import meta.modding.chart_editor.ChartingState;
import haxe.Json;
import game.cdev.CDevPopUp;
import game.cdev.CDevPopUp.PopUpButton;
import sys.FileSystem;
import sys.io.File;
import game.song.Song;
import flixel.addons.ui.FlxUICheckBox;
import flixel.util.FlxTimer;
import flixel.addons.display.FlxBackdrop;
import game.song.Song.SwagSong;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.addons.ui.FlxUINumericStepper;
import haxe.io.Path;
import flixel.sound.FlxSound;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIInputText;
import meta.substates.DropFileSubstate;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import meta.states.MusicBeatState;
import meta.modding.ModdingScreen;

using StringTools;

class SongEditor extends MusicBeatState
{
	var bg:FlxSprite;
	var bgB:FlxSprite;
	var title:FlxSprite;

	var icon:FlxSprite;
	var titleText:FlxText;
	var menuBG:FlxSprite;

	var currentData:SwagSong;
	var jsonPATH:String = "";
	var checker:FlxBackdrop;

	public function new()
	{
		super();
		/*
		song: 'Your Song',
		notes: [],
		songEvents: [],
		bpm: 150,
		needsVoices: true,
		player1: 'bf',
		player2: 'dad',
		gfVersion: 'gf',
		stage: 'stage',
		speed: 1,
		offset: 0,
		validScore: true
		*/
		currentData = CDevConfig.utils.getTemplate(CHART);
		currentData.validScore = true;

		FlxG.mouse.visible = true;
		FlxG.sound.music.stop();

		menuBG = new FlxSprite().loadGraphic(Paths.image('menuDesat', 'preload'));
		menuBG.color = 0xff0088ff;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.alpha = 0.5;
		menuBG.antialiasing = CDevConfig.saveData.antialiasing;
		add(menuBG);

		checker = new FlxBackdrop(Paths.image('checker', 'preload'), XY);
		checker.scale.set(1.5, 1.5);
		checker.color = 0xFF006AFF;
		checker.blend = LAYER;
		add(checker);
		checker.scrollFactor.set(0, 0.07);
		checker.alpha = 0.4;
		checker.updateHitbox();

		bgB = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		bgB.alpha = 0.1;
		add(bgB);

		bg = FlxSpriteUtil.drawRoundRect(new FlxSprite().makeGraphic(1000, 600, FlxColor.TRANSPARENT), 0, 0, 1000, 600, 15, 15, FlxColor.BLACK);
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

		titleText = new FlxText(icon.x + icon.width + 8, 0, -1, "CDEV Engine - Add New Song Chart", 14);
		titleText.setFormat("VCR OSD Mono", 14, FlxColor.WHITE);
		titleText.y = icon.y + ((icon.width / 2) - (titleText.height / 2));
		add(titleText);

		createGUI();
	}

	var input_songName:FlxUIInputText;
	var label_songName:FlxText;

	var check_useVocal:FlxUICheckBox;

	var buttn_playBoth:FlxUIButton;

	var buttn_songInst:FlxUIButton;
	var label_songInst:FlxText;
	var fname_songInst:FlxText;
	var sound_songInst:FlxSound;
	var paths_songInst:String = "";
	var splay_songInst:FlxUIButton;

	var buttn_songVoic:FlxUIButton;
	var label_songVoic:FlxText;
	var fname_songVoic:FlxText;
	var sound_songVoic:FlxSound;
	var paths_songVoic:String = "";
	var splay_songVoic:FlxUIButton;

	var stepr_songBPM:FlxUINumericStepper;
	var label_songBPM:FlxText;

	var stepr_songSpeed:FlxUINumericStepper;
	var label_songSpeed:FlxText;

	var check_openEditor:FlxUICheckBox;

	function createGUI()
	{
		sound_songInst = new FlxSound();
		sound_songVoic = new FlxSound();

		input_songName = new FlxUIInputText(title.x + 40, title.y + 68, 200, "", 16, FlxColor.WHITE, FlxColor.fromRGB(70, 70, 70));
		input_songName.font = "VCR OSD Mono";
		input_songName.text = currentData.song;
		add(input_songName);
		label_songName = new FlxText(input_songName.x, input_songName.y - 25, 200, "Song Name", 20);
		label_songName.font = "VCR OSD Mono";
		add(label_songName);
		check_useVocal = new FlxUICheckBox(input_songName.x + input_songName.width + 20, input_songName.y,null,null,"Use Vocals?", 150, [], ()->{
			for (i in [buttn_songVoic, label_songVoic, fname_songVoic, sound_songVoic, splay_songVoic]){
				i.visible =	i.active = check_useVocal.checked;
			}
		});
		check_useVocal.button.label.setFormat("VCR OSD Mono", 14, FlxColor.WHITE, LEFT, OUTLINE,FlxColor.BLACK);
		check_useVocal.checked = currentData.needsVoices;
		add(check_useVocal);

		stepr_songBPM = new FlxUINumericStepper(input_songName.x, input_songName.y+input_songName.height+36, 1, 120, 0, 999, 0);
		stepr_songBPM.value = currentData.bpm;
		add(stepr_songBPM);
		label_songBPM = new FlxText(stepr_songBPM.x, stepr_songBPM.y - 25, 200, "Song BPM", 20);
		label_songBPM.font = "VCR OSD Mono";
		add(label_songBPM);

		stepr_songSpeed = new FlxUINumericStepper(stepr_songBPM.x + stepr_songBPM.width + 80, input_songName.y+input_songName.height+36, 1, 120, 0, 999, 0);
		stepr_songSpeed.value = currentData.speed;
		add(stepr_songSpeed);
		label_songSpeed = new FlxText(stepr_songSpeed.x, stepr_songSpeed.y - 25, 200, "Scroll Speed", 20);
		label_songSpeed.font = "VCR OSD Mono";
		add(label_songSpeed);


		buttn_songInst = new FlxUIButton(input_songName.x, input_songName.y + input_songName.height + 100, "Select File", function()
		{
			stopPreviews();
			openSubState(new DropFileSubstate(this, "paths_songInst", "ogg", function()
			{
				sound_songInst.loadStream(paths_songInst);
				sound_songInst.stop();
				resetPreviews();
				fname_songInst.text = "Selected: " + Path.withoutDirectory(paths_songInst);
			}, resetPreviews));
		}, true, false, 0xFF004DC0);
		buttn_songInst.resize(200, 50);
		var sprite = new FlxSprite().loadGraphic(Paths.image("ui/file", "shared"));
		sprite.scale.set(2, 2);
		buttn_songInst.addIcon(sprite, 20, 18, false);
		buttn_songInst.setLabelFormat(null, 16, FlxColor.WHITE);
		buttn_songInst.label.x += 20;
		buttn_songInst.label.y -= 10;
		add(buttn_songInst);
		splay_songInst = new FlxUIButton(buttn_songInst.x + buttn_songInst.width + 10, buttn_songInst.y, "PLAY", function()
		{
			if (sound_songInst.playing)
				sound_songInst.stop();
			else
				sound_songInst.play();

			splay_songInst.label.text = (sound_songInst.playing ? "STOP" : "PLAY");
		}, true, false, 0xFF004DC0);
		splay_songInst.resize(100, 50);
		splay_songInst.setLabelFormat(null, 16, FlxColor.WHITE);
		add(splay_songInst);
		label_songInst = new FlxText(buttn_songInst.x, buttn_songInst.y - 25, 300, "Instrumental", 20);
		label_songInst.font = "VCR OSD Mono";
		add(label_songInst);
		fname_songInst = new FlxText(buttn_songInst.x, buttn_songInst.y + buttn_songInst.height + 20, 300, "(No File Selected)", 16);
		fname_songInst.font = "VCR OSD Mono";
		add(fname_songInst);

		buttn_playBoth = new FlxUIButton(splay_songInst.x + splay_songInst.width + 40, buttn_songInst.y, "PLAY ALL", function()
		{
			if (sound_songInst.playing)
				sound_songInst.stop();
			else
				sound_songInst.play();

			if (currentData.needsVoices){
				if (sound_songVoic.playing)
					sound_songVoic.stop();
				else
					sound_songVoic.play();
			}

			buttn_playBoth.label.text = (sound_songInst.playing && sound_songVoic.playing ? "STOP ALL" : "PLAY ALL");
			splay_songInst.label.text = (sound_songInst.playing ? "STOP" : "PLAY");
			splay_songVoic.label.text = (sound_songVoic.playing ? "STOP" : "PLAY");
		}, true, false, 0xFF0063C0);
		buttn_playBoth.resize(100, 50);
		buttn_playBoth.setLabelFormat(null, 16, FlxColor.WHITE);
		add(buttn_playBoth);

		buttn_songVoic = new FlxUIButton(splay_songInst.x + splay_songInst.width + 180, input_songName.y + input_songName.height + 100, "Select File", function()
		{
			stopPreviews();
			openSubState(new DropFileSubstate(this, "paths_songVoic", "ogg", function()
			{
				label_songVoic.color = FlxColor.WHITE;
				sound_songVoic.loadStream(paths_songVoic);
				sound_songVoic.stop();
				resetPreviews();
				fname_songVoic.text = "Selected: " + Path.withoutDirectory(paths_songVoic);
			}, resetPreviews));
		}, true, false, 0xFF004DC0);
		buttn_songVoic.resize(200, 50);
		var sprite = new FlxSprite().loadGraphic(Paths.image("ui/file", "shared"));
		sprite.scale.set(2, 2);
		buttn_songVoic.addIcon(sprite, 20, 18, false);
		buttn_songVoic.setLabelFormat(null, 16, FlxColor.WHITE);
		buttn_songVoic.label.x += 20;
		buttn_songVoic.label.y -= 10;
		add(buttn_songVoic);
		splay_songVoic = new FlxUIButton(buttn_songVoic.x + buttn_songVoic.width + 10, buttn_songVoic.y, "PLAY", function()
		{
			if (sound_songVoic.playing)
				sound_songVoic.stop();
			else
				sound_songVoic.play();

			splay_songVoic.label.text = (sound_songVoic.playing ? "STOP" : "PLAY");
		}, true, false, 0xFF004DC0);
		splay_songVoic.resize(100, 50);
		splay_songVoic.setLabelFormat(null, 16, FlxColor.WHITE);
		add(splay_songVoic);
		label_songVoic = new FlxText(buttn_songVoic.x, buttn_songVoic.y - 25, 300, "Voices", 20);
		label_songVoic.font = "VCR OSD Mono";
		add(label_songVoic);
		fname_songVoic = new FlxText(buttn_songVoic.x, buttn_songVoic.y + buttn_songVoic.height + 20, 300, "(No File Selected)", 16);
		fname_songVoic.font = "VCR OSD Mono";
		add(fname_songVoic);

		var createAll:FlxUIButton = new FlxUIButton(bg.x + bg.width - 170, bg.y + bg.height - 45, "Add Song", function()
		{
			var allow:Bool = true;
			var errors:String = "";
			
			function addError(errorMessage:String):Void {
				allow = false;
				errors += "\n- " + errorMessage;
			}
			
			if (check_useVocal.checked && paths_songVoic == "") {
				addError("Using voices, but no voices path were provided.");
				label_songVoic.color = FlxColor.RED;
			}
			
			if (!FileSystem.exists(paths_songInst)) {
				addError("Inst file doesn't exist from the provided path.");
			}
			
			if (check_useVocal.checked && !FileSystem.exists(paths_songVoic)) {
				addError("Voice file doesn't exist from the provided path.");
			}
			
			if (CDevConfig.utils.containsBlockedSymbol(input_songName.text) 
				|| CDevConfig.utils.isBlockedWord(input_songName.text)) {
				addError("Used a blocked symbol / blocked word that's reserved by Windows.");
			}
			
			if (allow){
				var songsfolder:String = Paths.modsPath + "/" + Paths.currentMod + "/songs/";
				var chartfolder:String = Paths.modsPath + "/" + Paths.currentMod + "/data/charts/";
				var curSong:String = songsfolder + input_songName.text + "/";
				var curSongChart:String = chartfolder + input_songName.text + "/";
			
				var filePaths = {
					inst: Path.normalize(paths_songInst),
					voices: Path.normalize(paths_songVoic),
					instMod: Path.normalize(Sys.getCwd() + curSong + "Inst.ogg"),
					voicesMod: Path.normalize(Sys.getCwd() + curSong + "Voices.ogg"),
				};
			
				if (!FileSystem.exists(curSong))
					FileSystem.createDirectory(curSong);
			
				if (!FileSystem.exists(curSongChart))
					FileSystem.createDirectory(curSongChart);
			
				File.copy(filePaths.inst, filePaths.instMod);
				if (check_useVocal.checked) File.copy(filePaths.voices, filePaths.voicesMod);
			
				currentData.bpm = stepr_songBPM.value;
				currentData.speed = stepr_songSpeed.value;
				currentData.song = input_songName.text.trim();
				currentData.needsVoices = check_useVocal.checked;
				
				var json = {
					"song": currentData
				};
			
				var data:String = Json.stringify(json, "\t");
				File.saveContent(curSongChart + "/" + input_songName.text + ".json", data);
			
				if (check_openEditor.checked) {
					PlayState.isStoryMode = false;
					PlayState.storyPlaylist = [input_songName.text];
					PlayState.storyDifficulty = 1;
					PlayState.storyWeek = 1;
					PlayState.fromMod = Paths.currentMod;
					PlayState.difficultyName = "hard";
					leave(new ChartingState(currentData), true);
				} else {
					CDevConfig.utils.openFolder(songsfolder, true);
					leave();
				}
			} else {
				var butt:Array<PopUpButton> = [
					{ text: "OK", callback: closeSubState }
				];
				var text:String = "An error has occurred, try fixing these errors:" + errors;
				openSubState(new CDevPopUp("Error", text, butt, false, true));
				FlxG.sound.play(Paths.sound("cancelMenu"));
			}
			
		}, true, false, 0xFF004DC0);
		createAll.resize(150, 25);
		createAll.setLabelFormat(null, 10, FlxColor.WHITE);
		add(createAll);

		check_openEditor = new FlxUICheckBox(createAll.x, createAll.y - 22,null,null,"Open Chart Editor", 150, [], ()->{

		});
		add(check_openEditor);

		var loadJSON:FlxUIButton = new FlxUIButton(createAll.x - 170, bg.y + bg.height - 45, "Load from JSON", function()
		{
			openSubState(new DropFileSubstate(this, "jsonPATH", "json", () ->
			{
				currentData = Song.parseJSONshit(File.getContent(jsonPATH));
				updateSettings();
			}, resetPreviews));
		}, true, false, 0xFF004DC0);
		loadJSON.resize(150, 25);
		loadJSON.setLabelFormat(null, 10, FlxColor.WHITE);
		add(loadJSON);
	}

	function updateSettings(){
		stepr_songSpeed.value = currentData.speed;
		stepr_songBPM.value = currentData.bpm;
		check_useVocal.checked = currentData.needsVoices;
		input_songName.text = currentData.song;
	}

	function stopPreviews(){
		tapeStop(sound_songInst);
		tapeStop(sound_songVoic);
	}

	function resetPreviews(){
		tapeCancelAll();
		sound_songInst.pitch = sound_songInst.volume = 1;
		sound_songVoic.pitch = sound_songVoic.volume = 1;
	}

	var exit:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		checker.x -= elapsed * 20;
		checker.y += elapsed * 20;

		if (currentData != null) {
			currentData.needsVoices = check_useVocal.checked;
		}


		if (FlxG.keys.justPressed.ESCAPE && !exit)
		{
			leave();
		}
	}

	function leave(?State:Dynamic, ?special:Bool = false) {
		var e:Dynamic = State;
		if (e == null){
			e = new ModdingScreen();
		}
		FlxTween.tween(FlxG.camera, {zoom: 0.9, alpha:0}, 1, {ease:FlxEase.sineInOut});
		stopPreviews();
		exit = true;
		new FlxTimer().start(1.1, (t:FlxTimer) -> {
			if (special){
				LoadingState.loadAndSwitchState(State, false);
			} else{ 
				FlxG.switchState(State);
			}
		});

		FlxG.mouse.visible = false;
	}

	var existingTweenTape:Array<Dynamic> = []; // [FlxTween, FlxSound]
	function tapeCancelAll(){
		for (i => c in existingTweenTape){
			c[0].cancel();
			existingTweenTape.remove(c);
		}
	}
	function tapeStop(sound:FlxSound){
		if (sound==null)
			return;
		if (!sound.playing)
			return;

		var exists:Bool = false;
		var index:Int = -1;

		for (i => c in existingTweenTape){
			if (c[1] == sound){
				exists = true;
				index = i;
				break;
			}
		}

		if (exists){
			existingTweenTape[index][0].cancel();
			existingTweenTape.remove(existingTweenTape[index]);
		}

		var newTween:FlxTween = FlxTween.tween(sound, {pitch:0.1, volume:0}, 1, {ease:FlxEase.sineOut, onComplete:function(e) {
			sound.stop();
			for (i => c in existingTweenTape){
				if (c[1] == sound){
					existingTweenTape.remove(existingTweenTape[index]);
					break;
				}
			}
		}});

		existingTweenTape.push([newTween, sound]);
	}
}
