package game.system;

/**
 * Helper class for custom fonts in this engine.
 * Does this even used? I don't even know!
 */

class FunkinFonts {
    public static var CONSOLAS:String = #if windows '${Sys.getEnv("windir")}\\Fonts\\consola.ttf'; #else '_sans'; #end
    public static var VCR:String = "VCR OSD Mono";
    public static var PIXEL:String = 'Pixel Arial 11 Bold';
    public static var DIFF:String = 'Pah';
    public static var JETBRAINS:String = "JetBrains Mono NL Bold";
}