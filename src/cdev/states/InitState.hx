package cdev.states;

import cdev.graphics.MaterialIcon;
import cdev.backend.utils.MemoryUtils;

import flixel.math.FlxPoint;
import flixel.addons.transition.TransitionData;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;

/**
 * Initialization State of CDEV Engine.
 */
class InitState extends State {
    public static var nextState:Class<State> = EngineInfoState;
    override function create():Void {
        super.create();
        ///////////////////////
        /////    DEBUG    /////
        ///////////////////////
        MaterialIcon.init();

        ///////////////////////
        /////    DEBUG    /////
        ///////////////////////
        #if debug
        FlxG.console.registerClass(Engine);
        #end

        ///////////////////////
        /////   SIGNALS   /////
        ///////////////////////
        FlxG.signals.preStateSwitch.add(onStateSwitch);
		FlxG.signals.postStateSwitch.add(onPostStateSwitch);
        
        ///////////////////////
        ///// TRANSITIONS /////
        ///////////////////////
        var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
        diamond.persist = true;
        diamond.destroyOnNoUse = false;

        FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
            new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
        FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
            {asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

        transIn = FlxTransitionableState.defaultTransIn;
        transOut = FlxTransitionableState.defaultTransOut;
        
        ///// To next state /////
        FlxG.switchState(Type.createInstance(nextState, []));
    }

    private static function onStateSwitch():Void {
        // script stuff later  
        Assets.resetLoaded();
    }

    private static function onPostStateSwitch():Void {
        // script stuff later  
        MemoryUtils.clear(true);
    }
}