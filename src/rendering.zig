//! guess what this does

const std = @import("std");

const sokol = @import("sokol");
const gfx = sokol.gfx;
const log = sokol.log;
const app = sokol.app;
const glue = sokol.glue;
const sapp = sokol.app;

const ve = @import("VoxelEngine");
const math = ve.math;
const Vector = ve.math.Vector;
const Vec = Vector.Vec;
const uVec2 = Vec(2, u32);
const fVec2 = math.fVec2;
const fVec4 = math.fVec4;

const Vertex = @import("rendering/Vertex.zig");
const Pos = Vertex.Pos;
const Color = Vertex.Color;

const cell_shader = @import("shaders/cell.glsl.zig");

const vertices = [_]Vertex {
    Vertex { .pos = Pos{-1, 1} },
    Vertex { .pos = Pos{1, 1} },
    Vertex { .pos = Pos{1, -1} },
    Vertex { .pos = Pos{-1, -1} },    
};

const indices = [_]u16 {
    0, 1, 2,
    0, 2, 3,
};

// TODO : 
// - render tiling bg of all cells
// - 2d camera to support scrolling
// - render cell content as a layer on top of the cells
// - render ui on top of everything

pub const Camera2D = extern struct {
    pos: [2]f32,
    zoom: f32,
    viewport_size: [2]f32,

    /// compute vertex shader params from a camera
    fn vsParams(c: *Camera2D) cell_shader.VsParams {
        return .{
            .camera_pos = c.pos,
            .zoom = c.zoom,
            .viewport_size = c.viewport_size
        };
    }
};

// an instance of a single cell on the spreadsheet
pub const CellInstance = extern struct {
    pos: [2]f32,
    size: [2]f32,
    color: [4]f32,
};

pub const RenderedCell = extern struct {
    // todo : rect, color
};

const max_cells: usize = 128;

pub const Renderer = struct {
    pub const state = struct {
        var bind: gfx.Bindings = .{};
        var pip: gfx.Pipeline = .{};
        var pass_action: gfx.PassAction = .{};
        var n_instances: u32 = 0;
        var instances: [max_cells]CellInstance = undefined;
        var camera: Camera2D = .{
            .pos = .{0, 0},
            .zoom = 1,
            .viewport_size = .{1, 1},
        };
    };

    pub export fn init() void {
        gfx.setup(.{ 
            .environment = glue.environment(), 
            .logger = .{ .func = log.func } 
        });

        state.pass_action.colors[0] = .{
            .load_action = .CLEAR,
            .clear_value = .{ .r = 0, .g = 0, .b = 0, .a = 1 },
        };

        // vertices
        state.bind.vertex_buffers[0] = gfx.makeBuffer(.{
            .usage = .{ .vertex_buffer = true },
            .data = gfx.asRange(&vertices),
        });

        // indexing
        state.bind.index_buffer = gfx.makeBuffer(.{
            .usage = .{ .index_buffer = true },
            .data = gfx.asRange(&indices),
        });

        // instancing
        state.instances[0] = .{
            .pos = .{0, 0},
            .size = .{0.5, 0.5},
            .color = .{1, 1, 1, 1},
        };
        state.n_instances = 1;
        state.bind.vertex_buffers[1] = gfx.makeBuffer(.{
            .usage = .{
                .vertex_buffer = true,
                .stream_update = true,
            },
            .size = max_cells * @sizeOf(CellInstance),
        });

        // line of pipes
        state.pip = gfx.makePipeline(.{
            .shader = gfx.makeShader(cell_shader.cellShaderDesc(gfx.queryBackend())),
            .index_type = .UINT16,
            // TODO : add this back when we need to render layers
            // .depth = .{
            //     .compare = .LESS_EQUAL,
            //     .write_enabled = true,
            // },
            .layout = init: {
                var l = gfx.VertexLayoutState{};
                l.buffers[0].stride = @sizeOf(Vertex);
                l.buffers[1].stride = @sizeOf(CellInstance);
                l.buffers[1].step_func = .PER_INSTANCE;

                l.attrs[cell_shader.ATTR_cell_position] = .{
                    .buffer_index = 0,
                    .format = .FLOAT2,
                    .offset = @offsetOf(Vertex, "pos"),
                };

                l.attrs[cell_shader.ATTR_cell_inst_pos] = .{
                    .buffer_index = 1,
                    .format = .FLOAT2,
                    .offset = @offsetOf(CellInstance, "pos"),
                };

                l.attrs[cell_shader.ATTR_cell_inst_size] = .{
                    .buffer_index = 1,
                    .format = .FLOAT2,
                    .offset = @offsetOf(CellInstance, "size"),
                };

                l.attrs[cell_shader.ATTR_cell_inst_color] = .{
                    .buffer_index = 1,
                    .format = .FLOAT4,
                    .offset = @offsetOf(CellInstance, "color"),
                };

                break :init l;
            },
        });
    }

    pub export fn frame() void {
        const dt: f32 = @floatCast(sapp.frameDuration());
        state.camera.pos[1] += std.math.sin(dt);

        gfx.updateBuffer(
            state.bind.vertex_buffers[1], 
            gfx.asRange(&state.instances),
        ); 

        const vs_params = state.camera.vsParams();
        
        gfx.beginPass(.{
            .action = state.pass_action,
            .swapchain = glue.swapchain() 
        });

        gfx.applyPipeline(state.pip);
        gfx.applyBindings(state.bind);
        gfx.applyUniforms(cell_shader.UB_vs_params, gfx.asRange(&vs_params));

        gfx.draw(0, 6, state.n_instances);

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
