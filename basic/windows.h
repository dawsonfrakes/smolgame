// kernel32
typedef struct HINSTANCE__* HINSTANCE;
typedef HINSTANCE HMODULE;
typedef s64 (*PROC)(void);

#define KERNEL32_FUNCTIONS \
    X(HMODULE, GetModuleHandleW, u16 const*) \
    X(HMODULE, LoadLibraryW, u16 const*) \
    X(PROC, GetProcAddress, HMODULE, u8 const*) \
    X(void, Sleep, u32) \
    X(void, ExitProcess, u32)

// user32
#define USER32_FUNCTIONS \
    X(s32, SetProcessDPIAware, void)
