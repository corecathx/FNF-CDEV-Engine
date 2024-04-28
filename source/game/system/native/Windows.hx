package game.system.native;

/**
 * Native helper class for Windows.
 * - CoreCat :]
 */
@:buildXml('
<target id="haxe">
  <lib name="dwmapi.lib" if="windows" />
  <lib name="shell32.lib" if="windows" />
  <lib name="gdi32.lib" if="windows" />
  <lib name="ole32.lib" if="windows" />
  <lib name="uxtheme.lib" if="windows" />
</target>
')

@:cppFileCode('
#include <iostream>
#include <Windows.h>
#include <psapi.h>
#include <dwmapi.h>
#include <Shlobj.h>
#include <shellapi.h>
#include <cstdio>

static float CalculateCPULoad(unsigned long long idleTicks, unsigned long long totalTicks)
{
   static unsigned long long _previousTotalTicks = 0;
   static unsigned long long _previousIdleTicks = 0;

   unsigned long long totalTicksSinceLastTime = totalTicks-_previousTotalTicks;
   unsigned long long idleTicksSinceLastTime  = idleTicks-_previousIdleTicks;

   float ret = 1.0f-((totalTicksSinceLastTime > 0) ? ((float)idleTicksSinceLastTime)/totalTicksSinceLastTime : 0);

   _previousTotalTicks = totalTicks;
   _previousIdleTicks  = idleTicks;
   return ret;
}

static unsigned long long FileTimeToInt64(const FILETIME & ft) {return (((unsigned long long)(ft.dwHighDateTime))<<32)|((unsigned long long)ft.dwLowDateTime);}

float GetCPULoad()
{
   FILETIME idleTime, kernelTime, userTime;
   return GetSystemTimes(&idleTime, &kernelTime, &userTime) ? CalculateCPULoad(FileTimeToInt64(idleTime), FileTimeToInt64(kernelTime)+FileTimeToInt64(userTime))*100.0f : -1.0f;
}
')
class Windows
{
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
	public static function setDPIAware(){}

    @:functionCode('
        ULARGE_INTEGER freeBytesAvailableToCaller;
        ULARGE_INTEGER totalNumberOfBytes;
        ULARGE_INTEGER totalNumberOfFreeBytes;
    
        if (GetDiskFreeSpaceExA(NULL, &freeBytesAvailableToCaller, &totalNumberOfBytes, &totalNumberOfFreeBytes)) {
            double freeSpaceGB = static_cast<double>(freeBytesAvailableToCaller.QuadPart) / 1073741824;
            double totalSpaceGB = static_cast<double>(totalNumberOfBytes.QuadPart) / 1073741824;
        
            return freeSpaceGB;
        } else {
            DWORD errorCode = GetLastError();
            printf("oh no it failed, %d\\n", errorCode);
        }
    ')
    public static function getCurrentDriveSize():Float {
        return 0;
    }

    @:functionCode('
        PROCESS_MEMORY_COUNTERS info;
        GetProcessMemoryInfo(GetCurrentProcess(), &info, sizeof(info));
        return (size_t)info.WorkingSetSize;
    ')
    public static function getCurrentUsedMemory():Float{
        return 0.0;
    }

    @:functionCode('
        return GetCPULoad();
    ')
    public static function getCurrentCPUUsage():Float {
        return 0.0;
    }


}