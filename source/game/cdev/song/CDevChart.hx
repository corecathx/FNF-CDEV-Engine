package game.cdev.song;

// An attempt of making my own chart data since the chart editor got reworked....
typedef CDevChart = {
    var data:ChartData; //contains data like character stuffs and more
    var info:ChartInfo; //contains chart information
    var notes:Array<Dynamic>;
    var events:Array<Dynamic>;
}

typedef ChartInfo = {
    var name:String; //sogn name
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

/*typedef ChartNote = {
    var time:Float;
    var column:Int;
    var hold_length:Float;
    var type:String;
    var args:Array<String>;
}

// ChartEvent already used :(
typedef ChartEventInfo = {
    var name:String;
    var column:Int;
    var time:Float;
    var value1:String;
    var value2:String;
}*/