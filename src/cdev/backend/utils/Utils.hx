package cdev.backend.utils;

import lime.ui.KeyCode;
import cdev.backend.Chart.SongMeta;
import flixel.graphics.frames.FlxImageFrame;
import openfl.display.BitmapData;
import flixel.graphics.frames.FlxFrame;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxColor;
import cdev.objects.play.hud.RatingSprite.Rating;
import cdev.objects.play.notes.Note;
import sys.io.File;
import haxe.Json;

import openfl.media.Sound;
import openfl.text.TextField;
import openfl.text.TextFormat;
import cdev.backend.audio.SoundGroup.SoundTagStruct;

using StringTools;

/**
 * Contains useful functions used by the Engine.
 */
class Utils {
    public static var engineColor = {
        primary: 0xFF0060FF
    }
    public static function loadSong(songName:String, diff:String):{inst:Sound, voices:Array<SoundTagStruct>, chart:Chart, meta:SongMeta} {
        // Check if the song path exists.
        var path:String = '${Assets._SONG_PATH}/$songName';
        if (!FileSystem.exists(path)) {
            trace("Song could not be found.");
            return null;
        }
    
        // Checking meta file.
        var metaPath:String = '$path/meta.json';
        if (!FileSystem.exists(metaPath)) {
            trace("Meta file not found: " + metaPath);
            return null;
        }
    
        trace("Loading Meta: " + metaPath);
        var meta:SongMeta = Json.parse(File.getContent(metaPath));
    
        // Inst and voices stuff.
        var fileNames = {
            inst: "Inst",
            voices: {
                player: "Voices-player",
                opponent: "Voices"
            }
        };
        var diffInst:Bool = false;
        var diffVoices:Bool = false;
        for (data in meta.data.inst) {
            if (data.diff == diff) {
                fileNames.inst = '${data.folder}/Inst';
                diffInst = true;
                break;
            }
        }
        for (data in meta.data.voices) {
            if (data.diff == diff) {
                fileNames.voices.player = '${data.folder}/Voices-player';
                fileNames.voices.opponent = '${data.folder}/Voices';
                diffVoices = true;
                break;
            }
        }
    
        var trackPath:String = '$path/tracks';
        if (!FileSystem.exists(trackPath)) {
            trace("Tracks folder could not be found.");
            return null;
        }
        // Load Instrumental
        var instPath:String = '$trackPath/${fileNames.inst}.ogg';
        if (!FileSystem.exists(instPath)) {
            trace("Inst audio could not be found: " + instPath);
            return null;
        }
        var inst:Sound = Assets._sound_file(instPath);
    
        // Load Voice files
        var voices:Array<SoundTagStruct> = [];
        var foundPlayer:Bool = false;
        var foundOpponent:Bool = false;
        var playerVoxPath:String = '$trackPath/${fileNames.voices.player}.ogg';
        if (!foundPlayer && meta.multiVoice && FileSystem.exists(playerVoxPath)) {
            voices.push({
                sound: Assets._sound_file(playerVoxPath),
                tag: "player"
            });
            trace("Found player vocals.");
            foundPlayer = true;
        }

        var opponentVoxPath:String = '$trackPath/${fileNames.voices.opponent}.ogg';
        if (!foundOpponent && FileSystem.exists(opponentVoxPath)) {
            voices.push({
                sound: Assets._sound_file(opponentVoxPath),
                tag: !meta.multiVoice ? "player" : "others"
            });
            trace("Found opponent vocals, tag: " + (!meta.multiVoice ? "player" : "others"));
            foundOpponent = true;
        }
    
        // Load Chart
        var chartPath:String = '$path/charts/$diff.json';
        if (!FileSystem.exists(chartPath)) {
            trace("Chart file not found: " + chartPath);
            return null;
        }
    
        trace("Loading Chart: " + diff + ".json");
        var chartData = Json.parse(File.getContent(chartPath));
        var chart:Chart = Chart.convertLegacy(chartData.song);
    
        // Return loaded song data
        return {
            inst: inst,
            voices: voices,
            chart: chart,
            meta: meta
        };
    }
    
