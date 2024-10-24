#include "../basic/opengl.h"

#if TARGET_OS_WINDOWS
#define WGL_CONTEXT_MAJOR_VERSION_ARB 0x2091
#define WGL_CONTEXT_MINOR_VERSION_ARB 0x2092
#define WGL_CONTEXT_FLAGS_ARB 0x2094
#define WGL_CONTEXT_PROFILE_MASK_ARB 0x9126
#define WGL_CONTEXT_DEBUG_BIT_ARB 0x0001
#define WGL_CONTEXT_CORE_PROFILE_BIT_ARB 0x00000001

#define X(RET, NAME, ...) RET (*NAME)(__VA_ARGS__);
GDI32_FUNCTIONS
OPENGL32_FUNCTIONS
GL10_FUNCTIONS
GL20_FUNCTIONS
GL30_FUNCTIONS
GL41_FUNCTIONS
GL42_FUNCTIONS
GL43_FUNCTIONS
GL45_FUNCTIONS
#undef X

static HGLRC opengl_ctx;

#if BUILD_MODE_DEBUG
static void opengl_platform_debug_callback(u32 source, u32 type, u32 id, u32 severity, u32 length, u8* message, void* user_param) {
    WriteConsoleA(platform_stderr, message, length, null, null);
    WriteConsoleA(platform_stderr, "\r\n", 2, null, null);
}
#endif

static void opengl_platform_init(void) {
    HMODULE dll;
#define X(RET, NAME, ...) NAME = (RET (*)(__VA_ARGS__)) GetProcAddress(dll, #NAME);
    dll = LoadLibraryW(L"gdi32");
    GDI32_FUNCTIONS
    dll = LoadLibraryW(L"opengl32");
    OPENGL32_FUNCTIONS
    GL10_FUNCTIONS
#undef X

    static PIXELFORMATDESCRIPTOR pfd = {0};
    pfd.nSize = sizeof(PIXELFORMATDESCRIPTOR);
    pfd.nVersion = 1;
    pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL |
        PFD_DOUBLEBUFFER | PFD_DEPTH_DONTCARE;
    pfd.cColorBits = 24;
    s32 format = ChoosePixelFormat(platform_hdc, &pfd);
    SetPixelFormat(platform_hdc, format, &pfd);

    HGLRC temp_ctx = wglCreateContext(platform_hdc);
    wglMakeCurrent(platform_hdc, temp_ctx);

    HGLRC (*wglCreateContextAttribsARB)(HDC, HGLRC, s32*) =
        (HGLRC (*)(HDC, HGLRC, s32*))
        wglGetProcAddress("wglCreateContextAttribsARB");

    static s32 attribs[] = {
        WGL_CONTEXT_MAJOR_VERSION_ARB, 4,
        WGL_CONTEXT_MINOR_VERSION_ARB, 6,
        WGL_CONTEXT_FLAGS_ARB, WGL_CONTEXT_DEBUG_BIT_ARB,
        WGL_CONTEXT_PROFILE_MASK_ARB, WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
        0,
    };
    opengl_ctx = wglCreateContextAttribsARB(platform_hdc, null, attribs);
    if (opengl_ctx) {
        wglMakeCurrent(platform_hdc, opengl_ctx);
        wglDeleteContext(temp_ctx);
    }

#define X(RET, NAME, ...) NAME = (RET (*)(__VA_ARGS__)) wglGetProcAddress(#NAME);
    GL20_FUNCTIONS
    GL30_FUNCTIONS
    GL41_FUNCTIONS
    GL42_FUNCTIONS
    GL43_FUNCTIONS
    GL45_FUNCTIONS
#undef X
}

static void opengl_platform_deinit(void) {
    if (opengl_ctx) wglDeleteContext(opengl_ctx);
    opengl_ctx = null;
}

static void opengl_platform_present(void) {
    SwapBuffers(platform_hdc);
}
#endif

typedef struct {
    v3 position;
    v2 texcoord;
    u32 texture_index;
} OpenGL_Mesh_Vertex;

typedef struct {
    m4 mvp;
    u32 entity_id;
} OpenGL_Mesh_Instance;

static u8 basic_mesh_indices[] = {0, 1, 2, 2, 3, 0};
static OpenGL_Mesh_Vertex basic_mesh_vertices[] = {
    {.position = {-0.5f, -0.5f, 0.0f}, .texcoord = {0.0f, 0.0f}},
    {.position = {+0.5f, -0.5f, 0.0f}, .texcoord = {1.0f, 0.0f}},
    {.position = {+0.5f, +0.5f, 0.0f}, .texcoord = {1.0f, 1.0f}},
    {.position = {-0.5f, +0.5f, 0.0f}, .texcoord = {0.0f, 1.0f}},
};
static OpenGL_Mesh_Instance basic_mesh_instances[] = {
    {
        .mvp.e = {
            1.0f, 0.0f, 0.0f, 0.0f,
            0.0f, 1.0f, 0.0f, 0.0f,
            0.0f, 0.0f, 1.0f, 0.0f,
            0.0f, 0.0f, 0.0f, 1.0f,
        },
        .entity_id = 5,
    }
};

