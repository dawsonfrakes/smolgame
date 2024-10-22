enum DEVELOPER = true;
enum STEAM = true;
enum OPENGL = true;

import basic;

__gshared int platform_screen_width;
__gshared int platform_screen_height;

version (Windows) {
    import basic.windows;

    mixin ProcedureDeclarations!("Windows", kernel32);
    mixin ProcedureDeclarationsDynamic!("Windows", user32, dwmapi, winmm);

    __gshared HINSTANCE platform_hinstance;
    __gshared HWND platform_hwnd;
    __gshared HDC platform_hdc;

    mixin(import("platform/windows.d"));
}