    /**
	 * Converts bytes int to formatted sizes. (ex: 10 MB, 100 GB, 1000 TB, etc)
	 * @param bytes		Bytes number that will be converted
	 * @return String	Formatted size of the bytes
	 */
	public static function formatBytes(bytes:Float):String {
        if (bytes == 0)
            return "0 B";

        var size_name:Array<String> = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
        var digit:Int = Std.int(Math.log(bytes) / Math.log(1024));
        return FlxMath.roundDecimal(bytes / Math.pow(1024, digit), 2) + " " + size_name[digit];
    }

    /**
     * Splits `text` using \n.
     * @param text Your text.
     * @return Array<String>
     */
    public static function lineSplit(text:String):Array<String> {
        var list:Array<String> = text.trim().split('\n');
        for (i in 0...list.length)
            list[i] = list[i].trim();
        return list;
    }

    /**
     * Applies formats to text between marker characters and removes the markers.
     * Based off FlxText's applyMarkup function.
     *
     * Usage:
     * ```
     * var textField:TextField = new TextField();
     * Utils.applyMarkup(
     *     textField,
     *     "show $green text$ between dollar-signs",
     *     [{ format: greenFormat, marker: "$" }]
     * );
     * ```
     *
     * @param   textField   The target TextField to apply formats to
     * @param   input       The text you want to format
     * @param   rules       Array of format and marker pairs for selective text formatting
     */
    public static function applyTextFieldMarkup(textField:TextField, input:String, rules:Array<{format:TextFormat, marker:String}>):Void {
        if (rules == null || rules.length == 0) return;
        var originalText:String = textField.text;
        
        if (originalText != input)
            textField.text = input; // Only set the text if it's different.
    
        var rangeStarts:Array<Int> = [];
        var rangeEnds:Array<Int> = [];
        var rulesToApply:Array<{format:TextFormat, marker:String}> = [];
    
        for (rule in rules) {
            if (rule.marker == null || rule.format == null) continue;
            
            var start:Bool = false;
            var markerLength:Int = rule.marker.length;
            if (!input.contains(rule.marker)) continue;
    
            for (charIndex in 0...input.length) {
                if (input.substr(charIndex, markerLength) != rule.marker) continue;
    
                if (start) {
                    start = false;
                    rangeEnds.push(charIndex);
                } else {
                    start = true;
                    rangeStarts.push(charIndex);
                    rulesToApply.push(rule);
                }
            }
            
            if (start)
                rangeEnds.push(-1);
        }
    
        for (rule in rules)
            input = input.split(rule.marker).join("");
        
        for (i in 0...rangeStarts.length) {
            var delIndex:Int = rangeStarts[i];
            var markerLength:Int = rulesToApply[i].marker.length;
            
            for (j in 0...rangeStarts.length) {
                if (rangeStarts[j] > delIndex) rangeStarts[j] -= markerLength;
                if (rangeEnds[j] > delIndex) rangeEnds[j] -= markerLength;
            }
    
            delIndex = rangeEnds[i];
            for (j in 0...rangeStarts.length) {
                if (rangeStarts[j] > delIndex) rangeStarts[j] -= markerLength;
                if (rangeEnds[j] > delIndex) rangeEnds[j] -= markerLength;
            }
        }
    
        textField.text = input;
    
        for (i in 0...rangeStarts.length) {
            var startIdx:Int = rangeStarts[i];
            var endIdx:Int = rangeEnds[i];
            if (endIdx == -1) endIdx = input.length;
            textField.setTextFormat(rulesToApply[i].format, startIdx, endIdx);
        }
    }

    /**
     * Call this function to play the game's background music.
     */
    public static function playBGM(?name:String, ?volume:Float) {
        if (name == null) 
            name = "funkinBeat";

        // Just to make sure the audio doesn't go beyond player's music volume preferences.
        volume = (volume != null ? FlxMath.bound(volume, 0, Preferences.musicVolume) : Preferences.musicVolume);

        trace("Playing BGM... " + name + " // " + volume);
        if (FlxG.sound.music == null) 
            FlxG.sound.playMusic(Assets.music(name),volume);
    }
    
