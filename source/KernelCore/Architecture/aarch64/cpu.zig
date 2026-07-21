// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Wakana Kisarazu <wakanakisarazu.work@gmail.com>



pub inline fn enable_interrupts() void { asm volatile ("msr daifset, #2"); }

pub inline fn disable_interrupts() void { asm volatile ("msr daifclr, #2"); }

pub inline fn wait_for_interrupt() void { asm volatile ("wfi"); }