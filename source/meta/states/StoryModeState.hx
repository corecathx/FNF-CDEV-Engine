package meta.states;

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
 * Rewrite of StoryMenuState because yes.
 */

enum abstract StoryStatus(Int) {
    var WEEK = 0;
    var DIFF = 1;
}

class StoryModeState extends MusicBeatState {
    var curWeek:Int = 0;
    var curDiff:Int = 0;
    var diffStr:String = "easy";
    var goBack:Bool = false; //does the escape button pressed?

    // Objects 
    var bg:FlxSprite;
    var checkerBG:FlxBackdrop;

    var weekListBG:FlxSpriteGroup;
    var weekList:FlxTypedGroup<StoryItem>;

    var diffText:DifficultyText;

    var scoreTxt:FlxText;
    var weekName:FlxText;
    var trackTxt:FlxText;

    var character_group:FlxTypedGroup<Character>;
    override function create() {
        initialize();
        createStateUI();
        changeWeek();
        super.create();
    }

    function initialize(){
        #if desktop
		DiscordClient.changePresence("In the Story menu", null);
		#end

        Paths.destroyLoadedImages(false);
        CDevConfig.utils.getStateScript("StoryMenuState");
        
        WeekData.loadWeeks(); // Update the Week list
    }

    function createStateUI(){
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
        for (i in 0...2){
            var spr:FlxSprite = new FlxSprite(0,(FlxG.height-bHeight)*i).makeGraphic(FlxG.width,bHeight, FlxColor.BLACK);
            spr.alpha = 0.7;
            add(spr);
        }

        scoreTxt = new FlxText(20, 10, 0, "SCORE: 0", 30);
		scoreTxt.setFormat(FunkinFonts.VCR, 30);
        add(scoreTxt);

        weekName = new FlxText(0, 10, FlxG.width-20, "AWESOME WEEK NAME", 30);
		weekName.setFormat(FunkinFonts.VCR, 30, FlxColor.WHITE, RIGHT);
        add(weekName);

        trackTxt = new FlxText(20, 0, FlxG.width, "TRACKS: Song", 30);
        trackTxt.y = (FlxG.height-trackTxt.height)+5;
		trackTxt.setFormat(FunkinFonts.VCR, 30, FlxColor.WHITE, CENTER);
        add(trackTxt);

        diffText = new DifficultyText(0,0);
        diffText.active = diffText.visible = false;
        add(diffText);
    }

    function makeWeekSprites() {
        for (index => week in WeekData.loadedWeeks)
        {
            Paths.currentMod = week.mod;
            var weekThing:StoryItem = new StoryItem(0, 0, 0, week.data.weekTxtImgPath);
            weekThing.y = ((FlxG.height-weekThing.height)/2) + ((weekThing.height+40)*index);
            weekThing.x = (-500) - (35*index);
            weekThing.targetY = index;
            weekThing.scale.set(0.6,0.6);
            weekThing.ID = index;
            weekList.add(weekThing);

            weekThing.antialiasing = CDevConfig.saveData.antialiasing;
            weekThing.changeGraphic(week.data.weekTxtImgPath);

            if (weekThing.fileMissing) weekThing.visible = false;
        }
    }

    /**
     * Generating most blackbar stuffs used in the menu.
     */
    function genBlackBars(){
        // Week List BG
        weekListBG = new FlxSpriteGroup(-150);
        add(weekListBG);
        var tmp:FlxSprite = new FlxSprite().makeGraphic(576,884, FlxColor.BLACK);
        var tmp2:FlxSprite = new FlxSprite(tmp.x + tmp.width + 30).makeGraphic(20,Std.int(tmp.height), FlxColor.BLACK);

        for (i in [tmp,tmp2]){
            i.angle = 20;
            i.alpha = 0.5;
            weekListBG.add(i); 
        }
        weekListBG.antialiasing = CDevConfig.saveData.antialiasing;
    }

    var lerpScore:Int = 0;
	var intendedScore:Int = 0;

    var status:StoryStatus = WEEK;

    var bgAlphaI:Float = 1;
    var bgScaleI:Float = 1;
    var speed:Float = 1;
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        if (FlxG.sound.music != null) Conductor.songPosition = FlxG.sound.music.time;
        checkerBG.x -= elapsed * 20;
		checkerBG.y -= elapsed * 20;

        lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));
        scoreTxt.text = "WEEK SCORE:" + lerpScore;
    
        var lerpFactor:Float = 1 - (elapsed * 12);
        var bgLerp:Float = FlxMath.lerp(bgScaleI, bg.scale.x, lerpFactor);
        bg.scale.set(bgLerp, bgLerp);
        bg.alpha = FlxMath.lerp(bgAlphaI, bg.alpha, lerpFactor);
    
        CDevConfig.utils.setSoundPitch(FlxG.sound.music, FlxMath.lerp(speed, FlxG.sound.music.pitch, 1 - (elapsed * 4)));
    
        diffText.active = diffText.visible = status == DIFF;
        switch (status) {
            case WEEK:
                if (controls.UI_UP_P){
                    changeWeek(-1);
                    changeDifficulty();
                }

                if (controls.UI_DOWN_P){
                    changeWeek(1);
                    changeDifficulty();
                }
                if (controls.BACK && !goBack){
                    FlxG.sound.play(Paths.sound('cancelMenu'));
                    goBack = true;
                    if (CDevConfig.saveData.smoothAF)
                    {
                        FlxG.camera.zoom = 1;
                        FlxTween.tween(FlxG.camera, {zoom: 0.5}, 1, {ease: FlxEase.cubeOut});
                    }
                    FlxG.switchState(new MainMenuState());
                }
        
                if (controls.ACCEPT){
                    FlxG.sound.play(Paths.sound('confirmMenu'));
                    for (spr in weekList.members){
                        if (spr.ID == curWeek){
                            spr.x += 20;
                            spr.startFlashing();
                        } else {
                            spr.disabled = true;
                        }
                    }
                    diffText.changeDiff(diffStr);
                    status = DIFF;
                    bgScaleI = 1.2;
                    bgAlphaI = 0.5;
                    speed = 0.8;
                }
            case DIFF:
                var spr:StoryItem = weekList.members[curWeek];
                diffText.x = spr.x + spr.width + 20;
                diffText.y = spr.y+10;
                if (controls.UI_LEFT_P || controls.UI_RIGHT_P){
                    changeDifficulty(controls.UI_LEFT_P?-1:1);
                    diffText.changeDiff(diffStr);
                }
                if (controls.BACK){
                    bgScaleI = 1;
                    bgAlphaI = 1;
                    speed = 1;
                    FlxG.sound.play(Paths.sound('cancelMenu'));
                    if (spr != null) spr.stopFlashing();
                    for (spr in weekList.members) if (spr.ID != curWeek) spr.disabled = false;
                    status = WEEK;
                }

                if (controls.ACCEPT) {
                    var missingSongs:Array<String> = [];
                    var file:StoryData = WeekData.loadedWeeks[curWeek];
                
                    for (track in file.data.tracks) {
                        Paths.currentMod = file.mod;
                        var chartPath:String = '$track/';
                        var trackPath:String = '$track-$diffStr';
                
                        var paths:Array<String> = [
                            Paths.modJson(chartPath + trackPath),
                            Paths.json(chartPath + trackPath),
                            Paths.modJson(chartPath + track),
                            Paths.json(chartPath + track)
                        ];
                
                        var foundNothing:Bool = true;
                        for (path in paths) {
                            if (FileSystem.exists(path)) {
                                foundNothing = false;
                                break;
                            }
                        }
                
                        if (foundNothing) {
                            missingSongs.push(chartPath + trackPath);
                        }
                    }
                
                    if (missingSongs.length > 0) {
                        FlxG.sound.play(Paths.sound('cancelMenu'));
                        var errorMessage:String = "Couldn't load week due to a missing song file(s)\n" + missingSongs.join('\n');
                        CDevPopUp.open(this, "Error", errorMessage, [{
                            text: "OK",
                            callback: () -> closeSubState()
                        }]);
                    } else {
                        bgAlphaI = 0;
                        FlxG.sound.play(Paths.sound('confirmMenu'));
                        if (FlxG.sound.music != null) {
                            FlxG.sound.music.fadeOut(0.4, 0.3);
                        }
                
                        PlayState.storyPlaylist = file.data.tracks;
                        PlayState.isStoryMode = true;
                        PlayState.weekName = file.data.weekName;
                        PlayState.difficultyName = diffStr;
                        PlayState.storyDifficulty = curDiff;
                
                        var diffic:String = '-' + diffStr;
                        var tryJson:Dynamic = Song.loadFromJson(PlayState.storyPlaylist[0] + diffic, PlayState.storyPlaylist[0]);
                        if (tryJson == null && diffStr.toLowerCase() == "normal") {
                            Log.info("Chart JSON is null, but current selected difficulty is \"normal\", hold on...");
                            diffic = "";
                            tryJson = Song.loadFromJson(PlayState.storyPlaylist[0] + diffic, PlayState.storyPlaylist[0]);
                        }
                        if (tryJson != null) Log.info("I guess it worked!"); else Log.info("Oh, it doesn't work.");
                
                        PlayState.SONG = tryJson;
                        PlayState.storyWeek = curWeek;
                        PlayState.campaignScore = 0;
                        PlayState.fromMod = file.mod;

                        persistentDraw = persistentUpdate = true;

                        var characters:Array<Character> = [];
                        LoadingSubstate.load(this,[
                            () -> {
                                //Character Caching
                                for (chr in [PlayState.SONG.player2,PlayState.SONG.player1,PlayState.SONG.gfVersion]){
                                    var tempChar:Character = new Character(0,0,chr);
                                    tempChar.alpha = 0.00001;
                                    add(tempChar);
                                    characters.push(tempChar);
                                }
                            },
                            () -> {
                                //Stage Caching
                                new Stage(PlayState.SONG.stage, new PlayState(), true).createDaStage();
                            },
                            () -> {
                                // Music caching
                                for (msc in [Paths.inst(PlayState.SONG.song),Paths.voices(PlayState.SONG.song)]){
                                    if (msc != null) FlxG.sound.cache(msc);
                                }
                            }
                        ],["Characters", "Stage", "Music Files", "Clean-Up"],()->{
                            for (i in characters){
                                if (i != null) remove(i);
                            }
                            new FlxTimer().start(0.2, function(hasd:FlxTimer)
                            {
                                if (FlxG.sound.music != null) FlxG.sound.music.fadeOut(0.2, 0);
                                LoadingState.loadAndSwitchState(new PlayState(), true);
                            });
                        }, (wawas:String)->{
                            CDevPopUp.open(this,"Error","An error occured while running a task:\n-"+wawas,
                            [
                                {
                                    text: "OK", 
                                    callback:() -> {FlxG.switchState(new StoryModeState());}
                                }
                            ], false, true);
                        });
                    }
                }
                
        }
    }

    function changeDifficulty(change:Int = 0):Void {
        var difficulties = CoolUtil.songDifficulties;
        if (difficulties.length == 0) return;
    
        curDiff = (curDiff + change + difficulties.length) % difficulties.length;
    
        var diff:String = difficulties[curDiff].toLowerCase().trim();
    
        intendedScore = Highscore.getWeekScore(WeekData.loadedWeeks[curWeek].data.weekName, curDiff);
        diffStr = difficulties[curDiff];
    }
    
    
    var allowChange:Bool = true;
    function changeWeek(change:Int = 0):Void {
        if (!allowChange) return;
        var loadedWeeks = WeekData.loadedWeeks;
        if (loadedWeeks.length == 0) return;
    
        curWeek = (curWeek + change + loadedWeeks.length) % loadedWeeks.length;
    
        for (index => obj in weekList.members)
            obj.targetY = index - curWeek;
    
        Paths.currentMod = loadedWeeks[curWeek].mod;
        FlxG.sound.play(Paths.sound('scrollMenu'));
    
        updateTrackList();

        FunkinThread.doTask([()->{
            var firstTime:Float = Timer.stamp();
            updateCharacters();
            var result:Float = Timer.stamp() - firstTime;
            Log.info("Character loading took " + result + "s to finish.");
        }],(_)->{},()->{
            allowChange = true;
        },(fail:String)->{
            Log.error("Got an error while loading characters: " + fail);
        });
        
        var curWDiff = loadedWeeks[curWeek].data.weekDifficulties;
        if (curWDiff != null){
			if (curWDiff.length > 0)
				CoolUtil.songDifficulties = curWDiff;
			else
				CoolUtil.songDifficulties = CoolUtil.defaultDifficulties;
		} else{
			CoolUtil.songDifficulties = CoolUtil.defaultDifficulties;
		}

        weekName.text = loadedWeeks[curWeek].data.weekName.toUpperCase();
    }

    function updateTrackList() {
        var cwd = WeekData.loadedWeeks[curWeek].data;
        var trackList:Array<String> = [];
        
        for (track in cwd.tracks)
            trackList.push(CDevConfig.utils.capitalize(track));
        
        trackTxt.text = "TRACKS: " + trackList.join(", ");
        intendedScore = Highscore.getWeekScore(cwd.weekName, curDiff);
    }
    
    
    function updateCharacters() {
        allowChange = false;
        character_group.forEachAlive((char:Character) -> {
            char.kill();
            //char.destroy();
        });
        character_group.clear();

        var currentWeekData = WeekData.loadedWeeks[curWeek].data;

        for (index => data in currentWeekData.weekCharacters) {
            var char = data.trim();
            if (char == "") continue;
    
            var cSetting = currentWeekData.charSetting[index];
            var charObj = new Character(cSetting.position[0], cSetting.position[1], char, false, true);
            charObj.scale.set(cSetting.scale, cSetting.scale);
            charObj.flipX = cSetting.flipX;
            character_group.add(charObj);
        }
    }
    
    override function beatHit() {
        super.beatHit();
        character_group.forEachAlive((char:Character) -> {
            char.dance(false, curBeat);
        });
    }
}