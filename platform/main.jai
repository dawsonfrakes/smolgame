DEVELOPER :: true;
OPENGL :: true;

#import "My_Basic";

platform_screen_width : s32 = ---;
platform_screen_height : s32 = ---;

#if OS == .WINDOWS {
    #import "My_Windows";

    platform_hinstance : HINSTANCE = ---;
    platform_hwnd : HWND = ---;
    platform_hdc : HDC = ---;

    #load "windows.jai";
}

#if OPENGL #load "renderer_opengl.jai";
