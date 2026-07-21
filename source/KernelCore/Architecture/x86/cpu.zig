// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Wakana Kisarazu <wakanakisarazu.work@gmail.com>



pub inline fn enable_interrupts() void { asm volatile ("sti"); }

pub inline fn disable_interrupts() void { asm volatile ("cli"); }

pub inline fn wait_for_interrupt() void { asm volatile ("hlt"); }

pub inline fn load_interrupt_descriptor_table(idtr: usize) void { asm volatile ("lidt (%[idtr])" : : [idtr] "r" (idtr)); }

pub inline fn load_task_register(tr: u16) void { asm volatile ("ltr %[tr]" : : [tr] "r" (tr)); }

pub inline fn invalidate_tlb(addr: usize) void { asm volatile ("invlpg (%[addr])" : : [addr] "r" (addr) : "memory"); }

pub fn read_control_register(cr: u8) usize
{
    return switch (cr)
    {
        0 => { asm volatile ("mov %%cr0, %[result]" : [result] "=r" (-> usize)); },
        2 => { asm volatile ("mov %%cr2, %[result]" : [result] "=r" (-> usize)); },
        3 => { asm volatile ("mov %%cr3, %[result]" : [result] "=r" (-> usize)); },
        4 => { asm volatile ("mov %%cr4, %[result]" : [result] "=r" (-> usize)); },
        else => @compileError("Unsupported control register: " ++ @typeName(cr)),
    };
}

pub fn write_control_register(cr: u8, value: usize) void
{
    switch (cr)
    {
        0 => { asm volatile ("mov %[value], %%cr0" : : [value] "r" (value)); },
        2 => { asm volatile ("mov %[value], %%cr2" : : [value] "r" (value)); },
        3 => { asm volatile ("mov %[value], %%cr3" : : [value] "r" (value)); },
        4 => { asm volatile ("mov %[value], %%cr4" : : [value] "r" (value)); },
        else => @compileError("Unsupported control register: " ++ @typeName(cr)),
    }
}