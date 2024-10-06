package cdev.backend;

import flixel.util.FlxColor;
import cdev.objects.play.hud.RatingSprite.Rating;
import cdev.objects.play.notes.Note;
import sys.io.File;
import haxe.Json;
import sys.FileSystem;
import openfl.media.Sound;
import openfl.text.TextField;
import openfl.text.TextFormat;

using StringTools;

/**
 * Contains useful functions used by the Engine.
 */
class Utils {
    public static var engineColor = {
        primary: 0xFF0060FF
    }
    public static function loadSong(songName:String, diff:String):{inst:Sound, voices:Array<Sound>, chart:Chart} {
        // Initial checking if the song folder exists.
        var path:String = '${Assets._SONG_PATH}/$songName';
        if (!FileSystem.exists(path)) {
            trace("Song could not be found.");
            return null;
        }

        // Checking Inst file.
        trace("Loading Instrumental");
        var inst:Sound = Assets._sound_file('$path/Inst.ogg');
        if (inst == null) {
            trace("Inst audio could not be loaded.");
            return null;
        }

        // Checking Voice files.
        trace("Loading Voice files");
        var voices:Array<Sound> = [];
        for (files in FileSystem.readDirectory(path)) {
            if (FileSystem.isDirectory(path+"/"+files)) 
                continue;
            if (files.startsWith("Voices") && files.endsWith(".ogg")){
                voices.push(Assets._sound_file('$path/${files.replace(".ogg","")}.ogg'));
            }

        }

        // Checking chart file.
        trace("Loading Chart: " + diff + ".json");
        var chartPath:String = '$path/charts/$diff.json';
        if (!FileSystem.exists(chartPath)) {
            trace("Chart file not found: "+chartPath);
            return null;
        }

        trace("Converting Chart...");
        var chart:Chart = Chart.convertLegacy(Json.parse(File.getContent(chartPath)).song);

        trace("Returning Data...");
        // very smart.
        return {
            inst: inst,
            voices: voices,
            chart: chart
        }
    }
    /**
	 * Converts bytes int to formatted sizes. (ex: 10 MB, 100 GB, 1000 TB, etc)
	 * @param bytes		Bytes number that will be converted
	 * @return String	Formatted size of the bytes
	 */
	public static function formatBytes(bytes:Float):String
    {
        if (bytes == 0)
            return "0 B";

        var size_name:Array<String> = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
        var digit:Int = Std.int(Math.log(bytes) / Math.log(1024));
        return FlxMath.roundDecimal(bytes / Math.pow(1024, digit), 2) + " " + size_name[digit];
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
	 * Returns HH:MM:SS time format from miliseconds.
	 * @param ms Miliseconds to convert.
	 * @return String - Formatted time.
	 */
	public static function getTimeFormat(ms:Float):String
    {
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

    public static function getGameplayStatus(sick:Int, good:Int, bad:Int, shit:Int, miss:Int):String 
    {
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

    public static function getAccuracyRank(acc:Float):{rating:String, color:FlxColor}
    {
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
    
    public static function getNoteRating(note:Note, currentTime:Float):Rating
    {
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
}