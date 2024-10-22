module basic.windows;

import basic : AliasSeq, Opaque, Procedure, c_long, c_ulong;

// kernel32
mixin Opaque!"HINSTANCE";
alias HMODULE = HINSTANCE;
alias PROC = extern(Windows) ptrdiff_t function();

alias kernel32 = AliasSeq!(
    Procedure!(HMODULE, "GetModuleHandleW", const(wchar)*),
    Procedure!(HMODULE, "LoadLibraryW", const(wchar)*),
    Procedure!(PROC, "GetProcAddress", HMODULE, const(char)*),
    Procedure!(noreturn, "ExitProcess", uint),
);

// user32
enum IDI_WARNING = cast(const(wchar)*) 32515;
enum IDC_CROSS = cast(const(wchar)*) 32515;
enum CS_OWNDC = 0x0020;
enum WS_MAXIMIZEBOX = 0x00010000;
enum WS_MINIMIZEBOX = 0x00020000;
enum WS_THICKFRAME = 0x00040000;
enum WS_SYSMENU = 0x00080000;
enum WS_CAPTION = 0x00C00000;
enum WS_VISIBLE = 0x10000000;
enum WS_OVERLAPPEDWINDOW = WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX;
enum CW_USEDEFAULT = 0x80000000;
enum PM_REMOVE = 0x0001;
enum WM_CREATE = 0x0001;
enum WM_DESTROY = 0x0002;
enum WM_SIZE = 0x0005;
enum WM_PAINT = 0x000F;
enum WM_QUIT = 0x0012;
enum WM_ERASEBKGND = 0x0014;
enum WM_ACTIVATEAPP = 0x001C;
enum WM_KEYDOWN = 0x0100;
enum WM_KEYUP = 0x0101;
enum WM_SYSKEYDOWN = 0x0104;
enum WM_SYSKEYUP = 0x0105;
enum WM_SYSCOMMAND = 0x0112;
enum SC_KEYMENU = 0xF100;
enum GWL_STYLE = -16;
enum HWND_TOP = cast(HWND) 0;
enum SWP_NOSIZE = 0x0001;
enum SWP_NOMOVE = 0x0002;
enum SWP_NOZORDER = 0x0004;
enum SWP_FRAMECHANGED = 0x0020;
enum MONITOR_DEFAULTTOPRIMARY = 0x00000001;
enum VK_RETURN = 0x0D;
enum VK_ESCAPE = 0x1B;
enum VK_F4 = 0x73;
enum VK_F10 = 0x79;
enum VK_F11 = 0x7A;

mixin Opaque!"HDC";
mixin Opaque!"HWND";
mixin Opaque!"HMENU";
mixin Opaque!"HICON";
mixin Opaque!"HBRUSH";
mixin Opaque!"HCURSOR";
mixin Opaque!"HMONITOR";
alias WNDPROC = extern(Windows) ptrdiff_t function(HWND, uint, size_t, ptrdiff_t);
struct POINT {
    c_long x;
    c_long y;
}
struct RECT {
    c_long left;
    c_long top;
    c_long right;
    c_long bottom;
}
struct WNDCLASSEXW {
    uint cbSize;
    uint style;
    WNDPROC lpfnWndProc;
    int cbClsExtra;
    int cbWndExtra;
    HINSTANCE hInstance;
    HICON hIcon;
    HCURSOR hCursor;
    HBRUSH hbrBackground;
    const(wchar)* lpszMenuName;
    const(wchar)* lpszClassName;
    HICON hIconSm;
}
struct MSG {
    HWND hwnd;
    uint message;
    size_t wParam;
    ptrdiff_t lParam;
    c_ulong time;
    POINT pt;
    c_ulong lPrivate;
}
struct WINDOWPLACEMENT {
    uint length;
    uint flags;
    uint showCmd;
    POINT ptMinPosition;
    POINT ptMaxPosition;
    RECT rcNormalPosition;
    RECT rcDevice;
}
struct MONITORINFO {
    c_ulong cbSize;
    RECT rcMonitor;
    RECT rcWork;
    c_ulong dwFlags;
}

alias user32 = AliasSeq!(
    Procedure!(int, "SetProcessDPIAware"),
    Procedure!(HICON, "LoadIconW", HINSTANCE, const(wchar)*),
    Procedure!(HCURSOR, "LoadCursorW", HINSTANCE, const(wchar)*),
    Procedure!(ushort, "RegisterClassExW", const(WNDCLASSEXW)*),
    Procedure!(HWND, "CreateWindowExW", c_ulong, const(wchar)*, const(wchar)*, c_ulong, int, int, int, int, HWND, HMENU, HINSTANCE, void*),
    Procedure!(int, "PeekMessageW", MSG*, HWND, uint, uint, uint),
    Procedure!(int, "TranslateMessage", const(MSG)*),
    Procedure!(ptrdiff_t, "DispatchMessageW", const(MSG)*),
    Procedure!(HDC, "GetDC", HWND),
    Procedure!(int, "ValidateRect", HWND, const(RECT)*),
    Procedure!(int, "DestroyWindow", HWND),
    Procedure!(ptrdiff_t, "GetWindowLongPtrW", HWND, int),
    Procedure!(ptrdiff_t, "SetWindowLongPtrW", HWND, int, ptrdiff_t),
    Procedure!(int, "GetWindowPlacement", HWND, WINDOWPLACEMENT*),
    Procedure!(int, "SetWindowPlacement", HWND, const(WINDOWPLACEMENT)*),
    Procedure!(int, "SetWindowPos", HWND, HWND, int, int, int, int, uint),
    Procedure!(HMONITOR, "MonitorFromWindow", HWND, uint),
    Procedure!(int, "GetMonitorInfoW", HMONITOR, MONITORINFO*),
    Procedure!(ptrdiff_t, "DefWindowProcW", HWND, uint, size_t, ptrdiff_t),
    Procedure!(void, "PostQuitMessage", int),
);

// dwmapi
enum DWMWA_USE_IMMERSIVE_DARK_MODE = 20;
enum DWMWA_WINDOW_CORNER_PREFERENCE = 33;
enum DWMWCP_DONOTROUND = 1;

alias dwmapi = AliasSeq!(
    Procedure!(c_long, "DwmSetWindowAttribute", HWND, c_ulong, const(void)*, c_ulong),
);

// winmm
enum TIMERR_NOERROR = 0;

alias winmm = AliasSeq!(
    Procedure!(uint, "timeBeginPeriod", uint),
);
