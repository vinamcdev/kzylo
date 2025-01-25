const std = @import("std");
const fmt = @import("std").fmt;
const uefi = std.os.uefi;

pub fn puts(msg: []const u8) void {
    for (msg) |c| {
        const c_ = [2]u16{ c, 0 };
        const chr: *const [1:0]u16 = @ptrCast(&c_);
        _ = uefi.system_table.con_out.?.outputString(chr);
    }
}

pub fn printf(buf: []u8, comptime format: []const u8, args: anytype) void {
    puts(fmt.bufPrint(buf, format, args) catch unreachable);
}
