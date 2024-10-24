#include "../basic/vulkan.h"

#define X(RET, NAME, ...) RET (*NAME)(__VA_ARGS__);
VULKAN_EXPORTED_FUNCTIONS
VULKAN_GLOBAL_FUNCTIONS
VULKAN_INSTANCE_FUNCTIONS
#if BUILD_MODE_DEBUG
VULKAN_DEBUG_UTILS_EXTENSION_FUNCTIONS
#endif
VULKAN_SURFACE_EXTENSION_FUNCTIONS
#if TARGET_OS_WINDOWS
VULKAN_WIN32_SURFACE_EXTENSION_FUNCTIONS
#endif
VULKAN_SWAPCHAIN_EXTENSION_FUNCTIONS
#undef X

static struct {
    VkInstance instance;
#if BUILD_MODE_DEBUG
    VkDebugUtilsMessengerEXT debug_messenger;
#endif
    VkSurfaceKHR surface;
    VkPhysicalDevice physical_device;
    u32 graphics_queue_family_index;
    u32 present_queue_family_index;
    VkDevice device;
    VkQueue graphics_queue;
    VkQueue present_queue;
    VkSurfaceFormatKHR surface_format;
    VkPresentModeKHR surface_present_mode;

    VkSurfaceCapabilitiesKHR surface_capabilities;
    VkSwapchainKHR swapchain;
    u32 swapchain_image_count;
    VkImage swapchain_images[8];
    VkImageView swapchain_image_views[8];
    VkFramebuffer swapchain_framebuffers[8];
} vk;

static void vulkan_deinit(void);

#if BUILD_MODE_DEBUG
static u32 vulkan_debug_callback(
    VkDebugUtilsMessageSeverityFlagBitsEXT messageSeverity,
    VkDebugUtilsMessageTypeFlagsEXT messageType,
    VkDebugUtilsMessengerCallbackDataEXT* pCallbackData,
    void* pUserData)
{
    (void) (messageSeverity, messageType, pUserData);
#if TARGET_OS_WINDOWS
    WriteConsoleA(platform_stderr, pCallbackData->pMessage, (u32) u8strlen(pCallbackData->pMessage), null, null);
    WriteConsoleA(platform_stderr, "\r\n", 2, null, null);
#endif
    return false;
}
#endif

