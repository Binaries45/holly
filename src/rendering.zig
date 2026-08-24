//! guess what this does

const std = @import("std");

const sokol = @import("sokol");
const gfx = sokol.gfx;
const log = sokol.log;
const app = sokol.app;
const glue = sokol.glue;

const Vertex = @import("rendering/Vertex.zig");
const Pos = Vertex.Pos;
const Color = Vertex.Color;

const cell_shader = @import("shaders/cell.glsl.zig");

pub const Renderer = struct {
    pub const state = struct {
        var bind: gfx.Bindings = .{};
        var pip: gfx.Pipeline = .{};
    };

    pub export fn init() void {
        gfx.setup(.{ 
            .environment = glue.environment(), 
            .logger = .{ .func = log.func } 
        });

        std.debug.print("vertex size: {d}\n", .{@sizeOf(Vertex)});
        std.debug.print("color offset: {d}\n", .{@offsetOf(Vertex, "color")});

        const vertices = [_]Vertex {
            Vertex { .pos = Pos{0.0, 0.5},   .color = Color{1.0, 0.0, 0.0, 1.0} },
            Vertex { .pos = Pos{0.5, -0.5},  .color = Color{0.0, 1.0, 0.0, 1.0} },
            Vertex { .pos = Pos{-0.5, -0.5}, .color = Color{0.0, 0.0, 1.0, 1.0} },
        };

        // create vertex buffer with triangle vertices
        state.bind.vertex_buffers[0] = gfx.makeBuffer(.{
            .data = gfx.asRange(&vertices),
        });

        // create a shader and pipeline object
        state.pip = gfx.makePipeline(.{
            .shader = gfx.makeShader(cell_shader.cellShaderDesc(gfx.queryBackend())),
            .layout = init: {
                var l = gfx.VertexLayoutState{};
                l.buffers[0].stride = @sizeOf(Vertex);
                l.attrs[cell_shader.ATTR_cell_position].format = .FLOAT2;
                l.attrs[cell_shader.ATTR_cell_position].offset = @offsetOf(Vertex, "pos");
                l.attrs[cell_shader.ATTR_cell_color0].format = .FLOAT4;
                l.attrs[cell_shader.ATTR_cell_color0].offset = @offsetOf(Vertex, "color");
                break :init l;
            },
        });
    }

    pub export fn frame() void {
        gfx.beginPass(.{ .swapchain = glue.swapchain() });
        gfx.applyPipeline(state.pip);
        gfx.applyBindings(state.bind);
        gfx.draw(0, 3, 1);
        gfx.endPass();
        gfx.commit();
    }

    pub export fn cleanup() void {
        gfx.shutdown();
    }

    pub export fn run() void {
        app.run(.{ 
            .init_cb = init, 
            .frame_cb = frame, 
            .cleanup_cb = cleanup, 
            .width = 1280, 
            .height = 720, 
            .depth_format = .NONE, 
            .window_title = "Holly", 
            .icon = .{ .sokol_default = true }, 
            .logger = .{ .func = log.func} 
        });
    }
};
