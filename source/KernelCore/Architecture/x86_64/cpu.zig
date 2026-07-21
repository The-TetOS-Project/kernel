// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Wakana Kisarazu <wakanakisarazu.work@gmail.com>



pub inline fn enable_interrupts() void { asm volatile ("sti"); }

pub inline fn disable_interrupts() void { asm volatile ("cli"); }

pub inline fn wait_for_interrupt() void { asm volatile ("hlt"); }

pub inline fn load_interrupt_descriptor_table(irq_desc_tab: usize) void { asm volatile ("lidt (%[irq_desc_tab])" : : [irq_desc_tab] "r" (irq_desc_tab)); }

pub inline fn load_task_register(tsk_reg: u16) void { asm volatile ("ltr %[tr]" : : [tsk_reg] "r" (tsk_reg)); }

pub inline fn invalidate_tlb(addr: usize) void { asm volatile ("invlpg (%[addr])" : : [addr] "r" (addr) : "memory"); }

pub fn read_control_register(ctl_reg: u8) usize
{
    return switch (ctl_reg)
    {
        0 => { asm volatile ("mov %%cr0, %[result]" : [result] "=r" (-> usize)); },
        2 => { asm volatile ("mov %%cr2, %[result]" : [result] "=r" (-> usize)); },
        3 => { asm volatile ("mov %%cr3, %[result]" : [result] "=r" (-> usize)); },
        4 => { asm volatile ("mov %%cr4, %[result]" : [result] "=r" (-> usize)); },
        else => @compileError("Unsupported control register: " ++ @typeName(ctl_reg)),
    };
}

pub fn write_control_register(ctl_reg: u8, val: usize) void
{
    switch (ctl_reg)
    {
        0 => { asm volatile ("mov %[val], %%cr0" : : [val] "r" (val)); },
        2 => { asm volatile ("mov %[val], %%cr2" : : [val] "r" (val)); },
        3 => { asm volatile ("mov %[val], %%cr3" : : [val] "r" (val)); },
        4 => { asm volatile ("mov %[val], %%cr4" : : [val] "r" (val)); },
        else => @compileError("Unsupported control register: " ++ @typeName(ctl_reg)),
    }
}