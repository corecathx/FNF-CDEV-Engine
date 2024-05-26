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
	var waveformSprite:FlxSprite;

	override function create()
	{
		FlxG.mouse.visible = true;
		FlxG.sound.music.stop();
		waveformSprite = new FlxSprite().makeGraphic(1, 1, 0xFFFFFFFF);
		add(waveformSprite);

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

		updateWaveform();
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

	// ctrl + c & ctrl + v from ChartingState.hx
	var waveformPrinted:Bool = true;
	var wavData:Array<Array<Array<Float>>> = [[[0], [0]], [[0], [0]]];

	var lastWaveformHeight:Int = 0;

	function updateWaveform()
	{
		#if desktop
		if (waveformPrinted)
		{
			var width:Int = Std.int(FlxG.height);
			var height:Int = Std.int(FlxG.width);
			if (lastWaveformHeight != height && waveformSprite.pixels != null)
			{
				waveformSprite.pixels.dispose();
				waveformSprite.pixels.disposeImage();
				waveformSprite.makeGraphic(width, height, 0x00FFFFFF);
				lastWaveformHeight = height;
			}
			waveformSprite.pixels.fillRect(new Rectangle(0, 0, width, height), 0x00FFFFFF);
		}
		waveformPrinted = false;

		if (!FlxG.sound.music.playing)
		{
			return;
		}

		wavData[0][0] = [];
		wavData[0][1] = [];
		wavData[1][0] = [];
		wavData[1][1] = [];

		var sound:FlxSound = FlxG.sound.music;

		var st:Float = sound.time;
		var et:Float = st + (2000);

		@:privateAccess {
			if (sound != null && sound._sound != null && sound._sound.__buffer != null && sound._sound.__buffer.data != null)
			{
				var bytes:Bytes = sound._sound.__buffer.data.toBytes();

				wavData = waveformData(sound._sound.__buffer, bytes, st, et, 1, wavData, Std.int(FlxG.height / 2));
			}
		}

		// Draws
		var gSize:Int = Std.int(FlxG.width);
		var hSize:Int = Std.int(FlxG.height);
		var size:Float = 1;

		var leftLength:Int = (wavData[0][0].length > wavData[0][1].length ? wavData[0][0].length : wavData[0][1].length);
		var rightLength:Int = (wavData[1][0].length > wavData[1][1].length ? wavData[1][0].length : wavData[1][1].length);

		var length:Int = leftLength > rightLength ? leftLength : rightLength;

		for (index in 0...length)
		{
			var lmin:Float = FlxMath.bound(((index < wavData[0][0].length && index >= 0) ? wavData[0][0][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;
			var lmax:Float = FlxMath.bound(((index < wavData[0][1].length && index >= 0) ? wavData[0][1][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;

			var rmin:Float = FlxMath.bound(((index < wavData[1][0].length && index >= 0) ? wavData[1][0][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;
			var rmax:Float = FlxMath.bound(((index < wavData[1][1].length && index >= 0) ? wavData[1][1][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;

			waveformSprite.pixels.fillRect(new Rectangle(hSize - (lmin + rmin), index * size, (lmin + rmin) + (lmax + rmax), size), 0xFF003DE4);
		}

		waveformPrinted = true;
		waveformSprite.angle = -90;
		waveformSprite.screenCenter();
		#end
	}

	function waveformData(buffer:AudioBuffer, bytes:Bytes, time:Float, endTime:Float, multiply:Float = 1, ?array:Array<Array<Array<Float>>>,
			?steps:Float):Array<Array<Array<Float>>>
	{
		#if (lime_cffi && !macro)
		if (buffer == null || buffer.data == null)
			return [[[0], [0]], [[0], [0]]];

		var khz:Float = (buffer.sampleRate / 1000);
		var channels:Int = buffer.channels;

		var index:Int = Std.int(time * khz);

		var samples:Float = ((endTime - time) * khz);

		if (steps == null)
			steps = 1280;

		var samplesPerRow:Float = samples / steps;
		var samplesPerRowI:Int = Std.int(samplesPerRow);

		var gotIndex:Int = 0;

		var lmin:Float = 0;
		var lmax:Float = 0;

		var rmin:Float = 0;
		var rmax:Float = 0;

		var rows:Float = 0;

		var simpleSample:Bool = true; // samples > 17200;
		var v1:Bool = false;

		if (array == null)
			array = [[[0], [0]], [[0], [0]]];

		while (index < (bytes.length - 1))
		{
			if (index >= 0)
			{
				var byte:Int = bytes.getUInt16(index * channels * 2);

				if (byte > 65535 / 2)
					byte -= 65535;

				var sample:Float = (byte / 65535);

				if (sample > 0)
					if (sample > lmax)
						lmax = sample;
					else if (sample < 0)
						if (sample < lmin)
							lmin = sample;

				if (channels >= 2)
				{
					byte = bytes.getUInt16((index * channels * 2) + 2);

					if (byte > 65535 / 2)
						byte -= 65535;

					sample = (byte / 65535);

					if (sample > 0)
					{
						if (sample > rmax)
							rmax = sample;
					}
					else if (sample < 0)
					{
						if (sample < rmin)
							rmin = sample;
					}
				}
			}

			v1 = samplesPerRowI > 0 ? (index % samplesPerRowI == 0) : false;
			while (simpleSample ? v1 : rows >= samplesPerRow)
			{
				v1 = false;
				rows -= samplesPerRow;

				gotIndex++;

				var lRMin:Float = Math.abs(lmin) * multiply;
				var lRMax:Float = lmax * multiply;

				var rRMin:Float = Math.abs(rmin) * multiply;
				var rRMax:Float = rmax * multiply;

				if (gotIndex > array[0][0].length)
					array[0][0].push(lRMin);
				else
					array[0][0][gotIndex - 1] = array[0][0][gotIndex - 1] + lRMin;

				if (gotIndex > array[0][1].length)
					array[0][1].push(lRMax);
				else
					array[0][1][gotIndex - 1] = array[0][1][gotIndex - 1] + lRMax;

				if (channels >= 2)
				{
					if (gotIndex > array[1][0].length)
						array[1][0].push(rRMin);
					else
						array[1][0][gotIndex - 1] = array[1][0][gotIndex - 1] + rRMin;

					if (gotIndex > array[1][1].length)
						array[1][1].push(rRMax);
					else
						array[1][1][gotIndex - 1] = array[1][1][gotIndex - 1] + rRMax;
				}
				else
				{
					if (gotIndex > array[1][0].length)
						array[1][0].push(lRMin);
					else
						array[1][0][gotIndex - 1] = array[1][0][gotIndex - 1] + lRMin;

					if (gotIndex > array[1][1].length)
						array[1][1].push(lRMax);
					else
						array[1][1][gotIndex - 1] = array[1][1][gotIndex - 1] + lRMax;
				}

				lmin = 0;
				lmax = 0;

				rmin = 0;
				rmax = 0;
			}

			index++;
			rows++;
			if (gotIndex > steps)
				break;
		}

		return array;
		#else
		return [[[0], [0]], [[0], [0]]];
		#end
	}
}
