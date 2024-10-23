__save_placement := WINDOWPLACEMENT.{length=size_of(WINDOWPLACEMENT)};
toggle_fullscreen :: () #no_context {
    style := GetWindowLongPtrW(platform_hwnd, GWL_STYLE);
    if style & WS_OVERLAPPEDWINDOW {
        mi := MONITORINFO.{cbSize=size_of(MONITORINFO)};
        GetMonitorInfoW(MonitorFromWindow(platform_hwnd, MONITOR_DEFAULTTOPRIMARY), *mi);

        GetWindowPlacement(platform_hwnd, *__save_placement);
        SetWindowLongPtrW(platform_hwnd, GWL_STYLE, style & ~WS_OVERLAPPEDWINDOW);
        SetWindowPos(platform_hwnd, HWND_TOP,
            mi.rcMonitor.left, mi.rcMonitor.top,
            mi.rcMonitor.right - mi.rcMonitor.left,
            mi.rcMonitor.bottom - mi.rcMonitor.top,
            SWP_FRAMECHANGED);
    } else {
        SetWindowLongPtrW(platform_hwnd, GWL_STYLE, style | WS_OVERLAPPEDWINDOW);
        SetWindowPlacement(platform_hwnd, *__save_placement);
        SetWindowPos(platform_hwnd, xx null, 0, 0, 0, 0, SWP_NOSIZE |
            SWP_NOMOVE | SWP_NOZORDER | SWP_FRAMECHANGED);
    }
}

update_cursor_clip :: () #no_context {
    ClipCursor(null);
}

clear_held_keys :: () #no_context {

}

just_resized := true;
entry :: () {
    platform_hinstance = GetModuleHandleW(null);

    sleep_is_granular := timeBeginPeriod && timeBeginPeriod(1) == TIMERR_NOERROR;

    SetProcessDPIAware();
    wndclass : WNDCLASSEXW;
    wndclass.cbSize = size_of(WNDCLASSEXW);
    wndclass.style = CS_OWNDC;
    wndclass.lpfnWndProc = (hwnd: HWND, message: u32, wParam: u64, lParam: s64) -> s64 #c_call {
        if message == {
            case WM_PAINT;
                ValidateRect(hwnd, null);
            case WM_ERASEBKGND;
                return 1;
            case WM_ACTIVATEAPP;
                if wParam != 0 update_cursor_clip();
                else clear_held_keys();
            case WM_SIZE;
                platform_screen_width = cast,no_check(u16) lParam;
                platform_screen_height = cast,no_check(u16) (cast,no_check(u64) lParam >> 16);
                just_resized = true;
            case WM_CREATE;
                platform_hwnd = hwnd;
                platform_hdc = GetDC(hwnd);

                if DwmSetWindowAttribute {
                    dark_mode : s32 = xx true;
                    DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, *dark_mode, size_of(s32));
                    round_mode : s32 = DWMWCP_DONOTROUND;
                    DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, *round_mode, size_of(s32));
                }
            case WM_DESTROY;
                PostQuitMessage(0);
            case WM_SYSCOMMAND;
                if wParam == SC_KEYMENU return 0;
                #through;
            case;
                return DefWindowProcW(hwnd, message, wParam, lParam);
        }
        return 0;
    };
    wndclass.hInstance = platform_hinstance;
    wndclass.hIcon = LoadIconW(xx null, IDI_WARNING);
    wndclass.hCursor = LoadCursorW(xx null, IDC_CROSS);
    wndclass.lpszClassName = (#run ascii_to_utf16le_string_literal("A")).data;
    RegisterClassExW(*wndclass);
    CreateWindowExW(0, wndclass.lpszClassName, (#run ascii_to_utf16le_string_literal("Game")).data,
        WS_OVERLAPPEDWINDOW | WS_VISIBLE,
        CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
        xx null, xx null, platform_hinstance, null);

    opengl_init();
    defer opengl_deinit();

    while game_loop := true {
        msg : MSG = ---;
        while PeekMessageW(*msg, xx null, 0, 0, PM_REMOVE) {
            using msg;
            TranslateMessage(*msg);
            if message == {
                case WM_KEYDOWN; #through;
                case WM_KEYUP; #through;
                case WM_SYSKEYDOWN; #through;
                case WM_SYSKEYUP;
                    pressed := lParam & (1 << 31) == 0;
                    repeat := pressed && lParam & (1 << 30) != 0;
                    sys := message == WM_SYSKEYDOWN || message == WM_SYSKEYUP;
                    alt := sys && lParam & (1 << 29) != 0;

                    if !repeat && (!sys || alt || wParam == VK_F10) {
                        if pressed {
                            if wParam == VK_F4 && alt DestroyWindow(platform_hwnd);
                            if wParam == VK_F11 || (wParam == VK_RETURN && alt) toggle_fullscreen();
                            if DEVELOPER && wParam == VK_ESCAPE DestroyWindow(platform_hwnd);
                        }
                    }

                    DispatchMessageW(*msg); // @Hack make steam overlay happy
                case WM_QUIT;
                    break game_loop;
                case;
                    DispatchMessageW(*msg);
            }
        }

        if just_resized {
            just_resized = false;
            opengl_resize();
        }

        opengl_present();

        if sleep_is_granular {
            Sleep(1);
        }
    }
}

#program_export
RawEntryPoint :: () #c_call {
    first_thread_context : type_of(context);
    push_context first_thread_context {
        entry();
    }
    ExitProcess(0);
}
