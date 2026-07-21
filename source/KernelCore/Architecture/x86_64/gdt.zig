// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Wakana Kisarazu <wakanakisarazu.work@gmail.com>
const std = @import("std");



const ENTRY_SIZE: u16 = @sizeOf(SegmentEntry) * 5 + @sizeOf(TaskStateEntry);
const TABLE_SIZE: u16 = ENTRY_SIZE - 1;

const NULL_OFFSET: u16 = 0x00;
const KERNEL_CODE_OFFSET: u16 = NULL_OFFSET + @sizeOf(SegmentEntry);
const KERNEL_DATA_OFFSET: u16 = KERNEL_CODE_OFFSET + @sizeOf(SegmentEntry);
const USER_CODE_OFFSET: u16 = KERNEL_DATA_OFFSET + @sizeOf(SegmentEntry);
const USER_DATA_OFFSET: u16 = USER_CODE_OFFSET + @sizeOf(SegmentEntry);
const TSS_OFFSET: u16 = USER_DATA_OFFSET + @sizeOf(SegmentEntry);

const TASK_STATE_AVAILABLE: u4 = 9;
const TASK_STATE_BUSY: u4 = 11;


const Error = error 
{
    Invalid_Parameters,
};


/// The structure representing the access bits of a GDT entry.
const AccessBits = packed struct (u8)
{
    const Standard = packed struct (u4) {
        /// 1 bit representing whether the segement has been accessed.
        /// 
        /// **NOTE:** This should be treated as reserved:
        /// The CPU will set this automatically.
        is_accessed:                u1,

        /// 1 bit representing the segment's R/W/X privileges.
        /// 
        /// - Unset:    Code: execute-only. Data: read-only.
        /// - Set:      Code: execute and read. Data: read and write.
        read_write:                 u1,

        /// 1 bit representing whether the segment is executable by lower privileges or growing direction.
        /// 
        /// - Unset:    Code: cannot be executed by lower privilege level code. Data: grows upward.
        /// - Set:      Code: can be executed by lower privilege level code. Data: grows downward.
        direction_conforming:       u1,

        /// 1 bit representing whether the segment is executable.
        /// 
        /// - Unset:    Is a data segment.
        /// - Set:      Is a code segment.
        executable:                 u1,
    };

    const TaskState = packed struct (u4) {
        /// 4 bits representing the type field.
        type_field: u4,
    };

    lower: packed union (u4) { standard: Standard, task_state: TaskState },

    /// 1 bit representing the segment's descriptor type.
    /// 
    /// - Unset:    Is a system descriptor.
    /// - Set:      Is a normal descriptor.
    descriptor_type:            u1,

    /// 2 bits representing the segment's privilege/ring level.
    descriptor_privilege_level: u2,

    /// 1 bit representing whether the segment is present.
    /// 
    /// **NOTE:** This should not be set for the NULL segment.
    is_present:                    u1,


    inline fn INIT(
        comptime TYPE: enum { NULL, TSS, CODE, DATA },
        comptime RING: u2,
    ) @This()!Error {
        comptime if ((TYPE == .NULL or TYPE == .TSS) and (RING != 0)) return Error.Invalid_Parameters;

        comptime return switch (TYPE) {
            .NULL => .{
                .lower = .{
                    .standard = .{
                        .is_accessed = 0,
                        .read_write = 0,
                        .direction_conforming = 0,
                        .executable = 0,
                    },
                },
                .descriptor_type = 0,
                .descriptor_privilege_level = 0,
                .is_present = 0,
            },

            .TSS => .{
                .lower = .{
                    .task_state = .{
                        .type_field = TASK_STATE_AVAILABLE,
                    },
                },
                .descriptor_type = 0,
                .descriptor_privilege_level = 0,
                .is_present = 1,
            },

            .CODE => .{
                .lower = .{
                    .standard = .{
                        .is_accessed = 0,
                        .read_write = 1,
                        .direction_conforming = 0,
                        .executable = 1,
                    },
                },
                .descriptor_type = 1,
                .descriptor_privilege_level = RING,
                .is_present = 1,
            },

            .DATA => .{
                .lower = .{
                    .standard = .{
                        .is_accessed = 0,
                        .read_write = 1,
                        .direction_conforming = 0,
                        .executable = 0,
                    },
                },
                .descriptor_type = 1,
                .descriptor_privilege_level = RING,
                .is_present = 1,
            },
        };
    }

    pub const NULL: @This() = INIT(.NULL, 0);
    pub const TSS: @This() = INIT(.TSS, 0);
    pub const KERNEL_CODE: @This() = INIT(.CODE, 0);
    pub const KERNEL_DATA: @This() = INIT(.DATA, 0);
    pub const USER_CODE: @This() = INIT(.CODE, 3);
    pub const USER_DATA: @This() = INIT(.DATA, 3);
};


