package cdev.backend.audio;

import openfl.media.Sound;
import flixel.FlxBasic;

/**
 * Tag Types for SoundTag.
 */
enum abstract SoundTagLists(String) from String to String {
    var INST = "inst";
    var PLAYER = "player";
    var OTHERS = "others";
}

typedef SoundTagStruct = {sound:Sound, tag:String};

typedef SoundTag = {snd:FlxSound, tag:String};

/**
 * Sound Group is used to handle an instrumental as well as the character voices.
 */
class SoundGroup extends FlxBasic {
    public var playing:Bool = false;

    public var speed:Float = 1;
    public var resyncThreshold:Float = 20;

    public var inst:FlxSound;
    public var voices:Array<SoundTag> = [];
    public var onComplete(default, set):Void -> Void = ()->{};

    public function new(instSnd:Sound, voiceSnds:Array<SoundTagStruct>) {
        super();

        inst = FlxG.sound.load(instSnd);
        for (snd in voiceSnds) {
            var sound:SoundTag = createSoundTag(snd.sound, snd.tag);
            voices.push(sound);
        }

        trace("Sound Group is ready.");
    }

    inline function createSoundTag(snd:Sound, ?tag:String = "") {
        return {snd: FlxG.sound.load(snd), tag: tag};
    }

    override function update(elapsed:Float) {
        if (inst.playing) {
            Conductor.instance.time += elapsed * (1000 * speed);
            inst.pitch = speed;
    
            if (Math.abs(Conductor.instance.time - inst.time) > resyncThreshold) {
                Conductor.instance.time = inst.time;
            }
    
            FlxG.watch.addQuick("CondTime", Conductor.instance.time);
            FlxG.watch.addQuick("InstTime", inst.time);

            var l:Int = 0;
            forEachVoices((sound:SoundTag) -> {
                if (Math.abs(sound.snd.time - inst.time) > resyncThreshold) {
                    sound.snd.time = inst.time;
                }
                sound.snd.pitch = speed;
                FlxG.watch.addQuick("Snd"+l+"Time", sound.snd.time);
                l++;
            });

        }
    
        super.update(elapsed);
    }
    

    public function play(?time:Float) {
        trace("playing");
        playing = true;
        if (time != null) {
            inst.time = time;
            forEachVoices((sound:SoundTag)->{sound.snd.time=time;});
        }
        inst.play();
        forEachVoices((sound:SoundTag)->{if (sound.snd != null) sound.snd.play();});
    }

    public function forEachVoices(callback:SoundTag->Void) {
        for (voice in voices) {
            callback(voice);
        }
    }

    public function setTagVolume(tag:String, volume:Float = 1) {
        forEachVoices((sound:SoundTag)->{
            if (sound.tag != tag) return;
            sound.snd.volume = volume;
        });
    }

    private function set_onComplete(val:Void->Void):Void->Void {
        onComplete = val;
        if (inst == null)
            return val;
        return inst.onComplete = onComplete;
    }

    override function destroy() {
        super.destroy();
    }
    
}