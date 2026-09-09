const Cell = @This();

/// the coordinates of a cell
pub const Pos = struct {
    // note : this wont be stored directly were gonna store stuff sparsely and use the position as a key
    row: u32,
    col: u32,
};

// TODO : value & styling

/// position of the cell relative to cel 0,0
pos: Pos,
