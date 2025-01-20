const std = @import("std");
const fmt = @import("std").fmt;
const global = @import("../constants.zig");

fn puts(msg: []const u8) void {
    for (msg) |c| {
        const c_ = [2]u16{ c, 0 };
        _ = global.con_out.outputString(@as(*const [1:0]u16, &c_));
    }
}

pub fn printf(buf: []u8, comptime format: []const u8, args: anytype) void {
    puts(fmt.bufPrint(buf, format, args) catch unreachable);
}
