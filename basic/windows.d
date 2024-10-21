module basic.windows;

import basic : AliasSeq, Procedure;

// kernel32
struct HINSTANCE__; alias HINSTANCE = HINSTANCE__*;
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
enum WM_QUIT = 0x0012;

struct HDC__; alias HDC = HDC__*;
struct HWND__; alias HWND = HWND__*;
struct HMENU__; alias HMENU = HMENU__*;
struct HICON__; alias HICON = HICON__*;
struct HBRUSH__; alias HBRUSH = HBRUSH__*;
struct HCURSOR__; alias HCURSOR = HCURSOR__*;
struct HMONITOR__; alias HMONITOR = HMONITOR__*;
alias WNDPROC = extern(Windows) ptrdiff_t function(HWND, uint, size_t, ptrdiff_t);
struct POINT {
    int x;
    int y;
}
struct RECT {
    int left;
    int top;
    int right;
    int bottom;
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
    uint time;
    POINT pt;
    uint lPrivate;
}

alias user32 = AliasSeq!(
    Procedure!(int, "SetProcessDPIAware"),
    Procedure!(HICON, "LoadIconW", HINSTANCE, const(wchar)*),
    Procedure!(HCURSOR, "LoadCursorW", HINSTANCE, const(wchar)*),
    Procedure!(ushort, "RegisterClassExW", const(WNDCLASSEXW)*),
    Procedure!(HWND, "CreateWindowExW", uint, const(wchar)*, const(wchar)*, uint, int, int, int, int, HWND, HMENU, HINSTANCE, void*),
    Procedure!(int, "PeekMessageW", MSG*, HWND, uint, uint, uint),
    Procedure!(int, "TranslateMessage", const(MSG)*),
    Procedure!(ptrdiff_t, "DispatchMessageW", const(MSG)*),
    Procedure!(ptrdiff_t, "DefWindowProcW", HWND, uint, size_t, ptrdiff_t),
    Procedure!(void, "PostQuitMessage", int),
);

// winmm
enum TIMERR_NOERROR = 0;

alias winmm = AliasSeq!(
    Procedure!(uint, "timeBeginPeriod", uint),
);
