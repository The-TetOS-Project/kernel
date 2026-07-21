// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Wakana Kisarazu <wakanakisarazu.work@gmail.com>
const std = @import("std");



const ENTRY_AMOUNT: u16 = 256;
const TABLE_SIZE: u16 = @sizeOf(Entry) * ENTRY_AMOUNT - 1;

/// Privilege level 0: Kernelspace
const RING_0: u2 = 0x0;
/// Privilege level 0: Unused
const RING_1: u2 = 0x1;
/// Privilege level 0: Unused
const RING_2: u2 = 0x2;
/// Privilege level 0: Userspace
const RING_3: u2 = 0x3;

const TASK_GATE: u4 = 0x5;
const CALL_GATE: u4 = 0xC;
const INTERRUPT_GATE: u4 = 0xE;
const TRAP_GATE: u4 = 0xF;


/// The structure representing the option bits of a IDT entry.
const OptionBits = packed struct (u15) 
{
    /// 3 bits representing the IST.
    ist: u3,

    /// 5 bits reserved for future use.
    __reserved_1: u5,

    /// 1 bit representing IDT gate type.
    gate_type: u1,

    /// 2 bits reserved for future use.
    /// 
    /// **NOTE:** This should be treated as reserved but must be set.
    __reserved_2: u2,

    /// 1 bit represeting the storage segment. 
    /// 
    /// **NOTE:** This should be teated as reserved as it's mostly legacy.
    storage_segment: u1,

    /// 2 bits representing privilege/ring level.
    privilege_level: u2,

    /// 1 bit representing if the IDT entry is present.
    present: u1,
};

/// The structure representing a IDT entry.
pub const Entry = packed struct 
{
    /// Lower 16 bits of the handler offset address.
    offset_low:         u16,

    /// 16 bits representing the selector
    selector:           u16,

    /// 15 bits representing the option bits.
    option:             OptionBits,

    /// Middle 16 bits of the handler offset address.
    offset_mid:         u16,

    /// 32 bits reserved for future use.
    __reserved_2:       u32,
};

/// The structure representing a pointer to a IDT entry.
pub const Pointer = packed struct (u48) 
{   
    /// 16 bits representing total IDT size (minus 1) in bytes. 
    limit:  u16,

    /// 64 bits representing the IDT location base address.
    base:   u32,


    pub fn init() @This() {
        return .{
            .limit = TABLE_SIZE,
            .base = 0
        };
    }
};

pub const interruptHandler = fn() callconv(.naked) void;