	/**
	 * Returns HH:MM:SS time format from miliseconds.
	 * @param ms Miliseconds to convert.
	 * @return String - Formatted time.
	 */
	public static function getTimeFormat(ms:Float):String {
        if (ms < 0) 
            ms = 0;
        var inSeconds:Int = Math.floor(ms / 1000);
        var secs:String = '' + inSeconds % 60;
        var mins:String = "" + Math.floor(inSeconds / 60)%60;
        var hour:String = '' + Math.floor((inSeconds / 3600))%24; 
        if (inSeconds < 0)
            inSeconds = 0;
        if (ms < 0)
            ms = 0;

        if (secs.length < 2)
            secs = '0' + secs;

        var shit:String = mins + ":" + secs;
        if (hour != "0"){
            if (mins.length < 2) mins = "0"+ mins;
            shit = hour+":"+mins + ":" + secs;
        }
        return shit;
    }

    /**
     * Formats a number with dots and stuff, something like
     * 500435111 => 500.435.111
     * @param num the number you want to comment
     * @return String
     */
    public static function formatNumber(num:Int):String {
        var str:String = Std.string(num);
        var result:String = "";
        var count:Int = 0;
    
        for (i in 0...str.length) {
            result = str.charAt(str.length - 1 - i) + result;
            count++;
            if (count % 3 == 0 && i != str.length - 1) 
                result = "." + result;
        }
    
        return result;
    }    

    public static function getGameplayStatus(sick:Int, good:Int, bad:Int, shit:Int, miss:Int):String  {
        var daRank:String = '';
        if (miss == 0 && bad == 0 && shit == 0 && good == 0)
            daRank = "MFC";
        else if (miss == 0 && bad == 0 && shit == 0 && good >= 1)
            daRank = "GFC";
        else if (miss == 0)
            daRank = "FC";
        else if (miss < 10)
            daRank = "SDCB";
        else
            daRank = "Clear";

        return daRank;
    }

    public static function getAccuracyRank(acc:Float):{rating:String, color:FlxColor} {
        acc = Math.round(acc);
        var ratingData:Array<{accuracy:Int, data:{rating:String, color:FlxColor}}> = [
            {accuracy: 1,   data: {rating:"?", color: 0xFFFFFFFF}},
            {accuracy: 70,   data: {rating:"F", color: 0xFFFF0000}},
            {accuracy: 75,  data: {rating:"D", color: 0xFFFF8800}},
            {accuracy: 80,  data: {rating:"C", color: 0xFFFFD900}},
            {accuracy: 85,  data: {rating:"B", color: 0xFFB3FF00}},
            {accuracy: 90,  data: {rating:"A", color: 0xFF1EFF00}},
            {accuracy: 95,  data: {rating:"S", color: 0xFF00CCFF}},
            {accuracy: 99,  data: {rating:"S+", color: 0xFF00CCFF}},
            {accuracy: 100, data: {rating:"S++", color: 0xFF00CCFF}}
        ];
    
        for (data in ratingData)
            if (acc <= data.accuracy)
                return data.data;
        
        return {rating:"S++", color: 0xFF00CCFF};
    }

    /**
     * Returns Accuracy Rating based off your accuracy.
     * @param acc Your accuracy.
     * @return String
     */
    public static function getAccuracyRating(acc:Float):String {
        acc = Math.round(acc); // Round the accuracy
    
        var ratingData:Array<{accuracy:Int, rating:String}> = [
            {accuracy: 1,  rating: "N/A"},
            {accuracy: 2,  rating: "Bro"},
            {accuracy: 5,  rating: "Nahh"},
            {accuracy: 10,  rating: "Lmao"},
            {accuracy: 20, rating: "Wtf"},
            {accuracy: 30, rating: "Shit"},
            {accuracy: 40, rating: "Eh"},
            {accuracy: 50, rating: "Bad"},
            {accuracy: 60, rating: "Okay"},
            {accuracy: 69, rating: "Decent"},
            {accuracy: 70, rating: "Nice"},
            {accuracy: 80, rating: "Good"},
            {accuracy: 90, rating: "Great"},
            {accuracy: 99, rating: "Sick!"},
            {accuracy: 100, rating: "Perfect!"}
        ];
    
        for (data in ratingData)
            if (acc <= data.accuracy)
                return data.rating;
    
        return "Amazing!"; // Just incase the accuracy went above 100.
    }
    