static bool vulkan_swapchain_init(void) {
    VkResult result;

    result = vkGetPhysicalDeviceSurfaceCapabilitiesKHR(vk.physical_device, vk.surface, &vk.surface_capabilities);
    if (result != VK_SUCCESS) goto error;

    u32 requested_image_count = vk.surface_capabilities.minImageCount + 1;
    if (vk.surface_capabilities.maxImageCount) {
        requested_image_count = min(requested_image_count, vk.surface_capabilities.maxImageCount);
    }

    static VkSwapchainCreateInfoKHR swapchain_create_info = {0};
    swapchain_create_info.sType = VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR;
    swapchain_create_info.surface = vk.surface;
    swapchain_create_info.minImageCount = requested_image_count;
    swapchain_create_info.imageFormat = vk.surface_format.format;
    swapchain_create_info.imageColorSpace = vk.surface_format.colorSpace;
    swapchain_create_info.imageExtent.width = vk.surface_capabilities.currentExtent.width;
    swapchain_create_info.imageExtent.height = vk.surface_capabilities.currentExtent.height;
    swapchain_create_info.imageArrayLayers = 1;
    swapchain_create_info.imageUsage = VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT;
    swapchain_create_info.imageSharingMode = vk.graphics_queue_family_index == vk.present_queue_family_index ?
        VK_SHARING_MODE_EXCLUSIVE : VK_SHARING_MODE_CONCURRENT;
    swapchain_create_info.queueFamilyIndexCount = vk.graphics_queue_family_index == vk.present_queue_family_index ? 0 : 2;
    swapchain_create_info.pQueueFamilyIndices = (u32 []) {vk.graphics_queue_family_index, vk.present_queue_family_index};
    swapchain_create_info.preTransform = vk.surface_capabilities.currentTransform;
    swapchain_create_info.compositeAlpha = VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR;
    swapchain_create_info.presentMode = vk.surface_present_mode;
    swapchain_create_info.clipped = true;
    result = vkCreateSwapchainKHR(vk.device, &swapchain_create_info, null, &vk.swapchain);
    if (result != VK_SUCCESS) goto error;

    vk.swapchain_image_count = len(vk.swapchain_images);
    result = vkGetSwapchainImagesKHR(vk.device, vk.swapchain, &vk.swapchain_image_count, vk.swapchain_images);
    if (result != VK_SUCCESS && result != VK_INCOMPLETE) goto error;

    for (u32 i = 0; i < vk.swapchain_image_count; i += 1) {
        static VkImageViewCreateInfo image_view_create_info = {0};
        image_view_create_info.sType = VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO;
        image_view_create_info.image = vk.swapchain_images[i];
        image_view_create_info.viewType = VK_IMAGE_VIEW_TYPE_2D;
        image_view_create_info.format = vk.surface_format.format;
        image_view_create_info.components.r = VK_COMPONENT_SWIZZLE_IDENTITY;
        image_view_create_info.components.g = VK_COMPONENT_SWIZZLE_IDENTITY;
        image_view_create_info.components.b = VK_COMPONENT_SWIZZLE_IDENTITY;
        image_view_create_info.components.a = VK_COMPONENT_SWIZZLE_IDENTITY;
        image_view_create_info.subresourceRange.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT;
        image_view_create_info.subresourceRange.baseMipLevel = 0;
        image_view_create_info.subresourceRange.levelCount = 1;
        image_view_create_info.subresourceRange.baseArrayLayer = 0;
        image_view_create_info.subresourceRange.layerCount = 1;
        result = vkCreateImageView(vk.device, &image_view_create_info, null, vk.swapchain_image_views + i);
        if (result != VK_SUCCESS) goto error;

        static VkFramebufferCreateInfo framebuffer_create_info = {0};
        framebuffer_create_info.sType = VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO;
        // framebuffer_create_info.renderPass = vk.main_render_pass;
        framebuffer_create_info.attachmentCount = 1;
        framebuffer_create_info.pAttachments = vk.swapchain_image_views + i;
        framebuffer_create_info.width = vk.surface_capabilities.currentExtent.width;
        framebuffer_create_info.height = vk.surface_capabilities.currentExtent.height;
        framebuffer_create_info.layers = 1;
        // result = vkCreateFramebuffer(vk.device, &framebuffer_create_info, null, vk.swapchain_framebuffers + i);
        // if (result != VK_SUCCESS) goto error;
    }

    return true;
error:
    vulkan_deinit();
    return false;
}

static void vulkan_swapchain_deinit(void) {
    for (u32 i = 0; i < vk.swapchain_image_count; i += 1) {
        if (vk.swapchain_framebuffers[i]) vkDestroyFramebuffer(vk.device, vk.swapchain_framebuffers[i], null);
        if (vk.swapchain_image_views[i]) vkDestroyImageView(vk.device, vk.swapchain_image_views[i], null);
    }
    if (vk.swapchain) vkDestroySwapchainKHR(vk.device, vk.swapchain, null);
}

