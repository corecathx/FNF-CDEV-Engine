package;

import sys.io.File;
import haxe.Json;
import sys.FileSystem;

using StringTools;

/**
 * CDEV CHART INFOS
 */
typedef CDevChart = {
    var data:ChartData; //contains data like character stuffs and more
    var info:ChartInfo; //contains chart information
    var notes:Array<Dynamic>;
    var events:Array<Dynamic>;
}

typedef ChartInfo = {
    var name:String; //sogn name
    var composer:String;
    var bpm:Float;
    var speed:Float;
    var time_signature:Array<Int>; //[4,4]
    var version:String; // engine version
}

typedef ChartData = {
    var player:String;
    var opponent:String;
    var third_char:String; //this sucks
    var stage:String;
    
    var note_skin:String;
}

/**
 * BASE GAME CHART INFOS
 */
typedef SongEvent =
{
	var name:String; // dumb
}
typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var songEvents:Array<SongEvent>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;
	var offset:Float;
	var stage:String;

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var validScore:Bool;
}

typedef SwagSection =
{
	var sectionNotes:Array<Dynamic>; // strumtime, notedata, sustain, //new: notetype, //new: params[]
	var sectionEvents:Array<Dynamic>; // eventName, data, strumtime, val1, val2
	var lengthInSteps:Int;
	var typeOfSection:Int;
	var mustHitSection:Bool;
	var banger:Bool;
	var bpm:Float;
	var changeBPM:Bool;
	var altAnim:Bool;
	var p1AltAnim:Bool;
}

class ChartConverter
{
    static var chartFolderTemp:String = "./chartTemp/";
    /**
     * Main function of this class, used by haxe.
     */
    public static function main() {
        cls();
        Sys.println("Base FNF Chart to CDEV Chart");
        var path:String = askInput("Folder path of base game charts [cdev engine assets folder required]");
        if (!FileSystem.exists(path)){
            Sys.println("Folder doesn't exists.");
            return;
        }
        var chartFolder:String = path+"/data/charts/";
        if (!FileSystem.exists(chartFolder)){
            Sys.println("Charts folder doesn't exists, are you sure this is CDEV Engine assets folder?");
            return;
        }

        if (!FileSystem.exists(chartFolderTemp)){
            Sys.println("Creating temp folder to store converted charts...");
            FileSystem.createDirectory(chartFolderTemp);
        }


        for (song in FileSystem.readDirectory(chartFolder)){
            Sys.println("Converting: " + song);
            var newPath:String = chartFolderTemp+"/"+song+"/";
            if (!FileSystem.exists(newPath)){
                FileSystem.createDirectory(newPath);
            }

            convertChart(song, chartFolder);
            Sys.sleep(0.1);
        }
    }

    /**
     * Converting charts...
     * @param songName 
     * @param rootFolder 
     */
    static function convertChart(songName:String, rootFolder:String) {
        var songPath:String = rootFolder+"/"+songName+"/";
        for (file in FileSystem.readDirectory(songPath)){
            if (!file.endsWith('json') || !file.startsWith(songName)) {
                Sys.println("Skipping " + file+", seems like not a chart json file.");
                continue;
            }
            Sys.println("Reading: " + file);
            var baseFile:SwagSong = cast Json.parse(File.getContent(songPath+"/"+file)).song;
            Sys.println("Converting....");
            var newFile:CDevChart = fnftocdev_chart(baseFile);
            // trace(daJson);

            var newPath:String = chartFolderTemp+"/"+songName+"/"+file.substr(0, file.length - 5)+".cdc";
            File.saveContent(newPath, Json.stringify(newFile, null, "\t"));
            Sys.println("File saved in " + newPath);
        }
    }

    /**
	 * Converts a base FNF chart to CDEV Engine's chart format.
     * straight up copied from CDevUtils.
	 * @param json The JSON of your FNF Chart 
	 * @return New CDEV Chart Object
	 */
	static function fnftocdev_chart(json:SwagSong):CDevChart {
		var notes:Array<Dynamic> = [];
		var events:Array<Dynamic> = [];
		var safeJSON:SwagSong = json;
		
		for (i in safeJSON.notes){
			for (j in i.sectionNotes){
				if (i.mustHitSection){//swap the section if it's a player section.
					var note = j;
					note[1] = (note[1] + 4) % 8;
					j = note;
				}
				notes.push([j[0],j[1],j[2],(j[3]==null?"Default Note":j[3]),(j[4]==null?['','']:j[4])]);
			}
			if (Reflect.hasField(i,"sectionEvents")){ // bruh
				for (k in i.sectionEvents){
					events.push([k[0],k[1],k[2],k[3],k[4]]);
				}
			}
		}
		var cdev:CDevChart = {
			data: {
				player: safeJSON.player1,
				opponent: safeJSON.player2,
				third_char: (safeJSON.gfVersion == null ? "gf" : safeJSON.gfVersion),
				stage: safeJSON.stage,
				note_skin: "notes/NOTE_assets"
			},
			info: {
				name: safeJSON.song,
				composer: "Kawai Sprite",
				bpm: safeJSON.bpm,
				speed: safeJSON.speed,
				time_signature: [4,4], // since most of fnf songs are charted in 4/4 time signature, set this by default.
				version: "CDEV Chart Converter 0.1.0"
			},
			notes: notes,
			events: events
		}

		return cdev;
	}

    /**
     * ignore anything below this comment..
     */

    static function cls() {
        for (i in 0...20){
            Sys.println("\r");
        }
    }

    static function askInput(ask:String):String{
        Sys.print("[?] "+ask+ " >> ");
		var input = Sys.stdin().readLine();
		return input;
    }
}