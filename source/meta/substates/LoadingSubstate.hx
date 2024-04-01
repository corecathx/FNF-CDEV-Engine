package meta.substates;

import flixel.tweens.FlxEase;
import sys.thread.Mutex;

import flixel.tweens.FlxTween;
import openfl.system.System;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import game.system.FunkinThread;
import flixel.FlxG;
import flixel.FlxSprite;
import game.objects.FunkinBar;


/**
 * A helper loading class for CDEV Engine.
 */
class LoadingSubstate extends MusicBeatSubstate {
    var _loadingBar:FunkinBar;
    var _loadingBG:FlxSprite;
    var _loadingText:FlxText;

    var _loadingProgress = {cur: 0, max: 0};
    var _lerpProgress:Float = 0;
    var _tn:Array<String> = [];
    public function new(task:Array<()->Void>, taskNames:Array<String>, onLoadComplete:()->Void) {
        super();
        trace("LOADING STARTED");
        _loadingProgress.max = task.length;
        _tn = taskNames;

        _loadingBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF1B1919);
        var divZoom:Float = 1/FlxG.camera.zoom;
        _loadingBG.scale.set(divZoom,divZoom);
        _loadingBG.alpha = 0;
        //add(_loadingBG);

        _loadingBar = new FunkinBar(0,0,"healthBar", ()->{return _lerpProgress;},0,_loadingProgress.max);
        _loadingBar.setColors(FlxColor.fromInt(0xFF00A2FF), FlxColor.BLACK);
        _loadingBar.screenCenter();
        _loadingBar.y += 90;
        add(_loadingBar);

        _loadingText = new FlxText(0, _loadingBar.y + 30, "Loading...", 20);
		_loadingText.setFormat(FunkinFonts.VCR, 20, FlxColor.CYAN, CENTER, OUTLINE, FlxColor.BLACK);
		_loadingText.screenCenter(X);
		add(_loadingText);

        //_loadingBG.scrollFactor.set();
        //FlxTween.tween(_loadingBG, {alpha:0.5}, 0.3);
        for (_o in [_loadingBar, _loadingText]){
            _o.alpha = 0;
            _o.scrollFactor.set();
            _o.y += 50;
            FlxTween.tween(_o, {alpha:1, y:_o.y-50}, 0.7, {ease:FlxEase.cubeOut});
        }
        
        FunkinThread.doTask(task, (__loadCount)->{
            _loadingProgress.cur = __loadCount;
        }, ()->onActualLoadComplete(onLoadComplete));
    }

    var _curLoadText:String = "";
    override function update(elapsed:Float) {
        super.update(elapsed);
        _lerpProgress = FlxMath.lerp(_loadingProgress.cur, _lerpProgress,1-(elapsed*6));
        var percent:Float = FlxMath.bound(FlxMath.roundDecimal((_lerpProgress/_loadingProgress.max)*100, 2)+2, 0, 100);
        _curLoadText = 'Loading: ${_tn[_loadingProgress.cur]} // $percent%';

        if (_loadingText.text != _curLoadText){
            _loadingText.text = _curLoadText;
            _loadingText.screenCenter(X);
        }
    }

    // i don't know what to call this
    function onActualLoadComplete(onComplete:()->Void){
        System.gc(); // hmm
        onComplete();
    }

    /**
     * Literally a shortcut for openSubState(new LoadingState([], ()->{})) lol;
     * @param task
     */
    public static function load(current:MusicBeatState, task:Array<()->Void>, taskNames:Array<String>, onLoadComplete:()->Void){
        current.openSubState(new LoadingSubstate(task, taskNames, onLoadComplete));
    }
}