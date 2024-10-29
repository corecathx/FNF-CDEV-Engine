package cdev.backend.audio;

import openfl.media.SoundChannel;
import lime.media.AudioSource;
import haxe.io.Bytes;
import lime.media.AudioBuffer;
import openfl.media.Sound;

class AudioUtils {
    public static function getPeakAmplitude(source:FlxSound):Float {
        if (source == null) 
            return 0;
        @:privateAccess {
            var sound:Sound = source._sound;
            var channel:SoundChannel = source._channel;
            if (sound == null || channel == null)
                return 0;

            var buffer:AudioBuffer = source._channel.__audioSource.buffer;
            if (buffer == null) return 0;
            var bytes:Bytes = buffer.data.toBytes();
            var peak:Float = 0;
            var khz:Float = buffer.sampleRate / 1000;
            var channels:Int = buffer.channels;

            var index:Int = Std.int(source.time * khz);

            if (index >= 0 && index < (bytes.length / (2 * channels))) {
                var byte:Int = bytes.getUInt16(index * channels * 2);
                if (byte > 65535 / 2) byte -= 65535;
                var sample:Float = Math.abs(byte / 65535);
                peak = sample;

                if (channels >= 2) {
                    byte = bytes.getUInt16((index * channels * 2) + 2);
                    if (byte > 65535 / 2) byte -= 65535;
                    sample = Math.abs(byte / 65535);
                    if (sample > peak) peak = sample;
                }
            }
        
            return peak;
        }
    }    
}
