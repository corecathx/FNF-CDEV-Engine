package cdev.backend.audio;

import openfl.media.Sound;
import flixel.FlxBasic;

class SoundGroup extends FlxBasic {
    public var playing:Bool = false;

    public var inst:FlxSound;
    public var voices:Array<FlxSound> = [];
    public function new(instSnd:Sound, voiceSnds:Array<Sound>) {
        super();

        inst = FlxG.sound.load(instSnd);
        for (snd in voiceSnds) {
            var sound:FlxSound = FlxG.sound.load(snd);
            voices.push(sound);
        }

        trace("Sound Group is ready.");
    }

    override function update(elapsed:Float) {
        if (inst.playing) {
            Conductor.current.time += elapsed * 1000;
    
            if (Math.abs(Conductor.current.time - inst.time) > 20) {
                Conductor.current.time = inst.time;
            }
    
            forEachVoices((snd:FlxSound) -> {
                if (Math.abs(snd.time - inst.time) > 20) {
                    snd.time = inst.time;
                }
            });
        }
    
        super.update(elapsed);
    }
    

    public function play(?time:Float) {
        playing = true;
        if (time != null) {
            inst.time = time;
            forEachVoices((snd:FlxSound)->{snd.time=time;});
        }
        inst.play();
        forEachVoices((snd:FlxSound)->{if (snd != null) snd.play();});
    }

    public function forEachVoices(callback:FlxSound->Void) {
        for (voice in voices) {
            callback(voice);
        }
    }
}