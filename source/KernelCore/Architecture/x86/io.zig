// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Wakana Kisarazu <wakanakisarazu.work@gmail.com>



pub fn read(port: u16, comptime T: type) T
{
    return switch (T) {
        u8      => asm volatile ("inb %[port], %[result]" : [result] "={al}" (-> T) : [port] "N{dx}" (port) : "memory"),
        u16     => asm volatile ("inw %[port], %[result]" : [result] "={ax}" (-> T) : [port] "N{dx}" (port) : "memory"),
        u32     => asm volatile ("inl %[port], %[result]" : [result] "={eax}" (-> T) : [port] "N{dx}" (port) : "memory"),
        else    => @compileError("Unsupported type: T: " ++ @typeName(T))
    };
}

pub fn write(port: u16, data: anytype) void
{
    switch (@TypeOf(data)) {
        u8      => asm volatile ("outb %[data], %[port]" : [data] "{al}" (data) : [port] "{dx}" (port) : "memory"),
        u16     => asm volatile ("outw %[data], %[port]" : [data] "{ax}" (data) : [port] "{dx}" (port) : "memory"),
        u32     => asm volatile ("outl %[data], %[port]" : [data] "{eax}" (data) : [port] "{dx}" (port) : "memory"),
        else    => @compileError("Unsupported type: data: " ++ @typeName(@TypeOf(data)))
    }
}