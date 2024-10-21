#!rdmd -betterC

enum DEVELOPER = true;
enum STEAM = true;
enum VULKAN = true;

static if (STEAM) {
    import basic.steam;

    __gshared bool steam_enabled;
    __gshared ISteamUser SteamUser;
    __gshared ISteamUtils SteamUtils;
    __gshared ISteamFriends SteamFriends;
}

static if (VULKAN) {
    import basic.vulkan;

    struct VulkanObjects {
        VkInstance instance;
        VkPhysicalDevice physical_device;
    }

    __gshared bool vulkan_enabled;
    __gshared VulkanObjects vk;

    static foreach (proc; AliasSeq!(vulkan_global_procs, vulkan_instance_procs)) {
        mixin("__gshared extern(System) proc.ReturnType function"~proc.ArgTypes.stringof~" "~proc.name~";");
    }

    void platform_renderer_init() {
        HMODULE dll = LoadLibraryW("vulkan-1");
        if (!dll) return;
        PFN_vkGetInstanceProcAddr vkGetInstanceProcAddr =
            cast(PFN_vkGetInstanceProcAddr)
            GetProcAddress(dll, "vkGetInstanceProcAddr");
        if (!vkGetInstanceProcAddr) return;

        static foreach (proc; vulkan_global_procs) {
            mixin(proc.name~" = "~"cast(typeof("~proc.name~")) vkGetInstanceProcAddr(null, "~proc.name.stringof~");");
        }

        VkInstanceCreateInfo instance_info;
        instance_info.sType = VkStructureType.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
        VkResult result = vkCreateInstance(&instance_info, null, &vk.instance);
        if (result != VkResult.VK_SUCCESS) return;
        vulkan_enabled = true;

        static foreach (proc; vulkan_instance_procs) {
            mixin(proc.name~" = "~"cast(typeof("~proc.name~")) vkGetInstanceProcAddr(vk.instance, "~proc.name.stringof~");");
        }

        uint physical_device_count = 1;
        result = vkEnumeratePhysicalDevices(vk.instance, &physical_device_count, &vk.physical_device);
        if (result != VkResult.VK_SUCCESS || result != VkResult.VK_INCOMPLETE) goto error;

        return;
    error:
        platform_renderer_deinit();
    }

    void platform_renderer_deinit() {
        if (!vulkan_enabled) return;

        if (vk.instance) vkDestroyInstance(vk.instance, null);
        vk = vk.init;
    }
}

