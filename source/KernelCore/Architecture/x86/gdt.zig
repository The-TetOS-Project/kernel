// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Wakana Kisarazu <wakanakisarazu.work@gmail.com>
const std = @import("std");



const ENTRY_AMOUNT: u16 = 6;
const TABLE_SIZE: u16 = @sizeOf(Entry) * ENTRY_AMOUNT - 1;

const NULL_OFFSET: u16 = 0x00;
const KERNEL_CODE_OFFSET: u16 = 0x08;
const KERNEL_DATA_OFFSET: u16 = 0x10;
const USER_CODE_OFFSET: u16 = 0x18;
const USER_DATA_OFFSET: u16 = 0x20;
const TSS_OFFSET: u16 = 0x28;


/// The structure representing the access bits of a GDT entry.
const AccessBits = packed struct (u8)
{   
    /// 1 bit representing whether the segement has been accessed.
    /// 
    /// **NOTE:** This should be treated as reserved as the CPU will set this automatically.
    accessed:                   u1,

    /// 1 bit representing the segment's R/W/X privileges.
    read_write:                 u1,

    /// 1 bit representing the legacy segment options.
    /// 
    /// **NOTE:** This should be treated as reserved as it's mostly legacy.
    direction_conforming:       u1,

    /// 1 bit representing whether the segment is executable.
    executable:                 u1,

    /// 1 bit representing the segment's descriptor type.
    /// 
    /// **NOTE:** This should not be set for the TSS descriptor.
    descriptor_type:            u1,

    /// 2 bits representing the segment's privilege/ring level.
    descriptor_privilege_level: u2,

    /// 1 bit representing whether the segment is present.
    /// 
    /// **NOTE:** This should not be set for the NULL segment.
    present:                    u1,


    inline fn INIT(
        comptime RW:        bool,
        comptime EXE:       bool,
        comptime IS_TSS:    bool,
        comptime IS_NULL:   bool,
        comptime RING:      u2,
    ) @This() {

        comptime return .{
            .accessed = 0,
            .read_write = RW,
            .executable = EXE,
            .descriptor_type = if (IS_TSS) 0 else 1,
            .descriptor_privilege_level = RING,
            .present = if (IS_NULL) 0 else 1,
        };
    }
    

    pub const NULL: @This() = INIT(false, false, false, true, 0);
    pub const KERNEL_CODE: @This() = INIT(true, true, false, false, 0);
    pub const KERNEL_DATA: @This() = INIT(true, false, false, false, 0);
    pub const USER_CODE: @This() = INIT(true, true, false, false, 3);
    pub const USER_DATA: @This() = INIT(true, false, false, false, 3);
    pub const TSS: @This() = INIT(false, true, true, false, 0);
};

/// The structure representing the flag bits of a GDT entry.
const FlagBits = packed struct (u4)
{   
    /// 1 bit reserved for future use.
    __reserved:     u1,

    /// 1 bit represents whether the segment is 64bit.
    /// 
    /// **NOTE:** This cannot be set if `thirty_two_bit` is set.
    sixty_four_bit: u1,

    /// 1 bit represents whether the segment is 32bit.
    /// 
    /// **NOTE:** This cannot be set if `sixty_four_bit` is set.
    thirty_two_bit: u1,
    
    /// 1 bit represents the segment's granularity.
    /// 
    /// - When set, 4KB (page) blocks are used.
    /// - When unset, 1B (byte) blocks are used.
    granularity:    u1,


    inline fn INIT(
        comptime MODE:  enum { long, protected },
        comptime GRAN:  enum { page, byte },
    ) @This() {

        comptime return .{
            .__reserved = 0,
            .sixty_four_bit = if (MODE == .long) 1 else 0,
            .thirty_two_bit = if (MODE == .protected) 0 else 1, 
            .granularity = if (GRAN == .page) 1 else if (GRAN == .byte) 0,
        };
    }


    pub const NULL: @This() = INIT(.protected, .byte);
    pub const PROTECTED_MODE: @This() = INIT(.protected, .page);
};

/// The structure representing a GDT entry.
pub const Entry = packed struct
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


    inline fn INIT(
        comptime BASE:      u32,
        comptime LIMIT:     u20,
        comptime ACCESS:    AccessBits,
        comptime FLAGS:     FlagBits,
    ) @This() {

        comptime return .{
            .limit_low = @truncate(LIMIT),
            .base_low = @truncate(BASE),
            .base_middle = @truncate(BASE >> 16),
            .access = ACCESS,
            .limit_high = @truncate(LIMIT >> 16),
            .flags = FLAGS,
        };
    }


    pub const NULL: @This() = INIT(0, 0, AccessBits.NULL, FlagBits.NULL);
    pub const KERNEL_CODE: @This() = INIT(0, 0xFFFFF, AccessBits.KERNEL_CODE, FlagBits.LONG_MODE);
    pub const KERNEL_DATA: @This() = INIT(0, 0xFFFFF, AccessBits.KERNEL_DATA, FlagBits.LONG_MODE);
    pub const USER_CODE: @This() = INIT(0, 0xFFFFF, AccessBits.USER_CODE, FlagBits.LONG_MODE);
    pub const USER_DATA: @This() = INIT(0, 0xFFFFF, AccessBits.USER_DATA, FlagBits.LONG_MODE);
    pub const TSS: @This() = INIT(0, 0xFFFFF, AccessBits.TSS, FlagBits.LONG_MODE);


    pub fn init() [ENTRY_AMOUNT]@This() {
        var temp: [ENTRY_AMOUNT]@This() = undefined;

        temp[0] = NULL;
        temp[1] = KERNEL_CODE;
        temp[2] = KERNEL_DATA;
        temp[3] = USER_CODE;
        temp[4] = USER_DATA;
        temp[5] = TSS;

        return temp;
    }
};

/// The structure representing a TSS descriptor.
pub const Tss = packed struct
{
    /// 16 bits pointing to previous TSS.
    prev:           u32,

    esp_0:          u32,
    ss_0:           u32,

    esp_1:          u32,
    ss_1:           u32,

    esp_2:          u32,
    ss_2:           u32,

    /// 32 bits reperesnting Control Register 3.
    cr3:            u32,

    eip:            u32,
    eflags:         u32,

    eax:            u32,    
    ecx:            u32,
    edx:            u32,
    ebx:            u32,
    esp:            u32,
    ebp:            u32,

    esi:            u32,
    edi:            u32,

    es:             u32,
    cs:             u32,
    ss:             u32,
    ds:             u32,
    fs:             u32,
    gs:             u32,

    ldt:            u32,

    /// 16 bits for the I/O map. 
    base_io_map:    u16,
};

/// The structure representing a pointer to a GDT entry.
pub const Pointer = packed struct (u48)
{   
    /// 16 bits representing total GDT size (minus 1) in bytes. 
    limit:  u16,

    /// 32 bits representing the GDT location base address.
    base:   u32,


    pub fn init() @This() {
        return .{
            .limit = TABLE_SIZE,
            .base = undefined,
        };
    }
};