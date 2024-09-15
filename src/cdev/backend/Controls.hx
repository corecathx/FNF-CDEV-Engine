package cdev.backend;

import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;

class Controls {
	// Pressed //
    public static var UP_P(get, never):Bool;
	public static var DOWN_P(get, never):Bool;
	public static var LEFT_P(get, never):Bool;
	public static var RIGHT_P(get, never):Bool;
    static function get_UP_P() return justPressed('up');
	static function get_DOWN_P() return justPressed('down');
	static function get_LEFT_P() return justPressed('left');
	static function get_RIGHT_P() return justPressed('right');
    //
	public static var UI_UP_P(get, never):Bool;
	public static var UI_DOWN_P(get, never):Bool;
	public static var UI_LEFT_P(get, never):Bool;
	public static var UI_RIGHT_P(get, never):Bool;
	static function get_UI_UP_P() return justPressed('ui_up');
	static function get_UI_DOWN_P() return justPressed('ui_down');
	static function get_UI_LEFT_P() return justPressed('ui_left');
	static function get_UI_RIGHT_P() return justPressed('ui_right');


	// Held //
	public static var UI_UP(get, never):Bool;
	public static var UI_DOWN(get, never):Bool;
	public static var UI_LEFT(get, never):Bool;
	public static var UI_RIGHT(get, never):Bool;
    static function get_UP() return pressed('up');
	static function get_DOWN() return pressed('down');
	static function get_LEFT() return pressed('left');
	static function get_RIGHT() return pressed('right');
    //
	public static var UP(get, never):Bool;
	public static var DOWN(get, never):Bool;
	public static var LEFT(get, never):Bool;
	public static var RIGHT(get, never):Bool;
	static function get_UI_UP() return pressed('ui_up');
	static function get_UI_DOWN() return pressed('ui_down');
	static function get_UI_LEFT() return pressed('ui_left');
	static function get_UI_RIGHT() return pressed('ui_right');


	// Released //
    public static var UP_R(get, never):Bool;
	public static var DOWN_R(get, never):Bool;
	public static var LEFT_R(get, never):Bool;
	public static var RIGHT_R(get, never):Bool;
    static function get_UP_R() return justReleased('up');
	static function get_DOWN_R() return justReleased('down');
	static function get_LEFT_R() return justReleased('left');
	static function get_RIGHT_R() return justReleased('right');
    //
	public static var UI_UP_R(get, never):Bool;
	public static var UI_DOWN_R(get, never):Bool;
	public static var UI_LEFT_R(get, never):Bool;
	public static var UI_RIGHT_R(get, never):Bool;
	static function get_UI_UP_R() return justReleased('ui_up');
	static function get_UI_DOWN_R() return justReleased('ui_down');
	static function get_UI_LEFT_R() return justReleased('ui_left');
	static function get_UI_RIGHT_R() return justReleased('ui_right');

	// Menu Controls (Pressed) //
	public static var ACCEPT(get, never):Bool;
	public static var BACK(get, never):Bool;
	public static var PAUSE(get, never):Bool;
	public static var RESET(get, never):Bool;
	static function get_ACCEPT() return justPressed('accept');
	static function get_BACK() return justPressed('back');
	static function get_PAUSE() return justPressed('pause');
	static function get_RESET() return justPressed('reset');
    
    @:noCompletion public static var keyboardBinds:Map<String, Array<FlxKey>> = [];

    /**
     * Initialize the controls.
     */
    public static function init() {
        for (key in Reflect.fields(EnginePrefs.keybinds)){
            var fieldVal:Array<String> = Reflect.getProperty(EnginePrefs.keybinds,key);
            var parsed:Array<FlxKey> = [FlxKey.fromString(fieldVal[0]), FlxKey.fromString(fieldVal[1])];
            keyboardBinds.set(key, parsed);
        }
        trace(keyboardBinds);
    }

	static function justPressed(key:String):Bool
		return FlxG.keys.anyJustPressed(keyboardBinds[key]);

	static function pressed(key:String):Bool
		return FlxG.keys.anyPressed(keyboardBinds[key]);

    static function justReleased(key:String):Bool
		return FlxG.keys.anyJustReleased(keyboardBinds[key]);
}