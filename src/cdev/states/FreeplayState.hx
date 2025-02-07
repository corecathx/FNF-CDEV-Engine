package cdev.states;

import cdev.objects.play.hud.HealthIcon;
import cdev.backend.Chart.SongMeta;

using StringTools;

typedef FreeplaySongList = {name:String, meta:SongMeta}

class FreeplayState extends State
{
	var bg:Background;
	var difficultyList:Array<String> = [];
	var currentDifficulty(default,set):Int = 0;

	var currentSelection(default,set):Int = 0;
    var songs:Array<FreeplaySongList> = [];
	var grpSongs:FlxTypedGroup<Alphabet>;
	var iconList:Array<HealthIcon> = [];

	var diffText:Text;

	override public function create()
	{
		super.create();
		bg = new Background();
		bg.screenCenter();
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);
		initSongs();

		diffText = new Text(10,0, "< DIFF >");
		diffText.y = FlxG.height - diffText.height - 10; 
		add(diffText);
	}

    function initSongs() {
		var _songList:Array<String> = Utils.lineSplit(Assets.text("freeplayList"));

        for (_song in _songList) {
			var path:String = '${Assets._SONG_PATH}/$_song';
			if (!FileSystem.exists(path)) 
				continue;
			var metaPath:String = '$path/meta.json';
			if (!FileSystem.exists(metaPath)) 
				continue;

			var meta:SongMeta = Json.parse(File.getContent(metaPath));
			songs.push({name: _song, meta:meta});
        }
		if (Preferences.verboseLog)
            trace("Generating UI...");
		for (index => _song in songs) {
			var sng:Alphabet = new Alphabet(120, (FlxG.height * 0.48) + (120 * index), _song.meta.name, true);
			sng.menuItem = true;
			sng.target = index;
			sng.ID = index;
			grpSongs.add(sng);

			var icon:HealthIcon = new HealthIcon(HealthIcon.getIcon(_song.meta.icon), false);
			icon.active = false;
			add(icon);
			iconList.push(icon);
		}

		currentSelection = 0;
    }

	override public function update(elapsed:Float) {
		super.update(elapsed);

		if (Controls.UI_UP_P) currentSelection -= 1;
        if (Controls.UI_DOWN_P) currentSelection += 1;

		if (Controls.UI_LEFT_P) currentDifficulty -= 1;
        if (Controls.UI_RIGHT_P) currentDifficulty += 1;

		if (Controls.ACCEPT) {
			FlxG.switchState(new PlayState(songs[currentSelection].name, difficultyList[currentDifficulty]));
		}

		for (index => icon in iconList)  {
			var _parent:Alphabet = grpSongs.members[index];
			icon.setPosition(_parent.x + _parent.width + 10, _parent.y + (_parent.height - icon.height) * 0.5);
		}
		
	}

	function set_currentSelection(val:Int):Int {
        val = FlxMath.wrap(val,0,songs.length-1);
        FlxG.sound.play(Assets.sound("scrollMenu"),0.7);
        
        for (sng in grpSongs.members) {
            var icon:HealthIcon = iconList[sng.ID];

            sng.target = sng.ID - val;
            sng.alpha = icon.alpha = (sng.target == 0) ? 1 : 0.7;
        }
		bg.intendedColor = FlxColor.fromString("#" + songs[val].meta.color);
		difficultyList = songs[val].meta.difficulties;

		// When the difficulty list isn't the same as DiffText, update.
		if (difficultyList[currentDifficulty] != diffText?.text) 
			currentDifficulty = 0;
        return currentSelection = val;
    }

	function set_currentDifficulty(val:Int):Int {
		val = FlxMath.wrap(val,0,difficultyList.length-1);
		if (diffText != null)
			diffText.text = '< ${difficultyList[val]} >';
		return currentDifficulty = val;
	}
}

class Background extends Sprite {
    public var intendedColor(default, set):FlxColor = FlxColor.WHITE;
	public var transitionTime:Float = 0.6;
    var lastColor:FlxColor = FlxColor.WHITE;

    public function new():Void {
        super(0, 0);
		loadGraphic(Assets.image("menus/menuDesat"));
    }

	var _time:Float = 0;
    override function update(elapsed:Float):Void {
        if (lastColor != intendedColor && _time < transitionTime) {
			_time += elapsed;
            color = FlxColor.interpolate(lastColor, intendedColor, _time / transitionTime);
        }
        
        super.update(elapsed);
    }

    function set_intendedColor(val:FlxColor):FlxColor {
        _time = 0;
        lastColor = color;
        return intendedColor = val;
    }
}