package game;

import sys.thread.Mutex;
import flixel.input.keyboard.FlxKey;
import haxe.Timer;
import openfl.media.Sound;
import sys.thread.Thread;

/**
 * Input Helper Class for CDEV Engine.
 * Todo: Make all of this works like InputManager.SPACE or something idk
 */
@:cppFileCode('
#include <Windows.h>
')
class InputManager {
    public var lastPassedMS:Float = 0.01; // Input Thread Framerate

    public var keysHeld:Array<Bool> = []; // PRESSED
    public var keysPressed:Array<Bool> = []; // JUST PRESSED

    public var prevKeys:Array<Bool> = [];
    public var stopped:Bool = false; // Does this thread should be ended?
    private var mtx:Mutex = null;
    public function new() {
        trace("Initializing Thread for Inputs...");
        
        mtx = new Mutex();
		Thread.createWithEventLoop(loop);
    }

    private function loop() {
        while (!stopped) {
            var startTime = Timer.stamp();
            try{
                mtx.acquire();
                update();
                mtx.release();
            } catch(e) { //this does NOT work
                trace("bruh: " + e.toString());
            }

            lastPassedMS = (Timer.stamp() - startTime) * 1000;
			Thread.processEvents();
        }
        if (stopped) { 
            trace("Input thread ended.");
        }
    }

    public dynamic function update() {
        // key press thing
        for (i in 0...keysHeld.length) 
            prevKeys[i] = keysHeld[i];
        
        // Key Down thing
        keysHeld[0] = getKeyPress(FlxKey.LEFT) || getKeyPress(FlxKey.fromString(CDevConfig.saveData.leftBind)); // 'S'
        keysHeld[1] = getKeyPress(FlxKey.DOWN) || getKeyPress(FlxKey.fromString(CDevConfig.saveData.downBind)); // 'D'
        keysHeld[2] = getKeyPress(FlxKey.UP) || getKeyPress(FlxKey.fromString(CDevConfig.saveData.upBind)); // 'K'
        keysHeld[3] = getKeyPress(FlxKey.RIGHT) || getKeyPress(FlxKey.fromString(CDevConfig.saveData.rightBind)); // 'L'
        
        // Just like Flixel's "JUST_PRESSED" key state :pray:
        for (i in 0...keysHeld.length) keysPressed[i] = keysHeld[i] && !prevKeys[i];
    }

    @:functionCode('
        if (GetKeyState(key) & 0x8000) return true;
    ')
    public static function getKeyPress(key:Int):Bool {
        return false;
    }
}