static u32 opengl_main_fbo;
static u32 opengl_main_fbo_color0;
static u32 opengl_main_fbo_depth;

static u32 basic_mesh_vao;
static u32 basic_mesh_ibo;
static u32 basic_mesh_shader;
static u32 basic_mesh_texture;

static void opengl_init(void) {
    opengl_platform_init();

#if BUILD_MODE_DEBUG
    glEnable(GL_DEBUG_OUTPUT);
    glDebugMessageCallback(opengl_platform_debug_callback, null);
#endif

    glClipControl(GL_LOWER_LEFT, GL_ZERO_TO_ONE);

    glCreateFramebuffers(1, &opengl_main_fbo);
    glCreateRenderbuffers(1, &opengl_main_fbo_color0);
    glCreateRenderbuffers(1, &opengl_main_fbo_depth);

    u32 vbo;
    glCreateBuffers(1, &vbo);
    glNamedBufferData(vbo, sizeof(basic_mesh_vertices), basic_mesh_vertices, GL_STATIC_DRAW);
    u32 ebo;
    glCreateBuffers(1, &ebo);
    glNamedBufferData(ebo, sizeof(basic_mesh_indices), basic_mesh_indices, GL_STATIC_DRAW);
    u32 ibo;
    glCreateBuffers(1, &ibo);
    glNamedBufferData(ibo, sizeof(basic_mesh_instances), basic_mesh_instances, GL_STATIC_DRAW);

    u32 vao;
    glCreateVertexArrays(1, &vao);
    glVertexArrayElementBuffer(vao, ebo);
    u32 vbo_binding = 0;
    glVertexArrayVertexBuffer(vao, vbo_binding, vbo, 0, sizeof(OpenGL_Mesh_Vertex));
    u32 ibo_binding = 1;
    glVertexArrayVertexBuffer(vao, ibo_binding, ibo, 0, sizeof(OpenGL_Mesh_Instance));
    glVertexArrayBindingDivisor(vao, ibo_binding, 1);

    u32 position_attrib = 0;
    glEnableVertexArrayAttrib(vao, position_attrib);
    glVertexArrayAttribBinding(vao, position_attrib, vbo_binding);
    glVertexArrayAttribFormat(vao, position_attrib, 3, GL_FLOAT, false, offsetof(OpenGL_Mesh_Vertex, position));

    u32 texcoord_attrib = 1;
    glEnableVertexArrayAttrib(vao, texcoord_attrib);
    glVertexArrayAttribBinding(vao, texcoord_attrib, vbo_binding);
    glVertexArrayAttribFormat(vao, texcoord_attrib, 2, GL_FLOAT, false, offsetof(OpenGL_Mesh_Vertex, texcoord));

    u32 texture_index_attrib = 2;
    glEnableVertexArrayAttrib(vao, texture_index_attrib);
    glVertexArrayAttribBinding(vao, texture_index_attrib, vbo_binding);
    glVertexArrayAttribIFormat(vao, texture_index_attrib, 1, GL_UNSIGNED_INT, offsetof(OpenGL_Mesh_Vertex, texture_index));

    u32 mvp_attrib = 3;
    for (u8 i = 0; i < 4; i += 1) {
        glEnableVertexArrayAttrib(vao, mvp_attrib + i);
        glVertexArrayAttribBinding(vao, mvp_attrib + i, ibo_binding);
        glVertexArrayAttribFormat(vao, mvp_attrib + i, 4, GL_FLOAT, false, offsetof(OpenGL_Mesh_Instance, mvp) + i * sizeof(v4));
    }

    u32 entity_id_attrib = 7;
    glEnableVertexArrayAttrib(vao, entity_id_attrib);
    glVertexArrayAttribBinding(vao, entity_id_attrib, ibo_binding);
    glVertexArrayAttribIFormat(vao, entity_id_attrib, 1, GL_UNSIGNED_INT, offsetof(OpenGL_Mesh_Instance, entity_id));

    basic_mesh_vao = vao;
    basic_mesh_ibo = ibo;

    u8* vsrc =
    "#version 450\n"
    "layout(location = 0) in vec3 a_position;\n"
    "layout(location = 1) in vec2 a_texcoord;\n"
    "layout(location = 2) in uint a_texture_index;\n"
    "layout(location = 3) in mat4 i_mvp;\n"
    "layout(location = 7) in uint i_entity_id;\n"
    "layout(location = 1) out vec2 f_texcoord;\n"
    "void main() {\n"
    "   gl_Position = i_mvp * vec4(a_position, 1.0);"
    "   f_texcoord = a_texcoord;\n"
    "}\n";
    u32 vshader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vshader, 1, &vsrc, null);
    glCompileShader(vshader);

    u8* fsrc =
    "#version 450\n"
    "layout(location = 1) in vec2 f_texcoord;\n"
    "layout(location = 0) out vec4 color;\n"
    "layout(location = 0) uniform sampler2D u_texture[32];\n"
    "void main() {\n"
    "   color = texture(u_texture[0], f_texcoord);\n"
    "}\n";
    u32 fshader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fshader, 1, &fsrc, null);
    glCompileShader(fshader);

    u32 program = glCreateProgram();
    glAttachShader(program, vshader);
    glAttachShader(program, fshader);
    glLinkProgram(program);
    glDetachShader(program, fshader);
    glDetachShader(program, vshader);

    glDeleteShader(fshader);
    glDeleteShader(vshader);

    for (u8 i = 0; i < 32; i += 1) glProgramUniform1i(program, i, i);

    basic_mesh_shader = program;

    u32 texture;
    glCreateTextures(GL_TEXTURE_2D, 1, &texture);
    glTextureStorage2D(texture, 1, GL_RGB8, 512, 512);
    glTextureParameteri(texture, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

    u8* bmp_file = platform_read_entire_file("resources/textures/test.bmp");
    if (bmp_file) {
        u8* pixels = bmp_file + *(u32*) (bmp_file + 10);
        s32 width = *(u32*) (bmp_file + 18);
        s32 height = *(u32*) (bmp_file + 22);
        glTextureSubImage2D(texture, 0, 0, 0, width, height, GL_BGR, GL_UNSIGNED_BYTE, pixels);
        platform_free_entire_file(bmp_file);
    }

    basic_mesh_texture = texture;
}

