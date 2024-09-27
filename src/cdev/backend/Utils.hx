package cdev.backend;

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
}