/// The structure representing the flag bits of a GDT entry.
const FlagBits = packed struct (u4)
{   
    /// 1 bit represents the bit Intel left available for software use.
    /// 
    /// **NOTE:** This should be treated as reserved.
    available:      u1,

    /// 1 bit represents whether the segment is in long mode.
    /// 
    /// **NOTE:** This cannot be set if `default_size` is set.
    long_mode:      u1,

    /// 1 bit
    /// 
    /// **NOTE:** This cannot be set if `long_mode` is set.
    default_size:   u1,
    
    /// 1 bit represents the segment's granularity.
    /// 
    /// - Unset:    Byte (1B) granularity is used.
    /// - Set:      Page (4KB) granularity is used.
    granularity:    u1,
    

    inline fn INIT(
        comptime TYPE: enum { NULL, TSS, CODE, DATA },
    ) @This() {

        comptime return switch (TYPE) {
            .NULL => .{
                .available = 0,
                .long_mode = 0,
                .default_size = 0,
                .granularity = 0,
            },

            .TSS => .{
                .available = 0,
                .long_mode = 0,
                .default_size = 0,
                .granularity = 0,
            },

            .CODE => .{
                .available = 0,
                .long_mode = 1,
                .default_size = 0,
                .granularity = 1,
            },

            .DATA => .{
                .available = 0,
                .long_mode = 0,
                .default_size = 0,
                .granularity = 1,
            },
        };
    }

    pub const NULL: @This() = INIT(.NULL);
    pub const TSS: @This() = INIT(.TSS);
    pub const LONG_MODE_CODE: @This() = INIT(.CODE);
    pub const LONG_MODE_DATA: @This() = INIT(.DATA);

    // TODO: Implment PROTECTED_MODE_* with finer 
    // controls over INIT()
};

/// The structure representing the TSS.
pub const TaskStateSegment = packed struct (u128)
{
    /// 32 bits reserved for future use.
    __reserved_1:   u32,

    rsp_0:          u64,
    rsp_1:          u64,
    rsp_2:          u64,

    /// 32 bits reserved for future use.
    __reserved_2:   u32,

    ist_1:          u64,
    ist_2:          u64,
    ist_3:          u64,
    ist_4:          u64,
    ist_5:          u64,
    ist_6:          u64,
    ist_7:          u64,

    /// 64 bits reserved for future use.
    __reserved_3:   u64,

    /// 16 bits reserved for future use.
    __reserved_4:   u16,

    /// 16 bits for the I/O map. 
    base_io_map:    u16,
};

/// The structure representing a pointer to a GDT entry.
pub const Pointer = packed struct (u72)
{   
    /// 16 bits representing total GDT size (minus 1) in bytes. 
    limit:  u16,

    /// 64 bits representing the GDT location base address.
    base:   u64,


    pub fn init() @This() {
        return .{
            .limit = TABLE_SIZE,
            .base = undefined,
        };
    }
};

/// The structure representing a segment entry.
pub const SegmentEntry = packed struct (u64)
{
    /// Lower 16 bits of limit address.
    limit_low:      u16,

    /// Lower 16 bits of base address.
    base_low:       u16,

    /// Middle 8 bits of base address.
    base_middle:    u8,

    /// 8 bits representing the access bits.
    access:         AccessBits,

    /// Higher 4 bits of limit address.
    limit_high:     u4,

    /// 4 bits representing the flag bits.
    flags:          FlagBits,

    /// Higher 8 bits of base address.
    base_high:      u8,
};

/// The structure representing a TSS entry.
pub const TaskStateEntry = packed struct (u128)
{
    /// Lower 16 bits of limit address.
    limit_low:      u16,

    /// Lower 16 bits of base address.
    base_low:       u16,

    /// Middle 8 bits of base address.
    base_middle:    u8,

    /// 8 bits representing the access bits.
    access:         AccessBits,

    /// Higher 4 bits of limit address.
    limit_high:     u4,

    /// 4 bits representing the flag bits.
    flags:          FlagBits,

    /// Higher 8 bits of base address.
    base_high:      u8,

    /// Upper 32 bits of base address.
    base_upper:     u32,

    /// 32 bits that are reserved for future use.
    __reserved:     u32,
};

pub var task_state_segment: TaskStateSegment = 
.{
    .__reserved_1 = 0,

    .rsp_0 = 0,
    .rsp_1 = 0,
    .rsp_2 = 0,

    .__reserved_2 = 0,

    .ist_1 = 0,
    .ist_2 = 0,
    .ist_3 = 0,
    .ist_4 = 0,
    .ist_5 = 0,
    .ist_6 = 0,
    .ist_7 = 0,

    .__reserved_3 = 0,
    .__reserved_4 = 0,

    // Disables I/O bitmap.
    .base_io_map = @sizeOf(TaskStateSegment),
};

pub var gdt: struct 
{
    null: SegmentEntry,
    kernel_code: SegmentEntry,
    kernel_data: SegmentEntry,
    user_code: SegmentEntry,
    user_data: SegmentEntry,
    task_state: TaskStateEntry,
} = undefined;