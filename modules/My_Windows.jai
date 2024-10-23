kernel32 :: #library,system "kernel32";

HINSTANCE :: #type,distinct *void;
PROC :: #type () -> s64 #c_call;

GetModuleHandleW :: (name: *u16) -> HINSTANCE #foreign kernel32;
LoadLibraryW :: (name: *u16) -> HINSTANCE #foreign kernel32;
GetProcAddress :: (module: HINSTANCE, name: *u8) -> PROC #foreign kernel32;
ExitProcess :: (exit_code: u32) #foreign kernel32;

user32 :: #library,system "user32";

IDI_WARNING :: cast(*u16) 32515;
IDC_CROSS :: cast(*u16) 32515;
CS_OWNDC :: 0x0020;
WS_MAXIMIZEBOX :: 0x00010000;
WS_MINIMIZEBOX :: 0x00020000;
WS_THICKFRAME :: 0x00040000;
WS_SYSMENU :: 0x00080000;
WS_CAPTION :: 0x00C00000;
WS_VISIBLE :: 0x10000000;
WS_OVERLAPPEDWINDOW :: WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX;
CW_USEDEFAULT :: 0x80000000;
PM_REMOVE :: 0x0001;
WM_CREATE :: 0x0001;
WM_DESTROY :: 0x0002;
WM_SIZE :: 0x0005;
WM_PAINT :: 0x000F;
WM_QUIT :: 0x0012;
WM_ERASEBKGND :: 0x0014;
WM_ACTIVATEAPP :: 0x001C;
WM_KEYDOWN :: 0x0100;
WM_KEYUP :: 0x0101;
WM_SYSKEYDOWN :: 0x0104;
WM_SYSKEYUP :: 0x0105;
WM_SYSCOMMAND :: 0x0112;
SC_KEYMENU :: 0xF100;
VK_RETURN :: 0x0D;
VK_ESCAPE :: 0x1B;
VK_F4 :: 0x73;
VK_F10 :: 0x79;
VK_F11 :: 0x7A;

HDC :: #type,distinct *void;
HWND :: #type,distinct *void;
HMENU :: #type,distinct *void;
HICON :: #type,distinct *void;
HBRUSH :: #type,distinct *void;
HCURSOR :: #type,distinct *void;
HMONITOR :: #type,distinct *void;
WNDPROC :: #type (HWND, u32, u64, s64) -> s64 #c_call;
POINT :: struct {
    x : s32;
    y : s32;
}
RECT :: struct {
    left : s32;
    top : s32;
    right : s32;
    bottom : s32;
}
WNDCLASSEXW :: struct {
    cbSize : u32;
    style : u32;
    lpfnWndProc : WNDPROC;
    cbClsExtra : s32;
    cbWndExtra : s32;
    hInstance : HINSTANCE;
    hIcon : HICON;
    hCursor : HCURSOR;
    hbrBackground : HBRUSH;
    lpszMenuName : *u16;
    lpszClassName : *u16;
    hIconSm : HICON;
}
MSG :: struct {
    hwnd : HWND;
    message : u32;
    wParam : u64;
    lParam : s64;
    time : u32;
    pt : POINT;
    lPrivate : u32;
}

SetProcessDPIAware :: () -> s32 #foreign user32;
LoadIconW :: (instance: HINSTANCE, icon: *u16) -> HICON #foreign user32;
LoadCursorW :: (instance: HINSTANCE, cursor: *u16) -> HCURSOR #foreign user32;
RegisterClassExW :: (class: *WNDCLASSEXW) -> u16 #foreign user32;
CreateWindowExW :: (ex_style: u32, class_name: *u16, window_name: *u16, style: u32, x: s32, y: s32, width: s32, height: s32, parent: HWND, menu: HMENU, instance: HINSTANCE, param: *void) -> HWND #foreign user32;
PeekMessageW :: (message: *MSG, hwnd: HWND, min: u32, max: u32, flags: u32) -> s32 #foreign user32;
TranslateMessage :: (message: *MSG) -> s32 #foreign user32;
DispatchMessageW :: (message: *MSG) -> s64 #foreign user32;
ValidateRect :: (hwnd: HWND, rect: *RECT) -> s32 #foreign user32;
GetDC :: (hwnd: HWND) -> HDC #foreign user32;
DefWindowProcW :: (hwnd: HWND, message: u32, wParam: u64, lParam: s64) -> s64 #foreign user32;
DestroyWindow :: (hwnd: HWND) -> s32 #foreign user32;
PostQuitMessage :: (exit_code: s32) #foreign user32;

dwmapi :: #library,system "dwmapi";

DWMWA_USE_IMMERSIVE_DARK_MODE :: 20;
DWMWA_WINDOW_CORNER_PREFERENCE :: 33;
DWMWCP_DONOTROUND :: 1;

DwmSetWindowAttribute :: (hwnd: HWND, attribute: u32, data: *void, size: u32) -> s32 #foreign dwmapi;

winmm :: #library,system "winmm";

TIMERR_NOERROR :: 0;

timeBeginPeriod :: (interval: u32) -> u32 #foreign winmm;