    public static function getNoteRating(note:Note, currentTime:Float):Rating {
        var theTimingWindow:Array<Float> = [166,135,90,55];
        var theDiff = Math.abs((note.time - currentTime));
        for (i in 0...theTimingWindow.length){
            var judgeTime = theTimingWindow[i];
            var newTime = i + 1 > theTimingWindow.length - 1 ? 0 : theTimingWindow[i + 1];
            if (theDiff < judgeTime && theDiff >= newTime)
            {
                switch(i)
                {
                    case 0:
                        return SHIT;
                    case 1:
                        return BAD;
                    case 2:
                        return GOOD;
                    case 3:
                        return SICK;
                }
            }
        }
        return SHIT;
    }

    public static function getKeyFormat(key:FlxKey):String {
        switch (key) {
            case FlxKey.ZERO: return "0";
            case FlxKey.ONE: return "1";
            case FlxKey.TWO: return "2";
            case FlxKey.THREE: return "3";
            case FlxKey.FOUR: return "4";
            case FlxKey.FIVE: return "5";
            case FlxKey.SIX: return "6";
            case FlxKey.SEVEN: return "7";
            case FlxKey.EIGHT: return "8";
            case FlxKey.NINE: return "9";
            case FlxKey.COMMA: return ",";
            case FlxKey.PERIOD: return ".";
            case FlxKey.SEMICOLON: return ";";
            case FlxKey.QUOTE: return "'";
            case FlxKey.BACKSLASH: return "\\";
            case FlxKey.SLASH: return "/";
            case FlxKey.MINUS: return "-";
            case FlxKey.PLUS: return "=";
            case FlxKey.LBRACKET: return "[";
            case FlxKey.RBRACKET: return "]";
            case FlxKey.GRAVEACCENT: return "`";
            case FlxKey.SPACE: return " ";
            case FlxKey.TAB: return "\t";
            case FlxKey.ENTER: return "\n";
            default: return key.toString();
        }
    }

    public static function destroyObject(obj:FlxBasic) {
        if (obj == null) {
            trace("Could not destroy object.");
            return;
        }

        obj.kill();
        if (FlxG.state != null && FlxG.state.members.contains(obj))
            FlxG.state.remove(obj);

        obj.destroy();
    }

