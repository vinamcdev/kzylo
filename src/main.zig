const uefi = @import("std").os.uefi;
const string = @import("include/string.zig");

export var _fltused: i32 = 0;

pub fn main() uefi.Status {
    const boot_services = uefi.system_table.boot_services.?;
    var buf: [256]u8 = undefined;

    var memory_map: [*]uefi.tables.MemoryDescriptor = undefined;
    var memory_map_size: usize = 0;
    var memory_map_key: usize = undefined;
    var descriptor_size: usize = undefined;
    var descriptor_version: u32 = undefined;

    while (uefi.Status.BufferTooSmall == boot_services.getMemoryMap(&memory_map_size, memory_map, &memory_map_key, &descriptor_size, &descriptor_version)) {
        if (uefi.Status.Success != boot_services.allocatePool(uefi.tables.MemoryType.BootServicesData, memory_map_size, @as(*[*]align(8) u8, @ptrCast(&memory_map)))) {
            return uefi.Status.Aborted;
        }
    }

    var i: usize = 0;
    while (i < memory_map_size / descriptor_size) : (i += 1) {
        string.printf(buf[0..], "*** {:3} type={s:23} physical=0x{x:0>16} virtual=0x{x:0>16} pages={:16} uc={} wc={} wt={} wb={} uce={} wp={} rp={} xp={} nv={} more_reliable={} ro={} sp={} cpu_crypto={} memory_runtime={}\n", .{
            i,
            @tagName(memory_map[i].type),
            memory_map[i].physical_start,
            memory_map[i].virtual_start,
            memory_map[i].number_of_pages,
            @intFromBool(memory_map[i].attribute.uc),
            @intFromBool(memory_map[i].attribute.wc),
            @intFromBool(memory_map[i].attribute.wt),
            @intFromBool(memory_map[i].attribute.wb),
            @intFromBool(memory_map[i].attribute.uce),
            @intFromBool(memory_map[i].attribute.wp),
            @intFromBool(memory_map[i].attribute.rp),
            @intFromBool(memory_map[i].attribute.xp),
            @intFromBool(memory_map[i].attribute.nv),
            @intFromBool(memory_map[i].attribute.more_reliable),
            @intFromBool(memory_map[i].attribute.ro),
            @intFromBool(memory_map[i].attribute.sp),
            @intFromBool(memory_map[i].attribute.cpu_crypto),
            @intFromBool(memory_map[i].attribute.memory_runtime),
        });
    }

    _ = boot_services.stall(10 * 1000 * 1000);

    return uefi.Status.Success;
}
