// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Wakana Kisarazu <wakanakisarazu.work@gmail.com>
const builtin = @import("builtin");



const arch = switch (builtin.cpu.arch) 
{
    .arm        => @import("arm/root.zig"),
    .aarch64    => @import("aarch64/root.zig"),
    .riscv32    => @import("riscv32/root.zig"),
    .riscv64    => @import("riscv64/root.zig"),
    .x86        => @import("x86/root.zig"),
    .x86_64     => @import("x86_64/root.zig"),
    else        => @compileError("Unsupported architecture"),
};

pub const cpu = arch.cpu;
pub const gdt = arch.gdt;
pub const idt = arch.idt;
pub const io = arch.io;