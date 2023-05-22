#ifndef OSActivityLogMessageEvent_h
#define OSActivityLogMessageEvent_h

#include <sys/time.h>
@import Foundation;

#define OS_ACTIVITY_MAX_CALLSTACK 32

enum {
    OS_ACTIVITY_STREAM_TYPE_ACTIVITY_CREATE = 0x0201,
    OS_ACTIVITY_STREAM_TYPE_ACTIVITY_TRANSITION = 0x0202,
    OS_ACTIVITY_STREAM_TYPE_ACTIVITY_USERACTION = 0x0203,

    OS_ACTIVITY_STREAM_TYPE_TRACE_MESSAGE = 0x0300,

    OS_ACTIVITY_STREAM_TYPE_LOG_MESSAGE = 0x0400,
    OS_ACTIVITY_STREAM_TYPE_LEGACY_LOG_MESSAGE = 0x0480,

    OS_ACTIVITY_STREAM_TYPE_SIGNPOST_BEGIN = 0x0601,
    OS_ACTIVITY_STREAM_TYPE_SIGNPOST_END = 0x0602,
    OS_ACTIVITY_STREAM_TYPE_SIGNPOST_EVENT = 0x0603,

    OS_ACTIVITY_STREAM_TYPE_STATEDUMP_EVENT = 0x0A00,
};
typedef uint32_t os_activity_stream_type_t;

typedef uint64_t os_activity_id_t;
typedef struct os_activity_stream_s *os_activity_stream_t;
typedef struct os_activity_stream_entry_s *os_activity_stream_entry_t;

#define OS_ACTIVITY_STREAM_COMMON()                                            \
uint64_t trace_id;                                                           \
uint64_t timestamp;                                                          \
uint64_t thread;                                                             \
const uint8_t *image_uuid;                                                   \
const char *image_path;                                                      \
struct timeval tv_gmt;                                                       \
struct timezone tz;                                                          \
uint32_t offset

typedef struct os_activity_stream_common_s {
    OS_ACTIVITY_STREAM_COMMON();
} * os_activity_stream_common_t;

struct os_activity_create_s {
    OS_ACTIVITY_STREAM_COMMON();
    const char *name;
    os_activity_id_t creator_aid;
    uint64_t unique_pid;
};

struct os_activity_transition_s {
    OS_ACTIVITY_STREAM_COMMON();
    os_activity_id_t transition_id;
};

typedef struct os_log_message_s {
    OS_ACTIVITY_STREAM_COMMON();
    const char *format;
    const uint8_t *buffer;
    size_t buffer_sz;
    const uint8_t *privdata;
    size_t privdata_sz;
    const char *subsystem;
    const char *category;
    uint32_t oversize_id;
    uint8_t ttl;
    bool persisted;
} * os_log_message_t;

typedef struct os_trace_message_v2_s {
    OS_ACTIVITY_STREAM_COMMON();
    const char *format;
    const void *buffer;
    size_t bufferLen;
    xpc_object_t __unsafe_unretained payload;
} * os_trace_message_v2_t;

typedef struct os_activity_useraction_s {
    OS_ACTIVITY_STREAM_COMMON();
    const char *action;
    bool persisted;
} * os_activity_useraction_t;

typedef struct os_signpost_s {
    OS_ACTIVITY_STREAM_COMMON();
    const char *format;
    const uint8_t *buffer;
    size_t buffer_sz;
    const uint8_t *privdata;
    size_t privdata_sz;
    const char *subsystem;
    const char *category;
    uint64_t duration_nsec;
    uint32_t callstack_depth;
    uint64_t callstack[OS_ACTIVITY_MAX_CALLSTACK];
} * os_signpost_t;

typedef struct os_activity_statedump_s {
    OS_ACTIVITY_STREAM_COMMON();
    char *message;
    size_t message_size;
    char image_path_buffer[PATH_MAX];
} * os_activity_statedump_t;

struct os_activity_stream_entry_s {
    os_activity_stream_type_t type;

    pid_t pid;
    uint64_t proc_id;
    const uint8_t *proc_imageuuid;
    const char *proc_imagepath;

    os_activity_id_t activity_id;
    os_activity_id_t parent_id;

    union {
        struct os_activity_stream_common_s common;
        struct os_activity_create_s activity_create;
        struct os_activity_transition_s activity_transition;
        struct os_log_message_s log_message;
        struct os_trace_message_v2_s trace_message;
        struct os_activity_useraction_s useraction;
        struct os_signpost_s signpost;
        struct os_activity_statedump_s statedump;
    };
};

typedef bool (^os_activity_stream_block_t)(os_activity_stream_entry_t entry,
                                           int error);

#endif /* OSActivityLogMessageEvent_h */

