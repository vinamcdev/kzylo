const uefi = @import("std").os.uefi;
const string = @import("include/string.zig");

pub fn main() uefi.Status {
    _ = uefi.system_table.con_out.?.reset(false);
    _ = uefi.system_table.con_out.?.clearScreen();

    var buf: [256]u8 = undefined;
    string.printf(buf[0..], "done\n", .{});

    _ = uefi.system_table.boot_services.?.stall(3_000_000);

    return uefi.Status.Success;
}
