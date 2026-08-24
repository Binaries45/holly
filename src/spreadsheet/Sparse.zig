//! Sparse cell storage

const std = @import("std");
const AutoHashMap = std.AutoHashMap;

const Cell = @import("Cell.zig");

cells: AutoHashMap(Cell.Pos, Cell),
