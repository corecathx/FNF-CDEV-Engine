package cdev;

/**
 * Configuration class for CDEV Engine.
 */
class Config {
    /**
     * Contains the version and API level of CDEV Engine.
     * `version` - The engine's version in SemVer format.
     * `apiLevel` - The engine's API level.
     */
    public static var engine:{version:String, apiLevel:Int} = {
        version: "0.1.0",
        apiLevel: 1
    }

    /**
     * Initialize CDEV Engine's saved configuration.
     */
    public static function init() {
        // TODO: add init logic here.
    }
}
