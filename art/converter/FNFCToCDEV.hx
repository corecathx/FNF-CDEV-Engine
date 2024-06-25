import haxe.ds.ArraySort;
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

class FNFCToCDEV {
    
    static var chartFolderTemp:String = "./chartTemp-FNFC/";
    /**
     * Main function of this class, used by haxe.
     */
    public static function main():Void {
        cls();
        Sys.println("FNFC Chart to CDEV Chart");
        var path:String = askInput("Folder path of the FNFC chart (containing -chart and -meta)");
        if (!FileSystem.exists(path)){
            Sys.println("Folder doesn't exists.");
            return;
        }
        if (!FileSystem.isDirectory(path)) {
            Sys.println("Path should be directory.");
            return;
        }

        //F:\[2] Programs\[2] Games\funkin-windows-64bit\assets\data\songs\darnell\
        var chartFolder:Array<String> = FileSystem.readDirectory(path);
        var chartExists:Bool = false;
        var metaExists:Bool = false;
        for (i in chartFolder) {
            i = i.substr(0, i.length - 5);
            trace(i);
            if (i.endsWith("-chart")) chartExists = true;
            if (i.endsWith("-metadata")) metaExists = true;
        }
        cls();

        if (!chartExists || !metaExists){
            Sys.println("Some files are missing.");
            return;
        }

        Sys.println("Found 'em all!");
        Sys.println(chartFolder+"\n");

        if (!FileSystem.exists(chartFolderTemp)){
            Sys.println("Creating temp folder to store converted charts...");
            FileSystem.createDirectory(chartFolderTemp);
        }

        var chartData:String = "";
        var metaData:String = "";
        for (files in chartFolder) {
            var i = files.substr(0, files.length - 5);
            if (i.endsWith("-chart")) chartData = File.getContent(path+"/"+files);
            if (i.endsWith("-metadata")) metaData = File.getContent(path+"/"+files);
        }
        cls();
        if (chartData == "" || metaData == ""){
            Sys.println("Failed getting datas.");
            return;
        }

        Sys.println("Read success! Converting...");
        fnfc_to_cdev(chartData,metaData);
    }
    static function fnfc_to_cdev(chart:String, meta:String) {
        var c_json:Dynamic = Json.parse(chart);
        var m_json:Dynamic = Json.parse(meta);
        var notes:Array<Dynamic> = [];
        var cdev_events:Array<Dynamic> = [];

        var cdev:CDevChart = {
			data: {
				player: m_json.playData.characters.player,
				opponent: m_json.playData.characters.opponent,
				third_char: (m_json.playData.characters.girlfriend == null ? "gf" : m_json.playData.characters.girlfriend),
				stage: m_json.playData.stage,
				note_skin: "notes/NOTE_assets"
			},
			info: {
				name: m_json.songName,
				composer: m_json.artist,
				bpm: m_json.timeChanges[0].bpm,
				speed: 2,
				time_signature: [4,4], // since most of fnf songs are charted in 4/4 time signature, set this by default.
				version: "CDEV Chart Converter 0.1.0"
			},
			notes: [],
			events: []
		}

        var events:Array<Dynamic> = cast c_json.events;
        for (event in events) {
            if (event.e == "FocusCamera"){
                cdev_events.push(["Change Camera Focus", 0, event.t, Reflect.getProperty(event.v,"char") == 0 ? "bf" : "dad", ""]);
            }
        }
        cdev.events = cdev_events;

        for (diff in Reflect.fields(c_json.notes)){
            notes = [];
            cdev.info.speed = Reflect.getProperty(c_json.scrollSpeed, diff);
            var nArray:Array<Dynamic> = Reflect.getProperty(c_json.notes,diff);
            for (note in nArray) {
                notes.push([note.t, ((note.d+4)%8), note.l, (note.k == null?"Default Note":note.k), ['','']]);
            }
            cdev.notes = notes;
            if (!FileSystem.exists(chartFolderTemp+"/"+cdev.info.name+"/")){
                FileSystem.createDirectory(chartFolderTemp+"/"+cdev.info.name+"/");
            }
            var newPath:String = chartFolderTemp+"/"+cdev.info.name+"/"+cdev.info.name.toLowerCase()+"-"+diff+".cdc";
            File.saveContent(newPath, Json.stringify(cdev, null, "\t"));
        }

    }

