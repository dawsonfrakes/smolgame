#!rdmd -betterC

version (Windows) {
    import basic.windows;

    __gshared HINSTANCE platform_hinstance = void;

    enum STATIC_WINDOWS_LIBRARIES = ["kernel32"];
    static foreach (lib; STATIC_WINDOWS_LIBRARIES) {
        static foreach (proc; mixin(lib)) {
            mixin("extern extern(Windows) proc.ReturnType"~" "~proc.name~proc.ArgTypes.stringof~";");
        }
    }

    enum DYNAMIC_WINDOWS_LIBRARIES = ["user32", "winmm"];
    static foreach (lib; DYNAMIC_WINDOWS_LIBRARIES) {
        static foreach (proc; mixin(lib)) {
            mixin("__gshared extern(Windows) proc.ReturnType"~" function"~proc.ArgTypes.stringof~" "~proc.name~";");
        }
    }

    extern(Windows) noreturn WinMainCRTStartup() {
        static foreach (lib; DYNAMIC_WINDOWS_LIBRARIES) {{
            HMODULE dll = LoadLibraryW(lib);
            static foreach (proc; mixin(lib)) {
                mixin(proc.name~" = cast(typeof("~proc.name~")) GetProcAddress(dll, "~proc.name.stringof~");");
            }
        }}

        platform_hinstance = GetModuleHandleW(null);

        bool sleep_is_granular = timeBeginPeriod(1) == TIMERR_NOERROR;

        SetProcessDPIAware();
        WNDCLASSEXW wndclass;
        wndclass.cbSize = WNDCLASSEXW.sizeof;
        wndclass.style = CS_OWNDC;
        wndclass.lpfnWndProc = (hwnd, message, wParam, lParam) {
            switch (message) {
                case WM_DESTROY:
                    PostQuitMessage(0);
                    return 0;
                default:
                    return DefWindowProcW(hwnd, message, wParam, lParam);
            }
        };
        wndclass.hInstance = platform_hinstance;
        wndclass.hIcon = LoadIconW(null, IDI_WARNING);
        wndclass.hCursor = LoadCursorW(null, IDC_CROSS);
        wndclass.lpszClassName = "A"w.ptr;
        RegisterClassExW(&wndclass);
        CreateWindowExW(0, wndclass.lpszClassName, "Game"w.ptr,
            WS_OVERLAPPEDWINDOW | WS_VISIBLE,
            CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
            null, null, platform_hinstance, null);

        game_loop: while (true) {
            MSG msg = void;
            while (PeekMessageW(&msg, null, 0, 0, PM_REMOVE)) {
                TranslateMessage(&msg);
                with (msg) switch (message) {
                    case WM_QUIT:
                        break game_loop;
                    default:
                        DispatchMessageW(&msg);
                }
            }
        }

        ExitProcess(0);
    }

    pragma(linkerDirective, "-subsystem:windows");
    static foreach (lib_name; STATIC_WINDOWS_LIBRARIES) {
        pragma(lib, lib_name);
    }
}
