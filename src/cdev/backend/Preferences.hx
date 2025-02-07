package cdev.backend;

// Hell!
typedef KeybindsList = {
    left:Array<String>, down:Array<String>, up:Array<String>, right:Array<String>, // notes
    ui_left:Array<String>, ui_down:Array<String>, ui_up:Array<String>, ui_right:Array<String>, // ui
    accept:Array<String>, back:Array<String>, pause:Array<String>, reset:Array<String> // basic stuff
};

@:structInit
class Preferences {
    /**
     * These are your saved Keybinds.
     */
    public static var keybinds:KeybindsList = {
        left: ["LEFT", "S"],
        down: ["DOWN", "D"],
        up: ["UP", "K"],
        right: ["RIGHT", "L"],
        
        ui_left: ["LEFT", "A"],
        ui_down: ["DOWN", "S"],
        ui_up: ["UP", "W"],
        ui_right: ["RIGHT", "D"],
        
        accept: ["ENTER", "SPACE"],
        back: ["ESCAPE", "BACKSPACE"],
        pause: ["ENTER", "ESCAPE"],
        reset: ["R", "F5"]
    };

    /**
     * Should we use antialiasing for sprites? (smoother visuals)
     */
    public static var antialiasing:Bool = true;

    /**
     * Toggle downscroll or upscroll for notes in gameplay.
     */
    public static var downscroll:Bool = true;

    /**
     * Cache graphics to GPU for better performance.
     */
    public static var gpuTexture:Bool = true;

    /**
     * Set your preferred music volume.
     */
    public static var musicVolume:Float = 0.7;

    /**
     * Set your preferred sound effects volume.
     */
    public static var sfxVolume:Float = 1;

    /**
     * Whether to show every log messages, no exceptions.
     */
    public static var verboseLog:Bool = false;
}
