// kernel32
#define STD_ERROR_HANDLE ((u32) -12)
#define OPEN_EXISTING 3
#define FILE_ATTRIBUTE_NORMAL 0x80
#define MEM_COMMIT 0x00001000
#define MEM_RESERVE 0x00002000
#define MEM_RELEASE 0x00008000
#define GENERIC_READ 0x80000000
#define PAGE_READWRITE 0x04
#define INVALID_HANDLE_VALUE ((HANDLE) -1)

typedef void* HANDLE;
typedef struct HINSTANCE__* HINSTANCE;
typedef HINSTANCE HMODULE;
typedef struct { int _unused; } SECURITY_ATTRIBUTES;
typedef struct { int _unused; } OVERLAPPED;
typedef s64 (*PROC)(void);

#define KERNEL32_FUNCTIONS \
    X(HMODULE, GetModuleHandleW, u16*) \
    X(HMODULE, LoadLibraryW, u16*) \
    X(PROC, GetProcAddress, HMODULE, u8*) \
    X(s32, AllocConsole, void) \
    X(HANDLE, GetStdHandle, u32) \
    X(s32, WriteConsoleA, HANDLE, void*, u32, u32*, void*) \
    X(HANDLE, CreateFileA, u8*, u32, u32, SECURITY_ATTRIBUTES*, u32, u32, HANDLE) \
    X(s32, CloseHandle, HANDLE) \
    X(s32, GetFileSizeEx, HANDLE, s64*) \
    X(s32, ReadFile, HANDLE, void*, u32, u32*, OVERLAPPED*) \
    X(void*, VirtualAlloc, void*, u64, u32, u32) \
    X(s32, VirtualFree, void*, u64, u32) \
    X(void, Sleep, u32) \
    X(void, ExitProcess, u32)

// user32
#define IDI_WARNING ((u16*) (u64) 32515)
#define IDC_CROSS ((u16*) (u64) 32515)
#define CS_OWNDC 0x0020
#define WS_MAXIMIZEBOX 0x00010000
#define WS_MINIMIZEBOX 0x00020000
#define WS_THICKFRAME 0x00040000
#define WS_SYSMENU 0x00080000
#define WS_CAPTION 0x00C00000
#define WS_VISIBLE 0x10000000
#define WS_OVERLAPPEDWINDOW (WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX)
#define CW_USEDEFAULT ((s32) 0x80000000)
#define PM_REMOVE 0x0001
#define WM_CREATE 0x0001
#define WM_DESTROY 0x0002
#define WM_SIZE 0x0005
#define WM_PAINT 0x000F
#define WM_QUIT 0x0012
#define WM_ERASEBKGND 0x0014
#define WM_ACTIVATEAPP 0x001C
#define WM_KEYDOWN 0x0100
#define WM_KEYUP 0x0101
#define WM_SYSKEYDOWN 0x0104
#define WM_SYSKEYUP 0x0105
#define WM_SYSCOMMAND 0x0112
#define SC_KEYMENU 0xF100
#define GWL_STYLE (-16)
#define HWND_TOP ((HWND) 0)
#define MONITOR_DEFAULTTOPRIMARY 0x00000001
#define SWP_NOSIZE 0x0001
#define SWP_NOMOVE 0x0002
#define SWP_NOZORDER 0x0004
#define SWP_FRAMECHANGED 0x0020
#define VK_RETURN 0x0D
#define VK_ESCAPE 0x1B
#define VK_F4 0x73
#define VK_F10 0x79
#define VK_F11 0x7A

typedef struct HDC__* HDC;
typedef struct HWND__* HWND;
typedef struct HMENU__* HMENU;
typedef struct HICON__* HICON;
typedef struct HBRUSH__* HBRUSH;
typedef struct HCURSOR__* HCURSOR;
typedef struct HMONITOR__* HMONITOR;
typedef s64 (*WNDPROC)(HWND, u32, u64, s64);
typedef struct {
    s32 x;
    s32 y;
} POINT;
typedef struct {
    s32 left;
    s32 top;
    s32 right;
    s32 bottom;
} RECT;
typedef struct {
    u32 cbSize;
    u32 style;
    WNDPROC lpfnWndProc;
    s32 cbClsExtra;
    s32 cbWndExtra;
    HINSTANCE hInstance;
    HICON hIcon;
    HCURSOR hCursor;
    HBRUSH hbrBackground;
    u16* lpszMenuName;
    u16* lpszClassName;
    HICON hIconSm;
} WNDCLASSEXW;
typedef struct {
    HWND hwnd;
    u32 message;
    u64 wParam;
    s64 lParam;
    u32 time;
    POINT pt;
    u32 lPrivate;
} MSG;
typedef struct {
    u32 length;
    u32 flags;
    u32 showCmd;
    POINT ptMinPosition;
    POINT ptMaxPosition;
    RECT rcNormalPosition;
    RECT rcDevice;
} WINDOWPLACEMENT;
typedef struct {
    u32 cbSize;
    RECT rcMonitor;
    RECT rcWork;
    u32 dwFlags;
} MONITORINFO;