static void vulkan_init(void) {
#if TARGET_OS_WINDOWS
    HMODULE dll;
#define X(RET, NAME, ...) NAME = (RET (*)(__VA_ARGS__)) GetProcAddress(dll, #NAME);
    dll = LoadLibraryW(L"vulkan-1");
    VULKAN_EXPORTED_FUNCTIONS
#undef X
#endif

#define X(RET, NAME, ...) NAME = (RET (*)(__VA_ARGS__)) vkGetInstanceProcAddr(null, #NAME);
    VULKAN_GLOBAL_FUNCTIONS
#undef X

    if (!vkCreateInstance) goto error;

    VkResult result;
    u32 count;
    static union {
        VkQueueFamilyProperties queue_families[16];
        VkSurfaceFormatKHR surface_formats[16];
        VkPresentModeKHR surface_present_modes[16];
    } buffers;

    static u8* instance_extensions[] = {
#if BUILD_MODE_DEBUG
        VK_EXT_DEBUG_UTILS_EXTENSION_NAME,
#endif
        VK_KHR_SURFACE_EXTENSION_NAME,
#if TARGET_OS_WINDOWS
        VK_KHR_WIN32_SURFACE_EXTENSION_NAME,
#endif
    };

#if BUILD_MODE_DEBUG
    static VkDebugUtilsMessengerCreateInfoEXT debug_messenger_create_info = {0};
    debug_messenger_create_info.sType = VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT;
    debug_messenger_create_info.messageSeverity = VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT |
        VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT;
    debug_messenger_create_info.messageType = VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT |
        VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT;
    debug_messenger_create_info.pfnUserCallback = vulkan_debug_callback;
#endif

    static VkInstanceCreateInfo instance_create_info = {0};
    instance_create_info.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
#if BUILD_MODE_DEBUG
    instance_create_info.pNext = &debug_messenger_create_info;
#endif
    instance_create_info.enabledExtensionCount = len(instance_extensions);
    instance_create_info.ppEnabledExtensionNames = instance_extensions;
    result = vkCreateInstance(&instance_create_info, null, &vk.instance);
    if (result != VK_SUCCESS) goto error;

#define X(RET, NAME, ...) NAME = (RET (*)(__VA_ARGS__)) vkGetInstanceProcAddr(vk.instance, #NAME);
    VULKAN_INSTANCE_FUNCTIONS
#if BUILD_MODE_DEBUG
    VULKAN_DEBUG_UTILS_EXTENSION_FUNCTIONS
#endif
    VULKAN_SURFACE_EXTENSION_FUNCTIONS
#if TARGET_OS_WINDOWS
    VULKAN_WIN32_SURFACE_EXTENSION_FUNCTIONS
#endif
    VULKAN_SWAPCHAIN_EXTENSION_FUNCTIONS
#undef X

#if BUILD_MODE_DEBUG
    result = vkCreateDebugUtilsMessengerEXT(vk.instance, &debug_messenger_create_info, null, &vk.debug_messenger);
    if (result != VK_SUCCESS) goto error;
#endif

#if TARGET_OS_WINDOWS
    static VkWin32SurfaceCreateInfoKHR surface_create_info = {0};
    surface_create_info.sType = VK_STRUCTURE_TYPE_WIN32_SURFACE_CREATE_INFO_KHR;
    surface_create_info.hinstance = platform_hinstance;
    surface_create_info.hwnd = platform_hwnd;
    result = vkCreateWin32SurfaceKHR(vk.instance, &surface_create_info, null, &vk.surface);
    if (result != VK_SUCCESS) goto error;
#endif

    count = 1;
    result = vkEnumeratePhysicalDevices(vk.instance, &count, &vk.physical_device);
    if (result != VK_SUCCESS && result != VK_INCOMPLETE) goto error;

    count = len(buffers.queue_families);
    vkGetPhysicalDeviceQueueFamilyProperties(vk.physical_device, &count, buffers.queue_families);

    vk.graphics_queue_family_index = (u32) -1;
    vk.present_queue_family_index = (u32) -1;
    for (u32 i = 0; i < count; i += 1) {
        if (vk.graphics_queue_family_index == -1 &&
            buffers.queue_families[i].queueFlags & VK_QUEUE_GRAPHICS_BIT)
        {
            vk.graphics_queue_family_index = i;
        }

        u32 present_supported;
        result = vkGetPhysicalDeviceSurfaceSupportKHR(vk.physical_device, i, vk.surface, &present_supported);
        if (result != VK_SUCCESS) goto error;
        if (vk.present_queue_family_index == -1 && present_supported) {
            vk.present_queue_family_index = i;
        }

        if (vk.graphics_queue_family_index != -1 && vk.present_queue_family_index != -1) break;
    }
    if (vk.graphics_queue_family_index == -1) goto error;
    if (vk.present_queue_family_index == -1) goto error;

    static VkDeviceQueueCreateInfo device_queue_create_infos[2] = {0};
    device_queue_create_infos[0].sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO;
    device_queue_create_infos[0].queueFamilyIndex = vk.graphics_queue_family_index;
    device_queue_create_infos[0].queueCount = 1;
    device_queue_create_infos[0].pQueuePriorities = (f32 []) {0.0f};
    device_queue_create_infos[1].sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO;
    device_queue_create_infos[1].queueFamilyIndex = vk.present_queue_family_index;
    device_queue_create_infos[1].queueCount = 1;
    device_queue_create_infos[1].pQueuePriorities = (f32 []) {0.0f};

    static u8* device_extensions[] = {VK_KHR_SWAPCHAIN_EXTENSION_NAME};

    static VkDeviceCreateInfo device_create_info = {0};
    device_create_info.sType = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO;
    device_create_info.queueCreateInfoCount = vk.graphics_queue_family_index == vk.present_queue_family_index ? 1 : 2;
    device_create_info.pQueueCreateInfos = device_queue_create_infos;
    device_create_info.enabledExtensionCount = len(device_extensions);
    device_create_info.ppEnabledExtensionNames = device_extensions;
    result = vkCreateDevice(vk.physical_device, &device_create_info, null, &vk.device);
    if (result != VK_SUCCESS) goto error;

    vkGetDeviceQueue(vk.device, vk.graphics_queue_family_index, 0, &vk.graphics_queue);
    vkGetDeviceQueue(vk.device, vk.present_queue_family_index, 0, &vk.present_queue);

    count = len(buffers.surface_formats);
    result = vkGetPhysicalDeviceSurfaceFormatsKHR(vk.physical_device, vk.surface, &count, buffers.surface_formats);
    if (result != VK_SUCCESS && result != VK_INCOMPLETE) goto error;

    vk.surface_format.format = buffers.surface_formats[0].format;
    vk.surface_format.colorSpace = buffers.surface_formats[0].colorSpace;
    for (u32 i = 0; i < count; i += 1) {
        if (buffers.surface_formats[i].format == VK_FORMAT_B8G8R8A8_SRGB &&
            buffers.surface_formats[i].colorSpace == VK_COLOR_SPACE_SRGB_NONLINEAR_KHR)
        {
            vk.surface_format.format = buffers.surface_formats[i].format;
            vk.surface_format.colorSpace = buffers.surface_formats[i].colorSpace;
            break;
        }
    }

    count = len(buffers.surface_present_modes);
    result = vkGetPhysicalDeviceSurfacePresentModesKHR(vk.physical_device, vk.surface, &count, buffers.surface_present_modes);
    if (result != VK_SUCCESS && result != VK_INCOMPLETE) goto error;

    vk.surface_present_mode = VK_PRESENT_MODE_FIFO_KHR;
    for (u32 i = 0; i < count; i += 1) {
        if (buffers.surface_present_modes[i] == VK_PRESENT_MODE_MAILBOX_KHR) {
            vk.surface_present_mode = buffers.surface_present_modes[i];
            break;
        }
    }

    return;
error:
    vulkan_deinit();
}

static void vulkan_deinit(void) {
    if (vk.instance) {
        vulkan_swapchain_deinit();
        if (vk.device) {
            vkDestroyDevice(vk.device, null);
        }
        if (vk.debug_messenger) vkDestroyDebugUtilsMessengerEXT(vk.instance, vk.debug_messenger, null);
        if (vk.surface) vkDestroySurfaceKHR(vk.instance, vk.surface, null);
        vkDestroyInstance(vk.instance, null);
    }
    // memset(&vk, 0, sizeof(vk));
}

static void vulkan_resize(void) {
    if (!platform_screen_width || !platform_screen_height) return;

    vulkan_swapchain_init();
}

static void vulkan_present(void) {

}
