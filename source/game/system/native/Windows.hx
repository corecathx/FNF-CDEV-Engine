package game.system.native;

@:buildXml('
<target id="haxe">
	<lib name="dwmapi.lib" if="windows" />
	<lib name="shell32.lib" if="windows" />
	<lib name="gdi32.lib" if="windows" />
	<lib name="ole32.lib" if="windows" />
	<lib name="uxtheme.lib" if="windows" />
</target>
')

// majority is taken from microsofts doc 
@:cppFileCode('
#include <iostream>
#include <Windows.h>
#include <dwmapi.h>
#include <Shlobj.h>
')
class Windows {
    @:functionCode('
        int darkMode = enable ? 1 : 0;

        HWND window = FindWindowA(NULL, title.c_str());
        // Look for child windows if top level aint found
        if (window == NULL) window = FindWindowExA(GetActiveWindow(), NULL, NULL, title.c_str());

        if (window != NULL && S_OK != DwmSetWindowAttribute(window, 19, &darkMode, sizeof(darkMode))) {
            DwmSetWindowAttribute(window, 20, &darkMode, sizeof(darkMode));
        }
    ')
    public static function setWindowDarkMode(title:String, enable:Bool) {}

    @:functionCode('
        SetProcessDPIAware();
    ')
    public static function setDPIAware() {}

}