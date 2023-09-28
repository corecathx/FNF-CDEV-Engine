package engineutils;

@:buildXml('<lib name="OpenAL32" />') // Include OpenAL library
@:native("cpp") extern class AudioDeviceManager {
    public static function listAudioDevices():Array<String>;
    public static function initializeAudioDeviceMonitoring(callback:Void->Void):Void;
}
