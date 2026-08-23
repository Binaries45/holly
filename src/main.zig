const std = @import("std");
const Io = std.Io;

const holy = @import("holy");

pub fn main(init: std.process.Init) !void {
    _ = init;
    std.debug.print("Hello, World!", .{});
}
