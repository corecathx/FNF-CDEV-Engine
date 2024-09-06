package funkin.vis.dsp;

import funkin.vis.fast.FastUInt8Array;
import flixel.FlxG;
import flixel.math.FlxMath;
import funkin.vis.grig.audio.FFT;
import funkin.vis.grig.audio.FFTVisualization;
import lime.media.AudioSource;

using funkin.vis.grig.audio.lime.UInt8ArrayTools;

class Bar
{
	public var value:Float;
	public var peak:Float;

	public function new(value:Float, peak:Float)
	{
		this.value = value;
		this.peak = peak;
	}
}

class SpectralAnalyzer
{
	private inline static final fftN:Int = 512;

	public var currentFrame(get, never):Int;
	public var numChannels(get, never):Int;

	private var audioSource:lime.media.AudioSource;
	private var fft:FFT;
	private var vis:FFTVisualization;
	private var barCount:Int;
	private var barHistories = new Array<RecentPeakFinder>();
	private var maxDelta:Float;
	private var peakHold:Int;
	private var blackmanWindow = new Array<Float>();

	public function new(audioSource:lime.media.AudioSource, barCount:Int, maxDelta:Float = 0.01, peakHold:Int = 30)
	{
		this.audioSource = audioSource;
		this.barCount = barCount;
		this.maxDelta = maxDelta;
		this.peakHold = peakHold;
		this.fft = new FFT(fftN);
		this.vis = new FFTVisualization();

		blackmanWindow.resize(fftN);
		for (i in 0...fftN)
		{
			blackmanWindow[i] = calculateBlackmanWindow(i, fftN);
		}
	}

	public function getLevels(?levels:Array<Bar>):Array<Bar>
	{
		if (levels != null)
			levels = [];
		var numOctets = Std.int(audioSource.buffer.bitsPerSample / 8);
		var wantedLength = fftN * numOctets * audioSource.buffer.channels;
		var startFrame = currentFrame;
		startFrame -= startFrame % numOctets;
		var segment = audioSource.buffer.data.subarray(startFrame, min(startFrame + wantedLength, audioSource.buffer.data.length));
		var signal = getSignal(segment, audioSource.buffer.bitsPerSample);

		if (audioSource.buffer.channels > 1)
		{
			var mixed:Array<Float> = [];
			mixed.resize(Std.int(signal.length / audioSource.buffer.channels));
			for (i in 0...mixed.length)
			{
				mixed[i] = 0.0;
				for (c in 0...audioSource.buffer.channels)
				{
					mixed[i] += 0.7 * signal[i * audioSource.buffer.channels + c];
				}
				mixed[i] *= blackmanWindow[i];
			}
			signal = mixed;
		}

		var range = 16;
		var freqs = fft.calcFreq(signal);
		var bars = vis.makeLogGraph(freqs, barCount, 40, range);

		if (bars.length - 1 > barHistories.length)
			barHistories.resize(bars.length - 1);

		levels.resize(bars.length - 1);
		for (i in 0...bars.length - 1)
		{
			if (barHistories[i] == null)
				barHistories[i] = new RecentPeakFinder();
			var recentValues = barHistories[i];
			var value = bars[i] / range;

			// slew limiting
			var lastValue = recentValues.lastValue;
			if (maxDelta > 0.0)
			{
				var delta = clamp(value - lastValue, -1 * maxDelta, maxDelta);
				value = lastValue + delta;
			}
			recentValues.push(value);

			var recentPeak = recentValues.peak;

			if (levels[i] != null)
			{
				levels[i].value = value;
				levels[i].peak = recentPeak;
			}
			else
				levels[i] = new Bar(value, recentPeak);
		}
		return levels;
	}

	// Prevents a memory leak by reusing array
	var _buffer:Array<Float> = [];

	function getSignal(data:lime.utils.UInt8Array, bitsPerSample:Int):Array<Float>
	{
		switch (bitsPerSample)
		{
			case 8:
				_buffer.resize(data.length);
				for (i in 0...data.length)
					_buffer[i] = data[i] / 128.0;

			case 16:
				_buffer.resize(Std.int(data.length / 2));
				for (i in 0..._buffer.length)
					_buffer[i] = data.getInt16(i * 2) / 32767.0;

			case 24:
				_buffer.resize(Std.int(data.length / 3));
				for (i in 0..._buffer.length)
					_buffer[i] = data.getInt24(i * 3) / 8388607.0;

			case 32:
				_buffer.resize(Std.int(data.length / 4));
				for (i in 0..._buffer.length)
					_buffer[i] = data.getInt32(i * 4) / 2147483647.0;

			default:
				trace('Unknown integer audio format');
		}
		return _buffer;
	}

	@:generic
	static inline function clamp<T:Float>(val:T, min:T, max:T):T
		return val <= min ? min : val >= max ? max : val;

	@:generic
	static public inline function min<T:Float>(x:T, y:T):T
		return x > y ? y : x;

	private inline function get_currentFrame():Int
		return Std.int(FlxMath.remapToRange(FlxG.sound.music.time, 0, FlxG.sound.music.length, 0, audioSource.buffer.data.length));

	private inline function get_numChannels():Int
		return audioSource.buffer.channels;

	static function calculateBlackmanWindow(n:Int, fftN:Int)
	{
		final thing = 2 * Math.PI * n / (fftN - 1);
		return 0.42 - 0.50 * Math.cos(thing) + 0.08 * Math.cos(2 * thing);
	}
}
