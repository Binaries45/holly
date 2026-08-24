const std = @import("std");
const Io = std.Io;

const rendering = @import("rendering.zig");
const Renderer = rendering.Renderer;

pub fn main(init: std.process.Init) !void {
    _ = init;
    Renderer.run();
}