#define USER32_FUNCTIONS \
    X(s32, SetProcessDPIAware, void) \
    X(HICON, LoadIconW, HINSTANCE, u16*) \
    X(HCURSOR, LoadCursorW, HINSTANCE, u16*) \
    X(u16, RegisterClassExW, WNDCLASSEXW*) \
    X(HWND, CreateWindowExW, u32, u16*, u16*, u32, s32, s32, s32, s32, HWND, HMENU, HINSTANCE, void*) \
    X(s32, PeekMessageW, MSG*, HWND, u32, u32, u32) \
    X(s32, TranslateMessage, MSG*) \
    X(s64, DispatchMessageW, MSG*) \
    X(HDC, GetDC, HWND) \
    X(s32, ValidateRect, HWND, RECT*) \
    X(s32, DestroyWindow, HWND) \
    X(s64, GetWindowLongPtrW, HWND, s32) \
    X(s64, SetWindowLongPtrW, HWND, s32, s64) \
    X(s32, GetWindowPlacement, HWND, WINDOWPLACEMENT*) \
    X(s32, SetWindowPlacement, HWND, WINDOWPLACEMENT*) \
    X(HMONITOR, MonitorFromWindow, HWND, u32) \
    X(s32, GetMonitorInfoW, HMONITOR, MONITORINFO*) \
    X(s32, SetWindowPos, HWND, HWND, s32, s32, s32, s32, u32) \
    X(s64, DefWindowProcW, HWND, u32, u64, s64) \
    X(void, PostQuitMessage, s32)

// gdi32
#define PFD_DOUBLEBUFFER 0x00000001
#define PFD_DRAW_TO_WINDOW 0x00000004
#define PFD_SUPPORT_OPENGL 0x00000020
#define PFD_DEPTH_DONTCARE 0x20000000

typedef struct {
    u16 nSize;
    u16 nVersion;
    u32 dwFlags;
    u8 iPixelType;
    u8 cColorBits;
    u8 cRedBits;
    u8 cRedShift;
    u8 cGreenBits;
    u8 cGreenShift;
    u8 cBlueBits;
    u8 cBlueShift;
    u8 cAlphaBits;
    u8 cAlphaShift;
    u8 cAccumBits;
    u8 cAccumRedBits;
    u8 cAccumGreenBits;
    u8 cAccumBlueBits;
    u8 cAccumAlphaBits;
    u8 cDepthBits;
    u8 cStencilBits;
    u8 cAuxBuffers;
    u8 iLayerType;
    u8 bReserved;
    u32 dwLayerMask;
    u32 dwVisibleMask;
    u32 dwDamageMask;
} PIXELFORMATDESCRIPTOR;

#define GDI32_FUNCTIONS \
    X(s32, ChoosePixelFormat, HDC, PIXELFORMATDESCRIPTOR*) \
    X(s32, SetPixelFormat, HDC, s32, PIXELFORMATDESCRIPTOR*) \
    X(s32, SwapBuffers, HDC)

// opengl32
typedef struct HGLRC__* HGLRC;

#define OPENGL32_FUNCTIONS \
    X(HGLRC, wglCreateContext, HDC) \
    X(s32, wglDeleteContext, HDC) \
    X(s32, wglMakeCurrent, HDC, HGLRC) \
    X(PROC, wglGetProcAddress, u8*)

// dwmapi
#define DWMWA_USE_IMMERSIVE_DARK_MODE 20
#define DWMWA_WINDOW_CORNER_PREFERENCE 33
#define DWMWCP_DONOTROUND 1

#define DWMAPI_FUNCTIONS \
    X(s32, DwmSetWindowAttribute, HWND, u32, void*, u32)

// winmm
#define TIMERR_NOERROR 0

#define WINMM_FUNCTIONS \
    X(u32, timeBeginPeriod, u32)
