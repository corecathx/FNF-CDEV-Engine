package cdev.graphics;

class MaterialIcon {
    public static var CHECK:FlxGraphic;

    public static function init() {
        trace("Initializing icons");
        CHECK = Assets.image("ui/icons/check");
    }
}