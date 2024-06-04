
/*
    Main handler for Character changing event.
    This script mainly used to changing character mid-song without getting a lag.
*/

var cachedCharacters:Array<Dynamic> = []; // ["forChar", Character];
function create(){
    //make sure it's all null.
    public['dad'] = null;
    public['gf'] = null;
    public['bf'] = null;
}

function postCreate(){
    if (cachedCharacters >= 2){
        //trace("C")
    }
}

function onEventLoaded(n,v1,v2){
    if (n == "Replace Character"){
        if (_hasCharacter(v2, v1) == null){
            var theChar:Character = new Character(-4000,0,v2, (v1.toLowerCase() == "bf"));
            theChar.alpha = 0.0001;
            add(theChar);
            var data = [v1,v2, theChar];
            cachedCharacters.push(data);
            trace("Successfully cached " + v2 + ", data saved: " + data);
        }
    }
}

function onEvent(n, v1, v2){
    if (n == "Replace Character"){
        var name = v1.toLowerCase();
        var char = (name == "dad" ? PlayState.dad : (name == "gf" ? PlayState.gf : PlayState.boyfriend));
        var icon = (name == "dad" ? PlayState.iconP2 : PlayState.iconP1);
        var s = FlxG.state;
        var p:PlayState = s;

        char.visible = false;

        if (_hasCharacter(v2,v1) != null){
            public[name] = _hasCharacter(v2,v1);
            public[name].x = char.x;
            public[name].y = char.y;
            public[name].alpha = 1;
            s.insert(_getLayerPosition(char)+1,public[name]);
            
            icon.changeDaIcon(public[name].healthIcon);

            var color1 = _getColorFromArray((public['bf'] == null ? PlayState.boyfriend.healthBarColors : public['bf'].healthBarColors));
            var color2 = _getColorFromArray((public['dad'] == null ? PlayState.dad.healthBarColors : public['dad'].healthBarColors));

            PlayState.healthBar.createFilledBar(color2, color1);
            return;
        }
        trace("Cached Character data has no cached character of " + v2 + "!");
        return;
    }
}

/*
    Newly added character handler.
*/
var curBeat = 0;
var curStep = 0;

// Used for handling the hold timers
function update(e){
    var char = [public['dad'], public['gf'], public['gf']];

    for (c in char)
    {
        if (c != null)
        {
            var name = c.animation.curAnim.name;
            if (StringTools.startsWith(name, "sing"))
            {
                c.holdTimer += e;
                if (c.holdTimer >= (Conductor.crochet/1000)*2)
                    c.dance(_getCurAlt(curStep, c.isPlayer), curBeat);
            }
        }
    }
}

function stepHit(s){
    curStep = s;
}

// Used for dance functions.
function beatHit(b){
    curBeat = b;
    var char = [public['dad'], public['gf'], public['gf']];

    for (c in char)
    {
        if (c != null)
        {
            var name = c.animation.curAnim.name;
            if (!StringTools.startsWith(name, "sing"))
            {
                c.dance(_getCurAlt(curStep, c.isPlayer), curBeat);
            }
        }
    }
}
var anims = ["singLEFT", "singDOWN", "singUP", "singRIGHT"];
function p1NoteHit(data, s){
    var animToPlay:String = anims[data];
    var isAlt:Bool = _getCurAlt(curStep, true);
    var char:Character = public['bf'];

    if (char == null)
        return;

    if (isAlt && char.animOffsets.exists(anims[data] + char.singAltPrefix))
        animToPlay = anims[data] + char.singAltPrefix;

    char.playAnim(animToPlay, true);
    char.holdTimer = 0;
}

function p2NoteHit(data, s){
    var animToPlay:String = anims[data];
    var isAlt:Bool = _getCurAlt(curStep, true);
    var char:Character = public['dad'];

    if (char == null)
        return;

    if (isAlt && char.animOffsets.exists(anims[data] + char.singAltPrefix))
        animToPlay = anims[data] + char.singAltPrefix;

    char.playAnim(animToPlay, true);
    char.holdTimer = 0;
}

function onNoteMiss(data){
    var char:Character = public['bf'];
    if (char == null) return;
    var animToPlay:String = anims[data] + "miss";

    if (char.animOffsets.exists(animToPlay))
        char.playAnim(animToPlay, true);
}

/*
    Function
*/

function _getCurAlt(step,player){
    var currentSong = PlayState.SONG;
    if (currentSong.notes[Math.floor(step / 16)] != null)
        return (player ? currentSong.notes[Math.floor(step / 16)].p1AltAnim : currentSong.notes[Math.floor(step / 16)].altAnim);
    return false;
}

function _getLayerPosition(o){
    var s = FlxG.state;
    var p:PlayState = s;

    return s.members.indexOf(o);
}

function _getColorFromArray(a){
    var t = FlxColor.fromRGB(a[0], a[1], a[2]);
    trace(t);
    return t;
}

function _hasCharacter(name, forChar){
    for (i in cachedCharacters){
        if (i[0] == forChar && i[1] == name){
            return i[2];
        }
    }
    return null;
}