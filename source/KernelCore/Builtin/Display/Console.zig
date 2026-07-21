// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Wakana Kisarazu <wakanakisarazu.work@gmail.com>



const WIDTH = 80;
const HEIGHT = 25;


const Color = enum(u4) 
{
    black = 0,
    blue = 1,
    green = 2,
    cyan = 3,
    red = 4,
    magenta = 5,
    brown = 6,
    light_gray = 7,
    dark_gray = 8,
    light_blue = 9,
    light_green = 10,
    light_cyan = 11,
    light_red = 12,
    light_magenta = 13,
    light_brown = 14,
    white = 15,
};

const Attribute = packed struct (u8)
{
    foreground: Color,
    background: Color,

    inline fn INIT(
        comptime FG: Color,
        comptime BG: Color
    ) @This() {

        comptime return .{
            .foreground = FG,
            .background = BG,
        };
    }

    pub const WHITE_ON_BLACK: @This() = INIT(.white, .black);
};

const Cell = packed struct (u16)
{
    character: u8,
    attribute: Attribute,


    inline fn INIT(
        comptime CHAR: u8,
        comptime ATTR: Attribute
    ) @This() {

        comptime return .{
            .character = CHAR,
            .attribute = ATTR,
        };
    }

    pub fn init(
        char: u8,
        attr: Attribute
    ) @This() {

        return .{
            .character = char,
            .attribute = attr
        };
    }

    pub const @":": @This() = INIT(':', .WHITE_ON_BLACK);
    pub const @"3": @This() = INIT('3', .WHITE_ON_BLACK);
    pub const SPACE: @This() = INIT(' ', .WHITE_ON_BLACK);
};


current_row:    usize,
current_column: usize,


var attribute: Attribute = .INIT(.light_red, .black);
const buffer: [*]volatile Cell = @ptrFromInt(0xB8000);


pub fn write(c: u8, a: Attribute, x: usize, y: usize) void
{
    const idx = y * WIDTH + x;

    buffer[idx] = Cell.init(c, a);
}

pub fn init() @This()
{
    var y: usize = 0;
    while (y < HEIGHT) : (y += 1) {
        var x: usize = 0;
        while (x < WIDTH) : (x += 1) {
            const idx = y * WIDTH + x;

            buffer[idx] = Cell.init(Cell.@":".character, .WHITE_ON_BLACK);
        }
    }

    return .{
        .current_row = 0,
        .current_column = 0,  
    };
}