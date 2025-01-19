const std = @import("std");

const FeatureMod = struct {
    add: std.Target.Cpu.Feature.Set = std.Target.Cpu.Feature.Set.empty,
    sub: std.Target.Cpu.Feature.Set = std.Target.Cpu.Feature.Set.empty,
};

fn getFeatureMod(comptime arch: std.Target.Cpu.Arch) FeatureMod {
    var mod: FeatureMod = .{};

    switch (arch) {
        .x86_64 => {
            const Features = std.Target.x86.Feature;

            mod.add.addFeature(@intFromEnum(Features.soft_float));
            mod.sub.addFeature(@intFromEnum(Features.mmx));
            mod.sub.addFeature(@intFromEnum(Features.sse));
            mod.sub.addFeature(@intFromEnum(Features.sse2));
            mod.sub.addFeature(@intFromEnum(Features.avx));
            mod.sub.addFeature(@intFromEnum(Features.avx2));
        },
        else => @compileError("Unimplemented architecture"),
    }
    return mod;
}

const kernel_config = .{
    .arch = std.Target.Cpu.Arch.x86_64,
};

pub fn build(b: *std.Build) void {
    const feature_mod = getFeatureMod(kernel_config.arch);

    const target_query: std.Target.Query = .{
        .cpu_arch = kernel_config.arch,
        .os_tag = .freestanding,
        .abi = .none,
        .cpu_features_add = feature_mod.add,
        .cpu_features_sub = feature_mod.sub,
    };

    const target = b.resolveTargetQuery(target_query);

    const kernel_optimize = .ReleaseFast;

    const kernel = b.addExecutable(.{
        .name = "kzylo",
        .root_source_file = .{ .cwd_relative = "src/main.zig" },
        .target = target,
        .optimize = kernel_optimize,
    });

    const kernel_file = "bin/kzylo.bin";
    const bin_Dir = try std.fs.cwd().openDir("bin/", .{});
    defer bin_Dir.close();

    kernel.setLinkerScript(.{ .cwd_relative = "linker.ld" });
    b.addInstallArtifact(kernel, .{ .dest_dir = bin_Dir });

    const iso_dir = "iso";
    const iso_kernel_path = iso_dir ++ "/boot/kzylo.bin";
    const copy_to_iso = b.addSystemCommand(&[_][]const u8{
        "cp",
        kernel_file,
        iso_kernel_path,
    });
    copy_to_iso.step.dependOn(&kernel.step);

    const iso_file = "kzylo.iso";
    const iso_command = b.addSystemCommand(&[_][]const u8{
        "grub-mkrescue",
        "-o",
        iso_file,
        iso_dir,
    });
    iso_command.step.dependOn(&copy_to_iso.step);

    const run_qemu_command = b.addSystemCommand(&[_][]const u8{
        "qemu-system-x86_64",
        "-kernel",
        kernel_file,
        "-nographic",
    });
    run_qemu_command.step.dependOn(&kernel.step);

    b.default_step.dependOn(&iso_command.step);
}
