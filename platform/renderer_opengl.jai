#import "My_OpenGL";

#if OS == .WINDOWS {
    using gl10_instance : gl10; // @Hack surely there's a cleaner way to do function pointers at compile time?

    opengl_ctx : HGLRC = xx null;

    opengl_platform_init :: () {
        pfd : PIXELFORMATDESCRIPTOR;
        pfd.nSize = size_of(PIXELFORMATDESCRIPTOR);
        pfd.nVersion = 1;
        pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL |
            PFD_DOUBLEBUFFER | PFD_DEPTH_DONTCARE;
        pfd.cColorBits = 24;
        format := ChoosePixelFormat(platform_hdc, *pfd);
        SetPixelFormat(platform_hdc, format, *pfd);

        temp_ctx := wglCreateContext(platform_hdc);
        wglMakeCurrent(platform_hdc, temp_ctx);
        defer wglDeleteContext(temp_ctx);

        wglCreateContextAttribsARB :=
            cast(PFN_wglCreateContextAttribsARB)
            wglGetProcAddress("wglCreateContextAttribsARB");

        attribs := s32.[
            WGL_CONTEXT_MAJOR_VERSION_ARB, 4,
            WGL_CONTEXT_MINOR_VERSION_ARB, 6,
            WGL_CONTEXT_FLAGS_ARB, xx ifx DEVELOPER WGL_CONTEXT_DEBUG_BIT_ARB,
            WGL_CONTEXT_PROFILE_MASK_ARB, WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
            0,
        ];
        opengl_ctx = wglCreateContextAttribsARB(platform_hdc, xx null, attribs.data);
        wglMakeCurrent(platform_hdc, opengl_ctx);

        dll := LoadLibraryW((#run ascii_to_utf16le_string_literal("opengl32")).data);
        glClear = cast(type_of(glClear)) GetProcAddress(dll, "glClear");
    }

    opengl_platform_deinit :: () {
        if opengl_ctx wglDeleteContext(opengl_ctx);
        opengl_ctx = xx null;
    }

    opengl_platform_present :: () {
        SwapBuffers(platform_hdc);
    }
}

opengl_init :: () {
    opengl_platform_init();
}

opengl_deinit :: () {
    opengl_platform_deinit();
}

opengl_resize :: () {
    if !platform_screen_width || !platform_screen_height return;

}

opengl_present :: () {
    glClear(GL_COLOR_BUFFER_BIT);

    opengl_platform_present();
}
