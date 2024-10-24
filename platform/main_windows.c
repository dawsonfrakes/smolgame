#include "../basic/basic.h"
#include "../basic/windows.h"

#define X(RET, NAME, ...) RET NAME(__VA_ARGS__);
KERNEL32_FUNCTIONS
#undef X

#define X(RET, NAME, ...) RET (*NAME)(__VA_ARGS__);
USER32_FUNCTIONS
#undef X

void WinMainCRTStartup(void) {
    HMODULE dll;
#define X(RET, NAME, ...) NAME = (RET (*)(__VA_ARGS__)) GetProcAddress(dll, #NAME);
    dll = LoadLibraryW(L"user32");
    USER32_FUNCTIONS
#undef X

    SetProcessDPIAware();

    ExitProcess(0);
}
