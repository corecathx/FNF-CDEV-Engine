package funkin.vis.dsp;

import funkin.vis.fast.FastUInt8Array;
import flixel.FlxG;
import flixel.math.FlxMath;
import funkin.vis.grig.audio.FFT;
import funkin.vis.grig.audio.FFTVisualization;
import lime.media.AudioSource;

using funkin.vis.grig.audio.lime.UInt8ArrayTools;

class Bar {
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
		for (i in 0...fftN) {
			blackmanWindow[i] = calculateBlackmanWindow(i, fftN);
		}
	}

	public function getLevels():Array<Bar>
	{
		var numOctets = Std.int(audioSource.buffer.bitsPerSample / 8);
		var wantedLength = fftN * numOctets * numChannels;
		var startFrame = currentFrame;
		startFrame -= startFrame % numOctets;
		var data:FastUInt8Array = audioSource.buffer.data;
		var segment = data.subarray(startFrame, Utils.min(startFrame + wantedLength, audioSource.buffer.data.length));
		var signal = segment.toInterleaved(audioSource.buffer.bitsPerSample);

		if (numChannels > 1) {
			var mixed = new Array<Float>();
			mixed.resize(Std.int(signal.length / numChannels));
			for (i in 0...mixed.length) {
				mixed[i] = 0.0;
				for (c in 0...numChannels) {
					mixed[i] += 0.7 * signal[i*numChannels+c];
				}
				mixed[i] *= blackmanWindow[i];
			}
			signal = mixed;
		}

		// trace(signal);

		var range = 16;
		var freqs = fft.calcFreq(signal);
		var bars = vis.makeLogGraph(freqs, barCount, 40, range);

		if (bars.length > barHistories.length) {
			barHistories.resize(bars.length);
		}

		var levels = new Array<Bar>();
		levels.resize(bars.length);
		for (i in 0...bars.length) {
			if (barHistories[i] == null) barHistories[i] = new RecentPeakFinder();
			var recentValues = barHistories[i];
			var value = bars[i] / range;

			// slew limiting
			var lastValue = recentValues.lastValue;
			if (maxDelta > 0.0) {
				var delta = Utils.clamp(value - lastValue, -1 * maxDelta, maxDelta);
				value = lastValue + delta;
			}
			recentValues.push(value);

			var recentPeak = recentValues.peak;

			levels[i] = new Bar(value, recentPeak);
		}
		return levels;
	}

	private inline function get_currentFrame():Int
	{
		return Std.int(FlxMath.remapToRange(FlxG.sound.music.time, 0, FlxG.sound.music.length, 0, audioSource.buffer.data.length));
	}

	private inline function get_numChannels():Int
	{
		return audioSource.buffer.channels;
	}

	static function calculateBlackmanWindow(n:Int, fftN:Int)
	{
		final thing = 2 * Math.PI * n / (fftN - 1);
		return 0.42 - 0.50 * Math.cos(thing) + 0.08 * Math.cos(2 * thing);
	}
}