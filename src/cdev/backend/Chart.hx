package cdev.backend;

import haxe.Json;

typedef ChartNote = {
    var time:Float;
    var data:Int;
    var length:Float;
    var strum:Int;
    var type:String;
    var args:Array<String>;
}
typedef ChartEvent = {
    var time:Float;
    var data:Int;
    var name:String;
    var args:Array<String>;
}

@:structInit
class Chart {
    // Contains character data and skins data
    public var data:{
        player:String,
        opponent:String,
        spectator:String,
        stage:String,
        
        note_skin:String,
        splash_skin:String
    };
    // Contains chart information
    public var info:{ 
        name:String,
        meta:Array<{
            key:String, value:String
        }>,
        bpm:Float,
        speed:Float,
        time_signature:Array<Int>,
        version:String
    };
    // Notes in the chart. 
    public var notes:Array<ChartNote>;
    // Events in the chart.
    public var events:Array<ChartEvent>;

    public static function parse(rawJSON:String) {
        var data:Chart = null;
        try{
            data = cast Json.parse(rawJSON);
        }catch(e) {
            trace("Failed parsing chart: " + e.toString());
        }
        return data;
    }

    /**
     * Loads basic template of CDEV Engine's Chart Format.
     */
    public static function getTemplate() {
        var c:Chart = {
            data: {
                player: "bf",
                opponent: "dad",
                spectator: "gf",
                stage: "stage",
                note_skin: "notes/NOTE_assets",
                splash_skin: "notes/splash/NOTE_splash"
            },
            info: {
                name: "Tutorial",
                meta: [
                    { key: "Composer", value: "Kawai Sprite" },
                    { key: "Charter", value: "ninjamuffin99" },
                ],
                bpm: 100,
                speed: 1,
                time_signature: [4,4],
                version: Config.engine.version
            },
            notes: [],
            events: []
        };
        return c;
    }

    /**
	 * Converts a Legacy FNF chart to CDEV Engine's chart format.
	 * @param json The JSON of your FNF Chart 
	 * @return New CDEV Chart Object
	 */
	public static function convertLegacy(json:FNFLegacyChart):Chart
    {
        trace("Preparing to convert...");
        if (json == null) {
            trace("JSON is null?");
            return getTemplate();
        }
        var notes:Array<ChartNote> = [];
        var events:Array<ChartEvent> = [];
        var safeJSON:FNFLegacyChart = json;
        
        var lastHitSection:Bool = false;

        var curBPM:Float = safeJSON.bpm;
        var totalPos:Float = 0;

        trace("Converting...");

        for (index => i in safeJSON.notes){ 
            if (i.changeBPM && i.bpm != curBPM) {
                events.push({
                    time: totalPos, data: 0, name: "Change BPM", args: [Std.string(i.bpm)]
                });
                curBPM = i.bpm;
            }
            if (lastHitSection != i.mustHitSection) {
                events.push({
                    time: totalPos, data: 0, name: "Change Camera Focus", args: [i.mustHitSection ? "bf" : "dad"]
                });
                lastHitSection =  i.mustHitSection;
            }

            for (j in i.sectionNotes) {
                if (i.mustHitSection) { //swap the section if it's a player section.
                    j[1] = (j[1] + 4) % 8;
                }
                if (i.p1AltAnim || i.altAnim) 
                    j[3] = "Alt Anim";
                notes.push({
                    time: j[0], data: Std.int(j[1]%4), length: j[2], strum: j[1] > 3 ? 1 : 0, type:(j[3]==null?"Default Note":j[3]),args:(j[4]==null?['','']:j[4])
                });
            }

            if (Reflect.hasField(i,"sectionEvents")){ // bruh
                for (k in i.sectionEvents) events.push({
                    time: k[2], data: k[1], name: k[0], args: [k[3],k[4]]
                });
            }

            totalPos += ((60 / curBPM) * 1000)*4;
        }

        trace("Converted all notes & events. Sorting...");
        events.sort((a:Dynamic, b:Dynamic)->{
            var result:Int = 0;
    
            if (a.time < b.time)
                result = -1;
            else if (a.time > b.time)
                result = 1;
    
            return result;
        });

        notes.sort((a:Dynamic, b:Dynamic)->{
            var result:Int = 0;
    
            if (a.time < b.time)
                result = -1;
            else if (a.time > b.time)
                result = 1;
    
            return result;
        });

        var cdev:Chart = {
            data: {
                player: safeJSON.player1,
                opponent: safeJSON.player2,
                spectator: (safeJSON.gfVersion == null ? "gf" : safeJSON.gfVersion),
                stage: safeJSON.stage,
                note_skin: "notes/NOTE_assets",
                splash_skin: "notes/splash/NOTE_splash",
            },
            info: {
                name: safeJSON.song,
                meta: [
                    { key: "Composer", value: "Kawai Sprite" },
                ],
                bpm: safeJSON.bpm,
                speed: safeJSON.speed,
                time_signature: [4,4], // since most of fnf songs are charted in 4/4 time signature, set this by default.
                version: Config.engine.version
            },
            notes: notes,
            events: events
        }

        trace("Chart convert finished.");
        return cdev;
    }
}

typedef FNFLegacyChart = {
	var song:String;
	var notes:Array<FNFLegacySection>;
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

typedef FNFLegacySection = {
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