package meta.debug;

import game.system.FunkinSoundFilter;
import haxe.io.Bytes;
import openfl.geom.Rectangle;
import sys.FileSystem;
import lime.media.vorbis.VorbisFile;
import sys.io.File;
import lime.media.AudioBuffer;
import openfl.net.URLRequest;
import lime.media.AudioSource;
import openfl.media.Sound;
import haxe.Timer;

using StringTools;

class AudioLoadState extends MusicBeatState
{
	var displayText:FlxText;

	var weirdness:FlxText;

	override function create()
	{
		FlxG.mouse.visible = true;

		displayText = new FlxText(0, 0, -1, "drop any .ogg file here to start the stuff, idk.", 14);
		displayText.color = 0xFFFFFFFF;
		displayText.font = FunkinFonts.CONSOLAS;
		add(displayText);

		weirdness = new FlxText(20,100,-1,"", 14);
		weirdness.color = 0xFFFFFFFF;
		weirdness.font = FunkinFonts.CONSOLAS;
		add(weirdness);

		FlxG.stage.application.window.onDropFile.add(processDropFile);


		super.create();
	}

	var currentLowPassGain:Float = 1;
	var currentLowPassHF:Float = 0.0134;
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.stage.application.window.onDropFile.remove(processDropFile);
			FlxG.switchState(new meta.states.MainMenuState());
		}
		if (FlxG.keys.pressed.Q){
			currentLowPassGain -= 0.01;
		} else if (FlxG.keys.pressed.W) {
			currentLowPassGain += 0.01;
		}

		if (FlxG.keys.pressed.A){
			currentLowPassHF -= 0.01;
		} else if (FlxG.keys.pressed.S) {
			currentLowPassHF += 0.01;
		}

		currentLowPassGain = FlxMath.bound(currentLowPassGain,0,1);
		currentLowPassHF = FlxMath.bound(currentLowPassHF,0,1);

		if (FlxG.sound.music != null) {
			FunkinSoundFilter.setLowPass(FlxG.sound.music,currentLowPassGain,currentLowPassHF);
		}

		weirdness.text = "lpg: " + currentLowPassGain
		+"\nlphf: " + currentLowPassHF;
	}

	function changeDisplayText(to:String)
	{
		displayText.text = to;
		displayText.setPosition(20, FlxG.height - displayText.height - 20);
	}

	function processDropFile(data:String)
	{
		changeDisplayText("Loading from \"" + data + "\"...\nFOCUS NOW!!!!!");
		var startLoading:Float = Timer.stamp();
		var fileSize = FileSystem.stat(data).size;
		//var sndObj:Sound = Sound.fromAudioBuffer((data.endsWith(".ogg") ? AudioBuffer.fromVorbisFile(VorbisFile.fromFile(data)) : AudioBuffer.fromFile(data)));
		FlxG.sound.music.loadStream(data);
		FlxG.sound.music.play();

		changeDisplayText('File Path   : ${data}\n'
			+ 'File Size   : ${CDevConfig.utils.convert_size(fileSize)}\n'
			+ 'Sample Rate : ${FlxG.keys.pressed.SPACE ? "Undefined" : '0'}\n'/*${sndObj.sampleRate}*/
			+ 'Loaded time : ${FlxMath.roundDecimal(Timer.stamp() - startLoading, 3)}s\n'
			+ 'Method      : ${FlxG.keys.pressed.SPACE ? "Old" : "New"}');
	}
}
