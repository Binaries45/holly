//! guess what this does

const sokol = @import("sokol");
const gfx = sokol.gfx;
const log = sokol.log;
const app = sokol.app;
const glue = sokol.glue;

pub const Renderer = struct {
    pub const state = struct {
        bind: gfx.Bindings = .{},
        pip: gfx.Pipeline = .{},
    };

    pub export fn init() void {
        gfx.setup(.{ 
            .environment = glue.environment(), 
            .logger = .{ .func = log.func } 
        });
        // TODO : vertex / index buffers
        // TODO : pipeline setup
    }

    pub export fn frame() void {
        gfx.beginPass(.{ .swapchain = glue.swapchain() });
        // gfx.applyPipeline(state.pip);
        // gfx.applyBindings(state.bind);
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
