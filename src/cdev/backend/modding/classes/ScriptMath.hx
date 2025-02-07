package cdev.backend.modding.classes;

/**
 * A wrapper for Math class to be used in scripts.
 */
class ScriptMath {
    public static var PI:Float = Math.PI;
    public static var NEGATIVE_INFINITY:Float = Math.NEGATIVE_INFINITY;
    public static var POSITIVE_INFINITY:Float = Math.POSITIVE_INFINITY;
    public static var NaN:Float = Math.NaN;

    public static function abs(v:Float):Float 
        return Math.abs(v);

    public static function min(a:Float, b:Float):Float
        return Math.min(a, b);

    public static function max(a:Float, b:Float):Float
        return Math.max(a, b);

    public static function sin(v:Float):Float
        return Math.sin(v);

    public static function cos(v:Float):Float
        return Math.cos(v);

    public static function tan(v:Float):Float
        return Math.tan(v);

    public static function asin(v:Float):Float
        return Math.asin(v);

    public static function acos(v:Float):Float
        return Math.acos(v);

    public static function atan(v:Float):Float
        return Math.atan(v);

    public static function atan2(y:Float, x:Float):Float
        return Math.atan2(y, x);

    public static function exp(v:Float):Float
        return Math.exp(v);

    public static function log(v:Float):Float
        return Math.log(v);

    public static function pow(v:Float, exp:Float):Float
        return Math.pow(v, exp);

    public static function sqrt(v:Float):Float
        return Math.sqrt(v);

    public static function round(v:Float):Int
        return Math.round(v);

    public static function floor(v:Float):Int
        return Math.floor(v);

    public static function ceil(v:Float):Int
        return Math.ceil(v);

    public static function random():Float
        return Math.random();

    public static function ffloor(v:Float):Float
        return Math.ffloor(v);

    public static function fceil(v:Float):Float
        return Math.fceil(v);

    public static function fround(v:Float):Float
        return Math.fround(v);

    public static function isFinite(f:Float):Bool 
        return Math.isFinite(f);

    public static function isNaN(f:Float):Bool 
        return Math.isNaN(f);
}