module basic.vulkan;

import basic : AliasSeq, Procedure;

struct VkInstance__; alias VkInstance = VkInstance__*;
struct VkPhysicalDevice__; alias VkPhysicalDevice = VkPhysicalDevice__*;
struct VkDevice__; alias VkDevice = VkDevice__*;
alias PFN_vkVoidFunction = extern(System) void function();
alias PFN_vkGetInstanceProcAddr = extern(System) PFN_vkVoidFunction function(VkInstance, const(char)*);
alias PFN_vkAllocationFunction = extern(System) void* function(void*, size_t, size_t, VkSystemAllocationScope);
alias PFN_vkReallocationFunction = extern(System) void* function(void*, void*, size_t, size_t, VkSystemAllocationScope);
alias PFN_vkFreeFunction = extern(System) void function(void*, void*);
alias PFN_vkInternalAllocationNotification = extern(System) void function(void*, size_t, VkInternalAllocationType, VkSystemAllocationScope);
alias PFN_vkInternalFreeNotification = extern(System) void function(void*, size_t, VkInternalAllocationType, VkSystemAllocationScope);
alias VkFlags = uint;
enum VkResult : int {
    VK_SUCCESS = 0,
    VK_NOT_READY = 1,
    VK_TIMEOUT = 2,
    VK_EVENT_SET = 3,
    VK_EVENT_RESET = 4,
    VK_INCOMPLETE = 5,
    VK_ERROR_OUT_OF_HOST_MEMORY = -1,
    VK_ERROR_OUT_OF_DEVICE_MEMORY = -2,
    VK_ERROR_INITIALIZATION_FAILED = -3,
    VK_ERROR_DEVICE_LOST = -4,
    VK_ERROR_MEMORY_MAP_FAILED = -5,
    VK_ERROR_LAYER_NOT_PRESENT = -6,
    VK_ERROR_EXTENSION_NOT_PRESENT = -7,
    VK_ERROR_FEATURE_NOT_PRESENT = -8,
    VK_ERROR_INCOMPATIBLE_DRIVER = -9,
    VK_ERROR_TOO_MANY_OBJECTS = -10,
    VK_ERROR_FORMAT_NOT_SUPPORTED = -11,
    VK_ERROR_FRAGMENTED_POOL = -12,
    VK_ERROR_UNKNOWN = -13,
}
enum VkStructureType : int {
    VK_STRUCTURE_TYPE_APPLICATION_INFO = 0,
    VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO = 1,
    VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO = 2,
    VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO = 3,
    VK_STRUCTURE_TYPE_SUBMIT_INFO = 4,
    VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO = 5,
    VK_STRUCTURE_TYPE_MAPPED_MEMORY_RANGE = 6,
    VK_STRUCTURE_TYPE_BIND_SPARSE_INFO = 7,
    VK_STRUCTURE_TYPE_FENCE_CREATE_INFO = 8,
    VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO = 9,
    VK_STRUCTURE_TYPE_EVENT_CREATE_INFO = 10,
    VK_STRUCTURE_TYPE_QUERY_POOL_CREATE_INFO = 11,
    VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO = 12,
    VK_STRUCTURE_TYPE_BUFFER_VIEW_CREATE_INFO = 13,
    VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO = 14,
    VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO = 15,
    VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO = 16,
    VK_STRUCTURE_TYPE_PIPELINE_CACHE_CREATE_INFO = 17,
    VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO = 18,
    VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO = 19,
    VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO = 20,
    VK_STRUCTURE_TYPE_PIPELINE_TESSELLATION_STATE_CREATE_INFO = 21,
    VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO = 22,
    VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO = 23,
    VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO = 24,
    VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO = 25,
    VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO = 26,
    VK_STRUCTURE_TYPE_PIPELINE_DYNAMIC_STATE_CREATE_INFO = 27,
    VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO = 28,
    VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO = 29,
    VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO = 30,
    VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO = 31,
    VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO = 32,
    VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO = 33,
    VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO = 34,
    VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET = 35,
    VK_STRUCTURE_TYPE_COPY_DESCRIPTOR_SET = 36,
    VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO = 37,
    VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO = 38,
    VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO = 39,
    VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO = 40,
    VK_STRUCTURE_TYPE_COMMAND_BUFFER_INHERITANCE_INFO = 41,
    VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO = 42,
    VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO = 43,
    VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER = 44,
    VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER = 45,
    VK_STRUCTURE_TYPE_MEMORY_BARRIER = 46,
    VK_STRUCTURE_TYPE_LOADER_INSTANCE_CREATE_INFO = 47,
    VK_STRUCTURE_TYPE_LOADER_DEVICE_CREATE_INFO = 48,
}
enum VkInternalAllocationType : int {
    VK_INTERNAL_ALLOCATION_TYPE_EXECUTABLE = 0,
}
enum VkSystemAllocationScope : int {
    VK_SYSTEM_ALLOCATION_SCOPE_COMMAND = 0,
    VK_SYSTEM_ALLOCATION_SCOPE_OBJECT = 1,
    VK_SYSTEM_ALLOCATION_SCOPE_CACHE = 2,
    VK_SYSTEM_ALLOCATION_SCOPE_DEVICE = 3,
    VK_SYSTEM_ALLOCATION_SCOPE_INSTANCE = 4,
}
struct VkAllocationCallbacks {
    void* pUserData;
    PFN_vkAllocationFunction pfnAllocation;
    PFN_vkReallocationFunction pfnReallocation;
    PFN_vkFreeFunction pfnFree;
    PFN_vkInternalAllocationNotification pfnInternalAllocation;
    PFN_vkInternalFreeNotification pfnInternalFree;
}
struct VkApplicationInfo {
    VkStructureType sType;
    const(void)* pNext;
    const(char)* pApplicationName;
    uint applicationVersion;
    const(char)* pEngineName;
    uint engineVersion;
    uint apiVersion;
}
alias VkInstanceCreateFlags = VkFlags;
struct VkInstanceCreateInfo {
    VkStructureType sType;
    const(void)* pNext;
    VkInstanceCreateFlags flags;
    const(VkApplicationInfo)* pApplicationInfo;
    uint enabledLayerCount;
    const(char*)* ppEnabledLayerNames;
    uint enabledExtensionCount;
    const(char*)* ppEnabledExtensionNames;
}
struct VkPhysicalDeviceFeatures {
    uint robustBufferAccess;
    uint fullDrawIndexUint32;
    uint imageCubeArray;
    uint independentBlend;
    uint geometryShader;
    uint tessellationShader;
    uint sampleRateShading;
    uint dualSrcBlend;
    uint logicOp;
    uint multiDrawIndirect;
    uint drawIndirectFirstInstance;
    uint depthClamp;
    uint depthBiasClamp;
    uint fillModeNonSolid;
    uint depthBounds;
    uint wideLines;
    uint largePoints;
    uint alphaToOne;
    uint multiViewport;
    uint samplerAnisotropy;
    uint textureCompressionETC2;
    uint textureCompressionASTC_LDR;
    uint textureCompressionBC;
    uint occlusionQueryPrecise;
    uint pipelineStatisticsQuery;
    uint vertexPipelineStoresAndAtomics;
    uint fragmentStoresAndAtomics;
    uint shaderTessellationAndGeometryPointSize;
    uint shaderImageGatherExtended;
    uint shaderStorageImageExtendedFormats;
    uint shaderStorageImageMultisample;
    uint shaderStorageImageReadWithoutFormat;
    uint shaderStorageImageWriteWithoutFormat;
    uint shaderUniformBufferArrayDynamicIndexing;
    uint shaderSampledImageArrayDynamicIndexing;
    uint shaderStorageBufferArrayDynamicIndexing;
    uint shaderStorageImageArrayDynamicIndexing;
    uint shaderClipDistance;
    uint shaderCullDistance;
    uint shaderFloat64;
    uint shaderInt64;
    uint shaderInt16;
    uint shaderResourceResidency;
    uint shaderResourceMinLod;
    uint sparseBinding;
    uint sparseResidencyBuffer;
    uint sparseResidencyImage2D;
    uint sparseResidencyImage3D;
    uint sparseResidency2Samples;
    uint sparseResidency4Samples;
    uint sparseResidency8Samples;
    uint sparseResidency16Samples;
    uint sparseResidencyAliased;
    uint variableMultisampleRate;
    uint inheritedQueries;
}
alias VkDeviceQueueCreateFlags = VkFlags;
struct VkDeviceQueueCreateInfo {
    VkStructureType sType;
    const(void)* pNext;
    VkDeviceQueueCreateFlags flags;
    uint queueFamilyIndex;
    uint queueCount;
    const(float)* pQueuePriorities;
}
alias VkDeviceCreateFlags = VkFlags;
struct VkDeviceCreateInfo {
    VkStructureType sType;
    const(void)* pNext;
    VkDeviceCreateFlags flags;
    uint queueCreateInfoCount;
    const(VkDeviceQueueCreateInfo)* pQueueCreateInfos;
    uint enabledLayerCount;
    const(char*)* ppEnabledLayerNames;
    uint enabledExtensionCount;
    const(char*)* ppEnabledExtensionNames;
    const(VkPhysicalDeviceFeatures)* pEnabledFeatures;
}

alias vulkan_global_procs = AliasSeq!(
    Procedure!(VkResult, "vkCreateInstance", const(VkInstanceCreateInfo)*, const(VkAllocationCallbacks)*, VkInstance*),
);

alias vulkan_instance_procs = AliasSeq!(
    Procedure!(void, "vkDestroyInstance", VkInstance, const(VkAllocationCallbacks)*),
    Procedure!(VkResult, "vkEnumeratePhysicalDevices", VkInstance, uint*, VkPhysicalDevice*),
    Procedure!(VkResult, "vkCreateDevice", const(VkDeviceCreateInfo)*, const(VkAllocationCallbacks)*, VkDevice*),
);
