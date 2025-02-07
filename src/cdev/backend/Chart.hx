package cdev.backend;

import haxe.Json;

////////////////////////////
////// SONG  METADATA //////
////////////////////////////
/**
 * Song's Metadata, also used by the freeplay.
 */
typedef SongMeta = {
    var name:String;
    var artist:String;
    var color:String;
    var icon:String;
    var bpm:Int;
    var data:{
        var inst:Array<{
            var diff:String;
            var folder:String;
        }>;
        var voices:Array<{
            var diff:String;
            var folder:String;
        }>;
    };
    var difficulties:Array<String>;
    var multiVoice:Bool;
}

////////////////////////////
//////   CHART DATA   //////
////////////////////////////

/**
 * Data types that are supported by the event.
 */
enum abstract EventDataType(String) from String to String {
    var BOOLEAN = "boolean";
    var NUMBER = "number";
    var STRING = "string";
}

/**
 * Note data stored in the chart.
 */
typedef ChartNote = {
    var time:Float;
    var data:Int;
    var length:Float;
    var strum:Int;
    var type:String;
    var args:Array<String>;
}

/**
 * Event data stored in the chart
 */
typedef ChartEventGroup = {
    var time:Float;
    var events:Array<ChartEvent>;
}

/**
 * Event object inside the Event group.
 */
typedef ChartEvent = {
    var name:String;
    var type:EventDataType;
    var values:Array<Any>;
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
    public var events:Array<ChartEventGroup>;

    public static function parse(rawJSON:String) {
        var data:Chart = null;
        try{
            data = cast Json.parse(rawJSON);
        }catch(e) {
            Log.error("Failed parsing chart: " + e.toString());
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
                version: Engine.version
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
        if (json == null) {
            Log.warn("Could not convert, given JSON is null.");
            return getTemplate();
        }
        inline function __addEvent(array:Array<ChartEventGroup>, time:Float, event:ChartEvent) {
            var __done:Bool = false;
            for (eventGrp in array) {
                if (eventGrp.time == time) {
                    eventGrp.events.push(event);
                    __done = true;
                }
            }
            if (!__done) {
                array.push({
                    time: time,
                    events: [event]
                });
            }
        }
        var notes:Array<ChartNote> = [];
        var events:Array<ChartEventGroup> = [];
        var safeJSON:FNFLegacyChart = json;
        
        var lastHitSection:Bool = false;

        var curBPM:Float = safeJSON.bpm;
        var totalPos:Float = 0;

        for (index => i in safeJSON.notes){ 
            if (i.changeBPM && i.bpm != curBPM) {
                __addEvent(events, totalPos, {
                    name: "Change BPM", 
                    type: NUMBER,
                    values: [i.bpm]
                });
                curBPM = i.bpm;
            }
            if (lastHitSection != i.mustHitSection) {
                __addEvent(events, totalPos, {
                    name: "Change Camera Focus", 
                    type: STRING,
                    values: [i.mustHitSection ? "bf" : "dad"]
                });
                lastHitSection =  i.mustHitSection;
            }

            for (j in i.sectionNotes) {
                var noteType:String = '${Std.string(j[3])}'; // HashLink bugged "Uncaught exception: Can't cast i32 to String"
                if (i.mustHitSection)  // Swap the section if it's a player section.
                    j[1] = (j[1] + 4) % 8;

                if (i.p1AltAnim || i.altAnim) 
                    j[3] = "Alt Anim";
                notes.push({
                    time: j[0], 
                    data: Std.int(j[1]%4), 
                    length: j[2], 
                    strum: j[1] > 3 ? 1 : 0, 
                    type: noteType,
                    args: (j[4] == null ? ['',''] : j[4])
                });
            }

            if (Reflect.hasField(i,"sectionEvents")){
                for (k in i.sectionEvents) {
                    // Support for CDEV Engine Legacy ver.
                    __addEvent(events, totalPos, {
                        name: k[0], 
                        type: STRING,
                        values: [k[3],k[4]]
                    });
                }
            }

            totalPos += ((60 / curBPM) * 1000)*4;
        }

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
                version: Engine.version
            },
            notes: notes,
            events: events
        }

        if (Preferences.verboseLog)
            Log.info("Chart converted.");
        return cdev;
    }

    /**
     * Returns value from the chart's meta property list.
     * @param chart The chart
     * @param key The key
     * @return String
     */
    public static function getMeta(chart:Chart, key:String):String {
        for (info in chart.info.meta) {
            if (info.key == key) 
                return info.value;
        }
        return "";
    }
}
////////////////////////////////////////////
//////////////// LEGACY FNF ////////////////
////////////////////////////////////////////
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