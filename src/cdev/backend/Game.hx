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

    override function create(_:Event) {
        super.create(_);
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
