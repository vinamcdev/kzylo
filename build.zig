const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{
        .default_target = .{
            .arch = .x86_64,
            .os = .freestanding,
        },
    });

    const mode = b.standardReleaseOptions();

    const kernel = b.addExecutable("kzylo", "src/main.zig");
    kernel.setTarget(target);
    kernel.setBuildMode(mode);
    kernel.linkerScript = "linker.ld";
    kernel.setOutputPath("bin/kzylo.bin");
    kernel.enableAssembly(true);
    kernel.strip = true;

    kernel.addIncludeDir("include");

    kernel.addLinkLibC();

    b.default_step.dependOn(&kernel.step);

    const iso = b.addSystemExecutable("iso", "grub-mkrescue");
    iso.addSystemCmdArg("-o");
    iso.addSystemCmdArg("bin/kzylo.iso");
    iso.addSystemCmdArg("boot/");
    iso.step.dependOn(&kernel.step);

    const run_qemu = b.step("run", "Run kernel in QEMU");
    run_qemu.dependOn(&kernel.step);
    run_qemu.step.dependOn(b.execCmd(&.{ "qemu-system-x86_64", "-kernel", kernel.getOutputPath() }));
}