         /*
	public function legacy_to_cdev(json:SwagSong):CDevChart
    {
        if (json == null) {
            Log.warn("JSON is null?");
            return CDEV_CHART_TEMPLATE;
        }
        var notes:Array<Dynamic> = [];
        var events:Array<Dynamic> = [];
        var safeJSON:SwagSong = json;
        
        var lastHitSection:Bool = false;

        var curBPM:Float = safeJSON.bpm;
        var totalPos:Float = 0;

        for (index => i in safeJSON.notes){ 
            if (i.changeBPM && i.bpm != curBPM) {
                events.push(["Change BPM", 0, totalPos, Std.string(i.bpm), ""]);
                curBPM = i.bpm;
            }
            if (lastHitSection != i.mustHitSection) {
                events.push(["Change Camera Focus", 0, totalPos, i.mustHitSection ? "bf" : "dad", ""]);
                lastHitSection =  i.mustHitSection;
            }

            for (j in i.sectionNotes){
                if (i.mustHitSection){ //swap the section if it's a player section.
                    var note = j;
                    note[1] = (note[1] + 4) % 8;
                    j = note;
                }
                if (i.p1AltAnim || i.altAnim) j[3] = "Alt Anim";
                notes.push([j[0],j[1],j[2],(j[3]==null?"Default Note":j[3]),(j[4]==null?['','']:j[4])]);
            }

            if (Reflect.hasField(i,"sectionEvents")){ // bruh
                for (k in i.sectionEvents) events.push([k[0],k[1],k[2],k[3],k[4]]);
            }

            totalPos += ((60 / curBPM) * 1000)*4;
        }

        events.sort((a:Dynamic, b:Dynamic)->{
            var result:Int = 0;
    
            if (a[2] < b[2])
                result = -1;
            else if (a[2] > b[2])
                result = 1;
    
            return result;
        });

        notes.sort((a:Dynamic, b:Dynamic)->{
            var result:Int = 0;
    
            if (a[0] < b[0])
                result = -1;
            else if (a[0] > b[0])
                result = 1;
    
            return result;
        });
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


    static function convertChart(songName:String, rootFolder:String) {
        var songPath:String = rootFolder+"/"+songName+"/";
        for (file in FileSystem.readDirectory(songPath)){
            if (!file.endsWith('json') || !file.startsWith(songName)) {
                continue;
            }
            Sys.println("Working on: " + file);
            var baseFile:SwagSong = cast Json.parse(File.getContent(songPath+"/"+file)).song;
            var newFile:CDevChart = fnftocdev_chart(baseFile);
            // trace(daJson);

            var newPath:String = chartFolderTemp+"/"+songName+"/"+file.substr(0, file.length - 5)+".cdc";
            File.saveContent(newPath, Json.stringify(newFile, null, "\t"));
        }
    }

	static function fnftocdev_chart(json:SwagSong):CDevChart {
		var notes:Array<Dynamic> = [];
		var events:Array<Dynamic> = [];
		var safeJSON:SwagSong = json;
		
        var lastHitSection:Bool = false;

        var curBPM:Float = safeJSON.bpm;
        var totalPos:Float = 0;

		for (index => i in safeJSON.notes){ 
            Sys.println("Working: " + ((index/safeJSON.notes.length)*100) + "%");
            if (i.changeBPM && i.bpm != curBPM) {
                events.push(["Change BPM", 0, totalPos, Std.string(i.bpm), ""]);
                curBPM = i.bpm;
            }
            if (lastHitSection != i.mustHitSection) {
                events.push(["Change Camera Focus", 0, totalPos, i.mustHitSection ? "bf" : "dad", ""]);
                lastHitSection =  i.mustHitSection;
            }

			for (j in i.sectionNotes){
				if (i.mustHitSection){ //swap the section if it's a player section.
					var note = j;
					note[1] = (note[1] + 4) % 8;
					j = note;
				}
				if (i.p1AltAnim || i.altAnim) j[3] = "Alt Anim";
				notes.push([j[0],j[1],j[2],(j[3]==null?"Default Note":j[3]),(j[4]==null?['','']:j[4])]);
			}
            
			if (Reflect.hasField(i,"sectionEvents")){ // bruh
				for (k in i.sectionEvents) events.push([k[0],k[1],k[2],k[3],k[4]]);
			}

            totalPos += ((60 / curBPM) * 1000)*4;
		}

        events.sort((a:Dynamic, b:Dynamic)->{
            var result:Int = 0;
    
            if (a[2] < b[2])
                result = -1;
            else if (a[2] > b[2])
                result = 1;
    
            return result;
        });

        notes.sort((a:Dynamic, b:Dynamic)->{
            var result:Int = 0;
    
            if (a[0] < b[0])
                result = -1;
            else if (a[0] > b[0])
                result = 1;
    
            return result;
        });
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
	}*/

    /**
     * ignore anything below this comment..
     */

    static function cls() Sys.command("cls");

    static function askInput(ask:String):String{
        Sys.print("[?] "+ask+ " >> ");
		var input = Sys.stdin().readLine();
		return input;
    }

}