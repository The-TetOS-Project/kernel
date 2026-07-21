// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Wakana Kisarazu <wakanakisarazu.work@gmail.com>
const std = @import("std");
const Build = std.Build;

const zonfig = @import("zonfig");



const Config = struct 
{

};
pub fn build(b: *std.Build) void
{   
//    const optimize = b.standardOptimizeOption(.{ .preferred_optimize_mode = .Debug });
//    const target = b.standardTargetOptions(.{ .default_target = .{ .cpu_arch = .x86_64, .os_tag = .freestanding, .abi = .none } });

    const zonfigDep = b.dependency("zonfig", .{});

    zonfig.addConfigStep(b, zonfigDep, "config.zig.zon", ".config.zig.zon");
}