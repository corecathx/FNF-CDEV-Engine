package game.system;

import lime.media.openal.AL;

/**
 * Sound Filter class for CDEV Engine.
 * - Known bug: sometimes not working
 */
class FunkinSoundFilter
{
	public static function setLowPass(sound:FlxSound, gain:Float = 1, gainHF:Float = 0.0134)
	{
        try{
            if (sound == null)
            {
                Log.warn("Could not create lowpass filter, sound is null.");
                return;
            }
    
            @:privateAccess var a = sound._sound.__buffer;
            @:privateAccess var b = a.__srcBuffer; 
    
            var af = AL.createFilter();
            AL.filteri(af, AL.FILTER_TYPE, AL.FILTER_LOWPASS);
            AL.filterf(af, AL.LOWPASS_GAIN, gain);
            AL.filterf(af, AL.LOWPASS_GAINHF, gainHF);
            AL.sourcei(b, AL.DIRECT_FILTER, af);
        }catch(e){
            Log.warn("Low-pass audio filter fail: "+e.toString());
        }

	}
}
