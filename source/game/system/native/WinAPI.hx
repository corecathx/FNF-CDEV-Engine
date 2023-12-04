package game.system.native;

import cpp.ConstCharStar;
import cpp.RawConstPointer;
import cpp.RawPointer;

@:include("windows.h")

@:struct
@:structAccess
@:native("WNDCLASSEX")
extern class WNDCLASSEX {
    var cbSize:UInt;
    var style:UInt;
    var lpfnWndProc:Any;
    var cbClsExtra:Int;
    var cbWndExtra:Int;
    var hInstance:HINSTANCE;
    var hIcon:HICON;
    var hCursor:HCURSOR;
    var hbrBackground:HBRUSH;
    var lpszMenuName:ConstCharStar;
    var lpszClassName:ConstCharStar;
    var hIconSm:HICON;
}

@:struct
@:structAccess
@:native("MSG")
extern class MSG {
}

@:struct
@:structAccess
@:native("PAINTSTRUCT")
extern class PAINTSTRUCT {
}

@:native("HINSTANCE")   extern class HINSTANCE { }
@:native("HICON")       extern class HICON { }
@:native("HCURSOR")     extern class HCURSOR { }
@:native("HBRUSH")      extern class HBRUSH { }
@:native("HWND")        extern class HWND { }
@:native("HMENU")       extern class HMENU { }
@:native("HDC")         extern class HDC { }

extern class Windows {
    @:native("createWNDCLASSEX")        public static function createWNDCLASSEX():WNDCLASSEX;
    @:native("createMSG")               public static function createMSG():MSG;
    @:native("createPAINTSTRUCT")       public static function createPAINTSTRUCT():PAINTSTRUCT;
    
    @:native("RegisterClassEx")         public static function registerClassEx(lpwcx:RawConstPointer<WNDCLASSEX>):Bool;
    @:native("GetModuleHandle")         public static function getModuleHandle(lpModuleName:ConstCharStar):HINSTANCE;
    @:native("CreateWindow")            public static function createWindow(lpClassName:ConstCharStar,
                                                                            lpWindowName:ConstCharStar,
                                                                            dwStyle:Int,
                                                                            x:Int, y:Int,
                                                                            nWidth:Int, nHeight:Int,
                                                                            hWndParent:HWND, hMenu:HMENU,
                                                                            hInstance:HINSTANCE,
                                                                            lpVoid:RawPointer<cpp.Void>):HWND;
    @:native("ShowWindow")              public static function showWindow(hWnd:HWND, nCmdShow:Int):Bool;
    @:native("UpdateWindow")            public static function updateWindow(hWnd:HWND):Bool;
    @:native("GetMessage")              public static function getMessage(lpMsg:RawPointer<MSG>, hWnd:HWND,
                                                                          wMsgFilterMin:UInt, wMsgFilterMax:UInt):Bool;
    @:native("TranslateMessage")        public static function translateMessage(lpMsg:RawPointer<MSG>):Bool;
    @:native("DispatchMessage")         public static function dispatchMessage(lpMsg:RawPointer<MSG>):Int;
    @:native("DefWindowProc")           public static function defWindowProc(hwnd:HWND, message:UInt, wParam:Int, lParam:Int):Int;
    
    @:native("BeginPaint")              public static function beginPaint(hwnd:HWND, lpPaint:RawPointer<PAINTSTRUCT>):HDC;
    @:native("TextOut")                 public static function textOut(hdc:HDC, x:Int, y:Int, lpString:ConstCharStar, c:Int):Bool;
    @:native("EndPaint")                public static function endPaint(hwnd:HWND, lpPaint:RawConstPointer<PAINTSTRUCT>):Bool;
    
    @:native("PostQuitMessage")         public static function postQuitMessage(nExitCode:Int):Void;
    @:native("GetLastError")            public static function getLastError():Int;
}

@:cppFileCode("
    WNDCLASSEX  createWNDCLASSEX()  { return { sizeof(WNDCLASSEX) }; }
    MSG         createMSG()         { return { }; }
    PAINTSTRUCT createPAINTSTRUCT() { return { }; }
")

@:buildXml('<target id="haxe" tool="linker" toolid="exe"><lib name="gdi32.lib" /></target>') // for TextOut
@:headerInclude("windows.h")
@:unreflective
class Main {
	static function main() {
        var hInst = Windows.getModuleHandle(null);
        
        var wcex:WNDCLASSEX = Windows.createWNDCLASSEX();
        wcex.style = untyped __cpp__("CS_HREDRAW | CS_VREDRAW");
        wcex.lpfnWndProc = untyped __cpp__("reinterpret_cast<WNDPROC>(::test::win32::Main_obj::WndProc)");
        wcex.cbClsExtra = 0;
        wcex.cbWndExtra = 0;
        wcex.hInstance = hInst;
        wcex.hIcon = null;
        wcex.hCursor = null;
        wcex.hbrBackground = null;
        wcex.lpszMenuName = null;
        wcex.lpszClassName = "myTestApp";
        wcex.hIconSm = null;
        if (!Windows.registerClassEx(RawConstPointer.addressOf(wcex))) {
            var lastError = Windows.getLastError();
            trace('Failed to register window (${lastError})'); 
            return;
        }
        
        var hwnd:HWND = Windows.createWindow("myTestApp", "My Title",
                                             untyped __cpp__("WS_OVERLAPPEDWINDOW"),
                                             untyped __cpp__("CW_USEDEFAULT"), untyped __cpp__("CW_USEDEFAULT"),
                                             500, 500,
                                             null, null, hInst, null);
        Windows.showWindow(hwnd, untyped __cpp__("SW_SHOW"));
        Windows.updateWindow(hwnd);
        
        trace(hwnd);
        
        var msg:MSG = Windows.createMSG();
        while (Windows.getMessage(RawPointer.addressOf(msg), null, 0, 0)) {
            Windows.translateMessage(RawPointer.addressOf(msg));
            Windows.dispatchMessage(RawPointer.addressOf(msg));
        }
	}
    
    public static function WndProc(hwnd:HWND, message:UInt, wParam:Int, lParam:Int):Int {
        switch (message) {
            case 15: // WM_PAINT
                var ps:PAINTSTRUCT = Windows.createPAINTSTRUCT();
                var hdc:HDC = Windows.beginPaint(hwnd, RawPointer.addressOf(ps));
                Windows.textOut(hdc, 5, 5, "Hello World!", "Hello World!".length);
                Windows.endPaint(hwnd, RawConstPointer.addressOf(ps));
            case 2:  // WM_DESTROY
                Windows.postQuitMessage(0);
            default:
                return Windows.defWindowProc(hwnd, message, wParam, lParam);
        }
        return 0;
    }
}