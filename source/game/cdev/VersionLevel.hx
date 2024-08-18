package game.cdev;

/**
 * Represents different version levels of the game.
 * Each version level is associated with a specific integer value.
 */
class VersionLevel {
    /** Version 0.1.0 **/
    public static var _010:Int = 1; 
    /** Version 0.1.1 **/
    public static var _011:Int = 2; 
    /** Version 0.1.2 **/
    public static var _012:Int = 3;
    /** Version 1.1 **/
    public static var _110:Int = 4;
    /** Version 1.2 **/
    public static var _120:Int = 5;
    /** Version 1.4 **/
    public static var _140:Int = 6;
    /** Version 1.4.1 **/
    public static var _141:Int = 7;
    /** Version 1.5 **/
    public static var _150:Int = 8;
    /** Version 1.6 **/
    public static var _160:Int = 9;
    /** Version 1.6.1 **/
    public static var _161:Int = 10;
    /** Version 1.6.2 **/
    public static var _162:Int = 11;
    /** Version 1.6.3 **/
    public static var _163:Int = 12;
    /** Version 1.7 **/
    public static var _170:Int = 13;

    static var __VERSION_MAPPING:Map<String, Int> = [
        '0.1.0' => _010,
        '0.1.1' => _011,
        '0.1.2' => _012,
        '1.1' => _110,
        '1.2' => _120,
        '1.4' => _140,
        '1.4.1' => _141,
        '1.5' => _150,
        '1.6' => _160,
        '1.6.1' => _161,
        '1.6.2' => _162,
        '1.6.3' => _163,
        '1.7' => _170
    ];

    /**
     * Returns Version Level integer value based of Version String.
     * For example: "1.7" -> 13.
     * @param verString 
     * @return Int
     */
    public static function fromString(verString:String):Int {
        var ret:Null<Int> = __VERSION_MAPPING.get(verString);
        if (ret == null) return 0;
        return ret;
    }
}
