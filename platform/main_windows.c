#define RENDERER_OPENGL 1

#include "../basic/basic.h"
#include "../basic/windows.h"

#define X(RET, NAME, ...) RET NAME(__VA_ARGS__);
KERNEL32_FUNCTIONS
#undef X

#define X(RET, NAME, ...) RET (*NAME)(__VA_ARGS__);
USER32_FUNCTIONS
DWMAPI_FUNCTIONS
WINMM_FUNCTIONS
#undef X

static s32 platform_screen_width;
static s32 platform_screen_height;
static HINSTANCE platform_hinstance;
static HWND platform_hwnd;
static HDC platform_hdc;
#if BUILD_MODE_DEBUG
static HANDLE platform_stderr;
#endif

#if RENDERER_OPENGL
#include "renderer_opengl.c"
#define renderer_init opengl_init
#define renderer_deinit opengl_deinit
#define renderer_resize opengl_resize
#define renderer_present opengl_present
#else
#define renderer_init()
#define renderer_deinit()
#define renderer_resize()
#define renderer_present()
#endif

static void platform_toggle_fullscreen(void) {
    static WINDOWPLACEMENT save_placement = {sizeof(WINDOWPLACEMENT)};

    u32 style = (u32) GetWindowLongPtrW(platform_hwnd, GWL_STYLE);
    if (style & WS_OVERLAPPEDWINDOW) {
        static MONITORINFO mi = {sizeof(MONITORINFO)};
        GetMonitorInfoW(MonitorFromWindow(platform_hwnd, MONITOR_DEFAULTTOPRIMARY), &mi);

        GetWindowPlacement(platform_hwnd, &save_placement);
        SetWindowLongPtrW(platform_hwnd, GWL_STYLE, style & ~WS_OVERLAPPEDWINDOW);
        SetWindowPos(platform_hwnd, HWND_TOP,
            mi.rcMonitor.left, mi.rcMonitor.top,
            mi.rcMonitor.right - mi.rcMonitor.left,
            mi.rcMonitor.bottom - mi.rcMonitor.top,
            SWP_FRAMECHANGED);
    } else {
        SetWindowLongPtrW(platform_hwnd, GWL_STYLE, style | WS_OVERLAPPEDWINDOW);
        SetWindowPlacement(platform_hwnd, &save_placement);
        SetWindowPos(platform_hwnd, null, 0, 0, 0, 0, SWP_NOSIZE |
            SWP_NOMOVE | SWP_NOZORDER | SWP_FRAMECHANGED);
    }
}

static void platform_update_cursor_clip(void) {

}

static void platform_clear_held_keys(void) {

}

static s64 platform_window_proc(HWND hwnd, u32 message, u64 wParam, s64 lParam) {
    switch (message) {
        case WM_PAINT: {
            ValidateRect(hwnd, null);
            return 0;
        }
        case WM_ERASEBKGND: {
            return 1;
        }
        case WM_ACTIVATEAPP: {
            if (wParam != 0) platform_update_cursor_clip();
            else platform_clear_held_keys();
            return 0;
        }
        case WM_SIZE: {
            platform_screen_width = (u16) (u64) lParam;
            platform_screen_height = (u16) ((u64) lParam >> 16);

            renderer_resize();
            return 0;
        }
        case WM_CREATE: {
            platform_hwnd = hwnd;
            platform_hdc = GetDC(hwnd);

            if (DwmSetWindowAttribute) {
                s32 dark_mode = 1;
                DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &dark_mode, 4);
                s32 round_mode = DWMWCP_DONOTROUND;
                DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, &round_mode, 4);
            }

            renderer_init();
            return 0;
        }
        case WM_DESTROY: {
            renderer_deinit();

            PostQuitMessage(0);
            return 0;
        }
        case WM_SYSCOMMAND: {
            if (wParam == SC_KEYMENU) return 0;
            // fallthrough;
        }
        default: {
            return DefWindowProcW(hwnd, message, wParam, lParam);
        }
    }
}

void WinMainCRTStartup(void) {
    HMODULE dll;
#define X(RET, NAME, ...) NAME = (RET (*)(__VA_ARGS__)) GetProcAddress(dll, #NAME);
    dll = LoadLibraryW(L"user32");
    USER32_FUNCTIONS
    dll = LoadLibraryW(L"dwmapi");
    DWMAPI_FUNCTIONS
    dll = LoadLibraryW(L"winmm");
    WINMM_FUNCTIONS
#undef X

    platform_hinstance = GetModuleHandleW(null);

#if BUILD_MODE_DEBUG
    AllocConsole();
    platform_stderr = GetStdHandle(STD_ERROR_HANDLE);
#endif

    bool sleep_is_granular = timeBeginPeriod && timeBeginPeriod(1) == TIMERR_NOERROR;

    SetProcessDPIAware();
    static WNDCLASSEXW wndclass = {0};
    wndclass.cbSize = sizeof(WNDCLASSEXW);
    wndclass.style = CS_OWNDC;
    wndclass.lpfnWndProc = platform_window_proc;
    wndclass.hInstance = platform_hinstance;
    wndclass.hIcon = LoadIconW(null, IDI_WARNING);
    wndclass.hCursor = LoadCursorW(null, IDC_CROSS);
    wndclass.lpszClassName = L"A";
    RegisterClassExW(&wndclass);
    CreateWindowExW(0, wndclass.lpszClassName, L"Game",
        WS_OVERLAPPEDWINDOW | WS_VISIBLE,
        CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
        null, null, platform_hinstance, null);

    for (;;) {
        MSG msg;
        while (PeekMessageW(&msg, null, 0, 0, PM_REMOVE)) {
            TranslateMessage(&msg);
            switch (msg.message) {
                case WM_KEYDOWN:
                case WM_KEYUP:
                case WM_SYSKEYDOWN:
                case WM_SYSKEYUP: {
                    bool pressed = (msg.lParam & 1U << 31) == 0;
                    bool repeat = pressed && (msg.lParam & 1 << 30) != 0;
                    bool sys = msg.message == WM_SYSKEYDOWN || msg.message == WM_SYSKEYUP;
                    bool alt = sys && (msg.lParam & 1 << 29) != 0;

                    if (!repeat && (!sys || alt || msg.wParam == VK_F10)) {
                        if (pressed) {
                            if (msg.wParam == VK_F4 && alt) DestroyWindow(platform_hwnd);
                            if (msg.wParam == VK_F11 || (msg.wParam == VK_RETURN && alt)) platform_toggle_fullscreen();
                            if (msg.wParam == VK_ESCAPE) DestroyWindow(platform_hwnd);
                        }
                    }

                    DispatchMessageW(&msg); // @Hack allow steam overlay to get input
                    break;
                }
                case WM_QUIT: {
                    goto game_loop_end;
                }
                default: {
                    DispatchMessageW(&msg);
                }
            }
        }

        renderer_present();

        if (sleep_is_granular) {
            Sleep(1);
        }
    }
game_loop_end:

    ExitProcess(0);
}
