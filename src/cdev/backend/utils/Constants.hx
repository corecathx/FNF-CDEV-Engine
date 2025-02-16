package cdev.backend.utils;

/**
 * Stores values to keep things consistent in the engine.
 * Every values here are unchangeable.
 */
@:publicFields
class Constants {
    /**
     * Used for CDEV Engine UI stuffs, such as editors, fps / memory counter.
     */
    static final UI_FONT:String = Assets.fonts.JETBRAINS;

    /**
     * Used for Gameplay UI stuffs, such as HUD.
     * By default, all texts in the engine will be displayed with this font.
     */
    static final GAME_FONT:String = Assets.fonts.VCR;
}