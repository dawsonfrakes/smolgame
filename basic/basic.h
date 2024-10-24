#if !defined(NDEBUG)
#define BUILD_MODE_DEBUG 1
#else
#define BUILD_MODE_DEBUG 0
#endif

#if defined(__x86_64__) || defined(_M_AMD64)
#define TARGET_CPU_ARCH_AMD64 1
#else
#define TARGET_CPU_ARCH_AMD64 0
#endif

#if defined(_WIN32) || defined(_WIN64) || defined(__WIN32__)
#define TARGET_OS_WINDOWS 1
#else
#define TARGET_OS_WINDOWS 0
#endif

#if defined(_MSC_VER)
#define COMPILER_MSVC 1
#else
#define COMPILER_MSVC 0
#endif

#if defined(__TINYC__)
#define COMPILER_TCC 1
#else
#define COMPILER_TCC 0
#endif

#define offsetof(T, F) ((s64) &((T*) 0)->F)
#define alignof(T) offsetof(struct { u8 x; T t; }, t)
#define min(X, Y) ((X) < (Y) ? (X) : (Y))
#define max(X, Y) ((X) > (Y) ? (X) : (Y))
#define len(X) (sizeof(X) / sizeof((X)[0]))
#define str(X) {len(X) - 1, (u8*) (X)}

#if BUILD_MODE_DEBUG
    #if COMPILER_MSVC
    #define debug_break() __debugbreak()
    #elif COMPILER_TCC
    #define debug_break() __asm__ ("int3")
    #else
    #error compiler undefined
    #endif
#define assert(X) do if (!(X)) debug_break(); while (0)
#else
#define debug_break()
#define assert(X) ((void) (X))
#endif

#if COMPILER_MSVC
#define align(X) __declspec(aligned(N))
#elif COMPILER_TCC
#define align(X) __attribute__((align(X)))
#else
#error compiler undefined
#endif

#if TARGET_CPU_ARCH_AMD64
typedef signed char s8;
typedef short s16;
typedef int s32;
typedef long long s64;

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef unsigned long long u64;
#endif

typedef s8 bool;

typedef float f32;
typedef double f64;

typedef struct {
    s64 count;
    u8* data;
} string;

typedef struct align(8) {
    f32 x;
    f32 y;
} v2;
typedef struct align(16) {
    f32 x;
    f32 y;
    f32 z;
    f32 _unused;
} v3;
typedef struct align(16) {
    f32 x;
    f32 y;
    f32 z;
    f32 w;
} v4;