version (Windows) {
    import basic.windows;

    __gshared int platform_screen_width;
    __gshared int platform_screen_height;
    __gshared HINSTANCE platform_hinstance;
    __gshared HWND platform_hwnd;
    __gshared HDC platform_hdc;

    enum STATIC_WINDOWS_LIBRARIES = ["kernel32"];
    static foreach (lib; STATIC_WINDOWS_LIBRARIES) {
        static foreach (proc; mixin(lib)) {
            mixin("extern extern(Windows) proc.ReturnType"~" "~proc.name~proc.ArgTypes.stringof~";");
        }
    }

    enum DYNAMIC_WINDOWS_LIBRARIES = ["user32", "dwmapi", "winmm"];
    static foreach (lib; DYNAMIC_WINDOWS_LIBRARIES) {
        static foreach (proc; mixin(lib)) {
            mixin("__gshared extern(Windows) proc.ReturnType"~" function"~proc.ArgTypes.stringof~" "~proc.name~";");
        }
    }

    enum DYNAMIC_C_LIBRARIES = ["steam_api64"];
    static foreach (lib; DYNAMIC_C_LIBRARIES) {
        static foreach (proc; mixin(lib)) {
            mixin("__gshared extern(C) proc.ReturnType"~" function"~proc.ArgTypes.stringof~" "~proc.name~";");
        }
    }

    void toggleFullscreen() {
        __gshared WINDOWPLACEMENT save_placement = {WINDOWPLACEMENT.sizeof};

        uint style = cast(uint) GetWindowLongPtrW(platform_hwnd, GWL_STYLE);
        if (style & WS_OVERLAPPEDWINDOW) {
            MONITORINFO mi = {MONITORINFO.sizeof};
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

    extern(Windows) noreturn WinMainCRTStartup() {
        enum DYNAMIC_LIBRARIES = DYNAMIC_WINDOWS_LIBRARIES ~ DYNAMIC_C_LIBRARIES;
        static foreach (lib; DYNAMIC_LIBRARIES) {{
            HMODULE dll = LoadLibraryW(lib);
            static foreach (proc; mixin(lib)) {
                mixin(proc.name~" = cast(typeof("~proc.name~")) GetProcAddress(dll, "~proc.name.stringof~");");
            }
        }}

        platform_hinstance = GetModuleHandleW(null);

        bool sleep_is_granular = timeBeginPeriod && timeBeginPeriod(1) == TIMERR_NOERROR;

        static if (STEAM) {
            steam_enabled = SteamAPI_InitFlat && SteamAPI_InitFlat(null) == SteamAPIInitResult.OK;
            scope(exit) if (steam_enabled) SteamAPI_Shutdown();
            SteamUser = SteamAPI_SteamUser_v023();
            SteamUtils = SteamAPI_SteamUtils_v010();
            SteamFriends = SteamAPI_SteamFriends_v017();
        }

        SetProcessDPIAware();
        WNDCLASSEXW wndclass;
        wndclass.cbSize = WNDCLASSEXW.sizeof;
        wndclass.style = CS_OWNDC;
        wndclass.lpfnWndProc = (hwnd, message, wParam, lParam) {
            switch (message) {
                case WM_PAINT:
                    ValidateRect(hwnd, null);
                    return 0;
                case WM_ERASEBKGND:
                    return 1;
                case WM_SYSCOMMAND:
                    if (wParam == SC_KEYMENU) return 0;
                    goto default;
                case WM_SIZE:
                    platform_screen_width = cast(ushort) cast(size_t) lParam;
                    platform_screen_height = cast(ushort) (cast(size_t) lParam >> 16);
                    return 0;
                case WM_CREATE:
                    platform_hwnd = hwnd;
                    platform_hdc = GetDC(hwnd);

                    if (DwmSetWindowAttribute) {
                        int dark_mode = 1;
                        DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &dark_mode, dark_mode.sizeof);
                        int round_mode = DWMWCP_DONOTROUND;
                        DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, &round_mode, round_mode.sizeof);
                    }

                    platform_renderer_init();
                    return 0;
                case WM_DESTROY:
                    platform_renderer_deinit();

                    PostQuitMessage(0);
                    return 0;
                default:
                    return DefWindowProcW(hwnd, message, wParam, lParam);
            }
        };
        wndclass.hInstance = platform_hinstance;
        wndclass.hIcon = LoadIconW(null, IDI_WARNING);
        wndclass.hCursor = LoadCursorW(null, IDC_CROSS);
        wndclass.lpszClassName = "A";
        RegisterClassExW(&wndclass);
        CreateWindowExW(0, wndclass.lpszClassName, "Game",
            WS_OVERLAPPEDWINDOW | WS_VISIBLE,
            CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
            null, null, platform_hinstance, null);

        game_loop: while (true) {
            MSG msg = void;
            while (PeekMessageW(&msg, null, 0, 0, PM_REMOVE)) {
                TranslateMessage(&msg);
                with (msg) switch (message) {
                    case WM_KEYDOWN:
                    case WM_KEYUP:
                    case WM_SYSKEYDOWN:
                    case WM_SYSKEYUP:
                        bool pressed = (lParam & 1 << 31) == 0;
                        bool repeat = pressed && (lParam & 1 << 30) != 0;
                        bool sys = message == WM_SYSKEYDOWN || message == WM_SYSKEYUP;
                        bool alt = sys && (lParam & 1 << 29) != 0;

                        if (!repeat && (!sys || alt || wParam == VK_F10)) {
                            if (pressed) {
                                if (wParam == VK_F4 && alt) DestroyWindow(platform_hwnd);
                                if (wParam == VK_F11 || (wParam == VK_RETURN && alt)) toggleFullscreen();
                                if (DEVELOPER && wParam == VK_ESCAPE) DestroyWindow(platform_hwnd);
                            }
                        }
                        break;
                    case WM_QUIT:
                        break game_loop;
                    default:
                        DispatchMessageW(&msg);
                }
            }

            static if (STEAM) if (steam_enabled) SteamAPI_RunCallbacks();

            if (sleep_is_granular) {
                Sleep(1);
            }
        }

        ExitProcess(0);
    }

    pragma(linkerDirective, "-subsystem:windows");
    static foreach (lib_name; STATIC_WINDOWS_LIBRARIES) {
        pragma(lib, lib_name);
    }
}
