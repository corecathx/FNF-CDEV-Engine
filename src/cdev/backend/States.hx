package cdev.backend;

import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;

class State extends FlxTransitionableState {
    override function create():Void {
        super.create();
        __assign_conductor(true);
    }

    override function destroy() {
        __assign_conductor(false);
        super.destroy();
    }

    private function beatHit(beats:Int) {}

    private function stepHit(steps:Int) {}

    private function __assign_conductor(_active:Bool) {
        if (_active) {
            Conductor.instance.onBeatTick.add(beatHit);
            Conductor.instance.onStepTick.add(stepHit);
        } else {
            Conductor.instance.onBeatTick.remove(beatHit);
            Conductor.instance.onStepTick.remove(stepHit);
        }
    }
}

class SubState extends FlxSubState {
    override function create():Void {
        super.create();
    }
}