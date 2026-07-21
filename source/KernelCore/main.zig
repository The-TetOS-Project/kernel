// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Wakana Kisarazu <wakanakisarazu.work@gmail.com>



const Archiecture = @import("Architecture/root.zig");
const Bootup = @import("Bootup/root.zig");
const Builtin = @import("Builtin/root.zig");


const Console = Builtin.Display.Console;



export fn kasane_kernel_entry() void
{
    _ = Console.init();
    _ = Console.write('!', .WHITE_ON_BLACK, 25, 50);
}