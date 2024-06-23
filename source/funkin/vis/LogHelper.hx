package funkin.vis;

class LogHelper
{
    public inline static function log2(x:Float):Float
    {
        return Math.log(x) / Math.log(2);
    }

    public inline static function log10(x:Float):Float
    {
        return Math.log(x) / Math.log(10);
    }
}