    public static function getFlxKey(key:KeyCode):FlxKey {
        var keyMap:Map<KeyCode, FlxKey> = [
            KeyCode.A => FlxKey.A,
            KeyCode.B => FlxKey.B,
            KeyCode.C => FlxKey.C,
            KeyCode.D => FlxKey.D,
            KeyCode.E => FlxKey.E,
            KeyCode.F => FlxKey.F,
            KeyCode.G => FlxKey.G,
            KeyCode.H => FlxKey.H,
            KeyCode.I => FlxKey.I,
            KeyCode.J => FlxKey.J,
            KeyCode.K => FlxKey.K,
            KeyCode.L => FlxKey.L,
            KeyCode.M => FlxKey.M,
            KeyCode.N => FlxKey.N,
            KeyCode.O => FlxKey.O,
            KeyCode.P => FlxKey.P,
            KeyCode.Q => FlxKey.Q,
            KeyCode.R => FlxKey.R,
            KeyCode.S => FlxKey.S,
            KeyCode.T => FlxKey.T,
            KeyCode.U => FlxKey.U,
            KeyCode.V => FlxKey.V,
            KeyCode.W => FlxKey.W,
            KeyCode.X => FlxKey.X,
            KeyCode.Y => FlxKey.Y,
            KeyCode.Z => FlxKey.Z,
            KeyCode.NUMBER_0 => FlxKey.ZERO,
            KeyCode.NUMBER_1 => FlxKey.ONE,
            KeyCode.NUMBER_2 => FlxKey.TWO,
            KeyCode.NUMBER_3 => FlxKey.THREE,
            KeyCode.NUMBER_4 => FlxKey.FOUR,
            KeyCode.NUMBER_5 => FlxKey.FIVE,
            KeyCode.NUMBER_6 => FlxKey.SIX,
            KeyCode.NUMBER_7 => FlxKey.SEVEN,
            KeyCode.NUMBER_8 => FlxKey.EIGHT,
            KeyCode.NUMBER_9 => FlxKey.NINE,
            KeyCode.RETURN => FlxKey.ENTER,
            KeyCode.ESCAPE => FlxKey.ESCAPE,
            KeyCode.BACKSPACE => FlxKey.BACKSPACE,
            KeyCode.TAB => FlxKey.TAB,
            KeyCode.SPACE => FlxKey.SPACE,
            KeyCode.LEFT => FlxKey.LEFT,
            KeyCode.RIGHT => FlxKey.RIGHT,
            KeyCode.UP => FlxKey.UP,
            KeyCode.DOWN => FlxKey.DOWN,
            KeyCode.F1 => FlxKey.F1,
            KeyCode.F2 => FlxKey.F2,
            KeyCode.F3 => FlxKey.F3,
            KeyCode.F4 => FlxKey.F4,
            KeyCode.F5 => FlxKey.F5,
            KeyCode.F6 => FlxKey.F6,
            KeyCode.F7 => FlxKey.F7,
            KeyCode.F8 => FlxKey.F8,
            KeyCode.F9 => FlxKey.F9,
            KeyCode.F10 => FlxKey.F10,
            KeyCode.F11 => FlxKey.F11,
            KeyCode.F12 => FlxKey.F12,
            KeyCode.GRAVE => FlxKey.GRAVEACCENT,
            KeyCode.MINUS => FlxKey.MINUS,
            KeyCode.EQUALS => FlxKey.PLUS,
            KeyCode.LEFT_BRACKET => FlxKey.LBRACKET,
            KeyCode.RIGHT_BRACKET => FlxKey.RBRACKET,
            KeyCode.BACKSLASH => FlxKey.BACKSLASH,
            KeyCode.SEMICOLON => FlxKey.SEMICOLON,
            KeyCode.QUOTE => FlxKey.QUOTE,
            KeyCode.COMMA => FlxKey.COMMA,
            KeyCode.PERIOD => FlxKey.PERIOD,
            KeyCode.SLASH => FlxKey.SLASH,
            KeyCode.NUMPAD_PLUS => FlxKey.NUMPADPLUS,
            KeyCode.NUMPAD_MINUS => FlxKey.NUMPADMINUS,
            KeyCode.NUMPAD_MULTIPLY => FlxKey.NUMPADMULTIPLY,
            KeyCode.NUMPAD_DIVIDE => FlxKey.NUMPADSLASH,
            KeyCode.NUMPAD_0 => FlxKey.NUMPADZERO,
            KeyCode.NUMPAD_1 => FlxKey.NUMPADONE,
            KeyCode.NUMPAD_2 => FlxKey.NUMPADTWO,
            KeyCode.NUMPAD_3 => FlxKey.NUMPADTHREE,
            KeyCode.NUMPAD_4 => FlxKey.NUMPADFOUR,
            KeyCode.NUMPAD_5 => FlxKey.NUMPADFIVE,
            KeyCode.NUMPAD_6 => FlxKey.NUMPADSIX,
            KeyCode.NUMPAD_7 => FlxKey.NUMPADSEVEN,
            KeyCode.NUMPAD_8 => FlxKey.NUMPADEIGHT,
            KeyCode.NUMPAD_9 => FlxKey.NUMPADNINE
        ];

        if (keyMap.exists(key))
            return keyMap.get(key);

        return FlxKey.NONE;
    }    
}