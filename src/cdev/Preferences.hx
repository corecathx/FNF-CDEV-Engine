package cdev;

typedef KeybindsList = {
    left:Array<String>, down:Array<String>, up:Array<String>, right:Array<String>, // notes
    ui_left:Array<String>, ui_down:Array<String>, ui_up:Array<String>, ui_right:Array<String>, // ui
    accept:Array<String>, back:Array<String>, pause:Array<String>, reset:Array<String> // basic stuff
};

class Preferences {
    /**
     * Your saved Keybinds.
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
     * Defines whether to use antialiasing for sprites.
     */
    public static var antialiasing:Bool = true;

    /**
     * Defines whether to use down / up scrolling notes on gameplay.
     */
    public static var downscroll:Bool = true;
}
