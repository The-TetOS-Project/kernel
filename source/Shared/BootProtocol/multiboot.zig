// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Wakana Kisarazu <wakanakisarazu.work@gmail.com>
const std = @import("std");



const BOOTLOADER_MAGIC: u32 = 0x1BADB002;
const MEMORY_INFO: u32 = 0x00000001;
const MEMORY_MAP: u32 = 0x00000040;
const MEMORY_AVAILABLE: u32 = 0x00000001;
const MEMORY_RESERVED: u32 = 0x00000002;


pub const Info = packed struct
{
    flags: u32,

    memory_lower: u32,
    memory_upper: u32,

    boot_device: u32,

    command_line: u32,

    module_count: u32,
    module_address: u32,

    __reserved: u128,

    memory_map_length: u32,
    memory_map_address: u32,

    drives_length: u32,
    drives_address: u32,

    config_table: u32,

    bootloader_name: u32,

    apm_table: u32,

    vbe_control_info: u32,
    vbe_mode_info: u32,
    vbe_mode: u16,
    vbe_interface_segment: u16,
    vbe_interface_offset: u16,
    vbe_interface_length: u16,
};

pub const MemoryMapEntry = packed struct
{
    size: u32,
    base_address: u64,
    length: u64,
    @"type": u32,
};

pub const Module = packed struct
{
    start: u32,
    end: u32,
    command_line: u32,
    __reserved: u32,
};

pub const Header = packed struct
{
    magic: u32,
    flags: u32,
    checksum: u32,
};

// I think this is broken, but uh, Zig comptime functions because powerful macros go brr :3
pub fn INIT(comptime ALIGN: u32, comptime MEMINFO: u32) Header
{
    comptime return .{
        .checksum = BOOTLOADER_MAGIC,
        .flags = ALIGN | MEMINFO,
        .magic = -(BOOTLOADER_MAGIC + (ALIGN | MEMINFO)),
    };
}

export const HEADER: Header align(4) linksection(".rodata.boot") = INIT(1 << 0, 1 << 1);