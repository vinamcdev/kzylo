const uefi = @import("std").os.uefi;
const string = @import("include/string.zig");
const global = @import("constants.zig");

pub fn main() uefi.Status {
    global.init();

    _ = global.con_out.reset(false);
    _ = global.con_out.clearScreen();

    var buf: [256]u8 = undefined;
    string.printf(buf[0..], "done\n", .{});

    _ = global.boot_services.?.stall(3_000_000);

    return uefi.Status.Success;
}
