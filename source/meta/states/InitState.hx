package meta.states;

import lime.app.Application;
import openfl.display.Window;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import game.cdev.CDevMods.ModFile;
import flixel.util.FlxColor;
import game.cdev.engineutils.Discord.DiscordClient;
import flixel.addons.transition.TransitionData;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData.TransitionTileData;
import flixel.graphics.FlxGraphic;
import game.cdev.engineutils.Highscore;
import game.cdev.engineutils.PlayerSettings;

import flixel.FlxG;
import sys.FileSystem;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;

/**
 * Initialization Class for CDEV Engine.
 */
class InitState extends MusicBeatState {
    public static var status = {
        loadedSaves: false,
        transitionLoaded: false,
        loadedMod: false
    };

    public static var nextState:MusicBeatState = new TitleState();

    override function create() {
        doInit();

        // when crash handler is missing
        if (!FileSystem.exists("./cdev-crash_handler.exe"))
            Application.current.window.alert("CDEV Engine Crash Handler is missing, some stuff might break without it.", "Warning");

        FlxG.switchState(nextState);
        super.create();
    }

    function doInit(){
		if (!status.loadedSaves)
			CDevConfig.initSaves();

        PlayerSettings.init();
        init_flixel();
		Highscore.load();
        init_transition();
        init_windowTitle();
		#if desktop
		if (!CDevConfig.saveData.discordRpc)
			DiscordClient.shutdown();
		else
			DiscordClient.initialize();
		#end

        FlxG.mouse.useSystemCursor = true;
    }

    function init_flixel() {
        FlxG.sound.muteKeys = [ZERO, NUMPADZERO];
		FlxG.sound.volumeDownKeys = [MINUS, NUMPADMINUS];
		FlxG.sound.volumeUpKeys = [PLUS, NUMPADPLUS];
        
        FlxG.fixedTimestep = false;
		FlxG.save.bind('cdev_engine', 'EngineData');

		if (FlxG.save.data.lastVolume != null){
			FlxG.sound.volume = FlxG.save.data.lastVolume;
			trace("updated default volume: "+FlxG.sound.volume);
		} else{
			FlxG.save.data.lastVolume = FlxG.sound.volume;
			trace("created new save for volume");
		}
    }

    function init_transition(){
        var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
        diamond.persist = true;
        diamond.destroyOnNoUse = false;

        var transData:TransitionTileData = {
            asset: diamond,
            width: 32,
            height: 32
        }
        inline function __createTransData(up:Bool = false){
            var newTD:TransitionData = new TransitionData(FADE, FlxColor.BLACK, 0.5, new FlxPoint(0, up ? -1 : 1), transData,
            new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
            newTD.cameraMode = TransitionCameraMode.NEW;
            return newTD;
        }
        if (!status.transitionLoaded)
        {
            FlxTransitionableState.defaultTransIn = __createTransData(true);
            FlxTransitionableState.defaultTransOut = __createTransData();

            transIn = FlxTransitionableState.defaultTransIn;
            transOut = FlxTransitionableState.defaultTransOut;
        }
    }

    function init_windowTitle(){
        if (Paths.curModDir.length == 1)
        {
            if (!status.loadedMod)
            {
                Paths.currentMod = Paths.curModDir[0];
                status.loadedMod = true;
            } else{
                CDevConfig.setWindowProperty(true, "", "");
            }
        }
        else
        {
            CDevConfig.setWindowProperty(true, "", "");
        }

        if (status.loadedMod)
        {
            var d:ModFile = Paths.modData();
            CDevConfig.setWindowProperty(false, Reflect.getProperty(d, "window_title"), Paths.modFolders("winicon.png"));
        }
    }
}