package cdev.backend.native;

/**
 * Cross-platform support for native operations.
 */
class NativeUtils {
    /**
     * Returns current used memory in bytes for current platform.
     * If the platform is unsupported, it will return Garbage Collector memory.
     */
    public static function getUsedMemory() {
        #if windows
        return Windows.getCurrentUsedMemory();
        #else
        return openfl.system.System.totalMemory;
        #end
    }

    public static function setDPIAware() {
        #if windows
        Windows.setDPIAware();
        #else
        trace("This target is currently unsupported for DPI Aware Mode.");
        #end
    }

    public static function setWindowDarkMode(title:String, enable:Bool) {
        #if windows
        Windows.setWindowDarkMode(title, enable);
        #else
        trace("Unsupported platform, Dark mode property remains unchanged.");
        #end
    }
}