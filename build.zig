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

    const args = b.args;

    if (args) |argv| {
        for (argv) |arg| {
            std.debug.print("{s} ", .{arg});
        }
        std.debug.print("\n", .{});
    }

    const target_query: std.Target.Query = .{
        .cpu_arch = kernel_config.arch,
        .os_tag = .uefi,
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

    kernel.setLinkerScript(.{ .cwd_relative = "linker.ld" });
    _ = b.installArtifact(kernel);

    b.default_step.dependOn(&kernel.step);

    std.debug.print("[{s}OK{s}] Kernel build finished\n", .{ "\x1b[32;40m", "\x1b[39;49m" });
}
