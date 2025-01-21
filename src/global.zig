const uefi = @import("std").os.uefi;

pub var con_out: *uefi.protocol.SimpleTextOutput = undefined;
pub var system_table: *uefi.tables.SystemTable = undefined;
pub var boot_services: *uefi.tables.BootServices = undefined;
pub var runtime_services: *uefi.tables.RuntimeServices = undefined;

pub fn init() void {
    system_table = uefi.system_table;
    con_out = system_table.con_out.?;
    boot_services = system_table.boot_services.?;
    runtime_services = system_table.runtime_services;
}
