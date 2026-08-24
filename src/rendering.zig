//! guess what this does

const sokol = @import("sokol");
const gfx = sokol.gfx;
const log = sokol.log;
const app = sokol.app;
const glue = sokol.glue;

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

        // create vertex buffer with triangle vertices
        state.bind.vertex_buffers[0] = gfx.makeBuffer(.{
            .data = gfx.asRange(&[_]f32{
                // positions     colors
                0.0,  0.5,  0.5, 1.0, 0.0, 0.0, 1.0,
                0.5,  -0.5, 0.5, 0.0, 1.0, 0.0, 1.0,
                -0.5, -0.5, 0.5, 0.0, 0.0, 1.0, 1.0,
            }),
        });

        // create a shader and pipeline object
        state.pip = gfx.makePipeline(.{
            .shader = gfx.makeShader(cell_shader.triangleShaderDesc(gfx.queryBackend())),
            .layout = init: {
                var l = gfx.VertexLayoutState{};
                l.attrs[cell_shader.ATTR_triangle_position].format = .FLOAT3;
                l.attrs[cell_shader.ATTR_triangle_color0].format = .FLOAT4;
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
