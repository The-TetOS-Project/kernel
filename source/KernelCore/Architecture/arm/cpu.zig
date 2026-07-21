// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Wakana Kisarazu <wakanakisarazu.work@gmail.com>



pub inline fn enable_interrupts() void { asm volatile ("cpsie i"); }

pub inline fn disable_interrupts() void { asm volatile ("cpsid i"); }

pub inline fn wait_for_interrupt() void { asm volatile ("wfi"); }