static void opengl_deinit(void) {
    opengl_platform_deinit();
}

static void opengl_resize(void) {
    if (!platform_screen_width || !platform_screen_height) return;

    s32 fbo_color_samples_max;
    glGetIntegerv(GL_MAX_COLOR_TEXTURE_SAMPLES, &fbo_color_samples_max);
    s32 fbo_depth_samples_max;
    glGetIntegerv(GL_MAX_DEPTH_TEXTURE_SAMPLES, &fbo_depth_samples_max);
    u32 fbo_samples = (u32) min(fbo_color_samples_max, fbo_depth_samples_max);

    glNamedRenderbufferStorageMultisample(opengl_main_fbo_color0, fbo_samples,
        GL_RGBA16F, platform_screen_width, platform_screen_height);
    glNamedFramebufferRenderbuffer(opengl_main_fbo, GL_COLOR_ATTACHMENT0,
        GL_RENDERBUFFER, opengl_main_fbo_color0);

    glNamedRenderbufferStorageMultisample(opengl_main_fbo_depth, fbo_samples,
        GL_DEPTH_COMPONENT32F, platform_screen_width, platform_screen_height);
    glNamedFramebufferRenderbuffer(opengl_main_fbo, GL_DEPTH_ATTACHMENT,
        GL_RENDERBUFFER, opengl_main_fbo_depth);
}

static void opengl_present(void) {
    f32 color0[] = {0.6f, 0.2f, 0.2f, 1.0f};
    glClearNamedFramebufferfv(opengl_main_fbo, GL_COLOR, 0, color0);
    f32 depth = 0.0f;
    glClearNamedFramebufferfv(opengl_main_fbo, GL_DEPTH, 0, &depth);
    glBindFramebuffer(GL_FRAMEBUFFER, opengl_main_fbo);

    glViewport(0, 0, platform_screen_width, platform_screen_height);
    glUseProgram(basic_mesh_shader);
    glBindVertexArray(basic_mesh_vao);
    glBindTextureUnit(0, basic_mesh_texture);
    glDrawElementsInstancedBaseVertexBaseInstance(GL_TRIANGLES,
        len(basic_mesh_indices), GL_UNSIGNED_BYTE, (void*) 0,
        len(basic_mesh_instances), 0, 0);

    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glClear(0); // @Hack fix for intel default framebuffer resize bug

    glEnable(GL_FRAMEBUFFER_SRGB);
    glBlitNamedFramebuffer(opengl_main_fbo, 0,
        0, 0, platform_screen_width, platform_screen_height,
        0, 0, platform_screen_width, platform_screen_height,
        GL_COLOR_BUFFER_BIT, GL_NEAREST);
    glDisable(GL_FRAMEBUFFER_SRGB);

    opengl_platform_present();
}
