package cdev.backend;

import openfl.events.Event;
import flixel.FlxGame;

/**
 * CDEV Engine's custom FlxGame class.
 */
class Game extends FlxGame {
    /** Tracks the total elapsed time in seconds since the game started. **/
    public static var _ACTIVE_TIME:Float = 0;
    /** Active instance of CDEV's Game Class.  **/
    public static var current:Game = null;

    /** CDEV Engine's Init Game information. **/
    public var game:GameInfo = {
		width: 1280,
		height: 720,
		fps: 120,
		initState: cdev.states.InitState
	}
    
    /**
     * Creates a new CDEV Engine Game object.
     */
    public function new():Void {
        super(game.width, game.height, game.initState,game.fps,game.fps,true,false);
        current = this;
    }

    override function onEnterFrame(_):Void {
        ticks = getTicks();
        _elapsedMS = ticks - _total;
        _total = ticks;

        #if FLX_SOUND_TRAY
        if (soundTray != null && soundTray.active)
            soundTray.update(_elapsedMS);
        #end

        if (!_lostFocus || !FlxG.autoPause)
        {
            if (FlxG.vcr.paused)
            {
                if (FlxG.vcr.stepRequested)
                {
                    FlxG.vcr.stepRequested = false;
                }
                else if (_nextState == null) // don't pause a state switch request
                {
                    #if FLX_DEBUG
                    debugger.update();
                    // If the interactive debug is active, the screen must
                    // be rendered because the user might be doing changes
                    // to game objects (e.g. moving things around).
                    if (debugger.interaction.isActive())
                    {
                        draw();
                    }
                    #end
                    return;
                }
            }

            if (FlxG.fixedTimestep)
            {
                _accumulator += _elapsedMS;
                _accumulator = (_accumulator > _maxAccumulation) ? _maxAccumulation : _accumulator;

                while (_accumulator >= _stepMS)
                {
                    step();
                    _accumulator -= _stepMS;
                }
            }
            else
            {
                step();
            }

            #if FLX_DEBUG
            FlxBasic.visibleCount = 0;
            #end

            draw();

            #if FLX_DEBUG
            debugger.stats.visibleObjects(FlxBasic.visibleCount);
            debugger.update();
            #end
        }
    }
}

/**
 * A class containing information about your game.
 */
@:structInit
class GameInfo {
    /** Window width. **/
    public var width:Int;
    /** Window height. **/
    public var height:Int;
    /** Game's frame per second. **/
    public var fps:Int;
    
    public var initState:Dynamic;
}
