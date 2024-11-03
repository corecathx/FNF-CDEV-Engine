package cdev.backend;

import cdev.backend.macros.GitMacro;

typedef EngineData = {name:String, version:String, apiLevel:Int, label:String}

/**
 * `Engine` is a class that contains information about CDEV Engine.
 * Used for backend stuffs.
 */
class Engine {
    /**
     * Engine's display name.
     */
    public static var name:String = "CDEV Engine";
    /**
     * Engine's version in SemVer format.
     */
    public static var version:String = "0.1";
    /**
     * Engine's API Level, used for version checking.
     */
    public static var apiLevel:Int = 1;
    /**
     * Formatted name of the engine, used in Main Menu.
     */
    public static var label(get,never):String;
    /**
     * Engine's git commit hash.
     */
    public static final gitCommit:String = GitMacro.getCommitHash();
    /**
     * Engine's git branch.
     */
    public static final gitBranch:String = GitMacro.getGitBranch();

    /**
     * Initialize the engine's configuration.
     */
    public static function init() {
        // TODO: add stuff here.
        
    }

    public static function resetGame():Void {
        FlxG.resetGame();
        Assets.resetLoaded();
    }

    /////////////////////
    /// GET & SETTERS ///
    /////////////////////
    inline static function get_label():String 
        return '$name v$version';
}
