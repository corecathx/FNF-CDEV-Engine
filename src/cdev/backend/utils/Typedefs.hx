package cdev.backend.utils;

typedef Axis2D = {x:Float, y:Float}
typedef Animation = {
    name:String,
    prefix:String,
    fps:Int,
    indices:Array<Int>,
    loop:Bool,
    offset:Axis2D
}