const std = @import("std");
const Build = std.Build;

const shdc = @import("shdc");

const shader_dir = "src/shaders/";
const shaders = [_][]const u8{
    "cell"
};

fn buildShaders(b: *Build, exe: *Build.Step.Compile) !void {
    for (shaders) |s| {
        const shd_step = try buildShader(b, s);
        exe.step.dependOn(shd_step);
    } 
}

fn buildShader(b: *Build, name: []const u8) !*Build.Step {
    return shdc.createSourceFile(b, .{
        .shdc_dep = b.dependency("shdc", .{}),
        .input = b.fmt("{s}{s}.glsl", .{ shader_dir, name }),
        .output = b.fmt("{s}{s}.glsl.zig", .{ shader_dir, name }),
        .reflection = true,
        .slang = .{
            .glsl410 = true,
            // TODO : the line below only needs to be added for shader that use compute, 
            //        later there should be a way to tell which shaders need this, 
            //        and automatically compile to it but not glsl410.
            // .glsl430 = true,
            .metal_macos = true,
            .hlsl5 = true,
            .wgsl = true,
            .spirv_vk = true, 
        },
    });
}

pub fn build(b: *Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "holly",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{},
        }),
    });

    // idk if this is needed for others,
    // but I get a fuck ton of linker errors on my machine
    // when not linking these explicitly
    exe.root_module.linkSystemLibrary("asound", .{});
    exe.root_module.linkSystemLibrary("GL", .{});
    exe.root_module.linkSystemLibrary("X11", .{});
    exe.root_module.linkSystemLibrary("Xi", .{});
    exe.root_module.linkSystemLibrary("Xcursor", .{});

    const dep_sokol = b.dependency("sokol", .{
        .target = target,
        .optimize = optimize,
    });

    const mod_sokol = dep_sokol.module("sokol");

    exe.root_module.addImport("sokol", mod_sokol);

    try buildShaders(b, exe);

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });

    const run_exe_tests = b.addRunArtifact(exe_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_exe_tests.step);
}
